import 'package:flutter/material.dart';

class Flashcard {
  final String id;
  final String frontTitle;
  final String frontSubtitle;
  final String backContent;
  final String hint;
  final String category;
  final String subCategory;
  final String colorName;
  final int importance; // 1: Normal, 2: Önemli, 3: Sınavda Çıkar
  final List<String> options;
  final String correctAnswer;
  String status; // 'new', 'learned', 'repeat'
  bool isFavorite;

  Flashcard({
    required this.id,
    required this.frontTitle,
    this.frontSubtitle = '',
    required this.backContent,
    this.hint = '',
    this.category = 'Genel',
    this.subCategory = 'Genel',
    this.colorName = 'indigo',
    this.importance = 1,
    this.options = const [],
    this.correctAnswer = '',
    this.status = 'new',
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'frontTitle': frontTitle,
        'frontSubtitle': frontSubtitle,
        'backContent': backContent,
        'hint': hint,
        'category': category,
        'subCategory': subCategory,
        'colorName': colorName,
        'importance': importance,
        'options': options,
        'correctAnswer': correctAnswer,
        'status': status,
        'isFavorite': isFavorite,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] ?? '',
        frontTitle: json['frontTitle'] ?? '',
        frontSubtitle: json['frontSubtitle'] ?? '',
        backContent: json['backContent'] ?? '',
        hint: json['hint'] ?? '',
        category: json['category'] ?? 'Genel',
        subCategory: json['subCategory'] ?? 'Genel',
        colorName: json['colorName'] ?? 'indigo',
        importance: json['importance'] ?? 1,
        options: json['options'] != null ? List<String>.from(json['options']) : [],
        correctAnswer: json['correctAnswer'] ?? '',
        status: json['status'] ?? 'new',
        isFavorite: json['isFavorite'] ?? false,
      );
}

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

class DeckCategory {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String assetFile;
  final int totalCount;
  final List<Color> gradient;
  final List<String> subCategories;

  const DeckCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.assetFile,
    required this.totalCount,
    required this.gradient,
    required this.subCategories,
  });
}

final List<DeckCategory> kDeckCategories = [
  DeckCategory(
    id: 'yks',
    title: 'YKS (TYT & AYT)',
    subtitle: 'Matematik, Fizik, Kimya, Biyoloji, Türkçe, Edebiyat',
    icon: '🎓',
    assetFile: 'assets/data/cards_yks.json',
    totalCount: 10000,
    gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    subCategories: ['Matematik & Geometri', 'Fizik', 'Kimya', 'Biyoloji', 'Türkçe & Türk Edebiyatı', 'Tarih, Coğrafya & Felsefe'],
  ),
  DeckCategory(
    id: 'kpss',
    title: 'KPSS (GY & GK)',
    subtitle: 'Tarih, Coğrafya, Vatandaşlık, Güncel Bilgiler, Mantık',
    icon: '🏛️',
    assetFile: 'assets/data/cards_kpss.json',
    totalCount: 8000,
    gradient: [Color(0xFF059669), Color(0xFF10B981)],
    subCategories: ['Tarih', 'Coğrafya', 'Vatandaşlık & Anayasa Hukuku', 'Güncel Bilgiler & Genel Kültür', 'Türkçe & Sözel Mantık'],
  ),
  DeckCategory(
    id: 'software',
    title: 'Yazılım & Teknoloji',
    subtitle: 'Python, JS/TS, Git, Linux, C++, C#, Java, SQL, Algoritma',
    icon: '💻',
    assetFile: 'assets/data/cards_software.json',
    totalCount: 7000,
    gradient: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    subCategories: ['Python', 'JavaScript & TypeScript', 'Git & Versiyon Kontrolü', 'Linux & DevOps', 'C & C++ Sistem Programlama', 'C# & .NET', 'Java & Kotlin', 'SQL & Veritabanı Mimarisi', 'Veri Yapıları & Algoritmalar', 'Web & Sistem Mimarisi'],
  ),
  DeckCategory(
    id: 'english',
    title: 'İngilizce & YDS / TOEFL',
    subtitle: 'A1-C2 Kelimeler, Phrasal Verbs, İdiyomlar, Gramer',
    icon: '🌍',
    assetFile: 'assets/data/cards_english.json',
    totalCount: 5000,
    gradient: [Color(0xFFE11D48), Color(0xFFF43F5E)],
    subCategories: ['A1-A2 Seviye Kelimeler', 'B1-B2 Orta Düzey Kelimeler', 'C1-C2 Akademik Kelimeler', 'Phrasal Verbs (Deyimsel Fiiller)', 'İdiyomlar & Günlük Deyimler', 'Gramer & Bağlaçlar'],
  ),
  DeckCategory(
    id: 'dgs',
    title: 'DGS (Sayısal & Sözel)',
    subtitle: 'Sayısal Mantık, Problemler, Sözel Mantık, Paragraf',
    icon: '📐',
    assetFile: 'assets/data/cards_dgs.json',
    totalCount: 5000,
    gradient: [Color(0xFFD97706), Color(0xFFF59E0B)],
    subCategories: ['Sayısal Mantık & Akıl Yürütme', 'Matematik & Problemler', 'Sözel Bölüm & Paragraf Çözümleme'],
  ),
  DeckCategory(
    id: 'lgs',
    title: 'LGS (8. Sınıf MEB)',
    subtitle: 'Matematik, Fen, Türkçe, İnkılap, Din, İngilizce',
    icon: '🎒',
    assetFile: 'assets/data/cards_lgs.json',
    totalCount: 5000,
    gradient: [Color(0xFF7C3AED), Color(0xFFA855F7)],
    subCategories: ['Matematik', 'Fen Bilimleri', 'Türkçe', 'T.C. İnkılap Tarihi ve Atatürkçülük', 'Din Kültürü ve Ahlak Bilgisi', 'İngilizce'],
  ),
  DeckCategory(
    id: 'general',
    title: 'Genel Kültür & Bilim',
    subtitle: 'Başkentler, Sanat, Dünya Tarihi, Nobel Ödülleri, Uzay',
    icon: '🧠',
    assetFile: 'assets/data/cards_general.json',
    totalCount: 2000,
    gradient: [Color(0xFF0D9488), Color(0xFF14B8A6)],
    subCategories: ['Dünya Başkentleri & Coğrafya', 'Dünya Tarihi & Medeniyetler', 'Sanat & Dünya Klasikleri', 'Bilim Dünyası & Keşifler', 'Uzay, Astronomi & Coğrafya Harikaları'],
  ),
];
