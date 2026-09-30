import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/card_service.dart';

class SearchScreen extends StatefulWidget {
  final bool isDark;

  const SearchScreen({super.key, required this.isDark});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CardService _cardService = CardService.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  DeckCategory _selectedDeck = kDeckCategories[0];
  List<Flashcard> _deckCards = [];
  List<Flashcard> _filteredCards = [];
  bool _isLoading = true;
  String _statusFilter = 'all'; // all, learned, repeat, favorite

  @override
  void initState() {
    super.initState();
    _loadDeckCards();
  }

  Future<void> _loadDeckCards() async {
    setState(() => _isLoading = true);
    final cards = await _cardService.loadDeck(_selectedDeck);
    if (mounted) {
      setState(() {
        _deckCards = cards;
        _isLoading = false;
        _applySearch();
      });
    }
  }

  void _applySearch() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filteredCards = _deckCards.where((card) {
        // Status filter
        if (_statusFilter == 'learned' && card.status != 'learned') return false;
        if (_statusFilter == 'repeat' && card.status != 'repeat') return false;
        if (_statusFilter == 'favorite' && !card.isFavorite) return false;

        // Query filter
        if (query.isEmpty) return true;
        return card.frontTitle.toLowerCase().contains(query) ||
            card.frontSubtitle.toLowerCase().contains(query) ||
            card.backContent.toLowerCase().contains(query) ||
            card.subCategory.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showCardPreview(Flashcard card) {
    bool isFlipped = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final colors = cardGradients[card.colorName] ?? cardGradients['indigo']!;

          return AlertDialog(
            backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: EdgeInsets.zero,
            content: InkWell(
              onTap: () => setDialogState(() => isFlipped = !isFlipped),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 310,
                height: 420,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isFlipped
                      ? null
                      : LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  color: isFlipped ? (widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)) : null,
                  border: isFlipped ? Border.all(color: colors[0], width: 2) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            card.subCategory,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text('★' * card.importance, style: const TextStyle(color: Colors.amber, fontSize: 16)),
                      ],
                    ),
                    const Spacer(),
                    if (!isFlipped) ...[
                      Center(
                        child: Text(
                          card.frontTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (card.frontSubtitle.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            card.frontSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
                          ),
                        ),
                      ],
                    ] else ...[
                      const Text(
                        '✅ Cevap & Açıklama:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF10B981)),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            card.backContent,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: widget.isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Center(
                      child: Text(
                        isFlipped ? 'Ön Yüze Dön 🔄' : 'Cevabı Gör 🔄',
                        style: TextStyle(
                          color: isFlipped ? Colors.grey : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Kapat'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Kart Gezgini & Arama', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Deck Category Selector Dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DeckCategory>(
                    value: _selectedDeck,
                    isExpanded: true,
                    items: kDeckCategories.map((deck) {
                      return DropdownMenuItem<DeckCategory>(
                        value: deck,
                        child: Row(
                          children: [
                            Text(deck.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(deck.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                            Text('${deck.totalCount} Kart', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newDeck) {
                      if (newDeck != null) {
                        setState(() {
                          _selectedDeck = newDeck;
                        });
                        _loadDeckCards();
                      }
                    },
                  ),
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: '${_selectedDeck.title} içinde ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _applySearch();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (_) => _applySearch(),
              ),
            ),

            const SizedBox(height: 8),

            // Status Filter Chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildStatusChip('Tümü', 'all'),
                  _buildStatusChip('✅ Öğrenilenler', 'learned'),
                  _buildStatusChip('🔁 Tekrarlar', 'repeat'),
                  _buildStatusChip('❤️ Favoriler', 'favorite'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bulunan Kartlar: ${_filteredCards.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                  ),
                  const Text('Dokunarak Önizleyin', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),

            // Cards List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                              const SizedBox(height: 10),
                              Text(
                                'Aramanıza uygun kart bulunamadı.',
                                style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredCards.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (ctx, idx) {
                            final card = _filteredCards[idx];
                            final colors = cardGradients[card.colorName] ?? cardGradients['indigo']!;

                            return InkWell(
                              onTap: () => _showCardPreview(card),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colors[0],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            card.frontTitle,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${card.subCategory} • ${card.frontSubtitle.isNotEmpty ? card.frontSubtitle : card.backContent}',
                                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (card.status == 'learned')
                                      const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18)
                                    else if (card.status == 'repeat')
                                      const Icon(Icons.replay_rounded, color: Color(0xFFEF4444), size: 18)
                                    else
                                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _statusFilter = value;
              _applySearch();
            });
          }
        },
      ),
    );
  }
}
