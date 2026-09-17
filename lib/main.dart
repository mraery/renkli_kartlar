import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'default_cards.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const RenkliKartlarApp());
}

class RenkliKartlarApp extends StatefulWidget {
  const RenkliKartlarApp({super.key});

  @override
  State<RenkliKartlarApp> createState() => _RenkliKartlarAppState();
}

class _RenkliKartlarAppState extends State<RenkliKartlarApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renkli Kartlar',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorSchemeSeed: const Color(0xFF6366F1),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorSchemeSeed: const Color(0xFF6366F1),
      ),
      home: FlashcardScreen(onToggleTheme: _toggleTheme, isDark: _themeMode == ThemeMode.dark),
    );
  }
}

// --- KART MODELİ ---
class Flashcard {
  String id;
  String frontTitle;
  String frontSubtitle;
  String backContent;
  String hint;
  String category;
  String colorName;
  int importance; // 1: Normal, 2: Önemli, 3: Sınavda Çıkar
  String status; // new, learned, repeat

  Flashcard({
    required this.id,
    required this.frontTitle,
    this.frontSubtitle = '',
    required this.backContent,
    this.hint = '',
    this.category = 'Genel',
    this.colorName = 'emerald',
    this.importance = 1,
    this.status = 'new',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'frontTitle': frontTitle,
        'frontSubtitle': frontSubtitle,
        'backContent': backContent,
        'hint': hint,
        'category': category,
        'colorName': colorName,
        'importance': importance,
        'status': status,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] ?? '',
        frontTitle: json['frontTitle'] ?? '',
        frontSubtitle: json['frontSubtitle'] ?? '',
        backContent: json['backContent'] ?? '',
        hint: json['hint'] ?? '',
        category: json['category'] ?? 'Genel',
        colorName: json['colorName'] ?? 'emerald',
        importance: json['importance'] ?? 1,
        status: json['status'] ?? 'new',
      );
}

// Renk Temaları
final Map<String, List<Color>> cardGradients = {
  'emerald': [const Color(0xFF059669), const Color(0xFF10B981), const Color(0xFF34D399)],
  'indigo': [const Color(0xFF3730A3), const Color(0xFF4F46E5), const Color(0xFF6366F1)],
  'amber': [const Color(0xFFD97706), const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
  'rose': [const Color(0xFFBE123C), const Color(0xFFE11D48), const Color(0xFFF43F5E)],
  'violet': [const Color(0xFF6D28D9), const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
  'cyan': [const Color(0xFF0E7490), const Color(0xFF06B6D4), const Color(0xFF22D3EE)],
  'teal': [const Color(0xFF0F766E), const Color(0xFF14B8A6), const Color(0xFF2DD4BF)],
  'obsidian': [const Color(0xFF1E293B), const Color(0xFF334155), const Color(0xFF475569)],
};

// --- ANA EKRAN ---
class FlashcardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const FlashcardScreen({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with TickerProviderStateMixin {
  List<Flashcard> _allCards = [];
  List<Flashcard> _studyDeck = [];
  int _currentIndex = 0;
  String _activeFilter = 'all'; // all, important, repeat, or category

  // 3D Çevirme Animasyonu
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isBack = false;

  // Swipe Pozisyonu ve Çıkış Animasyonu
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;
  late AnimationController _swipeAnimationController;
  late Animation<double> _swipeTween;
  bool _isAnimatingSwipe = false;

  // Geri Alma Yığını
  final List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
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

    _loadCards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final isV300 = prefs.getBool('flashcards_v300_initialized') ?? false;
    final jsonStr = prefs.getString('flashcards_data');

    if (jsonStr != null) {
      try {
        final List list = json.decode(jsonStr);
        final loaded = list.map((e) => Flashcard.fromJson(e)).toList();
        // Eğer eski 6 kart yüklüyse otomatik 320 karta güncelle
        if (!isV300 && loaded.length <= 6) {
          _initDefaultCards();
          await prefs.setBool('flashcards_v300_initialized', true);
        } else {
          setState(() {
            _allCards = loaded;
          });
        }
      } catch (_) {
        _initDefaultCards();
        await prefs.setBool('flashcards_v300_initialized', true);
      }
    } else {
      _initDefaultCards();
      await prefs.setBool('flashcards_v300_initialized', true);
    }
    _filterCards();
  }

  void _initDefaultCards() {
    setState(() {
      _allCards = getDefaultFlashcards();
    });
    _saveCards();
  }

  void _restoreDefaultCards({VoidCallback? onDone}) {
    setState(() {
      _allCards = getDefaultFlashcards();
      _activeFilter = 'all';
      _currentIndex = 0;
      _history.clear();
      _resetFlip();
    });
    _saveCards();
    _filterCards();
    onDone?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📦 320 hazır bilgi kartı başarıyla yüklendi!'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext dialogContext, {VoidCallback? onDone}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Tüm Kartlar Silinsin mi?'),
          ],
        ),
        content: const Text(
          'Mevcut tüm kartlar silinecektir. Böylece sadece kendi kartlarını oluşturabilirsin.\n\n(İstediğinde hazır 320 kartı tek tuşla tekrar geri yükleyebilirsin.)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _allCards.clear();
                _studyDeck.clear();
                _history.clear();
                _currentIndex = 0;
                _resetFlip();
              });
              _saveCards();
              _filterCards();
              onDone?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Bütün kartlar silindi!'),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Evet, Hepsini Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_allCards.map((e) => e.toJson()).toList());
    await prefs.setString('flashcards_data', jsonStr);
  }

  void _filterCards() {
    setState(() {
      if (_activeFilter == 'all') {
        _studyDeck = List.from(_allCards);
      } else if (_activeFilter == 'important') {
        _studyDeck = _allCards.where((c) => c.importance >= 2).toList();
      } else if (_activeFilter == 'repeat') {
        _studyDeck = _allCards.where((c) => c.status == 'repeat').toList();
      } else {
        _studyDeck = _allCards.where((c) => c.category == _activeFilter).toList();
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

  void _animateAndSwipe(String status, int direction) {
    if (_isAnimatingSwipe || _currentIndex >= _studyDeck.length) return;
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
    if (_currentIndex >= _studyDeck.length) return;
    final card = _studyDeck[_currentIndex];

    HapticFeedback.mediumImpact();
    final wasReadded = (status == 'repeat');
    _history.add({
      'cardId': card.id,
      'prevStatus': card.status,
      'wasReadded': wasReadded,
    });

    setState(() {
      card.status = status;
      final real = _allCards.firstWhere((c) => c.id == card.id);
      real.status = status;

      if (wasReadded) {
        // Tekrar edilecek kartı destenin sonuna ekle ki tekrar karşısına çıksın!
        _studyDeck.add(card);
      }

      _currentIndex++;
      _resetFlip();
      _dragOffset = Offset.zero;
      _dragRotation = 0;
    });

    _saveCards();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              status == 'learned' ? Icons.check_circle : Icons.replay_circle_filled,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                status == 'learned'
                    ? '✅ "${card.frontTitle}" öğrenildi!'
                    : '🔁 "${card.frontTitle}" tekrar listesine eklendi!',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: status == 'learned' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 90, left: 20, right: 20),
      ),
    );
  }

  void _undo() {
    if (_history.isEmpty) return;
    final last = _history.removeLast();
    final real = _allCards.firstWhere((c) => c.id == last['cardId']);
    setState(() {
      real.status = last['prevStatus'];
      if (last['wasReadded'] == true && _studyDeck.isNotEmpty) {
        _studyDeck.removeLast();
      }
      if (_currentIndex > 0) _currentIndex--;
      _resetFlip();
      _dragOffset = Offset.zero;
      _dragRotation = 0;
    });
    _saveCards();
  }

  void _openCardForm({Flashcard? cardToEdit}) {
    final titleCtrl = TextEditingController(text: cardToEdit?.frontTitle ?? '');
    final subCtrl = TextEditingController(text: cardToEdit?.frontSubtitle ?? '');
    final backCtrl = TextEditingController(text: cardToEdit?.backContent ?? '');
    final hintCtrl = TextEditingController(text: cardToEdit?.hint ?? '');
    final catCtrl = TextEditingController(text: cardToEdit?.category ?? 'Genel');
    int importance = cardToEdit?.importance ?? 1;
    String colorName = cardToEdit?.colorName ?? 'emerald';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardToEdit == null ? 'Yeni Bilgi Kartı Ekle' : 'Kartı Düzenle',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Ön Yüz Başlığı (Soru/Kavram) *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subCtrl,
                      decoration: const InputDecoration(labelText: 'Alt Başlık / Konu', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: backCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Arka Yüz (Cevap/Açıklama) *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hintCtrl,
                      decoration: const InputDecoration(labelText: 'İpucu / Özel Not', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: catCtrl,
                      decoration: const InputDecoration(labelText: 'Ders / Kategori', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),
                    const Text('Önem Derecesi:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(3, (idx) {
                        return IconButton(
                          icon: Icon(
                            idx < importance ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setModalState(() => importance = idx + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    const Text('Kart Rengi:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: cardGradients.keys.map((cName) {
                        final isSel = cName == colorName;
                        return GestureDetector(
                          onTap: () => setModalState(() => colorName = cName),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: cardGradients[cName]!),
                              border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty || backCtrl.text.trim().isEmpty) return;
                          setState(() {
                            if (cardToEdit == null) {
                              _allCards.insert(
                                0,
                                Flashcard(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  frontTitle: titleCtrl.text.trim(),
                                  frontSubtitle: subCtrl.text.trim(),
                                  backContent: backCtrl.text.trim(),
                                  hint: hintCtrl.text.trim(),
                                  category: catCtrl.text.trim().isEmpty ? 'Genel' : catCtrl.text.trim(),
                                  colorName: colorName,
                                  importance: importance,
                                ),
                              );
                            } else {
                              cardToEdit.frontTitle = titleCtrl.text.trim();
                              cardToEdit.frontSubtitle = subCtrl.text.trim();
                              cardToEdit.backContent = backCtrl.text.trim();
                              cardToEdit.hint = hintCtrl.text.trim();
                              cardToEdit.category = catCtrl.text.trim().isEmpty ? 'Genel' : catCtrl.text.trim();
                              cardToEdit.colorName = colorName;
                              cardToEdit.importance = importance;
                            }
                          });
                          _saveCards();
                          _filterCards();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (_allCards.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.delete_forever, size: 20),
                          label: Text('🗑️ Bütün Kartları Sil (${_allCards.length})'),
                          onPressed: () {
                            _confirmDeleteAll(ctx, onDone: () {
                              setModalState(() {});
                            });
                          },
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.restore, size: 20),
                          label: const Text('📦 Hazır 320 Kartı Tekrar Yükle'),
                          onPressed: () {
                            _restoreDefaultCards(onDone: () {
                              setModalState(() {});
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openManageCards() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.78,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tüm Kartlar (${_allCards.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_allCards.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.delete_sweep, size: 20),
                        label: Text('🗑️ Bütün Kartları Sil (${_allCards.length})'),
                        onPressed: () {
                          _confirmDeleteAll(ctx, onDone: () {
                            setModalState(() {});
                          });
                        },
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.restore, size: 20),
                        label: const Text('📦 Hazır 320 Kartı Tekrar Yükle'),
                        onPressed: () {
                          _restoreDefaultCards(onDone: () {
                            setModalState(() {});
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Expanded(
                    child: _allCards.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.layers_clear, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text('Henüz kart bulunmuyor.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('İster üstteki butondan 320 hazır kartı yükle,\nister kendi kartlarını oluştur.',
                                    textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _allCards.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                              final card = _allCards[i];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(card.frontTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('${card.category} • ${"★" * card.importance}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _openCardForm(cardToEdit: card);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _allCards.removeAt(i);
                                        });
                                        _saveCards();
                                        _filterCards();
                                        setModalState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _allCards.map((c) => c.category).toSet().toList();
    final learnedCount = _allCards.where((c) => c.status == 'learned').length;
    final repeatCount = _allCards.where((c) => c.status == 'repeat').length;
    final remainingCount = math.max(0, _studyDeck.length - _currentIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🗂️ ', style: TextStyle(fontSize: 24)),
            Text('Renkli Kartlar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          if (_allCards.isEmpty)
            IconButton(
              icon: const Icon(Icons.restore, color: Color(0xFF10B981)),
              tooltip: 'Hazır 320 Kartı Tekrar Yükle',
              onPressed: () => _restoreDefaultCards(),
            ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Tüm Kartlar',
            onPressed: _openManageCards,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1), size: 28),
            tooltip: 'Yeni Kart Ekle',
            onPressed: () => _openCardForm(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtre Barı
            if (_allCards.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('Tümü (${_allCards.length})', 'all'),
                    _buildFilterChip('⭐ Önemliler (${_allCards.where((c) => c.importance >= 2).length})', 'important'),
                    _buildFilterChip('🔁 Tekrarlar ($repeatCount)', 'repeat'),
                    ...categories.map((cat) {
                      final count = _allCards.where((c) => c.category == cat).length;
                      return _buildFilterChip('🏷️ $cat ($count)', cat);
                    }),
                  ],
                ),
              ),
            if (_allCards.isNotEmpty) const SizedBox(height: 8),

            // İstatistik Barı
            if (_allCards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kalan: $remainingCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Tekrar: $repeatCount', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Öğrenilen: $learnedCount', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            if (_allCards.isNotEmpty) const SizedBox(height: 12),

            // Kart Alanı
            Expanded(
              child: Center(
                child: _allCards.isEmpty
                    ? _buildNoCardsState()
                    : (_currentIndex >= _studyDeck.length
                        ? _buildCompletedState()
                        : _buildCardArena(_studyDeck[_currentIndex])),
              ),
            ),

            // Alt Kontrol Butonları
            if (_allCards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.undo, Colors.grey, _undo, 'Geri Al', size: 48),
                    _buildActionButton(Icons.close, Colors.red, () => _animateAndSwipe('repeat', -1), 'Tekrar', size: 64),
                    _buildActionButton(Icons.flip, const Color(0xFF6366F1), _toggleFlip, 'Çevir', size: 52),
                    _buildActionButton(Icons.check, Colors.green, () => _animateAndSwipe('learned', 1), 'Öğrendim', size: 64),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCardsState() {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1).withAlpha(35),
            ),
            child: const Icon(Icons.layers_clear_rounded, size: 64, color: Color(0xFF6366F1)),
          ),
          const SizedBox(height: 20),
          const Text('Hiç Kart Kalmadı', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            'Tüm kartları sildin! Şimdi tamamen kendi kartlarını oluşturabilirsin. İstersen hazır 320 kartı tek tıkla geri getirebilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('➕ Kendi Kartını Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () => _openCardForm(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981), width: 1.6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.restore),
              label: const Text('📦 Hazır 320 Kartı Tekrar Yükle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () => _restoreDefaultCards(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSel = _activeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
        selected: isSel,
        selectedColor: const Color(0xFF6366F1),
        labelStyle: TextStyle(color: isSel ? Colors.white : null),
        onSelected: (_) {
          setState(() => _activeFilter = value);
          _filterCards();
        },
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap, String label, {double size = 56}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.45),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCompletedState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎉', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        const Text('Oturum Tamamlandı!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Bu kategorideki tüm kartları çalıştın.', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.replay),
          label: const Text('Hepsini Baştan Çalış'),
          onPressed: () {
            setState(() {
              for (var c in _allCards) {
                c.status = 'new';
              }
              _currentIndex = 0;
            });
            _saveCards();
            _filterCards();
          },
        ),
      ],
    );
  }

  Widget _buildCardArena(Flashcard card) {
    return GestureDetector(
      onTap: _toggleFlip,
      onHorizontalDragStart: (_) {
        if (_isAnimatingSwipe) return;
        _dragOffset = Offset.zero;
        _dragRotation = 0;
      },
      onHorizontalDragUpdate: (details) {
        if (_isAnimatingSwipe) return;
        setState(() {
          _dragOffset = Offset(_dragOffset.dx + details.delta.dx, 0);
          _dragRotation = (_dragOffset.dx / 280) * (math.pi / 7);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_isAnimatingSwipe) return;
        final dx = _dragOffset.dx;
        final vx = details.velocity.pixelsPerSecond.dx;

        // Hem parmak kaydırma mesafesi hem de hızlı fırlatma hızı
        final isSwipeRight = dx > 45 || (dx > 15 && vx > 200);
        final isSwipeLeft = dx < -45 || (dx < -15 && vx < -200);

        if (isSwipeRight) {
          _animateAndSwipe('learned', 1);
        } else if (isSwipeLeft) {
          _animateAndSwipe('repeat', -1);
        } else {
          setState(() {
            _dragOffset = Offset.zero;
            _dragRotation = 0;
          });
        }
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _dragRotation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  // 3D Dönüş Matrisi
                  final angle = _flipAnimation.value * math.pi;
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle);

                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    // Kesin Çözüm: Açıya göre YALNIZCA tek bir yüz render edilir, asla üst üste binemez!
                    child: angle < math.pi / 2
                        ? _buildFrontFace(card)
                        : Transform(
                            transform: Matrix4.identity()..rotateY(math.pi),
                            alignment: Alignment.center,
                            child: _buildBackFace(card),
                          ),
                  );
                },
              ),
              // Sağa Kaydırırken: "ÖĞRENDİM" Damgası & İndikatörü
              if (_dragOffset.dx > 15)
                Positioned(
                  top: 28,
                  left: 20,
                  child: Opacity(
                    opacity: ((_dragOffset.dx - 15) / 55).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: -math.pi / 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 22),
                            SizedBox(width: 6),
                            Text(
                              'ÖĞRENDİM',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Sola Kaydırırken: "TEKRAR" Damgası & İndikatörü
              if (_dragOffset.dx < -15)
                Positioned(
                  top: 28,
                  right: 20,
                  child: Opacity(
                    opacity: ((-_dragOffset.dx - 15) / 55).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: math.pi / 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.replay_circle_filled, color: Colors.white, size: 22),
                            SizedBox(width: 6),
                            Text(
                              'TEKRAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontFace(Flashcard card) {
    final colors = cardGradients[card.colorName] ?? cardGradients['emerald']!;
    return Container(
      width: 320,
      height: 440,
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
                child: Text('🏷️ ${card.category}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Text('★' * card.importance, style: const TextStyle(color: Colors.amber, fontSize: 18)),
            ],
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Text(
                  card.frontTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
                ),
                if (card.frontSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    card.frontSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 14),
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
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('💡 İpucu: ${card.hint}'), duration: const Duration(seconds: 3)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('💡 İpucu', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                const SizedBox(),
              const Row(
                children: [
                  Text('Çevir ', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  Icon(Icons.refresh, color: Colors.white70, size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackFace(Flashcard card) {
    return Container(
      width: 320,
      height: 440,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF1E293B),
        border: Border.all(color: Colors.white.withAlpha(40), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 25, offset: Offset(0, 10)),
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
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('✅ Cevap / Açıklama', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Text('★' * card.importance, style: const TextStyle(color: Colors.amber, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                card.backContent,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text('Ön Yüze Dön 🔄', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
