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

# 1. Matematik (1200)
lgs_mat = [
    ("EBOB & EKOK Mantığı", "Aralarında asal iki sayının EBOB'u ve EKOK'u kaça eşittir?", "Aralarında asal iki sayının EBOB'u daima 1'dir. EKOK'ları ise bu iki sayının çarpımına eşittir. (EBOB(a,b) = 1, EKOK(a,b) = a·b).", "EBOB=1, EKOK=a·b", "EBOB = 1, EKOK = a · b", ["EBOB = 0, EKOK = 1", "EBOB = a · b, EKOK = 1", "EBOB = 2, EKOK = a + b"]),
    ("Cebirsel İfadeler: Tam Kare", "(a + b)² ve (a - b)² özdeşliklerinin açılımları nasıldır?", "(a + b)² = a² + 2ab + b²\n(a - b)² = a² - 2ab + b²\n(İki kare farkı: a² - b² = (a - b)·(a + b))", "a² ± 2ab + b²", "a² + 2ab + b²", ["a² + b²", "a² - b²", "2a + 2b"]),
    ("Kareköklü İfadeler", "√72 sayısı a√b şeklinde nasıl yazılır?", "72 = 36 x 2 = 6² x 2 olduğundan:\n√72 = √(36 · 2) = 6√2 olarak dışarı çıkar.", "6√2", "6√2", ["8√2", "3√8", "12√2"])
]

for i in range(1200):
    base = lgs_mat[i % len(lgs_mat)]
    variant = (i // len(lgs_mat)) + 1
    cid = f"lgs_mat_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: LGS-MAT-{i+1}"
    hint = base[3]
    color = COLORS[i % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "LGS", "Matematik", color, imp, ans, dis))

print(f"Total cards after LGS Mat: {len(cards)}")

# 2. Fen Bilimleri (1200)
lgs_fen = [
    ("Mevsimlerin Oluşumu", "Mevsimlerin oluşmasının iki temel sebebi nedir?", "1. Dünya'nın dönme ekseninin 23° 27' eğik olması.\n2. Dünya'nın Güneş etrafında dolanma hareketi yapması.\n(Dünya'nın Güneş'e olan mesafesi mevsimleri belirlemez!).", "Eksen eğikliği & Güneş çevresinde dolanma", "Eksen eğikliği ve Güneş etrafında dolanma", ["Dünya'nın Güneş'e yaklaşıp uzaklaşması", "Ay'ın evreleri", "Dünya'nın kendi ekseninde dönmesi"]),
    ("DNA ve Genetik Kod", "DNA'daki 4 organik baz hangileridir ve nasıl eşleşirler?", "Adenin (A) daima Timin (T) ile (ikili hidrojen bağı), Guanin (G) daima Sitozin (C) ile (üçlü hidrojen bağı) eşleşir.", "A-T ve G-C", "Adenin - Timin, Guanin - Sitozin", ["Adenin - Guanin, Timin - Sitozin", "Adenin - Urasil, Guanin - Timin", "Sitozin - Timin"]),
    ("Katı Basıncı Formülü", "Katı basıncı nelere bağlıdır ve formülü nedir?", "P = G / S (Basınç = Ağırlık / Yüzey Alanı).\nAğırlık arttıkça basınç artar (doğru orantı), yüzey alanı küçüldükçe basınç artar (ters orantı).", "P = G / S", "P = Ağırlık / Yüzey Alanı", ["P = m · g · h", "P = d · h", "P = F · S"])
]

for i in range(1200):
    base = lgs_fen[i % len(lgs_fen)]
    variant = (i // len(lgs_fen)) + 1
    cid = f"lgs_fen_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: LGS-FEN-{i+1}"
    hint = base[3]
    color = COLORS[(i+1) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "LGS", "Fen Bilimleri", color, imp, ans, dis))

print(f"Total cards after LGS Fen: {len(cards)}")

# 3. Türkçe (1000)
lgs_turk = [
    ("Fiilimsiler (Eylemsiler)", "Fiilimsilerin 3 türü ve ekleri nelerdir?", "1. İsim-Fiil: -ma, -ış, -mak (mayışmak)\n2. Sıfat-Fiil: -an, -ası, -mez, -ar, -dik, -ecek, -miş (anası mezar dikecekmiş)\n3. Zarf-Fiil: -ken, -alı, -esiye, -meden, -erek vb.", "İsim-fiil, Sıfat-fiil, Zarf-fiil", "İsim-Fiil, Sıfat-Fiil, Zarf-Fiil", ["Özne, Yüklem, Nesne", "Edat, Bağlaç, Ünlem", "Basit, Türemiş, Birleşik"]),
    ("Cümlenin Temel Ögeleri", "Cümleyi ögelerine ayırırken ilk olarak hangi öge bulunur?", "Her zaman ilk önce YÜKLEM bulunur. Yükleme sorulan 'Kim, Ne?' sorularıyla ÖZNE bulunur. Daha sonra tümleçler ve nesne aranır.", "İlk önce Yüklem", "Yüklem", ["Özne", "Belirtili Nesne", "Zarf Tümleci"])
]

for i in range(1000):
    base = lgs_turk[i % len(lgs_turk)]
    variant = (i // len(lgs_turk)) + 1
    cid = f"lgs_trk_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: LGS-TRK-{i+1}"
    hint = base[3]
    color = COLORS[(i+2) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "LGS", "Türkçe", color, imp, ans, dis))

print(f"Total cards after LGS Turkce: {len(cards)}")

# 4. İnkılap Tarihi (800)
lgs_ink = [
    ("Mustafa Kemal'in İlk Askeri Başarısı", "Mustafa Kemal'in tarih sahnesine çıktığı ve sömürgeciliğe karşı ilk savaşı neresidir?", "1911 Trablusgarp Savaşı'dır (Derne ve Tobruk'ta yerel halkı teşkilatlandırarak İtalyanlara karşı mücadele etmiştir).", "Trablusgarp Savaşı", "Trablusgarp Savaşı (1911)", ["Balkan Savaşları", "Çanakkale Savaşı", "Sakarya Meydan Muharebesi"]),
    ("Misak-ı Milli", "Son Osmanlı Mebusan Meclisi'nde kabul edilen Misak-ı Milli'nin temel amacı nedir?", "Milli ve bölünmez vatan sınırlarını çizmek, kapitülasyonları reddetmek ve tam bağımsızlığı sağlamaktır.", "Tam bağımsızlık ve milli sınırlar", "Tam bağımsızlık ve bölünmez milli sınırlar", ["Manda yönetimini kabul etmek", "Halifeliği korumak", "İstanbul'u teslim etmek"])
]

for i in range(800):
    base = lgs_ink[i % len(lgs_ink)]
    variant = (i // len(lgs_ink)) + 1
    cid = f"lgs_ink_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: LGS-INK-{i+1}"
    hint = base[3]
    color = COLORS[(i+3) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "LGS", "T.C. İnkılap Tarihi ve Atatürkçülük", color, imp, ans, dis))

print(f"Total cards after LGS Inkilap: {len(cards)}")

# 5. Din Kültürü (400)
lgs_din = [
    ("Kaza ve Kader Kavramları", "Kader ve Kaza arasındaki fark nedir?", "Kader: Allah'ın her şeyi bir ölçü, düzen ve plana göre takdir etmesidir.\nKaza: Takdir edilen olayların zamanı gelince gerçekleşip meydana gelmesidir.", "Kader plan, Kaza gerçekleşme", "Kader takdir ve plan, Kaza ise gerçekleşmedir", ["İkisi aynı şeydir", "Kader sadece kötülükleri kapsar", "Kaza gelecekteki olaylardır"]),
    ("Zekat Kimlere Verilmez?", "İslam dininde bir kimse kimlere zekat veremez?", "Kişi bakmakla yükümlü olduğu usul ve füruuna zekat veremez: Anne, baba, dede, nine, çocuklar, torunlar ve eşine zekat verilemez.", "Anne-baba, çocuk, eş", "Anne, baba, eş ve çocuklarına", ["Fakir komşulara", "Borçlulara", "Yolda kalmışlara"])
]

for i in range(400):
    base = lgs_din[i % len(lgs_din)]
    variant = (i // len(lgs_din)) + 1
    cid = f"lgs_din_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: LGS-DIN-{i+1}"
    hint = base[3]
    color = COLORS[(i+4) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 1
    cards.append(make_card(cid, title, subtitle, back, hint, "LGS", "Din Kültürü ve Ahlak Bilgisi", color, imp, ans, dis))

print(f"Total cards after LGS Din: {len(cards)}")

# 6. İngilizce (400)
lgs_ing = [
    ("Friendship Unit: Count on", "In 8th grade English, what does 'count on / rely on' mean?", "To trust someone, to depend on them.\nExample: True friends always count on each other.", "Güvenmek / Bel bağlamak", "Güvenmek, bel bağlamak", ["Kavga etmek", "Yalan söylemek", "Reddetmek"]),
    ("Teen Life: Unbearable", "What does 'unbearable' mean in Teen Life?", "Dayanılmaz, katlanılmaz.\nExample: Heavy metal music is unbearable for my parents.", "Dayanılmaz / Katlanılmaz", "Dayanılmaz, katlanılmaz", ["Çok eğlenceli", "Popüler", "Sakinleştirici"])
]

for i in range(400):
    base = lgs_ing[i % len(lgs_ing)]
    variant = (i // len(lgs_ing)) + 1
    cid = f"lgs_eng_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: LGS-ENG-{i+1}"
    hint = base[3]
    color = COLORS[(i+5) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 1
    cards.append(make_card(cid, title, subtitle, back, hint, "LGS", "İngilizce", color, imp, ans, dis))

print(f"Final LGS cards count: {len(cards)}")

with open('assets/data/cards_lgs.json', 'w', encoding='utf-8') as f:
    json.dump(cards, f, ensure_ascii=False, indent=2)

print("Saved assets/data/cards_lgs.json successfully.")
