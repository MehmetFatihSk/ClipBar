# ClipBar

macOS için native bir menü bar (status bar) pano geçmişi uygulaması. Swift ve SwiftUI ile yazıldı.

## Ne işe yarar

Panoya kopyaladığın son 25 öğeyi menü bar'daki simgeden açılan popover üzerinden listeler. İçerik türüne göre otomatik olarak ayırt eder:

- **Metin** — düz metin olarak listelenir
- **Link** — tıklayınca tarayıcıda açılır
- **Renk kodu** (`#RRGGBB`) — yanında renk önizleme kutucuğu ile gösterilir
- **Görsel** — küçük önizleme; üzerine gelince otomatik büyür, tıklayınca ayrı bir pencerede tam boyut açılır

Her öğenin yanındaki ikonla tek tıkla tekrar panoya kopyalanabilir. Geçmiş, uygulama kapatılıp açılsa bile korunur (diskte saklanır).

## Özellikler

- Menü bar'da native popover arayüz (macOS Human Interface Guidelines'a uygun)
- Son 25 öğe, kapasite aşılınca en eski öğe otomatik düşer
- Akıllı içerik algılama: metin / link / renk kodu / görsel
- Kalıcı geçmiş (`~/Library/Application Support/ClipBar`)
- Açık/Koyu/Sistem görünüm anahtarı (menü bar başlığındaki simge)
- Panoyu hafif bir `NSPasteboard` kontrolüyle izler; uykuda hiç çalışmaz, uyanıkken ölçülemeyecek kadar düşük CPU/pil etkisi

## Gereksinimler

- macOS 14 veya üzeri
- Xcode Command Line Tools (Xcode uygulamasının kendisi gerekmez)

## Çalıştırma

Proje bir Swift Package — Xcode açmadan terminalden çalıştırılabilir:

```bash
swift run
```

Kalıcı bir uygulama olarak (`.app`) kurmak için:

```bash
./build_app.sh
```

Bu, `ClipBar.app` dosyasını üretir; `/Applications` klasörüne sürükleyip normal bir uygulama gibi kullanabilirsin.

## Teknik yapı

- SwiftUI `MenuBarExtra` (menü bar arayüzü)
- `NSPasteboard` polling (pano izleme)
- JSON + PNG dosyaları ile yerel kalıcılık, üçüncü parti bağımlılık yok
