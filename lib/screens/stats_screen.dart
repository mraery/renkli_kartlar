import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/card_service.dart';

class StatsScreen extends StatelessWidget {
  final bool isDark;

  const StatsScreen({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final service = CardService.instance;
    const totalCards = 42000;
    final learned = service.learnedIds.length;
    final repeat = service.repeatIds.length;
    final favorite = service.favoriteIds.length;
    final totalQuiz = service.totalQuizCorrect + service.totalQuizWrong;
    final accuracy = totalQuiz > 0 ? ((service.totalQuizCorrect / totalQuiz) * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 İstatistikler & Gelişim', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overall Mastery Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Genel Kart Başarısı', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    '%${((learned / totalCards) * 100).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (learned / totalCards).clamp(0.005, 1.0),
                      backgroundColor: Colors.white.withAlpha(50),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$learned / $totalCards kart öğrenildi',
                    style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4 Mini Stat Boxes
            Row(
              children: [
                _buildStatTile('✅ Öğrenilen', '$learned', const Color(0xFF10B981)),
                const SizedBox(width: 12),
                _buildStatTile('🔁 Tekrar Kutusu', '$repeat', const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatTile('❤️ Favoriler', '$favorite', const Color(0xFFEC4899)),
                const SizedBox(width: 12),
                _buildStatTile('🎯 Test Başarısı', '%$accuracy', const Color(0xFF6366F1)),
              ],
            ),

            const SizedBox(height: 24),

            // Leitner Spaced Repetition Box Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.all_inclusive, color: Color(0xFF6366F1), size: 22),
                      SizedBox(width: 8),
                      Text('Leitner Akıllı Tekrar Sistemi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Uygulama, zorlandığınız kartları otomatik olarak "Tekrar Kutusu"na aktarır ve destenin sonuna ekleyerek hafızada kalıcı hale gelene kadar karşınıza çıkarır.',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('📚 Kategori Bazlı İlerleme', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 12),

            // Per Category Progress
            ...kDeckCategories.map((deck) {
              final deckLearned = service.getLearnedCountForDeck(deck);
              final deckProgress = (deckLearned / deck.totalCount).clamp(0.0, 1.0);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(deck.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(deck.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Text(
                          '$deckLearned / ${deck.totalCount}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: deckProgress > 0 ? deckProgress : 0.01,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(deck.gradient[0]),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
