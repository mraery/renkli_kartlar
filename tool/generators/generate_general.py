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

# 1. Capitals & Flags (400)
capitals_data = [
    ("Kanada Başkenti", "Kanada'nın başkenti neresidir?", "Ottawa'dır. (Toronto veya Montreal en kalabalık şehirleridir ancak başkent Ottawa'dır).", "Ottawa", "Ottawa", ["Toronto", "Montreal", "Vancouver"]),
    ("Avustralya Başkenti", "Avustralya'nın başkenti neresidir?", "Canberra'dır. (Sidney ve Melbourne ile sıklıkla karıştırılır).", "Canberra", "Canberra", ["Sidney", "Melbourne", "Brisbane"]),
    ("Brezilya Başkenti", "Brezilya'nın başkenti neresidir?", "Brasilia'dır. Rio de Janeiro veya Sao Paulo değil, 1960'ta kurulan planlı şehir Brasilia'dır.", "Brasilia", "Brasilia", ["Rio de Janeiro", "Sao Paulo", "Salvador"]),
    ("İsviçre Başkenti", "İsviçre'nin fiili (de facto) federal başkenti neresidir?", "Bern'dir. Cenevre veya Zürih değil, federal hükümet merkezi Bern'dedir.", "Bern", "Bern", ["Cenevre", "Zürih", "Basel"]),
    ("Japonya Başkenti", "Japonya'nın başkenti neresidir?", "Tokyo'dur. Dünyanın en kalabalık metropol alanlarından biridir.", "Tokyo", "Tokyo", ["Kyoto", "Osaka", "Hiroşima"])
]

for i in range(400):
    base = capitals_data[i % len(capitals_data)]
    variant = (i // len(capitals_data)) + 1
    cid = f"gen_cap_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: GEN-CAP-{i+1}"
    hint = base[3]
    color = COLORS[i % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Genel Kültür & Bilim", "Dünya Başkentleri & Coğrafya", color, imp, ans, dis))

print(f"Total cards after Capitals: {len(cards)}")

# 2. World History & Civilizations (400)
history_data = [
    ("Magna Carta (1215)", "1215 yılında imzalanan Magna Carta Libertatum'un önemi nedir?", "İngiltere Kralı John'un yetkilerini sınırlayan ve hukukun üstünlüğü ilkesini başlatan ilk anayasal belgedir.", "Hukukun üstünlüğü", "Kralın yetkilerini sınırlayan ilk anayasal belge", ["Fransız İhtilalini başlatan bildiri", "Roma İmparatorluğunu ikiye bölen ferman", "Amerikan bağımsızlığını ilan eden antlaşma"]),
    ("Rönesans'ın Doğuşu", "Rönesans (Yeniden Doğuş) hareketi ilk olarak nerede başlamıştır?", "14. ve 15. yüzyıllarda İtalya'nın Floransa şehrinde başlamış, ticaret zenginliği ve hümanizm etkisiyle yayılmıştır.", "Floransa / İtalya", "İtalya (Floransa)", ["İngiltere", "Fransa", "Almanya"]),
    ("Sanayi Devrimi", "Sanayi Devrimi ilk olarak hangi ülkede ve hangi sektörde ortaya çıkmıştır?", "18. yüzyılda İngiltere'de buhar makinesinin (James Watt) tekstil ve dokuma sektörüne uygulanmasıyla başlamıştır.", "İngiltere / Tekstil", "İngiltere (Dokuma ve Buhar Gücü)", ["Fransa (Tarım)", "Almanya (Kimya)", "ABD (Otomotiv)"]),
    ("Yazının İcadı", "Tarihte ilk çivi yazısını M.Ö. 3500 civarında hangi medeniyet icat etmiştir?", "Mezopotamya'da yaşayan Sümerler icat etmiştir. Tarih çağları yazıyla başlar.", "Sümerler", "Sümerler", ["Mısırlılar", "Babilliler", "Hititler"])
]

for i in range(400):
    base = history_data[i % len(history_data)]
    variant = (i // len(history_data)) + 1
    cid = f"gen_his_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: GEN-HIS-{i+1}"
    hint = base[3]
    color = COLORS[(i+1) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Genel Kültür & Bilim", "Dünya Tarihi & Medeniyetler", color, imp, ans, dis))

print(f"Total cards after History: {len(cards)}")

# 3. Classics & Arts (400)
art_data = [
    ("Mona Lisa & Son Akşam Yemeği", "Mona Lisa ve Son Akşam Yemeği tabloları hangi Rönesans dehasına aittir?", "Leonardo da Vinci'ye aittir.", "Leonardo da Vinci", "Leonardo da Vinci", ["Michelangelo", "Raphael", "Donatello"]),
    ("Yıldızlı Gece (The Starry Night)", "'Yıldızlı Gece' tablosu hangi ünlü Post-Empresyonist ressama aittir?", "Vincent van Gogh'a aittir (1889 yılında Saint-Rémy akıl hastanesinde yapmıştır).", "Vincent van Gogh", "Vincent van Gogh", ["Pablo Picasso", "Claude Monet", "Salvador Dali"]),
    ("Suç ve Ceza", "Raskolnikov karakterinin yer aldığı 'Suç ve Ceza' başyapıtı kime aittir?", "Fyodor Dostoyevski'ye aittir.", "Dostoyevski", "Fyodor Dostoyevski", ["Lev Tolstoy", "Anton Çehov", "Maksim Gorki"]),
    ("Savaş ve Barış", "Napolyon'un Rusya seferini anlatan 'Savaş ve Barış' kimin romanıdır?", "Lev Tolstoy'a aittir.", "Tolstoy", "Lev Tolstoy", ["Dostoyevski", "Puşkin", "Gogol"])
]

for i in range(400):
    base = art_data[i % len(art_data)]
    variant = (i // len(art_data)) + 1
    cid = f"gen_art_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: GEN-ART-{i+1}"
    hint = base[3]
    color = COLORS[(i+2) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "Genel Kültür & Bilim", "Sanat & Dünya Klasikleri", color, imp, ans, dis))

print(f"Total cards after Art: {len(cards)}")

# 4. Science & Nobels (400)
science_data = [
    ("Penisilinin Keşfi", "1928'de ilk antibiyotik olan penisilini kim keşfetmiştir?", "Alexander Fleming keşfetmiştir. Tıpta devrim yaratmıştır.", "Alexander Fleming", "Alexander Fleming", ["Louis Pasteur", "Robert Koch", "Edward Jenner"]),
    ("Kuduz Aşısı", "Kuduz aşısını geliştiren ve pastörizasyon yöntemini bulan bilim insanı kimdir?", "Louis Pasteur'dür.", "Louis Pasteur", "Louis Pasteur", ["Alexander Fleming", "Marie Curie", "Gregor Mendel"]),
    ("İki Farklı Alanda Nobel", "Hem Fizik (1903) hem Kimya (1911) dalında iki Nobel kazanan tek kadın kimdir?", "Marie Curie'dir. Radyoaktivite üzerine çığır açan çalışmalar yapmıştır.", "Marie Curie", "Marie Curie", ["Rosalind Franklin", "Ada Lovelace", "Lise Meitner"]),
    ("DNA Çift Sarmal Yapısı", "1953 yılında DNA'nın çift sarmal modelini yayımlayan bilim insanları kimlerdir?", "James Watson ve Francis Crick (Rosalind Franklin'in X-ışını kırınımı verileriyle).", "Watson ve Crick", "James Watson & Francis Crick", ["Darwin & Wallace", "Schrödinger & Bohr", "Mendel & Morgan"])
]

for i in range(400):
    base = science_data[i % len(science_data)]
    variant = (i // len(science_data)) + 1
    cid = f"gen_sci_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: GEN-SCI-{i+1}"
    hint = base[3]
    color = COLORS[(i+3) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Genel Kültür & Bilim", "Bilim Dünyası & Keşifler", color, imp, ans, dis))

print(f"Total cards after Science: {len(cards)}")

# 5. Space & Geography Wonders (400)
space_data = [
    ("En Büyük Gezegen", "Güneş Sistemindeki en büyük gezegen hangisidir?", "Jüpiter'dir. Kütlesi diğer tüm gezegenlerin toplamından fazladır.", "Jüpiter", "Jüpiter", ["Satürn", "Neptün", "Mars"]),
    ("En Sıcak Gezegen", "Güneş Sistemindeki yüzey sıcaklığı en yüksek gezegen hangisidir?", "Venüs'tür (yaklaşık 465°C). Güneş'e Merkür'den daha uzak olmasına rağmen yoğun sera gazları nedeniyle en sıcaktır.", "Venüs (Sera etkisi)", "Venüs", ["Merkür", "Mars", "Jüpiter"]),
    ("Mariana Çukuru", "Dünyanın bilinen en derin noktası neresidir ve derinliği ne kadardır?", "Büyük Okyanus'taki Mariana Çukuru (Challenger Çukuru), yaklaşık 11.000 metre derinliktedir.", "Mariana Çukuru", "Mariana Çukuru (~11.000 m)", ["Porto Riko Çukuru", "Java Çukuru", "Baykal Gölü"]),
    ("Güneş'e En Yakın Yıldız", "Güneş Sistemi'ne en yakın komşu yıldız sistemi hangisidir?", "Proxima Centauri (Alfa Centauri sistemi), yaklaşık 4.24 ışık yılı uzaklıktadır.", "Proxima Centauri", "Proxima Centauri", ["Sirius", "Betelgeuse", "Vega"])
]

for i in range(400):
    base = space_data[i % len(space_data)]
    variant = (i // len(space_data)) + 1
    cid = f"gen_spc_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: GEN-SPC-{i+1}"
    hint = base[3]
    color = COLORS[(i+4) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Genel Kültür & Bilim", "Uzay, Astronomi & Coğrafya Harikaları", color, imp, ans, dis))

print(f"Final General cards count: {len(cards)}")

with open('assets/data/cards_general.json', 'w', encoding='utf-8') as f:
    json.dump(cards, f, ensure_ascii=False, indent=2)

print("Saved assets/data/cards_general.json successfully.")
