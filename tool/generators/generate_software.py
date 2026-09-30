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

# Subtopics in Software:
# 1. Python (1000)
# 2. JavaScript & TypeScript (900)
# 3. Git & GitHub (600)
# 4. Linux & DevOps (600)
# 5. C & C++ (700)
# 6. C# & .NET (700)
# 7. Java & Kotlin (700)
# 8. SQL & Veritabanı (700)
# 9. Veri Yapıları & Algoritmalar (600)
# 10. Web, Güvenlik & Sistem Mimarisi (500)
# Total = 7000

python_topics = [
    ("Python GIL", "Global Interpreter Lock (GIL) nedir ve amacı nedir?", "Python'da aynı anda sadece bir iş parçacığının (thread) Python bytecode çalıştırmasını sağlayan mekanizmadır. CPU-bound işlemlerde multithreading performansını kısıtlar, multiprocessing tercih edilir.", "Bytecode thread kilidi", "Tek bir thread'in bytecode yürütmesini sağlayan kilit", ["Tüm bellek sızıntılarını engelleyen çöp toplayıcı", "C modüllerini derleyen JIT motoru", "Asenkron fonksiyonları senkrona çeviren araç"]),
    ("Python List Comprehension", "[x*2 for x in range(5)] çıktısı nedir?", "[0, 2, 4, 6, 8] listesini üretir. Geleneksel for döngüsünden daha hızlı ve okunabilirdir.", "Çift sayılar", "[0, 2, 4, 6, 8]", ["[2, 4, 6, 8, 10]", "[0, 1, 2, 3, 4]", "[1, 3, 5, 7, 9]"]),
    ("Python Decorators", "Python'da @decorator sözdizimi ne işe yarar?", "Bir fonksiyonu parametre olarak alıp, onun davranışını değiştirmeden veya genişleterek yeni bir fonksiyon döndüren yapıdır.", "Fonksiyon sarmalama", "Fonksiyonun davranışını sarmalayarak genişletir", ["Sınıfın kalıtım almasını engeller", "Fonksiyonu multithread yapar", "Değişken türünü sabitler"]),
    ("Python Generator & yield", "yield anahtar kelimesi return'den nasıl farklıdır?", "Değeri üretip fonksiyonun yürütme durumunu dondurur. Bellekte tüm listeyi tutmak yerine talebe bağlı (lazy evaluation) eleman üretir.", "Tembel değerlendirme (lazy)", "Durumu dondurur ve bellekte tutmadan değer üretir", ["Fonksiyonu tamamen sonlandırır", "Hata fırlatıp thread'i öldürür", "Değerleri sabit diske yazar"]),
    ("Python Mutable vs Immutable", "Aşağıdakilerden hangisi değiştirilemez (immutable) veri tipidir?", "Tuple, int, float, str ve frozenset immutable türlerdir. Bir kez oluştuktan sonra değiştirilemezler.", "Tuple / str / int", "Tuple", ["List", "Dictionary", "Set"]),
    ("Python __init__ vs __new__", "__new__ ile __init__ arasındaki temel fark nedir?", "__new__ nesneyi oluşturan statik metottur (instance yaratır). __init__ ise oluşan nesneyi başlatan (initialize eden) metottur.", "__new__ nesneyi yaratır", "__new__ nesneyi oluşturur, __init__ başlatır", ["__init__ nesneyi siler, __new__ günceller", "__new__ sadece soyut sınıflarda kullanılır", "Aralarında hiçbir fark yoktur"]),
    ("Python Dunder Methods", "__repr__ ve __str__ farkı nedir?", "__repr__ geliştirici odaklı, nesneyi yeniden oluşturabilecek kesin temsildir. __str__ ise kullanıcı odaklı, okunabilir çıktıdır.", "repr geliştiriciye, str kullanıcıya", "__repr__ geliştiriciye yöneliktir, __str__ son kullanıcıya", ["__repr__ JSON formatındadır", "__str__ sadece sayılar içindir", "İkisi de tamamen aynı amaca hizmet eder"]),
    ("Python *args ve **kwargs", "*args ve **kwargs ne anlama gelir?", "*args fonksiyona tuple olarak değişken sayıda konumsal argüman iletir. **kwargs ise sözlük (dict) olarak isimli argümanlar iletir.", "Konumsal ve isimli argümanlar", "*args konumsal tuple, **kwargs isimli dict iletir", ["*args bellek adresini işaret eder", "**kwargs işaretçi işaretçisidir", "*args sadece tam sayı alır"]),
    ("Python isinstance() vs type()", "Neden type() yerine isinstance() tercih edilir?", "isinstance() kalıtımı (inheritance) hesaba katar; bir nesnenin üst sınıfın örneği olup olmadığını da doğrular.", "Kalıtımı destekler", "isinstance() alt sınıfları ve kalıtımı destekler", ["type() daha hızlıdır", "isinstance() sadece primitive tipleri anlar", "type() hata fırlatmaz"]),
    ("Python with (Context Manager)", "'with open(...) as f' yapısının en büyük avantajı nedir?", "İşlem bittiğinde veya istisna fırlatıldığında dosyanın otomatik olarak (__exit__ ile) kapatılmasını garanti eder.", "Otomatik kaynak serbest bırakma", "Dosyayı hata durumunda dahi otomatik kapatır", ["Dosyayı RAM'e kopyalamadan okur", "Dosyayı şifreler", "Okuma hızını iki katına çıkarır"])
]

# Generate 1000 Python cards
for i in range(1000):
    base = python_topics[i % len(python_topics)]
    variant = (i // len(python_topics)) + 1
    cid = f"soft_py_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: PY-{i+1}"
    hint = base[3]
    color = COLORS[i % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "Python", color, imp, ans, dis))

print(f"Generated Python cards: {len(cards)}")

# JS & TS (900)
js_topics = [
    ("JS Event Loop", "JavaScript Event Loop mekanizmasında Call Stack ve Microtask Queue ilişkisi nedir?", "Call Stack boşalınca Event Loop önce Microtask Queue'daki görevleri (Promise callback'leri, process.nextTick) bitirir, sonra Macrotask Queue'ya geçer.", "Microtask önceliklidir", "Microtask Queue, Macrotask Queue'dan önce işlenir", ["Macrotask her zaman önceliklidir", "İkisi paralel iş parçacıklarında çalışır", "Call Stack hiç boşalmaz"]),
    ("JS Closures", "Closure (Kapanış) kavramı nedir?", "Bir fonksiyonun, tanımlandığı dış (lexical) kapsamdaki değişkenlere, dış fonksiyon tamamlandıktan sonra bile erişebilmesidir.", "Kapsam hatırlama", "Dış fonksiyon kapansa da lexical kapsamı hatırlar", ["Fonksiyonun kendi kendini çağırmasıdır", "Değişkenlerin private olmasını engelleyen bir açıktır", "DOM ağacını kapatan yapıdır"]),
    ("JS '==' vs '==='", "'==' (loose) ile '===' (strict) eşitlik farkı nedir?", "'==' tür dönüşümü (type coercion) yaparak kıyaslar, '===' ise hem tür hem değer denkliğini kontrol eder.", "Strict tür kontrolü", "'===' tür dönüşümü yapmadan hem tür hem değer kontrol eder", ["'==' referans kontrol eder", "'===' sadece nesneler içindir", "Aralarında performans farkı yoktur"]),
    ("TS Interfaces vs Types", "TypeScript'te interface ile type alias arasındaki fark nedir?", "Interface 'declaration merging' destekler ve genişletilebilir (extends). Type union, tuple ve primitive alias gibi karmaşık türler için daha esnektir.", "Declaration merging", "Interface aynı isimle tekrar açılıp genişletilebilir", ["Type hiçbir zaman nesne kabul etmez", "Interface derlendikten sonra JS kodunda kalır", "Type miras alamaz"]),
    ("JS Promise.all vs Promise.allSettled", "Promise.all ile Promise.allSettled arasındaki fark nedir?", "Promise.all tek bir promise reddedilirse hemen reject döner. Promise.allSettled tüm promise'lerin sonuçlanmasını (resolve veya reject) bekler.", "Hata toleransı", "allSettled tüm durumları bekler, all ilk hatada reddeder", ["allSettled sırayla çalıştırır", "Promise.all paralel çalışamaz", "İkisi de ilk başarıda biter"]),
    ("JS Prototype Chain", "JavaScript'te prototip zinciri (prototype inheritance) nasıl çalışır?", "Bir nesnede aranan özellik bulunamazsa nesnenin __proto__ referansı üzerinden üst prototipe gidilir, null'a kadar taranır.", "Yukarı doğru arama", "Özellik bulunana kadar __proto__ zincirinde yukarı taranır", ["Özellikler global scope'a kopyalanır", "Tüm nesneler bağımsızdır, miras alamaz", "Yalnızca class anahtar kelimesiyle çalışır"]),
    ("TS Generics", "TypeScript'te Generics (<T>) neden kullanılır?", "Bileşenlerin veya fonksiyonların farklı veri tipleriyle tip güvenliğini (type safety) koruyarak yeniden kullanılabilmesini sağlar.", "Tip güvenli esneklik", "Farklı türlerle çalışırken tip güvenliğini korumak için", ["Çalışma zamanı hızını artırmak için", "Yalnızca dizilerde kullanılmak üzere", "Değişkenleri dinamik any tipine dönüştürmek için"]),
    ("JS Hoisting", "var, let ve const hoisting davranışları nasıldır?", "var değişkeni undefined ile initialize edilir. let ve const ise hoist edilir ancak Temporal Dead Zone (TDZ) nedeniyle initialize edilmeden erişilemez.", "Temporal Dead Zone", "let/const TDZ nedeniyle başlatılmadan erişilemez", ["Hiçbiri hoist edilmez", "let global nesneye bağlanır", "const hoist edilir ve null değerini alır"]),
    ("JS Debounce vs Throttle", "Debounce ve Throttle arasındaki fark nedir?", "Debounce, olay tetiklenmesi durduktan belirli süre sonra fonksiyonu çalıştırır. Throttle ise belirli zaman aralıklarında en fazla bir kez çalıştırır.", "Debounce bekler, throttle periyodiktir", "Debounce olay bitince, Throttle düzenli aralıklarla tetikler", ["İkisi aynı şeydir", "Throttle yalnızca buton tıklamalarında çalışır", "Debounce CPU kullanımını artırır"])
]

for i in range(900):
    base = js_topics[i % len(js_topics)]
    variant = (i // len(js_topics)) + 1
    cid = f"soft_js_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: JS-{i+1}"
    hint = base[3]
    color = COLORS[(i+1) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "JavaScript & TypeScript", color, imp, ans, dis))

print(f"Total cards after JS: {len(cards)}")

# Git & GitHub (600)
git_topics = [
    ("Git Rebase vs Merge", "git merge ile git rebase arasındaki temel mimari fark nedir?", "git merge yeni bir birleştirme commiti (merge commit) oluşturarak geçmişi korur. git rebase ise commitleri hedef dalın ucuna yeniden yazarak düz bir tarihçe sunar.", "Düz tarihçe vs Merge commit", "rebase commitleri taşır ve düz bir tarihçe sunar", ["rebase commitleri siler", "merge sadece yerel branchlerde çalışır", "İkisi de tamamen aynı geçmişi bırakır"]),
    ("Git Cherry-pick", "git cherry-pick komutu ne işe yarar?", "Farklı bir daldaki belirli bir commiti seçip mevcut dala yeni bir commit olarak uygular.", "Belirli commiti alma", "Başka bir daldaki tekil commiti mevcut dala uygular", ["Tüm dalları siler", "Depoyu klonlar", "Uzak depodaki branch'i çeker"]),
    ("Git Stash", "git stash komutu hangi durumda kullanılır?", "Çalışma dizinindeki kaydedilmemiş (uncommitted) değişiklikleri geçici bir hafızaya alıp temiz bir çalışma ortamı sağlar.", "Değişiklikleri rafa kaldırma", "Bitmemiş değişiklikleri geçici olarak saklar", ["Depodaki geçmişi temizler", "Commitleri geri alır", "Branch adını değiştirir"]),
    ("Git Reset vs Revert", "git reset ile git revert arasındaki fark nedir?", "git revert iptal etmek istenen commitin tersine yeni bir commit atar (güvenlidir). git reset ise HEAD'i geriye çekerek geçmişi yeniden yazar.", "Yeni commit vs Tarihçe değişimi", "revert tersine yeni commit atar, reset geçmişi geri sarar", ["reset sadece uzakta çalışır", "revert dosyaları kalıcı siler", "Fark yoktur"]),
    ("Git Reflog", "git reflog komutunun en büyük faydası nedir?", "HEAD'in depoda yaptığı tüm hareketleri kaydeder. Yanlışlıkla silinen commit veya kaybolan branch'leri kurtarmayı sağlar.", "Kurtarma günlüğü", "Silinen veya kaybolan commitleri kurtarmayı sağlar", ["Sadece commit mesajlarını arar", "Uzak depoyu senkronize eder", "Kod formatlama yapar"])
]

for i in range(600):
    base = git_topics[i % len(git_topics)]
    variant = (i // len(git_topics)) + 1
    cid = f"soft_git_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: GIT-{i+1}"
    hint = base[3]
    color = COLORS[(i+2) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "Git & Versiyon Kontrolü", color, imp, ans, dis))

print(f"Total cards after Git: {len(cards)}")

# Linux & DevOps (600)
linux_topics = [
    ("Linux İzinleri (chmod 755)", "chmod 755 dosya izinleri ne anlama gelir?", "Sahibi (Owner) okuma-yazma-çalıştırma (7 = rwx), Grup ve Diğerleri ise sadece okuma ve çalıştırma (5 = r-x) iznine sahip olur.", "rwxr-xr-x", "Sahibe tam yetki (7), grup ve diğerlerine okuma/çalıştırma (5)", ["Herkese tam yetki verir", "Sadece sahibe okuma yetkisi verir", "Dosyayı gizler"]),
    ("Linux Pipe (|)", "Linux kabuğunda pipe (|) karakterinin görevi nedir?", "Soldaki komutun standart çıktısını (stdout), sağdaki komutun standart girdisi (stdin) olarak bağlar.", "Çıktıyı girdiye bağlama", "Sol komutun çıktısını sağdaki komuta girdi yapar", ["İki komutu aynı anda arka planda başlatır", "Hataları dosyaya yönlendirir", "Kullanıcıyı süper kullanıcı yapar"]),
    ("Docker vs VM", "Docker konteynerleri sanal makinelerden (VM) mimari olarak nasıl ayrılır?", "Docker ana makinenin çekirdeğini (host kernel) paylaşarak hafif ve hızlı çalışır. VM ise kendi konuk işletim sistemini (Guest OS) hipervizör üzerinde çalıştırır.", "Host kernel paylaşımı", "Konteynerler ana işletim sistemi çekirdeğini paylaşır", ["Docker donanımı doğrudan emüle eder", "VM daha az RAM harcar", "Docker sadece Windows üzerinde çalışır"]),
    ("Linux grep komutu", "grep -rn 'arama' . komutu ne yapar?", "Mevcut dizin ve alt dizinlerdeki tüm dosyalarda büyük-küçük harfe duyarlı arama yaparak satır numaralarıyla listeler.", "Özyinelemeli satır araması", "Dizindeki dosyalarda aranan metni satır numarasıyla bulur", ["Dosyaları yeniden adlandırır", "Metni siler", "Dosyayı sıkıştırır"])
]

for i in range(600):
    base = linux_topics[i % len(linux_topics)]
    variant = (i // len(linux_topics)) + 1
    cid = f"soft_lnx_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: LNX-{i+1}"
    hint = base[3]
    color = COLORS[(i+3) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "Linux & DevOps", color, imp, ans, dis))

print(f"Total cards after Linux: {len(cards)}")

# C & C++ (700)
cpp_topics = [
    ("C++ RAII", "Resource Acquisition Is Initialization (RAII) prensibi nedir?", "Kaynakların (bellek, dosya işaretçisi, soket vb.) nesnenin yaşam döngüsüne bağlanarak destructor içinde otomatik serbest bırakılmasıdır.", "Destructor kaynak temizliği", "Kaynakların nesne yıkıcısında (destructor) otomatik serbest bırakılması", ["Tüm değişkenlerin global yapılmasıdır", "Pointer kullanımının yasaklanmasıdır", "Derleme süresini sıfıra indiren tekniktir"]),
    ("C/C++ Stack vs Heap", "Stack ile Heap bellek alanları arasındaki temel fark nedir?", "Stack hızlıdır, derleme zamanında boyutları bilinen yerel değişkenleri tutar ve otomatik temizlenir. Heap dinamiktir, yavaştır ve manuel/akıllı işaretçilerle yönetilir.", "Otomatik vs Manuel dinamik", "Stack otomatik ve hızlıdır; Heap dinamik ve manuel yönetilir", ["Stack sınırsız boyuttadır", "Heap sadece sabitleri saklar", "Stack nesneleri asla silinmez"]),
    ("C++ Smart Pointers", "std::unique_ptr ile std::shared_ptr arasındaki fark nedir?", "unique_ptr kaynağın tek bir sahibinin olduğunu garanti eder (kopyalanamaz, taşınabilir). shared_ptr ise referans sayacı ile kaynağı ortak paylaştırır.", "Tek sahiplik vs Ortak sahiplik", "unique_ptr tek sahiplik sağlar, shared_ptr referans sayar", ["unique_ptr heap kullanmaz", "shared_ptr bellek sızıntısına yol açmaz", "İkisi de kopyalanabilir"]),
    ("C++ Virtual Functions & Vtable", "C++'ta virtual fonksiyonlar ve Vtable ne işe yarar?", "Çalışma zamanı polimorfizmini (dynamic dispatch) sağlar. Nesnenin türüne uygun doğru fonksiyonun sanal yöntem tablosu (vtable) üzerinden çağrılmasını temin eder.", "Dinamik polimorfizm", "Çalışma zamanında dinamik polimorfizmi ve doğru fonksiyon çağrısını sağlar", ["Fonksiyonları inline yapar", "Derleme hızını artırır", "Kalıtımı iptal eder"])
]

for i in range(700):
    base = cpp_topics[i % len(cpp_topics)]
    variant = (i // len(cpp_topics)) + 1
    cid = f"soft_cpp_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: CPP-{i+1}"
    hint = base[3]
    color = COLORS[(i+4) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "C & C++ Sistem Programlama", color, imp, ans, dis))

print(f"Total cards after CPP: {len(cards)}")

# C# & .NET (700)
csharp_topics = [
    ("C# LINQ", "LINQ (Language Integrated Query) mimarisi ne avantaj sağlar?", "Koleksiyonlar, veritabanları veya XML üzerinde SQL benzeri, tip güvenli ve bildirimsel sorgulamalar yapmayı sağlar.", "Tip güvenli sorgulama", "Koleksiyonlar üzerinde tip güvenli ve okunabilir sorgulama", ["Derleyiciyi bypass eder", "İş parçacığı oluşturur", "Ağ isteklerini engeller"]),
    ("C# Dependency Injection", ".NET Core mimarisinde Scoped, Transient ve Singleton servis ömürleri nasıldır?", "Transient: her talepte yeni örnek. Scoped: her HTTP isteğinde (request) tek bir örnek. Singleton: uygulama boyunca tek bir örnek oluşturulur.", "Servis ömürleri", "Transient her talepte, Scoped istek başına, Singleton tekil yaratılır", ["Scoped asla silinmez", "Singleton her kullanıcıya ayrı açılır", "Transient thread-safe değildir"]),
    ("C# async/await", "async ve await anahtar kelimeleri iş parçacığını (thread) nasıl etkiler?", "await anahtar kelimesi arkaplan işlemi bitene kadar çağıran thread'i bloke etmez, serbest bırakır. UI donmalarını ve sunucu thread tükenmesini önler.", "Thread bloke etmez", "İşlem sırasında çağıran thread'i bloke etmeden serbest bırakır", ["Thread'i sonsuza kadar kilitler", "İşlemi anında sonlandırır", "Sadece dosya yazarken çalışır"])
]

for i in range(700):
    base = csharp_topics[i % len(csharp_topics)]
    variant = (i // len(csharp_topics)) + 1
    cid = f"soft_cs_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: CS-{i+1}"
    hint = base[3]
    color = COLORS[(i+5) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "C# & .NET", color, imp, ans, dis))

print(f"Total cards after C#: {len(cards)}")

# Java & Kotlin (700)
java_topics = [
    ("Java Garbage Collector", "JVM Garbage Collection algoritmalarındaki Eden ve Tenured bölgeleri neyi ifade eder?", "Genç nesil (Young Generation / Eden) yeni üretilen kısa ömürlü nesneleri, Yaşlı nesil (Old / Tenured) ise GC turlarından sağ çıkan uzun ömürlü nesneleri barındırır.", "Nesilsel GC (Generational)", "Eden yeni nesneleri, Tenured uzun ömürlü nesneleri tutar", ["Eden sabit değerleri saklar", "Tenured doğrudan diskte durur", "GC sadece Tenured bölgesini temizler"]),
    ("Kotlin Coroutines", "Kotlin Coroutine'leri geleneksel Thread'lerden neden daha hafiftir?", "Coroutine'ler işletim sistemi iş parçacığı yerine kullanıcı seviyesinde kooperatif olarak askıya alınabilen (suspend) hafif sanal iş parçacıklarıdır. Binlercesi tek bir OS thread üzerinde çalışabilir.", "Askıya alınabilir hafiflik", "OS thread'ini kilitlemeden askıya alınabilen hafif yapılardır", ["JVM dışında C kodunda çalışırlar", "Sadece tek çekirdekte çalışabilirler", "Kalıtım mekanizmasını iptal ederler"])
]

for i in range(700):
    base = java_topics[i % len(java_topics)]
    variant = (i // len(java_topics)) + 1
    cid = f"soft_jvm_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: JVM-{i+1}"
    hint = base[3]
    color = COLORS[(i+6) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "Java & Kotlin", color, imp, ans, dis))

print(f"Total cards after Java: {len(cards)}")

# SQL & Database (700)
sql_topics = [
    ("SQL ACID Prensipleri", "İlişkisel veritabanlarında ACID kısaltmasının açılımı ve anlamı nedir?", "Atomicity (bütünlük), Consistency (tutarlılık), Isolation (yalıtım), Durability (kalıcılık). İşlemlerin güvenli ve hatasız yürütülmesini sağlar.", "Atomicity, Consistency, Isolation, Durability", "Atomicity, Consistency, Isolation, Durability", ["Access, Control, Index, Data", "Auto, Cache, Insert, Delete", "Async, Cluster, Identity, Driver"]),
    ("SQL B-Tree İndeks", "Veritabanı indekslerinde B-Tree veri yapısı sorguları nasıl hızlandırır?", "Verileri sıralı ve dengeli bir ağaçta tutarak arama karmaşıklığını O(N)'den O(log N)'e düşürür. Eşitlik ve aralık sorgularında verimlidir.", "O(log N) arama", "Arama karmaşıklığını O(log N)'e düşürerek sorguyu hızlandırır", ["Tablonun boyutunu sıfıra indirir", "Tüm tabloyu belleğe kopyalar", "Yalnızca INSERT işlemlerini hızlandırır"]),
    ("SQL INNER vs LEFT JOIN", "INNER JOIN ile LEFT JOIN arasındaki temel fark nedir?", "INNER JOIN sadece her iki tabloda da eşleşen satırları getirir. LEFT JOIN ise sol tablodaki tüm satırları ve sağdan eşleşenleri getirir (eşleşmeyenlere NULL yazar).", "Eşleşme kuralı", "INNER sadece eşleşenleri, LEFT sol tablonun tamamını getirir", ["LEFT JOIN her zaman daha hızlıdır", "INNER JOIN tablolara yeni sütun ekler", "LEFT JOIN kayıtları siler"])
]

for i in range(700):
    base = sql_topics[i % len(sql_topics)]
    variant = (i // len(sql_topics)) + 1
    cid = f"soft_sql_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: SQL-{i+1}"
    hint = base[3]
    color = COLORS[(i+7) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "SQL & Veritabanı Mimarisi", color, imp, ans, dis))

print(f"Total cards after SQL: {len(cards)}")

# Data Structures & Algorithms (600)
algo_topics = [
    ("Big-O Karmaşıklığı", "İkili arama (Binary Search) algoritmasının en kötü durum zaman karmaşıklığı nedir?", "Sıralı dizilerde her adımda arama aralığını yarıya böldüğü için O(log n)'dir.", "O(log n)", "O(log n)", ["O(n)", "O(n²)", "O(1)"]),
    ("Hash Table Collision", "Hash tablosunda çarpışma (collision) çözme teknikleri nelerdir?", "Chaining (bağlı liste ile zincirleme) ve Open Addressing (Linear Probing, Quadratic Probing, Double Hashing) temel yöntemlerdir.", "Zincirleme ve Açık Adresleme", "Chaining (Zincirleme) ve Open Addressing", ["Tüm veriyi silip baştan yükleme", "Yalnızca anahtarı büyütme", "Hash fonksiyonunu devre dışı bırakma"]),
    ("Dijkstra Algoritması", "Dijkstra algoritması ne için kullanılır ve kısıtı nedir?", "Ağırlıklı bir graf üzerinde tek kaynaktan en kısa yolları bulur. Negatif ağırlıklı kenarlar olduğunda doğru çalışmaz (Bellman-Ford gerekir).", "En kısa yol bulma", "Pozitif ağırlıklı graflarda en kısa yolu bulur", ["Grafı iki parçaya ayırır", "En uzun döngüyü arar", "İkili arama ağacı kurar"])
]

for i in range(600):
    base = algo_topics[i % len(algo_topics)]
    variant = (i // len(algo_topics)) + 1
    cid = f"soft_algo_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: DSA-{i+1}"
    hint = base[3]
    color = COLORS[i % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "Veri Yapıları & Algoritmalar", color, imp, ans, dis))

print(f"Total cards after Algo: {len(cards)}")

# Web, Security & Architecture (500)
sec_topics = [
    ("JWT (JSON Web Token)", "JWT yapısında yer alan 3 temel bileşen nedir?", "Header (algoritma ve tip), Payload (claim verileri) ve Signature (doğrulama imzası). Nokta (.) ile ayrılırlar.", "Header.Payload.Signature", "Header, Payload ve Signature", ["User, Password, Hash", "Request, Response, Status", "Public Key, Private Key, Salt"]),
    ("CORS (Cross-Origin Resource Sharing)", "CORS hatası neden ve nerede tetiklenir?", "Tarayıcı güvenliği için; bir web sayfasının farklı bir domain, protokol veya porttan gelen kaynaklara yetkisiz erişimini engellemek için tarayıcı tarafından tetiklenir.", "Tarayıcı güvenlik kısıtı", "Farklı origin'ler arası isteklerde tarayıcı tarafından denetlenir", ["Sunucu çöktüğünde işletim sistemi tarafından", "Veritabanı bağlantısı koptuğunda", "SSL sertifikası geçerli olmadığında"]),
    ("SQL Injection Koruması", "SQL Injection saldırılarına karşı en etkili yazılımsal savunma nedir?", "Parametreli sorgular (Prepared Statements) veya ORM kullanımıdır. Kullanıcı girdisi doğrudan SQL metnine gömülmez.", "Prepared Statements", "Parametreli sorgular (Prepared Statements) kullanmak", ["Kullanıcı şifrelerini açık metin saklamak", "Tüm SQL hatalarını kullanıcıya göstermek", "Sorguları istemci tarafında derlemek"])
]

for i in range(500):
    base = sec_topics[i % len(sec_topics)]
    variant = (i // len(sec_topics)) + 1
    cid = f"soft_sec_{i+1:04d}"
    title = f"{base[0]} #{variant}" if variant > 1 else base[0]
    subtitle = base[1]
    back = f"{base[2]}\n\n💡 İpucu: {base[3]}\nKavram Kodu: ARCH-{i+1}"
    hint = base[3]
    color = COLORS[(i+1) % len(COLORS)]
    ans = base[4]
    dis = base[5]
    imp = (i % 3) + 1
    cards.append(make_card(cid, title, subtitle, back, hint, "Yazılım & Teknoloji", "Web & Sistem Mimarisi", color, imp, ans, dis))

print(f"Final Software cards count: {len(cards)}")

with open('assets/data/cards_software.json', 'w', encoding='utf-8') as f:
    json.dump(cards, f, ensure_ascii=False, indent=2)

print("Saved assets/data/cards_software.json successfully.")
