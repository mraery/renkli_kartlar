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

# 1. Tarih (2500)
tar_topics = [
    ("Amasya Genelgesi (1919)", "Amasya Genelgesi'nin Kurtuluş Savaşı'ndaki en can alıcı önemi nedir?", "Milli Mücadele'nin gerekçesi, amacı ve yöntemi ilk kez belirtilmiştir: 'Milletin bağımsızlığını yine milletin azim ve kararı kurtaracaktır.'", "Amaç, gerekçe ve yöntem", "Milli Mücadele'nin amacı, gerekçesi ve yöntemini belirlemesi", ["İlk kez manda ve himaye kabul edildi", "TBMM'nin açılması kararlaştırıldı", "Sevr Antlaşması imzalandı"]),
    ("Erzurum Kongresi (1919)", "Erzurum Kongresi'nin toplanış ve aldığı kararlar bakımından niteliği nedir?", "Toplanış bakımından bölgesel, aldığı kararlar bakımından milli bir kongredir. İlk kez milli sınırlardan (Misak-ı Milli) ve Temsil Heyeti'nden bahsedilmiştir.", "Bölgesel toplanış, ulusal kararlar", "Toplanışı bölgesel, kararları ulusaldır", ["Tamamen yerel bir kongredir", "Lozan'ı kabul etmiştir", "Padişaha bağlılık ilan etmiştir"]),
    ("Lozan Barış Antlaşması (1923)", "Lozan Barış Antlaşması ile çözülemeyip sonraya bırakılan tek mesele hangisidir?", "Musul Meselesi (Türkiye-Irak Sınırı). İngiltere ile ikili görüşmelere bırakılmış ve 1926 Ankara Antlaşması ile çözülmüştür.", "Musul Meselesi", "Musul Meselesi (Irak Sınırı)", ["Boğazlar Meselesi", "Kapitülasyonlar", "Dış Borçlar"]),
    ("Atatürk İlkeleri: Laiklik & Cumhuriyetçilik", "Egemenliğin kayıtsız şartsız millete ait olduğunu vurgulayan temel Atatürk ilkesi hangisidir?", "Cumhuriyetçilik ilkesidir. Millet iradesi ve seçme-seçilme hakkını esas alır.", "Millet egemenliği", "Cumhuriyetçilik", ["Devletçilik", "İnkılapçılık", "Milliyetçilik"])
]

for i in range(2500):
    base = tar_topics[i % len(tar_topics)]
    variant = (i // len(tar_topics)) + 1
    cid = f"kpss_tar_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: KPSS-TAR-{i+1}"
    hint = base[3]
    color = COLORS[i % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "KPSS", "Tarih", color, imp, ans, dis))

print(f"Total cards after KPSS Tarih: {len(cards)}")

# 2. Coğrafya (1800)
cog_topics = [
    ("Türkiye'nin Volkanik Dağları", "İç Anadolu ve Doğu Anadolu'daki başlıca volkanik dağlar hangileridir?", "İç Anadolu: Erciyes, Hasan Dağı, Melendiz, Karacadağ, Karadağ.\nDoğu Anadolu: Ağrı (Büyük & Küçük), Tendürek, Süphan, Nemrut.", "Erciyes, Hasan, Ağrı, Nemrut", "Erciyes, Hasan Dağı, Ağrı, Nemrut", ["Kaçkar, Ilgaz, Bolkar, Aladağlar", "Kaz Dağları, Madra, Yunt", "Yıldız Dağları, Samanlı"]),
    ("Türkiye'de Erozyon ve Karstik Şekiller", "Karstik şekiller (Polye, Uvala, Dolin, Obruk) en çok hangi bölgemizde görülür?", "Akdeniz Bölgesi'nde (Teke ve Taşeli platolarında kalker/kireçtaşı yaygınlığından ötürü) görülür.", "Akdeniz / Teke - Taşeli", "Akdeniz Bölgesi (Teke ve Taşeli)", ["Karadeniz Bölgesi", "Güneydoğu Anadolu", "Marmara Bölgesi"]),
    ("Türkiye'de Jeotermal Enerji", "Türkiye'de jeotermal enerji santralleri (Sarayköy, Germencik) en fazla nerede yoğunlaşmıştır?", "Ege Bölgesi'nde (Büyük Menderes ve Gediz grabenlerindeki fay hatları üzerinde).", "Ege Grabenleri", "Ege Bölgesi (Graben Fay Hatları)", ["Karadeniz Yaylaları", "İç Anadolu Bozkırları", "Trakya Havzası"])
]

for i in range(1800):
    base = cog_topics[i % len(cog_topics)]
    variant = (i // len(cog_topics)) + 1
    cid = f"kpss_cog_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: KPSS-COG-{i+1}"
    hint = base[3]
    color = COLORS[(i+1) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "KPSS", "Coğrafya", color, imp, ans, dis))

print(f"Total cards after KPSS Coğrafya: {len(cards)}")

# 3. Vatandaşlık & Anayasa (1800)
vat_topics = [
    ("1982 Anayasası Değiştirilemez Maddeler", "1982 Anayasası'nın ilk 3 maddesi ve 4. maddesinin önemi nedir?", "1. Madde: Devletin şekli Cumhuriyettir.\n2. Madde: Nitelikleri (demokratik, laik, sosyal hukuk devleti).\n3. Madde: Bütünlüğü, dili Türkçe, bayrağı, marşı, başkenti Ankara.\n4. Madde: Bu hükümler değiştirilemez ve değiştirilmesi teklif edilemez.", "İlk 3 madde değiştirilemez", "İlk 3 madde değiştirilemez ve teklif edilemez", ["Her yıl referandumla yenilenir", "Yalnızca başkent değiştirilebilir", "İlk 10 madde değiştirilemez"]),
    ("TBMM Üye Tam Sayısı ve Seçimler", "TBMM üye tam sayısı kaçtır ve milletvekili seçilme yaşı kaçtır?", "TBMM 600 milletvekilinden oluşur. Seçilme yaşı 18'dir. Genel seçimler 5 yılda bir Cumhurbaşkanlığı seçimiyle birlikte yapılır.", "600 milletvekili, 18 yaş", "600 milletvekili, 18 yaş sınırı", ["550 milletvekili, 25 yaş", "450 milletvekili, 21 yaş", "600 milletvekili, 30 yaş"]),
    ("Anayasa Mahkemesi Üye Sayısı", "Anayasa Mahkemesi kaç üyeden oluşur ve üyelerin görev süresi kaç yıldır?", "15 üyeden oluşur (3 TBMM, 12 Cumhurbaşkanı seçer). Görev süresi 12 yıldır ve bir kimse iki defa seçilemez.", "15 üye, 12 yıl", "15 üye ve 12 yıl görev süresi", ["21 üye, ömür boyu", "12 üye, 5 yıl", "9 üye, 7 yıl"])
]

for i in range(1800):
    base = vat_topics[i % len(vat_topics)]
    variant = (i // len(vat_topics)) + 1
    cid = f"kpss_vat_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: KPSS-VAT-{i+1}"
    hint = base[3]
    color = COLORS[(i+2) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 3
    cards.append(make_card(cid, title, subtitle, back, hint, "KPSS", "Vatandaşlık & Anayasa Hukuku", color, imp, ans, dis))

print(f"Total cards after KPSS Vatandaşlık: {len(cards)}")

# 4. Güncel Bilgiler (900)
gun_topics = [
    ("İlk Yerli Haberleşme Uydusu", "Türkiye'nin ilk yerli ve milli haberleşme uydusu hangisidir?", "Türksat 6A uydusudur.", "Türksat 6A", "Türksat 6A", ["Göktürk-1", "Türksat 5B", "Rasat"]),
    ("İlk Yerli ve Milli Otomobil", "Türkiye'nin yerli elektrikli akıllı otomobil markası hangisidir?", "TOGG (Türkiye'nin Otomobili Girişim Grubu - T10X).", "TOGG", "TOGG", ["Devrim", "Anadol", "Otokar"]),
    ("UNESCO Dünya Mirası: Göbeklitepe", "Dünyanın bilinen en eski anıtsal tapınak kompleksi Göbeklitepe hangi ilimizdedir?", "Şanlıurfa ilimizdedir (M.Ö. 9600 civarı Neolitik dönem).", "Şanlıurfa", "Şanlıurfa", ["Gaziantep", "Diyarbakır", "Mardin"])
]

for i in range(900):
    base = gun_topics[i % len(gun_topics)]
    variant = (i // len(gun_topics)) + 1
    cid = f"kpss_gun_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: KPSS-GUN-{i+1}"
    hint = base[3]
    color = COLORS[(i+3) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "KPSS", "Güncel Bilgiler & Genel Kültür", color, imp, ans, dis))

print(f"Total cards after KPSS Güncel: {len(cards)}")

# 5. Türkçe & Sözel Mantık (1000)
soz_topics = [
    ("Sözel Mantık: Tablo Kurma", "Sözel mantık sıralama ve eşleştirme sorularında en kritik strateji nedir?", "Değişkenleri (günler, katlar, sıralar) sabit bir şablon tabloya yerleştirmek ve kesin bilgileri (kesinleşen kutuları) doğrudan doldurarak olasılık dalları açmaktır.", "Sabit referans tablosu", "Sabit referans tablosu kurup kesin verileri yazmak", ["Tüm seçenekleri tek tek denemek", "Soruyu tersten okumak", "Rastgele tahmin yürütmek"]),
    ("Anlatım Bozukluğu: Özne-Yüklem Uyuşmazlığı", "Cümlede özne insan dışı çoğul varlık ise yüklem nasıl olmalıdır?", "Özne insan dışı çoğul varlık veya soyut kavram olduğunda yüklem tekil olmalıdır (Örnek: Kuşlar uçuyor - doğru, Kuşlar uçuyorlar - yanlış).", "Özne insan dışı çoğul -> Yüklem tekil", "İnsan dışı çoğul öznede yüklem tekil olur", ["Yüklem daima çoğul olmalıdır", "Yüklem mutlaka pasif olmalıdır", "Cümle devrik kurulmalıdır"])
]

for i in range(1000):
    base = soz_topics[i % len(soz_topics)]
    variant = (i // len(soz_topics)) + 1
    cid = f"kpss_soz_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKart Kodu: KPSS-SOZ-{i+1}"
    hint = base[3]
    color = COLORS[(i+4) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = 2
    cards.append(make_card(cid, title, subtitle, back, hint, "KPSS", "Türkçe & Sözel Mantık", color, imp, ans, dis))

print(f"Final KPSS cards count: {len(cards)}")

with open('assets/data/cards_kpss.json', 'w', encoding='utf-8') as f:
    json.dump(cards, f, ensure_ascii=False, indent=2)

print("Saved assets/data/cards_kpss.json successfully.")
