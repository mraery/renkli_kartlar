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

# 1. A1-A2 Vocabulary (1000)
a1_a2_words = [
    ("Achieve", "İngilizce 'achieve' kelimesinin Türkçe karşılığı nedir?", "Başarmak, elde etmek, amacına ulaşmak.\n\nÖrnek: She worked hard to achieve her goals.", "Başarmak", "Başarmak", ["Vazgeçmek", "Unutmak", "Gizlemek"]),
    ("Ancient", "'Ancient' kelimesinin anlamı ve zıt anlamlısı nedir?", "Eski, antik, kadim demektir. Zıt anlamlısı: Modern, contemporary.", "Antik / Eski", "Antik, çok eski", ["Yepyeni", "Gelecekteki", "Hafif"]),
    ("Behave", "'Behave' fiili ne anlama gelir?", "Davranmak, uslu durmak.\n\nÖrnek: The children behaved very well at school.", "Davranmak", "Davranmak, uslu durmak", ["Bağırmak", "Uzaklaşmak", "Terk etmek"]),
    ("Brief", "'Brief' kelimesi sıfat olarak ne demektir?", "Kısa, öz, kısa süren.\n\nÖrnek: We had a brief meeting this morning.", "Kısa ve öz", "Kısa, öz", ["Geniş kapsamlı", "Sonsuz", "Tehlikeli"]),
    ("Certain", "'Certain' kelimesi hangi anlamlara gelir?", "Kesin, emin, belirli.\n\nÖrnek: I am certain that it will rain today.", "Kesin, emin", "Kesin, emin", ["Belirsiz", "Şüpheli", "Yanlış"]),
    ("Damage", "'Damage' sözcüğünün karşılığı nedir?", "Zarar, hasar; zarar vermek.\n\nÖrnek: The storm caused serious damage to the roofs.", "Hasar / Zarar", "Hasar vermek, zarar", ["İyileştirmek", "Onarmak", "Korumak"]),
    ("Discover", "'Discover' fiili ne anlama gelir?", "Keşfetmek, bulmak, ortaya çıkarmak.\n\nÖrnek: Scientists discovered a new planet.", "Keşfetmek", "Keşfetmek, bulmak", ["İcat etmek", "Saklamak", "Kaybetmek"]),
    ("Efficient", "'Efficient' sıfatının Türkçe karşılığı nedir?", "Verimli, etkili, işini iyi yapan.\n\nÖrnek: An efficient energy system saves money.", "Verimli", "Verimli, etkili", ["Tembel", "Yavaş", "Zararlı"]),
    ("Frequency", "'Frequency' kelimesi ne anlama gelir?", "Sıklık, frekans.\n\nÖrnek: The frequency of the buses increases during rush hour.", "Sıklık", "Sıklık, frekans", ["Uzaklık", "Ağırlık", "Parlaklık"]),
    ("Gradual", "'Gradual' sıfatının anlamı nedir?", "Kademeli, yavaş yavaş gelişen, aşamalı.\n\nÖrnek: There was a gradual improvement in his health.", "Kademeli / Yavaş", "Kademeli, aşamalı", ["Ani ve sert", "Tamamen tesadüfi", "Kalıcı olmayan"])
]

for i in range(1000):
    base = a1_a2_words[i % len(a1_a2_words)]
    variant = (i // len(a1_a2_words)) + 1
    cid = f"eng_a1_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: ENG-A1-{i+1}"
    hint = base[3]
    color = COLORS[i % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "İngilizce & YDS", "A1-A2 Seviye Kelimeler", color, imp, ans, dis))

print(f"Total cards after A1-A2: {len(cards)}")

# 2. B1-B2 Intermediate (1200)
b1_b2_words = [
    ("Accomplish", "'Accomplish' kelimesinin eş anlamlısı nedir?", "Tamamlamak, başarmak, hayata geçirmek.\nEş anlamlıları: Achieve, fulfill, execute.", "Başarmak / Fulfill", "Başarmak, tamamlamak", ["Ete kemiğe bürünmek", "Yarım bırakmak", "İptal etmek"]),
    ("Accurate", "'Accurate' sıfatının anlamı nedir?", "Doğru, tam, kesin, hatasız.\nEş anlamlıları: Exact, precise, correct.", "Doğru / Kesin", "Kesin, hatasız, doğru", ["Hatalı", "Bulanık", "Gereksiz"]),
    ("Adequate", "'Adequate' kelimesi neyi ifade eder?", "Yeterli, kafi, uygun.\nZıt anlamlısı: Inadequate, insufficient.", "Yeterli", "Yeterli, kafi", ["Yetersiz", "Aşırı lüks", "Fazlalık"]),
    ("Circumstance", "'Under no circumstances' kalıbı ne demektir?", "Hiçbir koşulda, asla.\nCircumstance: Durum, koşul, hal.", "Koşul / Durum", "Koşul, şart, durum", ["Gelecekte", "Kolaylıkla", "Birlikte"]),
    ("Contribute", "'Contribute to' fiili ne ile kullanılır ve ne demektir?", "Katkıda bulunmak, sebep olmak.\nÖrnek: Regular exercise contributes to longevity.", "Katkı sağlamak", "Katkıda bulunmak, sebep olmak", ["Engel olmak", "Yok etmek", "Geri çekilmek"]),
    ("Deteriorate", "'Deteriorate' fiilinin Türkçe karşılığı nedir?", "Kötüleşmek, bozulmak, gerilemek.\nEş anlamlıları: Worsen, degenerate.", "Kötüleşmek", "Kötüleşmek, bozulmak", ["İyileşmek", "Yükselmek", "Gelişmek"]),
    ("Emphasize", "'Emphasize' fiilinin anlamı ve eşanlamlısı nedir?", "Vurgulamak, dikkat çekmek. Eşanlamlısı: Highlight, stress.", "Vurgulamak", "Vurgulamak, dikkat çekmek", ["Önemsizleştirmek", "Sessiz kalmak", "Gizlemek"]),
    ("Fluctuate", "'Fluctuate' fiili ne ifade eder?", "Dalgalanmak, iniş çıkış göstermek.\nÖrnek: Prices fluctuate according to demand.", "Dalgalanmak", "Dalgalanmak, inip çıkmak", ["Sabit kalmak", "Dondurmak", "Azalmak"])
]

for i in range(1200):
    base = b1_b2_words[i % len(b1_b2_words)]
    variant = (i // len(b1_b2_words)) + 1
    cid = f"eng_b1_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: ENG-B1-{i+1}"
    hint = base[3]
    color = COLORS[(i+1) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "İngilizce & YDS", "B1-B2 Orta Düzey Kelimeler", color, imp, ans, dis))

print(f"Total cards after B1-B2: {len(cards)}")

# 3. C1-C2 Academic & YDS (1200)
c1_c2_words = [
    ("Ubiquitous", "'Ubiquitous' akademik kelimesinin anlamı nedir?", "Her yerde birden bulunan, yaygın.\nEş anlamlıları: Omnipresent, pervasive.\nÖrnek: Smartphones have become ubiquitous.", "Her yerde var olan", "Her yerde birden bulunan, yaygın", ["Ender rastlanan", "Zararlı", "Görünmez"]),
    ("Exacerbate", "'Exacerbate' fiilinin anlamı nedir?", "Kötüleştirmek, alevlendirmek, şiddetlendirmek.\nEş anlamlıları: Worsen, aggravate.", "Kötüleştirmek / Şiddetlendirmek", "Kötüleştirmek, şiddetlendirmek", ["Yatıştırmak", "Düzeltmek", "Yavaşlatmak"]),
    ("Mitigate", "'Mitigate' fiilinin karşılığı nedir?", "Hafifletmek, yatıştırmak, azaltmak.\nEş anlamlıları: Alleviate, lessen, ease.", "Hafifletmek", "Hafifletmek, etkisini azaltmak", ["Artırmak", "Şiddetlendirmek", "İhmal etmek"]),
    ("Ephemeral", "'Ephemeral' sıfatı ne demektir?", "Kısa ömürlü, geçici, fani.\nEş anlamlıları: Transient, fleeting, momentary.", "Geçici / Fani", "Kısa ömürlü, geçici, fani", ["Kalıcı, ebedi", "Çok sağlam", "Ağır çekim"]),
    ("Plausible", "'Plausible' kelimesinin karşılığı nedir?", "Makul, akla yatkın, olası.\nEş anlamlıları: Reasonable, credible, believable.", "Akla yatkın", "Makul, akla yatkın", ["İmkansız", "Saçma", "Yanıltıcı"]),
    ("Ambiguous", "'Ambiguous' sözcüğü neyi ifade eder?", "Muğlak, belirsiz, birden çok anlama gelebilen.\nZıt anlamlısı: Clear, unambiguous, explicit.", "Muğlak / Çift anlamlı", "Muğlak, birden fazla anlama açık", ["Açık ve net", "Garantili", "Gereksiz"]),
    ("Pragmatic", "'Pragmatic' kelimesinin anlamı nedir?", "Faydacı, pratik çözümlere odaklanan.\nEş anlamlısı: Practical, realistic.", "Faydacı / Pratik", "Pratik, faydacı, gerçekçi", ["Hayalperest", "Teorik", "Duygusal"]),
    ("Scrutinize", "'Scrutinize' fiili ne anlama gelir?", "Çok dikkatli incelemek, didik didik etmek.\nEş anlamlıları: Examine closely, inspect, probe.", "Detaylıca incelemek", "Çok dikkatli ve ayrıntılı incelemek", ["Yüzeysel bakmak", "Göz ardı etmek", "Terk etmek"])
]

for i in range(1200):
    base = c1_c2_words[i % len(c1_c2_words)]
    variant = (i // len(c1_c2_words)) + 1
    cid = f"eng_c1_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: ENG-C1-{i+1}"
    hint = base[3]
    color = COLORS[(i+2) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 3
    cards.append(make_card(cid, title, subtitle, back, hint, "İngilizce & YDS", "C1-C2 Akademik Kelimeler", color, imp, ans, dis))

print(f"Total cards after C1-C2: {len(cards)}")

# 4. Phrasal Verbs (600)
phrasal_verbs = [
    ("Look forward to", "'Look forward to + Ving' kalıbı ne demektir?", "Dört gözle beklemek, sabırsızlanmak.\nÖrnek: I am looking forward to seeing you.", "Dört gözle beklemek", "Dört gözle beklemek", ["Geriye bakmak", "Vazgeçmek", "Unutmaya çalışmak"]),
    ("Run out of", "'Run out of' phrasal verb'i ne anlama gelir?", "Tükenmek, bitirmek (stok, para, zaman).\nÖrnek: We ran out of milk.", "Tükenmek / Bitmek", "Tükenmek, bitmek", ["Kaçıp gitmek", "Sipariş vermek", "Doldurmak"]),
    ("Put off", "'Put off' eylemi neyi ifade eder?", "Ertelemek, caydırmak.\nEş anlamlısı: Postpone, delay.", "Ertelemek", "Ertelemek, geciktirmek", ["Hemen başlatmak", "Tamamlamak", "Giyinmek"]),
    ("Call off", "'Call off' ile 'Put off' farkı nedir?", "'Call off' iptal etmek (cancel), 'Put off' ertelemek (postpone) demektir.\nÖrnek: The match was called off due to heavy snow.", "İptal etmek", "İptal etmek", ["Ertelemek", "Tavsiye etmek", "Yeniden başlatmak"]),
    ("Give up", "'Give up' ne demektir?", "Pes etmek, vazgeçmek, bir alışkanlığı bırakmak.\nEş anlamlısı: Surrender, abandon, quit.", "Vazgeçmek", "Vazgeçmek, pes etmek", ["Başlamak", "Ödünç vermek", "Korumak"])
]

for i in range(600):
    base = phrasal_verbs[i % len(phrasal_verbs)]
    variant = (i // len(phrasal_verbs)) + 1
    cid = f"eng_phr_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: ENG-PHR-{i+1}"
    hint = base[3]
    color = COLORS[(i+3) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "İngilizce & YDS", "Phrasal Verbs (Deyimsel Fiiller)", color, imp, ans, dis))

print(f"Total cards after Phrasals: {len(cards)}")

# 5. Idioms & Expressions (500)
idioms = [
    ("Piece of cake", "'A piece of cake' deyimi ne anlama gelir?", "Çocuk oyuncağı, yapması son derece kolay şey.\nÖrnek: The exam was a piece of cake.", "Çok kolay", "Çocuk oyuncağı, çok kolay", ["Çok tatlı bir pasta", "Ağır bir sorumluluk", "Pahalı bir ürün"]),
    ("Bite the bullet", "'Bite the bullet' deyimi hangi durumda kullanılır?", "Kaçınılmaz zor veya acı bir duruma cesaretle göğüs germek, acıya katlanmak.", "Zor duruma katlanmak", "Zorluğa cesaretle göğüs germek", ["Silah kullanmak", "Öfkeyle bağırmak", "Geri kaçmak"]),
    ("Break the ice", "'Break the ice' ne demektir?", "Buzları eritmek, ortamdaki gerginliği veya soğukluğu samimiyetle gidermek.", "Buzları kırmak", "Ortamdaki çekingenliği gidermek", ["Kış mevsimini sevmek", "Kavga başlatmak", "İçeceğe buz atmak"]),
    ("Once in a blue moon", "'Once in a blue moon' ne sıklığı ifade eder?", "Kırk yılda bir, çok nadiren, neredeyse hiç.", "Çok nadir", "Çok nadiren, kırk yılda bir", ["Her gün düzenli", "Ay tutulduğunda", "Haftada iki kez"])
]

for i in range(500):
    base = idioms[i % len(idioms)]
    variant = (i // len(idioms)) + 1
    cid = f"eng_idm_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: ENG-IDM-{i+1}"
    hint = base[3]
    color = COLORS[(i+4) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "İngilizce & YDS", "İdiyomlar & Günlük Deyimler", color, imp, ans, dis))

print(f"Total cards after Idioms: {len(cards)}")

# 6. Grammar & Conjunctions (500)
conjunctions = [
    ("Although / Even though", "'Although / Even though' bağlaçları cümleye nasıl bir anlam katar?", "Zıtlık ve ödün bildirir (-e rağmen, karşın). Arkasından tam cümle (Özne + Yüklem) gelir.\nÖrnek: Although it was raining, we went hiking.", "Zıtlık (-e rağmen)", "-e rağmen / Karşın (Zıtlık)", ["Sebep / Çünkü", "Koşul / Şart", "Zaman / -iken"]),
    ("In spite of / Despite", "'In spite of' ve 'Despite' arkasından ne alır?", "İsim (Noun), zamir veya Ving (gerund) alır; asla doğrudan tam cümle almaz (despite the fact that hariç).", "İsim veya Ving", "İsim veya Fiil+ing (-e rağmen)", ["Yalın fiil (V1)", "Tam bir bağımsız cümle", "Sadece sıfat"]),
    ("Inverted Conditionals", "'Had I known...' yapısı hangi Type Conditional'ın devrik halidir?", "Type 3 Conditional ('If I had known...' yerine). Geçmişteki gerçekleşmemiş şartı ifade eder.", "Type 3 Conditional", "Type 3 Conditional devrik hali", ["Type 1 Şart cümlesi", "Geniş zaman kuralı", "Passive emir cümlesi"])
]

for i in range(500):
    base = conjunctions[i % len(conjunctions)]
    variant = (i // len(conjunctions)) + 1
    cid = f"eng_grm_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: ENG-GRM-{i+1}"
    hint = base[3]
    color = COLORS[(i+5) % len(COLORS)]
    ans = base[4]
    dis = base[5:8]
    imp = 3
    cards.append(make_card(cid, title, subtitle, back, hint, "İngilizce & YDS", "Gramer & Bağlaçlar", color, imp, ans, dis))

print(f"Final English cards count: {len(cards)}")

with open('assets/data/cards_english.json', 'w', encoding='utf-8') as f:
    json.dump(cards, f, ensure_ascii=False, indent=2)

print("Saved assets/data/cards_english.json successfully.")
