# NAHealth App

Ứng dụng Flutter cho bệnh nhân của Bệnh viện Hữu Nghị Đa Khoa Nghệ An. Xem [`../docs/architecture/`](../docs/architecture/) để biết kiến trúc, cấu trúc thư mục và danh sách màn hình.

## Bắt đầu

Máy viết code này không có Flutter SDK cài sẵn nên phần khung native (android/ios/web) và việc build chưa được chạy thử. Sau khi clone:

```bash
cd app
flutter create --platforms=android,ios,web --org com.nahealth --project-name nahealth_app .
flutter pub get
flutter gen-l10n
flutter run
```

Lệnh `flutter create .` với các flag trên sẽ chỉ tạo thêm các thư mục `android/`, `ios/`, `web/`,... mà **không ghi đè** `lib/` hay `pubspec.yaml` đã có sẵn (nhưng vẫn nên `git status` kiểm tra lại sau khi chạy).

## Trạng thái

- Toàn bộ 25 màn hình theo mockup ở `NaHealth-UI/NAHealth App.dc.html` đã được viết bằng Flutter, dùng dữ liệu mock (fake delay/fake error) — chưa nối API thật.
- Chưa build/verify thực tế trên máy (thiếu SDK). Cần chạy `flutter analyze` và `flutter run` sau khi cài SDK để bắt lỗi biên dịch nếu có.
