import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/card_service.dart';
import 'study_screen.dart';
import 'quiz_screen.dart';
import 'search_screen.dart';
import 'stats_screen.dart';

class DeckSelectorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const DeckSelectorScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<DeckSelectorScreen> createState() => _DeckSelectorScreenState();
}

class _DeckSelectorScreenState extends State<DeckSelectorScreen> {
  final CardService _cardService = CardService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _cardService.init();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openStudy(DeckCategory deck, {String? subCategory}) async {
    setState(() => _isLoading = true);
    final cards = await _cardService.loadDeck(deck);
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => StudyScreen(
          title: deck.title,
          cards: cards,
          initialSubCategory: subCategory,
          isDark: widget.isDark,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _openQuiz(DeckCategory deck) async {
    setState(() => _isLoading = true);
    final cards = await _cardService.loadDeck(deck);
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => QuizScreen(
          deckTitle: deck.title,
          allCards: cards,
          isDark: widget.isDark,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _openCustomCardsStudy() {
    if (_cardService.customCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Henüz özel kart eklemediniz. "+" butonundan ilk kartınızı oluşturun!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _openAddCardDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => StudyScreen(
          title: 'Özel Kartlarım',
          cards: _cardService.customCards,
          isDark: widget.isDark,
          isCustomDeck: true,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _openAddCardDialog() {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final backCtrl = TextEditingController();
    final hintCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Özel');
    int importance = 2;
    String colorName = 'indigo';

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('✨ Yeni Bilgi Kartı Ekle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Ön Yüz Başlığı (Soru/Kavram) *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subCtrl,
                      decoration: const InputDecoration(labelText: 'Alt Başlık / Soru Detayı', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: backCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Arka Yüz (Cevap/Açıklama/Formül) *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hintCtrl,
                      decoration: const InputDecoration(labelText: 'İpucu', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: catCtrl,
                      decoration: const InputDecoration(labelText: 'Kategori / Ders', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),
                    const Text('Önem Derecesi:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(3, (idx) {
                        return IconButton(
                          icon: Icon(idx < importance ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                          onPressed: () => setModalState(() => importance = idx + 1),
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
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('Kartı Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty || backCtrl.text.trim().isEmpty) return;
                          final messenger = ScaffoldMessenger.of(context);
                          final newCard = Flashcard(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            frontTitle: titleCtrl.text.trim(),
                            frontSubtitle: subCtrl.text.trim(),
                            backContent: backCtrl.text.trim(),
                            hint: hintCtrl.text.trim(),
                            category: catCtrl.text.trim().isEmpty ? 'Özel' : catCtrl.text.trim(),
                            colorName: colorName,
                            importance: importance,
                            options: [backCtrl.text.trim(), 'Seçenek B', 'Seçenek C', 'Seçenek D'],
                            correctAnswer: backCtrl.text.trim(),
                          );
                          await _cardService.saveCustomCard(newCard);
                          if (ctx.mounted) Navigator.pop(ctx);
                          setState(() {});
                          messenger.showSnackBar(
                            const SnackBar(content: Text('✅ Özel kart başarıyla kaydedildi!'), backgroundColor: Color(0xFF10B981)),
                          );
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

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    const totalCards = 42000;
    final learnedCount = _cardService.learnedIds.length;
    final repeatCount = _cardService.repeatIds.length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🗂️ ', style: TextStyle(fontSize: 24)),
            Text('Renkli Kartlar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Kartlarda Ara',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => SearchScreen(isDark: isDark)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            tooltip: 'İstatistikler',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => StatsScreen(isDark: isDark)),
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Kart Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _openAddCardDialog,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                children: [
                  // Mega Summary Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withAlpha(100),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '⚡ DEV KART BANKASI',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${_cardService.streakDays} Gün Seri',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '42.000+ Soru & Bilgi Kartı',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'YKS, KPSS, DGS, LGS, Yazılım, İngilizce ve Genel Kültür konularını 3D kartlar ve testlerle ustalaş.',
                          style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildBannerStat('🎯 Toplam', '${totalCards + _cardService.customCards.length}'),
                            const SizedBox(width: 12),
                            _buildBannerStat('✅ Öğrenilen', '$learnedCount'),
                            const SizedBox(width: 12),
                            _buildBannerStat('🔁 Tekrar', '$repeatCount'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📚 Ders & Sınav Desteleri',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '7 Kategori',
                        style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Cards
                  ...kDeckCategories.map((deck) => _buildDeckCard(deck, isDark)),

                  const SizedBox(height: 16),

                  // Custom Cards Deck Card
                  _buildCustomCardsDeckCard(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildBannerStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckCard(DeckCategory deck, bool isDark) {
    final learned = _cardService.getLearnedCountForDeck(deck);
    final progress = (learned / deck.totalCount).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: deck.gradient),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(deck.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        deck.subtitle,
                        style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${deck.totalCount} Kart',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Subtopics preview chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: deck.subCategories.take(4).map((sub) {
                return GestureDetector(
                  onTap: () => _openStudy(deck, subCategory: sub),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sub,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress > 0 ? progress : 0.01,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(deck.gradient[0]),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deck.gradient[0],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.flip_to_back_rounded, size: 18),
                    label: const Text('3D Kart Çalış', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => _openStudy(deck),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: deck.gradient[0],
                      side: BorderSide(color: deck.gradient[0], width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.quiz_rounded, size: 18),
                    label: const Text('Test Çöz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => _openQuiz(deck),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCardsDeckCard(bool isDark) {
    final customCount = _cardService.customCards.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withAlpha(80),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Text('✍️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kendi Özel Kartlarım',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        customCount > 0 ? '$customCount özel kart oluşturdun' : 'Kendi sorularını ve notlarını ekle',
                        style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
                  onPressed: _openAddCardDialog,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.style, size: 18),
                    label: Text(customCount > 0 ? 'Özel Kartları Çalış ($customCount)' : 'İlk Kartını Ekle'),
                    onPressed: _openCustomCardsStudy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
