import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flashcard.dart';
import '../services/card_service.dart';

class QuizScreen extends StatefulWidget {
  final String deckTitle;
  final List<Flashcard> allCards;
  final bool isDark;

  const QuizScreen({
    super.key,
    required this.deckTitle,
    required this.allCards,
    required this.isDark,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final CardService _cardService = CardService.instance;
  late List<Flashcard> _quizQuestions;
  int _questionIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() {
    final shuffled = List<Flashcard>.from(widget.allCards)..shuffle();
    _quizQuestions = shuffled.take(20).toList();
    _questionIndex = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _selectedAnswer = null;
    _isAnswered = false;
  }

  void _selectOption(String option) {
    if (_isAnswered) return;
    final currentCard = _quizQuestions[_questionIndex];
    final isCorrect = option == currentCard.correctAnswer;

    setState(() {
      _selectedAnswer = option;
      _isAnswered = true;
      if (isCorrect) {
        _correctCount++;
        _cardService.markCardStatus(currentCard, 'learned');
        HapticFeedback.mediumImpact();
      } else {
        _wrongCount++;
        _cardService.markCardStatus(currentCard, 'repeat');
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _nextQuestion() {
    if (_questionIndex < _quizQuestions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _cardService.recordQuizResult(correct: _correctCount, wrong: _wrongCount);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Test Tamamlandı!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.deckTitle} Test Sonucunuz',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBox('Doğru', '$_correctCount', const Color(0xFF10B981)),
                _buildStatBox('Yanlış', '$_wrongCount', const Color(0xFFEF4444)),
                _buildStatBox(
                  'Başarı',
                  '%${((_correctCount / _quizQuestions.length) * 100).toStringAsFixed(0)}',
                  const Color(0xFF6366F1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _correctCount >= 15
                  ? '🌟 Harika bir başarı! Konuya çok iyi hakimsiniz.'
                  : '💡 Biraz daha kart tekrarı yaparak netlerinizi artırabilirsiniz.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Destelere Dön'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _initQuiz();
              });
            },
            child: const Text('Yeni 20 Soru'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    if (_quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deckTitle)),
        body: const Center(child: Text('Test oluşturulacak yeterli kart bulunamadı.')),
      );
    }

    final card = _quizQuestions[_questionIndex];
    final progress = (_questionIndex + 1) / _quizQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.deckTitle} Testi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('Soru ${_questionIndex + 1} / ${_quizQuestions.length}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 4),
                Text('$_correctCount', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 16),
                const SizedBox(width: 4),
                Text('$_wrongCount', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              minHeight: 6,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Tag Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            card.subCategory,
                            style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const Spacer(),
                        Text('★' * card.importance, style: const TextStyle(color: Colors.amber, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.frontTitle,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (card.frontSubtitle.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              card.frontSubtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Options List
                    const Text('Seçenekler:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    ...card.options.map((opt) => _buildOptionTile(opt, card, isDark)),

                    // Explanation Box when answered
                    if (_isAnswered) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedAnswer == card.correctAnswer
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedAnswer == card.correctAnswer ? Icons.check_circle : Icons.error,
                                  color: _selectedAnswer == card.correctAnswer
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedAnswer == card.correctAnswer ? 'Doğru Cevap!' : 'Yanlış Cevap!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedAnswer == card.correctAnswer
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.backContent,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Next Question Button
            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(_questionIndex < _quizQuestions.length - 1 ? Icons.arrow_forward : Icons.done_all),
                    label: Text(
                      _questionIndex < _quizQuestions.length - 1 ? 'Sonraki Soru' : 'Sonuçları Gör',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: _nextQuestion,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String option, Flashcard card, bool isDark) {
    Color borderColor = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15);
    Color bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;

    if (_isAnswered) {
      if (option == card.correctAnswer) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withAlpha(30);
        textColor = const Color(0xFF10B981);
      } else if (option == _selectedAnswer) {
        borderColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFEF4444).withAlpha(30);
        textColor = const Color(0xFFEF4444);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _selectOption(option),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (_isAnswered && option == card.correctAnswer)
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20)
              else if (_isAnswered && option == _selectedAnswer)
                const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
