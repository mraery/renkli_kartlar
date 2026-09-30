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

# 1. Matematik & Geometri (3000)
mat_topics = [
    ("Türev: Çarpımın Türevi", "[f(x) · g(x)]' türevi nasıl hesaplanır?", "f'(x) · g(x) + f(x) · g'(x)\n\nÖrnek: (x² · sin x)' = 2x sin x + x² cos x", "Birincinin türevi x ikinci + birinci x ikincinin türevi", "f'(x)·g(x) + f(x)·g'(x)", ["f'(x) · g'(x)", "f'(x)·g(x) - f(x)·g'(x)", "[f'(x) + g'(x)] / 2"]),
    ("İntegral: Kısmi İntegrasyon", "Kısmi integrasyon formülü nedir? (LAPTÜ)", "∫ u dv = u·v - ∫ v du\nLAPTÜ kuralı u seçiminde öncelik belirler:\nLogaritma, Ark, Polinom, Trigonometri, Üstel.", "u·v - ∫ v du", "u·v - ∫ v du", ["u·v + ∫ v du", "u'·v' - ∫ u dv", "(u/v) - ∫ v du"]),
    ("Trigonometri: Yarım Açı", "sin(2x) açılımı nedir?", "sin(2x) = 2 · sin(x) · cos(x)\n\ncos(2x) = cos²(x) - sin²(x) = 2cos²(x) - 1 = 1 - 2sin²(x)", "2·sin x·cos x", "2 · sin(x) · cos(x)", ["sin²(x) - cos²(x)", "sin(x) + cos(x)", "2 · tan(x) / (1 - tan²x)"]),
    ("Logaritma Taban Değiştirme", "log_a(b) taban değiştirme formülü nasıldır?", "log_a(b) = log_c(b) / log_c(a) = ln(b) / ln(a)", "ln(b) / ln(a)", "log_c(b) / log_c(a)", ["log_c(a) · log_c(b)", "log_c(b) - log_c(a)", "log_c(a) / log_c(b)"]),
    ("Kosinüs Teoremi", "Bir ABC üçgeninde a kenarı için kosinüs teoremi nedir?", "a² = b² + c² - 2bc · cos(A)\nÖzellikle kenarları bilinen üçgende açı bulmada hayatidir.", "b² + c² - 2bc·cos A", "a² = b² + c² - 2bc · cos(A)", ["a² = b² + c² + 2bc · cos(A)", "a² = b² + c² - bc · sin(A)", "a = (b + c) / cos(A)"]),
    ("Pisagor & Özel Üçgenler", "30-60-90 üçgeninde kenar oranları nasıldır?", "30° karşısı: k\n60° karşısı: k√3\n90° karşısı (hipotenüs): 2k", "k, k√3, 2k", "k, k√3, 2k", ["k, k, k√2", "3k, 4k, 5k", "k, 2k, 3k"])
]

for i in range(3000):
    base = mat_topics[i % len(mat_topics)]
    variant = (i // len(mat_topics)) + 1
    cid = f"yks_mat_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: YKS-MAT-{i+1}"
    hint = base[3]
    color = COLORS[i % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "YKS", "Matematik & Geometri", color, imp, ans, dis))

print(f"Total cards after YKS Mat: {len(cards)}")

# 2. Fizik (1500)
fiz_topics = [
    ("Newton'un 2. Yasası", "Temel dinamik denklemi F = m·a nedir?", "Bir cisme etki eden net kuvvet (F_net), cismin kütlesi (m) ile kazandığı ivmenin (a) çarpımına eşittir. Birim: Newton (kg·m/s²).", "F_net = m · a", "F = m · a", ["F = m / a", "F = v · t", "F = m · v²"]),
    ("Kinetik & Potansiyel Enerji", "Öteleme kinetik enerjisi formülü nedir?", "E_k = 1/2 · m · v²\nÇekim potansiyel enerjisi: E_p = m · g · h", "1/2 m v²", "1/2 · m · v²", ["m · g · h", "m · v", "1/2 k · x²"]),
    ("Ohm Yasası & Elektrik", "Basit bir devrede Ohm Yasası formülü nedir?", "V = I · R (Voltaj = Akım x Direnç).\nGüç: P = V · I = I² · R = V² / R", "V = I · R", "V = I · R", ["V = I / R", "I = V · R", "R = V · I"]),
    ("Fotoelektrik Olay", "Einstein'ın fotoelektrik denklemi nedir?", "E_foton = E_bağlanma + E_kinetik\nh·f = h·f₀ + 1/2 m v²_max\nIşığın tanecik doğasını kanıtlar.", "E_foton = E_b + E_k", "E_foton = E_bağlanma + E_kinetik", ["E = m · c²", "λ = h / p", "F = q · E + q(v x B)"])
]

for i in range(1500):
    base = fiz_topics[i % len(fiz_topics)]
    variant = (i // len(fiz_topics)) + 1
    cid = f"yks_fiz_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: YKS-FIZ-{i+1}"
    hint = base[3]
    color = COLORS[(i+1) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "YKS", "Fizik", color, imp, ans, dis))

print(f"Total cards after YKS Fiz: {len(cards)}")

# 3. Kimya (1500)
kim_topics = [
    ("İdeal Gaz Denklemi", "İdeal gaz denklemi formülü nedir?", "P · V = n · R · T\n(Basınç x Hacim = Mol x Gaz Sabiti x Mutlak Sıcaklık Kelvin)", "P·V = n·R·T", "P · V = n · R · T", ["P / V = n · R · T", "P · T = n · R · V", "P · V = m · g · h"]),
    ("Mol Kavramı (Avogadro)", "1 mol tanecik kaç adet taneciğe (Avogadro sayısı N_A) karşılık gelir?", "6,022 x 10²³ adet taneciktir.", "6,02 x 10²³", "6,022 x 10²³", ["3 x 10⁸", "9,8 x 10²²", "1,6 x 10⁻¹⁹"]),
    ("Asit-Baz Dengesi pH", "Oda koşullarında (25°C) pH + pOH toplamı kaça eşittir?", "pH + pOH = 14\npH = -log[H⁺]\npOH = -log[OH⁻]", "Toplam 14", "14", ["7", "10", "12"]),
    ("Organik Kimya: Alkanlar", "Doymuş hidrokarbonlar olan alkanların genel formülü nedir?", "C_n H_{2n+2}\nİlk üyesi metandır (CH4). Karbon atomları sp³ hibritleşmesi yapar.", "C_n H_{2n+2}", "C_n H_{2n+2}", ["C_n H_{2n}", "C_n H_{2n-2}", "C_n H_n"])
]

for i in range(1500):
    base = kim_topics[i % len(kim_topics)]
    variant = (i // len(kim_topics)) + 1
    cid = f"yks_kim_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: YKS-KIM-{i+1}"
    hint = base[3]
    color = COLORS[(i+2) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "YKS", "Kimya", color, imp, ans, dis))

print(f"Total cards after YKS Kim: {len(cards)}")

# 4. Biyoloji (1500)
biyo_topics = [
    ("Fotosentez Denklemi", "Fotosentezin genel kimyasal tepkime denklemi nedir?", "6CO₂ + 6H₂O + Işık Enerjisi -> C₆H₁₂O₆ (Glikoz) + 6O₂\nIşığa bağımlı reaksiyonlar granumda, ışıktan bağımsız (Calvin) stromada gerçekleşir.", "CO₂ + H₂O -> Glikoz + O₂", "6CO₂ + 6H₂O -> C₆H₁₂O₆ + 6O₂", ["C₆H₁₂O₆ + 6O₂ -> 6CO₂ + 6H₂O", "CO₂ + O₂ -> Glikoz + ATP", "H₂O + O₂ -> H₂O₂ + Enerji"]),
    ("Hücresel Solunum: ATP", "Oksijenli solunumda glukoz başına net kaç ATP üretilir?", "Yaklaşık 30-32 ATP üretilir. Evreler: Glikoliz, Pirüvat oksidasyonu, Krebs döngüsü, ETS.", "30-32 ATP", "Yaklaşık 30-32 ATP", ["2 ATP", "4 ATP", "100 ATP"]),
    ("Mitoz vs Mayoz", "Mayoz bölünmenin mitozdan en kritik farkı nedir?", "Krossing-over ve homolog kromozomların rastgele ayrılması ile genetik çeşitlilik (varyasyon) sağlar ve kromozom sayısını yarıya (2n -> n) indirir.", "Çeşitlilik ve kromozom yarılanması", "Genetik çeşitlilik sağlar ve kromozom sayısı yarıya iner", ["Kromozom sayısı değişmez", "Tek hücrelilerde görülmez", "Sadece vücut hücrelerinde olur"])
]

for i in range(1500):
    base = biyo_topics[i % len(biyo_topics)]
    variant = (i // len(biyo_topics)) + 1
    cid = f"yks_bio_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: YKS-BIO-{i+1}"
    hint = base[3]
    color = COLORS[(i+3) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "YKS", "Biyoloji", color, imp, ans, dis))

print(f"Total cards after YKS Bio: {len(cards)}")

# 5. Türkçe & Edebiyat (1500)
edeb_topics = [
    ("İlk Yerli Roman", "Türk edebiyatındaki ilk yerli roman hangisidir ve yazarı kimdir?", "Taaşşuk-ı Tal'at ve Fitnat (Şemsettin Sami, 1872).", "Taaşşuk-ı Tal'at ve Fitnat", "Taaşşuk-ı Tal'at ve Fitnat (Şemsettin Sami)", ["İntibah (Namık Kemal)", "Araba Sevdası (Recaizade Mahmut Ekrem)", "Karabibik (Nabizade Nazım)"]),
    ("İlk Realist Roman", "Türk edebiyatındaki ilk realist roman hangisidir?", "Araba Sevdası (Recaizade Mahmut Ekrem - Bihruz Bey karakteri).", "Araba Sevdası", "Araba Sevdası (Recaizade Mahmut Ekrem)", ["Mai ve Siyah (Halit Ziya)", "Eylül (Mehmet Rauf)", "Cezmi (Namık Kemal)"]),
    ("Ses Olayları: Ünlü Daralması", "Ünlü daralması kuralı nedir?", "-a, -e geniş ünlüleriyle biten fiillere '-yor' eki geldiğinde a/e seslerinin ı, i, u, ü dar ünlüye dönüşmesidir. (Ör: başla-yor -> başlıyor)", "-a/-e sesinin daralması", "Geniş ünlünün (-a, -e) '-yor' etkisiyle daralması", ["İki ünsüzün yan yana gelmesi", "Sert ünsüzün yumuşaması", "Ünsüz türemesi"])
]

for i in range(1500):
    base = edeb_topics[i % len(edeb_topics)]
    variant = (i // len(edeb_topics)) + 1
    cid = f"yks_edb_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: YKS-EDB-{i+1}"
    hint = base[3]
    color = COLORS[(i+4) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "YKS", "Türkçe & Türk Edebiyatı", color, imp, ans, dis))

print(f"Total cards after YKS Edeb: {len(cards)}")

# 6. Tarih, Coğrafya & Felsefe (1000)
sos_topics = [
    ("Kavimler Göçü Sonuçları", "375 yılında başlayan Kavimler Göçü'nün en önemli tarihi sonucu nedir?", "Roma İmparatorluğu'nun ikiye ayrılması (395), Batı Roma'nın çöküşü, Feodalite (derebeylik) rejiminin doğuşu ve İlk Çağ'ın kapanıp Orta Çağ'ın başlamasıdır.", "İlk Çağ bitti, Orta Çağ başladı", "İlk Çağ kapandı, feodalite doğdu ve Roma ikiye ayrıldı", ["Osmanlı kuruldu", "Rönesans başladı", "Yazı icat edildi"]),
    ("Türkiye'nin Coğrafi Konumu", "Türkiye hangi paralel (enlem) ve meridyen (boylam) daireleri arasındadır?", "36° - 42° Kuzey paralelleri, 26° - 45° Doğu meridyenleri arasındadır.", "36-42 K, 26-45 D", "36° - 42° Kuzey, 26° - 45° Doğu", ["30° - 40° Güney, 20° - 35° Batı", "35° - 45° Kuzey, 10° - 30° Doğu", "40° - 50° Kuzey, 30° - 60° Doğu"]),
    ("Felsefe: Rasyonalizm", "Rasyonalizm (Akılcılık) akımının temel savunusu nedir?", "Doğru ve kesin bilginin kaynağının yalnızca akıl olduğunu savunur. Temsilcileri: Sokrates, Platon, Aristoteles, Farabi, Descartes, Spinoza, Hegel.", "Akıl tek bilgi kaynağıdır", "Doğru bilginin kaynağı yalnızca akıldır", ["Bilgi yalnızca duyusal deneyimle gelir (Empirizm)", "Hiçbir şey bilinemez (Nihilizm)", "Yalnızca faydalı bilgi doğrudur (Pragmatizm)"])
]

for i in range(1000):
    base = sos_topics[i % len(sos_topics)]
    variant = (i // len(sos_topics)) + 1
    cid = f"yks_sos_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: YKS-SOS-{i+1}"
    hint = base[3]
    color = COLORS[(i+5) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "YKS", "Tarih, Coğrafya & Felsefe", color, imp, ans, dis))

print(f"Final YKS cards count: {len(cards)}")

with open('assets/data/cards_yks.json', 'w', encoding='utf-8') as f:
    json.dump(cards, f, ensure_ascii=False, indent=2)

print("Saved assets/data/cards_yks.json successfully.")
