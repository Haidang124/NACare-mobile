# Danh sách 25 màn hình — route → file

Khớp 1-1 với 25 màn hình trong mockup `NaHealth-UI/NAHealth App.dc.html` (`data-screen-label`). Cột "Trạng thái" phản ánh mức độ hoàn thiện thật của code (không phải mockup).

| # | Tên màn hình (mockup) | Route | File màn hình | Trạng thái |
|---|---|---|---|---|
| 1 | Onboarding | `/onboarding` | `features/auth/presentation/screens/onboarding_screen.dart` | Đầy đủ UI, có 3 slide |
| 2 | Đăng nhập | `/login` | `features/auth/presentation/screens/login_screen.dart` | Đầy đủ, gọi mock `sendOtp` |
| 3 | Xác thực OTP | `/otp` | `features/auth/presentation/screens/otp_screen.dart` | Đầy đủ, có đếm ngược gửi lại, xử lý OTP sai |
| 4 | Liên kết hồ sơ | `/link-profile` | `features/auth/presentation/screens/link_profile_screen.dart` | Đầy đủ 2 nhánh: tìm thấy hồ sơ / tạo hồ sơ mới |
| 5 | Thiết lập PIN | `/pin-setup` | `features/auth/presentation/screens/pin_setup_screen.dart` | Đầy đủ; nút Face ID/vân tay chỉ là placeholder (chưa nối `local_auth`) |
| 6 | Đồng ý dữ liệu (onboarding) | `/consent` | `features/consent/presentation/screens/consent_screen.dart` | Đầy đủ, nội dung tĩnh theo NĐ 13/2023 |
| 7 | Trang chủ | `/home` (tab) | `features/home/presentation/screens/home_screen.dart` | Đầy đủ: card lịch hẹn hôm nay, 4 shortcut, nhắc thuốc, kết quả mới |
| 8 | Lịch khám | `/appointments` (tab) | `features/appointments/presentation/screens/appointments_tab_screen.dart` | Đầy đủ, segment Sắp tới/Đã qua |
| 9 | Kết quả | `/results` (tab) | `features/results/presentation/screens/results_tab_screen.dart` | Đầy đủ |
| 10 | Thông báo | `/notifications` (tab) | `features/notifications/presentation/screens/notifications_screen.dart` | Đầy đủ, có filter chip theo loại |
| 11 | Cá nhân | `/profile` (tab) | `features/profile/presentation/screens/profile_tab_screen.dart` | Đầy đủ: hồ sơ người thân, menu, đăng xuất |
| 12 | Đặt lịch khám (5 bước) | `/appointments/book` | `features/appointments/presentation/screens/book_appointment_screen.dart` | Đầy đủ cả 5 bước (hồ sơ → chuyên khoa → ngày giờ → lý do → xác nhận) |
| 13 | Đặt lịch thành công | `/appointments/book/success` | `features/appointments/presentation/screens/booking_success_screen.dart` | Đầy đủ; nút "thêm vào lịch điện thoại" là placeholder |
| 14 | Chi tiết lịch hẹn | `/appointments/:id` | `features/appointments/presentation/screens/appointment_detail_screen.dart` | Đầy đủ; nút "Đổi lịch" tạm dẫn lại vào luồng đặt lịch |
| 15 | QR Check-in | `/checkin` | `features/checkin/presentation/screens/checkin_screen.dart` | UI đầy đủ; **mã QR chỉ là hình giả** (xem `04-viec-con-lai.md`) |
| 16 | Số thứ tự | `/queue` | `features/checkin/presentation/screens/queue_screen.dart` | UI đầy đủ; dữ liệu tĩnh, chưa có cập nhật realtime |
| 17 | Chi tiết kết quả | `/results/:id` | `features/results/presentation/screens/result_detail_screen.dart` | Đầy đủ, có đánh dấu chỉ số ngoài ngưỡng |
| 18 | Đơn thuốc | `/results/:id/prescription` | `features/prescriptions/presentation/screens/prescription_screen.dart` | Đầy đủ |
| 19 | Nhắc uống thuốc | `/medication-reminders` | `features/prescriptions/presentation/screens/medication_reminders_screen.dart` | Đầy đủ, đánh dấu đã uống cập nhật qua mock repo |
| 20 | Thông tin cá nhân | `/profile/personal-info` | `features/personal_info/presentation/screens/personal_info_screen.dart` | Đầy đủ hiển thị; nút "Chỉnh sửa" là placeholder (chưa có form sửa) |
| 21 | Thanh toán | `/profile/payments` | `features/payments/presentation/screens/payments_screen.dart` | Đầy đủ: khoản cần trả + lịch sử |
| 22 | Chi tiết hóa đơn | `/profile/payments/:id` | `features/payments/presentation/screens/bill_detail_screen.dart` | Đầy đủ; chọn phương thức + xác nhận (mock, chưa nối cổng thanh toán thật) |
| 23 | Sổ tiêm chủng | `/profile/immunization` | `features/immunization/presentation/screens/immunization_screen.dart` | Đầy đủ; nút "Thêm mũi tiêm" là placeholder |
| 24 | Chỉ số sức khỏe | `/profile/health-metrics` | `features/health_metrics/presentation/screens/health_metrics_screen.dart` | Đầy đủ, biểu đồ cột tự vẽ (không dùng thư viện chart); nút "Nhập chỉ số mới" là placeholder |
| 25 | Bảo mật | `/profile/security` | `features/security/presentation/screens/security_screen.dart` | Đầy đủ: toggle PIN/sinh trắc/ẩn nội dung, danh sách thiết bị |
| 25b | Quản lý đồng ý dữ liệu | `/profile/security/consent` | `features/security/presentation/screens/consent_management_screen.dart` | Đầy đủ, có nút "Gửi yêu cầu xóa dữ liệu" |

## Route không có trong mockup nhưng cần cho điều hướng thật

Các route trên dùng path param (`:id`) — mockup gốc là 1 file tĩnh nên không cần, nhưng app thật cần để mở đúng lịch hẹn/kết quả/hóa đơn cụ thể (ví dụ từ deep-link push notification, đúng yêu cầu ở `docs/product/ui-ux-app-benh-nhan.md` mục 3 "Quy tắc điều hướng").

## "5 state" theo checklist thiết kế

Checklist gốc (`docs/product/ui-ux-app-benh-nhan.md` mục 7) yêu cầu mỗi màn hình có đủ normal/empty/loading/error/permission. Trong code:
- **loading / error / empty**: tự động có ở mọi màn hình dùng `AsyncValueView` (xem `00-tong-quan-kien-truc.md` mục 4) — đã áp dụng cho tất cả màn hình danh sách/chi tiết ở trên.
- **permission** (chưa đăng nhập): xử lý tập trung ở `redirect` của `core/router/app_router.dart`, không lặp lại ở từng màn hình.
- **normal**: là nội dung chính đã mô tả ở bảng trên.

Phần **chưa làm đủ**: chưa có ảnh minh hoạ riêng cho từng empty/error state (đang dùng chung 1 bộ icon Material + text), và chưa test "mock data trường hợp dài" (tên rất dài, nhiều thuốc...) — ghi trong `04-viec-con-lai.md`.
