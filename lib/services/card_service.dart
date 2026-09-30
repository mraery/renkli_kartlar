import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class CardService {
  static final CardService instance = CardService._();
  CardService._();

  final Map<String, List<Flashcard>> _deckCache = {};
  Set<String> _learnedIds = {};
  Set<String> _repeatIds = {};
  Set<String> _favoriteIds = {};
  List<Flashcard> _customCards = [];
  bool _initialized = false;
  int _streakDays = 1;
  int _totalQuizCorrect = 0;
  int _totalQuizWrong = 0;

  Set<String> get learnedIds => _learnedIds;
  Set<String> get repeatIds => _repeatIds;
  Set<String> get favoriteIds => _favoriteIds;
  List<Flashcard> get customCards => _customCards;
  int get streakDays => _streakDays;
  int get totalQuizCorrect => _totalQuizCorrect;
  int get totalQuizWrong => _totalQuizWrong;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    final learnedList = prefs.getStringList('learned_card_ids') ?? [];
    final repeatList = prefs.getStringList('repeat_card_ids') ?? [];
    final favoriteList = prefs.getStringList('favorite_card_ids') ?? [];

    _learnedIds = learnedList.toSet();
    _repeatIds = repeatList.toSet();
    _favoriteIds = favoriteList.toSet();
    _streakDays = prefs.getInt('streak_days') ?? 1;
    _totalQuizCorrect = prefs.getInt('quiz_correct_count') ?? 0;
    _totalQuizWrong = prefs.getInt('quiz_wrong_count') ?? 0;

    final customJson = prefs.getString('custom_user_cards');
    if (customJson != null) {
      try {
        final List list = json.decode(customJson);
        _customCards = list.map((e) => Flashcard.fromJson(e)).toList();
      } catch (_) {
        _customCards = [];
      }
    }

    _initialized = true;
  }

  Future<List<Flashcard>> loadDeck(DeckCategory category) async {
    await init();
    if (_deckCache.containsKey(category.id)) {
      _applyUserStatus(_deckCache[category.id]!);
      return _deckCache[category.id]!;
    }

    try {
      final jsonStr = await rootBundle.loadString(category.assetFile);
      final List list = json.decode(jsonStr);
      final loaded = list.map((e) => Flashcard.fromJson(e)).toList();
      _applyUserStatus(loaded);
      _deckCache[category.id] = loaded;
      return loaded;
    } catch (e) {
      return [];
    }
  }

  void _applyUserStatus(List<Flashcard> cards) {
    for (var c in cards) {
      if (_learnedIds.contains(c.id)) {
        c.status = 'learned';
      } else if (_repeatIds.contains(c.id)) {
        c.status = 'repeat';
      } else {
        c.status = 'new';
      }
      c.isFavorite = _favoriteIds.contains(c.id);
    }
  }

  Future<void> markCardStatus(Flashcard card, String status) async {
    card.status = status;
    if (status == 'learned') {
      _learnedIds.add(card.id);
      _repeatIds.remove(card.id);
    } else if (status == 'repeat') {
      _repeatIds.add(card.id);
      _learnedIds.remove(card.id);
    } else {
      _learnedIds.remove(card.id);
      _repeatIds.remove(card.id);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('learned_card_ids', _learnedIds.toList());
    await prefs.setStringList('repeat_card_ids', _repeatIds.toList());
  }

  Future<void> toggleFavorite(Flashcard card) async {
    card.isFavorite = !card.isFavorite;
    if (card.isFavorite) {
      _favoriteIds.add(card.id);
    } else {
      _favoriteIds.remove(card.id);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_card_ids', _favoriteIds.toList());
  }

  Future<void> saveCustomCard(Flashcard card) async {
    final idx = _customCards.indexWhere((c) => c.id == card.id);
    if (idx >= 0) {
      _customCards[idx] = card;
    } else {
      _customCards.insert(0, card);
    }
    await _persistCustomCards();
  }

  Future<void> deleteCustomCard(String id) async {
    _customCards.removeWhere((c) => c.id == id);
    _learnedIds.remove(id);
    _repeatIds.remove(id);
    _favoriteIds.remove(id);
    await _persistCustomCards();
  }

  Future<void> _persistCustomCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_customCards.map((e) => e.toJson()).toList());
    await prefs.setString('custom_user_cards', jsonStr);
  }

  Future<void> recordQuizResult({required int correct, required int wrong}) async {
    _totalQuizCorrect += correct;
    _totalQuizWrong += wrong;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_correct_count', _totalQuizCorrect);
    await prefs.setInt('quiz_wrong_count', _totalQuizWrong);
  }

  int getLearnedCountForDeck(DeckCategory deck) {
    if (!_deckCache.containsKey(deck.id)) {
      // Approximate using category prefix
      return _learnedIds.where((id) => id.startsWith('${deck.id}_')).length;
    }
    return _deckCache[deck.id]!.where((c) => c.status == 'learned').length;
  }

  int getRepeatCountForDeck(DeckCategory deck) {
    if (!_deckCache.containsKey(deck.id)) {
      return _repeatIds.where((id) => id.startsWith('${deck.id}_')).length;
    }
    return _deckCache[deck.id]!.where((c) => c.status == 'repeat').length;
  }
}
