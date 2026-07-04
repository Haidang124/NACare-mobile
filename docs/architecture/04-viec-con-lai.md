# Việc còn lại

Ghi trung thực các điểm chưa hoàn thiện/đã đơn giản hoá khi viết khung app này, để không ai tưởng nhầm là "xong hết".

## 1. Chưa build/chạy thử được (quan trọng nhất)

Máy dùng để viết code này **không có Flutter SDK**, nên:
- Chưa chạy `flutter pub get`, `flutter analyze`, `flutter run` lần nào.
- Chưa có thư mục `android/`, `ios/`, `web/` (do `flutter create` sinh ra).
- Có khả năng vẫn còn lỗi biên dịch nhỏ (sai tên tham số, thiếu import) chưa bị bắt vì không chạy được `flutter analyze`.

**Việc cần làm đầu tiên** khi có máy có Flutter SDK: xem `README.md` ở thư mục `app/` để biết lệnh khởi tạo, sau đó chạy `flutter analyze` và sửa hết lỗi/cảnh báo trước khi làm gì khác.

## 2. i18n chưa phủ hết chuỗi text

Đã dựng sẵn khung ARB (`lib/l10n/app_vi.arb`, `l10n.yaml`, `AppLocalizations` wired vào `MaterialApp.router`) và dùng cho một số chuỗi chrome dùng chung. Nhưng **phần lớn text trong 25 màn hình vẫn viết thẳng (hard-code) tiếng Việt trong widget**, chưa qua ARB — khác với yêu cầu "text qua ARB, không hard-code" ở `docs/product/ui-ux-app-benh-nhan.md` mục 1.

Lý do đánh đổi: ARB hoá toàn bộ ~25 màn hình (mỗi label, mỗi câu mô tả) sẽ tăng đáng kể khối lượng code cho một app **chưa có API thật và chưa có ngôn ngữ thứ 2**. Đề xuất: làm ARB hoá dần theo từng feature khi feature đó được bệnh viện duyệt UI cuối cùng (tránh phải sửa key ARB nhiều lần theo các vòng duyệt copy).

## 3. Chưa có test tự động

Chưa có unit test cho repository/provider, chưa có widget test. Ưu tiên viết trước khi ghép API thật:
- Unit test cho `BookingController` (điều hướng 5 bước, `canGoNext`).
- Widget test cho `AsyncValueView` (đảm bảo đúng state hiển thị theo `AsyncValue`).
- Test mock repository trả đúng lỗi khi `forceError`/`forceEmpty` bật.

## 4. Placeholder / chưa nối hành động thật

| Chỗ | Hiện tại | Cần làm |
|---|---|---|
| QR check-in (`checkin_screen.dart`) | Mã QR vẽ giả (`PlaceholderQr`), **không quét được** | Thêm package `qr_flutter`, mã hoá mã lịch hẹn thật khi có API check-in |
| Face ID / vân tay (`pin_setup_screen.dart`, toggle trong `security_screen.dart`) | Chỉ là UI, chưa gọi hệ điều hành | Thêm package `local_auth` |
| Lưu PIN, token đăng nhập | Chỉ lưu trong state Riverpod (mất khi tắt app) | Thêm `flutter_secure_storage` khi ghép API thật, để phiên đăng nhập tồn tại qua các lần mở app |
| "Chỉnh sửa thông tin cá nhân", "Thêm mũi tiêm", "Nhập chỉ số mới", "Thêm vào lịch điện thoại" | Nút hiện `SnackBar` "sẽ hỗ trợ ở bản sau" | Cần thiết kế form chi tiết (chưa có trong mockup gốc) rồi mới code |
| "Đổi lịch" ở chi tiết lịch hẹn | Tạm dẫn thẳng vào luồng đặt lịch mới | Cần luồng đổi lịch riêng (giữ lại lịch cũ để huỷ sau khi đặt lịch mới thành công) — xem câu hỏi mở ở `docs/product/ui-ux-app-benh-nhan.md` mục 8 |
| Thanh toán (`bill_detail_screen.dart`) | Xác nhận thanh toán qua mock, không có cổng thanh toán thật | Ghép VNPay/Momo thật khi bệnh viện chọn cổng |
| Số thứ tự (`queue_screen.dart`) | Dữ liệu tĩnh, không tự cập nhật | Cần WebSocket/polling thật khi hệ thống hàng chờ của bệnh viện sẵn sàng (rủi ro đã nêu ở `docs/product/ui-ux-app-benh-nhan.md` Flow C bước 6) |

## 5. Nhánh nghiệp vụ chưa xử lý

- **Liên kết hồ sơ khi tìm thấy nhiều hồ sơ trùng số điện thoại**: `link_profile_screen.dart` mới xử lý 2 nhánh "tìm thấy đúng 1 hồ sơ" và "không tìm thấy". Nhánh "nhiều hồ sơ, cần xác minh thêm ngày sinh/CCCD" (mô tả ở `docs/product/ui-ux-app-benh-nhan.md` Flow A bước 3) chưa làm.
- **Xác thực 2 lớp khi thêm người thân**: `addFamilyMember` hiện chỉ nhận tên + năm sinh, chưa có bước "liên kết mã bệnh nhân + OTP riêng" như Flow F mô tả.

## 6. Go-live 2 (chưa có màn hình)

Theo `docs/product/ui-ux-app-benh-nhan.md` mục 5, các chức năng sau **chưa có màn hình** vì cũng không có trong mockup gốc: gói khám, chat/tư vấn, upload hồ sơ cũ, chăm sóc sau khám, đánh giá sau khám. Khi cần, tạo feature mới theo đúng khuôn ở `01-cau-truc-thu-muc.md`.

## 7. Native platform chưa sinh

Chưa có `android/`, `ios/`, `web/`, icon app, splash screen. Sau khi chạy `flutter create` theo hướng dẫn ở `README.md`, cần thêm:
- App icon + splash screen theo logo bệnh viện (`assets/images/logo.jpg`).
- Cấu hình quyền camera (cho QR check-in thật sau này) trong `Info.plist`/`AndroidManifest.xml`.
- Cấu hình deep-link (App Links/Universal Links) để mở đúng màn hình chi tiết từ push notification, đúng yêu cầu ở `docs/product/ui-ux-app-benh-nhan.md` mục 3.
