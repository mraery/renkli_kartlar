import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flashcard.dart';
import '../services/card_service.dart';

class StudyScreen extends StatefulWidget {
  final String title;
  final List<Flashcard> cards;
  final String? initialSubCategory;
  final bool isDark;
  final bool isCustomDeck;

  const StudyScreen({
    super.key,
    required this.title,
    required this.cards,
    this.initialSubCategory,
    required this.isDark,
    this.isCustomDeck = false,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> with TickerProviderStateMixin {
  final CardService _cardService = CardService.instance;
  late List<Flashcard> _deck;
  int _currentIndex = 0;
  String _activeFilter = 'all'; // all, important, repeat, favorite, or subCategory

  // 3D Flip Animation
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isBack = false;

  // Swipe Animation
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;
  late AnimationController _swipeAnimationController;
  late Animation<double> _swipeTween;
  bool _isAnimatingSwipe = false;

  // History stack for undo
  final List<Map<String, dynamic>> _history = [];

  // Auto-play slideshow timer
  Timer? _autoPlayTimer;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSubCategory != null) {
      _activeFilter = widget.initialSubCategory!;
    }
    _deck = List.from(widget.cards);
    _applyFilter();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    )..addListener(() {
        if (_flipAnimation.value >= 0.5 && !_isBack) {
          setState(() => _isBack = true);
        } else if (_flipAnimation.value < 0.5 && _isBack) {
          setState(() => _isBack = false);
        }
      });

    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _swipeTween = Tween<double>(begin: 0, end: 1).animate(_swipeAnimationController);
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _flipController.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      if (_activeFilter == 'all') {
        _deck = List.from(widget.cards);
      } else if (_activeFilter == 'important') {
        _deck = widget.cards.where((c) => c.importance >= 2).toList();
      } else if (_activeFilter == 'repeat') {
        _deck = widget.cards.where((c) => _cardService.repeatIds.contains(c.id)).toList();
      } else if (_activeFilter == 'favorite') {
        _deck = widget.cards.where((c) => _cardService.favoriteIds.contains(c.id)).toList();
      } else {
        _deck = widget.cards.where((c) => c.subCategory == _activeFilter).toList();
      }
      _currentIndex = 0;
      _resetFlip();
    });
  }

  void _resetFlip() {
    _flipController.reset();
    _isBack = false;
  }

  void _toggleFlip() {
    HapticFeedback.selectionClick();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  void _shuffleDeck() {
    setState(() {
      _deck.shuffle();
      _currentIndex = 0;
      _resetFlip();
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔀 Kartlar rastgele karıştırıldı!'),
        duration: Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });

    if (_isAutoPlaying) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏱️ Otomatik Slayt Modu Başlatıldı (4 saniyede bir çevirir/ilerler)'),
          backgroundColor: Color(0xFF6366F1),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted || _currentIndex >= _deck.length) {
          timer.cancel();
          setState(() => _isAutoPlaying = false);
          return;
        }
        if (!_isBack) {
          _toggleFlip();
        } else {
          _animateAndSwipe('learned', 1);
        }
      });
    } else {
      _autoPlayTimer?.cancel();
    }
  }

  void _animateAndSwipe(String status, int direction) {
    if (_isAnimatingSwipe || _currentIndex >= _deck.length) return;
    _isAnimatingSwipe = true;

    final targetX = direction * 500.0;
    final startOffset = _dragOffset;
    final startRotation = _dragRotation;
    final targetRotation = direction * (math.pi / 7);

    _swipeTween = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _swipeAnimationController, curve: Curves.easeOutQuad),
    )..addListener(() {
        setState(() {
          final t = _swipeTween.value;
          _dragOffset = Offset(
            startOffset.dx + (targetX - startOffset.dx) * t,
            startOffset.dy * (1 - t),
          );
          _dragRotation = startRotation + (targetRotation - startRotation) * t;
        });
      });

    _swipeAnimationController.forward(from: 0).then((_) {
      _finishSwipe(status);
      _isAnimatingSwipe = false;
    });
  }

  void _finishSwipe(String status) {
    if (_currentIndex >= _deck.length) return;
    final card = _deck[_currentIndex];

    HapticFeedback.lightImpact();
    final wasReadded = (status == 'repeat');
    _history.add({
      'card': card,
      'prevStatus': card.status,
      'wasReadded': wasReadded,
    });

    _cardService.markCardStatus(card, status);

    setState(() {
      if (wasReadded) {
        _deck.add(card);
      }
      _currentIndex++;
      _resetFlip();
      _dragOffset = Offset.zero;
      _dragRotation = 0;
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    final last = _history.removeLast();
    final Flashcard card = last['card'];

    _cardService.markCardStatus(card, last['prevStatus']);

    setState(() {
      if (last['wasReadded'] == true && _deck.isNotEmpty) {
        _deck.removeLast();
      }
      if (_currentIndex > 0) _currentIndex--;
      _resetFlip();
      _dragOffset = Offset.zero;
      _dragRotation = 0;
    });
  }

  void _toggleFavoriteCurrent() async {
    if (_currentIndex >= _deck.length) return;
    final card = _deck[_currentIndex];
    await _cardService.toggleFavorite(card);
    setState(() {});
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final totalInView = _deck.length;
    final remaining = math.max(0, totalInView - _currentIndex);
    final subCats = widget.cards.map((c) => c.subCategory).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text(
              _currentIndex < totalInView ? '${_currentIndex + 1} / $totalInView Kart' : 'Tamamlandı!',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isAutoPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: _isAutoPlaying ? Colors.amber : null),
            tooltip: _isAutoPlaying ? 'Otomatik Oynatmayı Durdur' : 'Otomatik Oynat',
            onPressed: _toggleAutoPlay,
          ),
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Desteyi Karıştır',
            onPressed: _shuffleDeck,
          ),
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Geri Al',
            onPressed: _history.isNotEmpty ? _undo : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sub-category and status filter chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('Tümü ($totalInView)', 'all'),
                  _buildFilterChip('⭐ Önemliler', 'important'),
                  _buildFilterChip('🔁 Tekrarlar', 'repeat'),
                  _buildFilterChip('❤️ Favoriler', 'favorite'),
                  ...subCats.map((sub) => _buildFilterChip(sub, sub)),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Top progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalInView > 0 ? (_currentIndex / totalInView).clamp(0.0, 1.0) : 0,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  minHeight: 5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Main Flashcard Area
            Expanded(
              child: remaining == 0
                  ? _buildCompletionView(isDark)
                  : Center(
                      child: GestureDetector(
                        onTap: _toggleFlip,
                        onPanUpdate: (details) {
                          if (_isAnimatingSwipe) return;
                          setState(() {
                            _dragOffset += details.delta;
                            _dragRotation = (_dragOffset.dx / 300) * (math.pi / 12);
                          });
                        },
                        onPanEnd: (details) {
                          if (_isAnimatingSwipe) return;
                          if (_dragOffset.dx > 100) {
                            _animateAndSwipe('learned', 1);
                          } else if (_dragOffset.dx < -100) {
                            _animateAndSwipe('repeat', -1);
                          } else {
                            setState(() {
                              _dragOffset = Offset.zero;
                              _dragRotation = 0;
                            });
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            final angle = _flipAnimation.value * math.pi;
                            final transform = Matrix4.identity()
                              ..setEntry(3, 2, 0.0015)
                              ..setTranslationRaw(_dragOffset.dx, _dragOffset.dy, 0.0)
                              ..rotateZ(_dragRotation)
                              ..rotateY(angle);

                            final card = _deck[_currentIndex];
                            final isCardFlipped = _flipAnimation.value >= 0.5;

                            return Transform(
                              transform: transform,
                              alignment: Alignment.center,
                              child: isCardFlipped
                                  ? Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..rotateY(math.pi),
                                      child: _buildBackFace(card, isDark),
                                    )
                                  : _buildFrontFace(card, isDark),
                            );
                          },
                        ),
                      ),
                    ),
            ),

            // Bottom action bar (Tekrar, İpucu, Favori, Öğrendim)
            if (remaining > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tekrar Et (Repeat) Button
                    _buildActionButton(
                      icon: Icons.replay_rounded,
                      label: 'Tekrar',
                      color: const Color(0xFFEF4444),
                      onPressed: () => _animateAndSwipe('repeat', -1),
                    ),

                    // İpucu (Hint) Button
                    _buildActionButton(
                      icon: Icons.lightbulb_outline_rounded,
                      label: 'İpucu',
                      color: Colors.amber[700]!,
                      onPressed: () {
                        final card = _deck[_currentIndex];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(card.hint.isNotEmpty ? '💡 İpucu: ${card.hint}' : '💡 İpucu: Kartı çevirerek detaylı cevabı inceleyin.'),
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),

                    // Favori Toggle
                    _buildActionButton(
                      icon: _deck[_currentIndex].isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      label: 'Favori',
                      color: const Color(0xFFEC4899),
                      onPressed: _toggleFavoriteCurrent,
                    ),

                    // Öğrendim (Learned) Button
                    _buildActionButton(
                      icon: Icons.check_rounded,
                      label: 'Öğrendim',
                      color: const Color(0xFF10B981),
                      onPressed: () => _animateAndSwipe('learned', 1),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _activeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _activeFilter = value;
            _applyFilter();
          });
        },
        selectedColor: const Color(0xFF6366F1).withAlpha(180),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(25),
              border: Border.all(color: color.withAlpha(100), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildFrontFace(Flashcard card, bool isDark) {
    final colors = cardGradients[card.colorName] ?? cardGradients['indigo']!;

    return Container(
      width: 320,
      height: 450,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        boxShadow: [
          BoxShadow(color: colors[0].withAlpha(90), blurRadius: 25, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('🏷️ ${card.subCategory}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Row(
                children: [
                  if (card.isFavorite) const Icon(Icons.favorite, color: Colors.pinkAccent, size: 18),
                  const SizedBox(width: 4),
                  Text('★' * card.importance, style: const TextStyle(color: Colors.amber, fontSize: 18)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Text(
                  card.frontTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold, height: 1.3),
                ),
                if (card.frontSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    card.frontSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (card.hint.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('💡 İpucu var', style: TextStyle(color: Colors.white70, fontSize: 11)),
                )
              else
                const SizedBox(),
              const Row(
                children: [
                  Text('Çevir ', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  Icon(Icons.touch_app_rounded, color: Colors.white70, size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackFace(Flashcard card, bool isDark) {
    return Container(
      width: 320,
      height: 450,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(color: const Color(0xFF6366F1).withAlpha(100), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 25, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '✅ Cevap & Açıklama',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Text('★' * card.importance, style: const TextStyle(color: Colors.amber, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                card.backContent,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Ön Yüze Dönmek İçin Dokun 🔄',
              style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration_rounded, color: Colors.amber, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Tebrikler! Desteyi Bitirdiniz 🎉',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Bu filtredeki tüm kartları başarıyla gözden geçirdiniz.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.replay),
              label: const Text('Desteyi Yeniden Başlat', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _history.clear();
                  _resetFlip();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
