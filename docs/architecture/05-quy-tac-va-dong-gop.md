# Quy tắc & đóng góp code

Tài liệu "sống" chốt các quy ước để nhiều người làm chung không giẫm chân nhau và
kiến trúc không bị xói mòn theo thời gian. Đọc kèm `00-tong-quan-kien-truc.md`
(vì sao) và `01-cau-truc-thu-muc.md` (cây thư mục).

## 1. Ranh giới tầng (được test tự động kiểm)

`test/architecture_test.dart` chạy cùng `flutter test`/CI và **fail** nếu vi phạm:

1. **`data/` không import `presentation/`.** Chiều phụ thuộc luôn là `presentation → data`.
2. **`screens/` và `widgets/` không import `data/repositories/`.** UI lấy repository
   qua **provider** (trả về interface), không import class repository/mock trực tiếp.

> Ví dụ đã sửa: `otp_screen.dart` từng import `mock_auth_repository.dart` chỉ để lấy
> hằng `kMockValidOtp`. Hằng đó đã chuyển sang `core/network/mock_config.dart` để UI
> không phải chạm tầng data. Rút ra: **thứ UI cần dùng thì đừng để nó nằm trong file Mock.**

Các quy tắc chỉ-bằng-quy-ước (chưa/không tự kiểm, cần review bằng mắt):
- `data/models/` là dữ liệu thuần: không `BuildContext`, không logic điều hướng.
- `providers/` là nơi **duy nhất** dựng `Mock*Repository` (composition root của feature).

## 2. Feature dùng chung

Một số feature là **hạ tầng dùng chung**, được feature khác import provider là **hợp lệ**:

- `auth` — trạng thái đăng nhập/phiên.
- `patient_profiles` — hồ sơ bệnh nhân đang chọn (nhiều màn đọc chung).
- `notifications` — badge/đếm thông báo.

Ngoài nhóm trên, **hạn chế** import chéo giữa các feature. Nếu thấy nhiều feature cùng
cần một model/entity (vd đang có `checkin` mượn `queue_status` của `appointments`), cân
nhắc đưa model dùng chung xuống `core/models/` thay vì import chéo. Quy tắc vàng: feature
chỉ import **model** hoặc **provider của feature-dùng-chung**, không bao giờ import
`Mock*Repository` của feature khác.

## 3. Thêm một feature mới

Dùng script sinh khung để mọi feature giống nhau:

```bash
cd app
dart run tool/new_feature.dart lab_results
```

Sinh sẵn `data/{models,repositories}` + `presentation/{providers,screens,widgets}` với
interface + mock + provider mẫu. Sau đó: thêm route ở `core/router/`, rồi `flutter analyze`.

## 4. Xử lý dữ liệu & lỗi

- Repository trả `Result<T>` (`core/network/result.dart`): `Success` hoặc `Failure(AppFailure)`.
  Không ném exception thô lên UI.
- Provider dùng `.dataOrThrow` để Riverpod bắt lỗi vào `AsyncValue.error`.
- Màn hình danh sách/chi tiết **luôn** dùng `AsyncValueView` để tự vẽ loading/error/empty
  — không tự viết if/else từng state. State "permission" (chưa đăng nhập) xử lý ở
  `redirect` của router, không lặp ở widget.

## 5. i18n (đang là nợ kỹ thuật)

Phần lớn text hiện hard-code tiếng Việt trong widget (xem `04-viec-con-lai.md`). Quy tắc
từ nay: **chuỗi hiển thị mới phải qua ARB** (`lib/l10n/app_vi.arb` → `flutter gen-l10n`),
không viết thẳng trong widget; migrate dần chuỗi cũ. Quan trọng cho app y tế (chuẩn hoá,
khả năng đa ngôn ngữ sau này).

## 6. Test

Kiến trúc mock-repository cho phép test **không cần backend, không cần dựng UI**: override
`xxxRepositoryProvider` bằng fake repo rồi đọc provider qua `ProviderContainer`.
- Khuôn mẫu: `test/features/checkin/queue_status_provider_test.dart`.
- Bật/tắt state để test UI: override `mockConfigProvider` (`forceError`/`forceEmpty`).
- Widget key ổn định để tìm trong test: khai báo ở `core/keys.dart` (`AppKeys.*`), không
  rải `Key('chuỗi thô')` khắp nơi.

## 7. Ghép API thật (sau này)

Khi backend sẵn sàng, mỗi feature chỉ đổi **1 dòng** trong `providers/` từ
`Mock*Repository(...)` sang `Api*Repository(...)`. Map lỗi HTTP → `AppFailure` tập trung
qua `core/network/error_mapper.dart` (lý tưởng đặt trong interceptor của client), để UI
không phải sửa gì.

## 8. Quy ước commit & review

- CI (`.github/workflows/ci.yml`) chạy `dart format` + `flutter analyze` + `flutter test`
  trên mỗi PR. PR chỉ merge khi CI xanh.
- `.github/CODEOWNERS` tự gán reviewer theo feature — cập nhật người phụ trách khi team đổi.
- Khuyến khích commit message theo user story để dễ truy vết, vd:
  `[f] 042 - Là bệnh nhân, tôi muốn xem số thứ tự hàng chờ`.
