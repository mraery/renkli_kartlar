import json
import random
import os

os.makedirs('assets/data', exist_ok=True)

COLORS = ['indigo', 'emerald', 'amber', 'rose', 'violet', 'cyan', 'teal', 'obsidian']

def make_card(cid, title, subtitle, back, hint, category, subcat, color, importance, answer, distractors):
    clean_distractors = [d for d in distractors if d != answer]
    opts = [answer] + clean_distractors[:3]
    while len(opts) < 4:
        opts.append(f"Seçenek {len(opts)+1}")
    random.shuffle(opts)
    return {
        "id": cid,
        "frontTitle": title,
        "frontSubtitle": subtitle,
        "backContent": back,
        "hint": hint,
        "category": category,
        "subCategory": subcat,
        "colorName": color,
        "importance": importance,
        "options": opts,
        "correctAnswer": answer
    }

cards = []

# 1. Sayısal Mantık & Akıl Yürütme (1500)
say_man_topics = [
    ("Sayı Dizileri & Örüntüler", "2, 6, 12, 20, 30, ? dizisinde soru işareti yerine ne gelmelidir?", "Dizi farkları: +4, +6, +8, +10... Sıradaki fark +12 olmalıdır.\n30 + 12 = 42\n(Ayrıca n·(n+1) kuralıdır: 1x2, 2x3, 3x4, 4x5, 5x6, 6x7 = 42).", "n · (n+1) kuralı", "42", ["40", "44", "46"]),
    ("Saat ve Açı Problemleri", "Saat 03:00'te akrep ile yelkovan arasındaki küçük açı kaç derecedir?", "360° / 12 saat = her saat aralığı 30°'dir. 3 saat fark = 3 x 30° = 90° (dik açı).", "3 x 30° = 90°", "90°", ["60°", "75°", "120°"]),
    ("Küp Açılımı & Yüzler", "Standart bir zarın karşılıklı yüzlerindeki noktaların toplamı daima kaçtır?", "Standart zarlarda karşılıklı yüzlerin toplamı daima 7'dir (1-6, 2-5, 3-4).", "Toplam 7", "7", ["6", "8", "9"])
]

for i in range(1500):
    base = say_man_topics[i % len(say_man_topics)]
    variant = (i // len(say_man_topics)) + 1
    cid = f"dgs_man_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: DGS-MAN-{i+1}"
    hint = base[3]
    color = COLORS[i % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "DGS", "Sayısal Mantık & Akıl Yürütme", color, imp, ans, dis))

print(f"Total cards after DGS Mantık: {len(cards)}")

# 2. Matematik & Problemler (2000)
prob_topics = [
    ("Hız & Hareket Problemleri", "Birbirine doğru gelen iki aracın karşılaşma süresi formülü nedir?", "Aralarındaki Mesafe (x) = (V₁ + V₂) · t_karşılaşma\nt = x / (V₁ + V₂)\n(Aynı yönde gitselerdi hızlar farkı alınırdı).", "t = Yol / Hızlar Toplamı", "t = x / (V₁ + V₂)", ["t = x / (V₁ - V₂)", "t = x · (V₁ + V₂)", "t = (V₁ + V₂) / x"]),
    ("İşçi Problemleri Formülü", "Bir işi A işçisi a saatte, B işçisi b saatte yapıyorsa birlikte çalışma formülü nedir?", "1/a + 1/b = 1/t\nBirlikte geçen sürede yapılan toplam iş = 1 tam.", "1/a + 1/b = 1/t", "1/a + 1/b = 1/t", ["a + b = t", "a · b = t", "t = (a + b) / 2"]),
    ("Yüzde, Kâr & Zarar", "Maliyeti 100 TL olan bir mala %20 kâr eklenip, satış fiyatı üzerinden %20 indirim yapılırsa sonuç ne olur?", "Satış = 100 x 1.20 = 120 TL.\nİndirim = 120 x 0.20 = 24 TL.\nSon Fiyat = 120 - 24 = 96 TL (%4 zarar edilir).", "%4 zarar", "%4 zarar edilir (96 TL)", ["Başabaş (100 TL)", "%4 kâr edilir", "%2 zarar edilir"]),
    ("Yaş Problemleri Mantığı", "İki kişi arasındaki yaş farkı zaman geçtikçe nasıl değişir?", "Yaş farkı asla değişmez; yıllar geçtikçe herkes eşit miktarda yaşlanır.", "Yaş farkı sabittir", "Yaş farkı daima sabit kalır", ["Yıllar geçtikçe fark azalır", "Yıllar geçtikçe fark ikiye katlanır", "Kişilerin hızına göre değişir"])
]

for i in range(2000):
    base = prob_topics[i % len(prob_topics)]
    variant = (i // len(prob_topics)) + 1
    cid = f"dgs_prb_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: DGS-PRB-{i+1}"
    hint = base[3]
    color = COLORS[(i+1) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "DGS", "Matematik & Problemler", color, imp, ans, dis))

print(f"Total cards after DGS Problemler: {len(cards)}")

# 3. Sözel Bölüm & Paragraf (1500)
par_topics = [
    ("Paragrafta Ana Düşünce", "Paragrafta ana düşünceyi (ana fikir) tespit etmenin en güvenilir yolu nedir?", "Yazarın bu parçayı yazmaktaki temel amacını ve bize iletmek istediği asıl mesajı aramaktır. Genellikle 'kısacası, özetle, asıl mesele, oysa' gibi bağlayıcı sözlerden sonra veya parçanın sonuç cümlesinde vurgulanır.", "Asıl iletilmek istenen mesaj", "Yazarın okuyucuya aktarmak istediği temel mesaj", ["Parçadaki en uzun cümle", "İlk kelimenin sözlük anlamı", "Yalnızca sayısal veriler"]),
    ("Akışı Bozan Cümle", "Bir paragrafta anlatımın akışını bozan cümleyi nasıl tespit ederiz?", "Parçanın genel konusundan, bakış açısından sapan veya bir önceki ve bir sonraki cümlenin anlamsal köprüsünü kıran cümledir.", "Farklı konuya veya boyuta kayan cümle", "Konunun dışına çıkan veya köprüyü bozan cümle", ["En kısa cümle", "İçinde fiilimsi olmayan cümle", "Soru içeren cümle"])
]

for i in range(1500):
    base = par_topics[i % len(par_topics)]
    variant = (i // len(par_topics)) + 1
    cid = f"dgs_par_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: DGS-PAR-{i+1}"
    hint = base[3]
    color = COLORS[(i+2) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "DGS", "Sözel Bölüm & Paragraf Çözümleme", color, imp, ans, dis))

print(f"Final DGS cards count: {len(cards)}")

with open('assets/data/cards_dgs.json', 'w', encoding='utf-8') as f:
    json.dump(cards, f, ensure_ascii=False, indent=2)

print("Saved assets/data/cards_dgs.json successfully.")
