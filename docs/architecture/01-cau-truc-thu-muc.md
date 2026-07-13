# Cấu trúc thư mục

```
app/
├── lib/
│   ├── main.dart                 # entrypoint, bọc ProviderScope
│   ├── app.dart                  # MaterialApp.router + theme + l10n + font-scale clamp
│   ├── l10n/
│   │   ├── app_vi.arb             # nguồn string tiếng Việt (chrome chung: nav, nút, state)
│   │   └── app_localizations.dart # SINH RA bởi `flutter gen-l10n` — không có sẵn trong repo
│   ├── core/                      # dùng chung toàn app, KHÔNG chứa logic riêng 1 feature
│   │   ├── theme/                 # app_colors.dart, app_typography.dart, app_spacing.dart, app_theme.dart
│   │   ├── router/                # app_routes.dart (hằng số path), app_router.dart (GoRouter)
│   │   ├── network/               # result.dart (Result<T>/AppFailure), mock_config.dart (fake delay/error)
│   │   ├── utils/                 # currency.dart...
│   │   └── widgets/                # design-system: buttons/, inputs/, cards/, badges/, states/, nav/, dialogs/, avatar/, misc/
│   │       └── widgets.dart        # barrel export — feature chỉ cần import file này
│   └── features/
│       ├── auth/                  # onboarding, đăng nhập, OTP, liên kết hồ sơ, PIN
│       ├── consent/                # màn hình đồng ý dữ liệu (onboarding, bắt buộc 1 lần)
│       ├── patient_profiles/       # hồ sơ bệnh nhân + người thân — dùng chung nhiều feature
│       ├── shell/                  # khung 5 tab (AppShell + bottom nav)
│       ├── home/                   # trang chủ / dashboard
│       ├── appointments/           # tab Lịch khám, đặt lịch 5 bước, chi tiết, thành công
│       ├── checkin/                # QR check-in + số thứ tự
│       ├── results/                # tab Kết quả, chi tiết kết quả + xét nghiệm
│       ├── prescriptions/          # đơn thuốc, nhắc uống thuốc
│       ├── notifications/          # tab Thông báo
│       ├── profile/                # tab Cá nhân (menu, người thân, đăng xuất)
│       ├── personal_info/          # thông tin hành chính + BHYT + tiền sử
│       ├── payments/                # thanh toán + lịch sử + chi tiết hóa đơn
│       ├── immunization/           # sổ tiêm chủng
│       ├── health_metrics/         # chỉ số sức khỏe
│       └── security/                # bảo mật (PIN/sinh trắc/thiết bị) + quản lý đồng ý dữ liệu
├── assets/images/logo.jpg          # copy từ NaCare-UI/assets/logo.jpg
├── plan/                            # bạn đang đọc thư mục này
├── pubspec.yaml
├── analysis_options.yaml
└── l10n.yaml
```

## Vì sao mỗi feature lại có `data/` và `presentation/` riêng

Xem lý do đầy đủ ở `00-tong-quan-kien-truc.md` mục 2. Tóm tắt: **UI (`presentation/`) không bao giờ import trực tiếp class Mock*Repository** — luôn qua provider. Điều này giúp:
1. Test UI bằng cách override provider bằng dữ liệu giả tuỳ ý, không cần chạy network.
2. Bật `forceError`/`forceEmpty`/tăng `minDelay` trong `mockConfigProvider` (xem `03-mock-api-va-repository.md`) để soi trạng thái loading/error/empty của MỌI feature cùng lúc, không phải sửa từng file.
3. Khi có API thật, người ghép API chỉ cần biết interface (`XxxRepository`) và không cần đọc code UI.

## Vị trí đặt code mới

- Thêm 1 màn hình cho feature đã có → thêm file trong `features/<feature>/presentation/screens/`, thêm route trong `core/router/app_router.dart`, thêm hằng số path trong `core/router/app_routes.dart`.
- Thêm 1 chức năng hoàn toàn mới (ví dụ "Gói khám", "Chat tư vấn" ở go-live 2) → tạo `features/<feature_moi>/` theo đúng khuôn `data/` + `presentation/` như các feature hiện có.
- Thêm 1 widget dùng chung cho ≥ 2 feature → đặt trong `core/widgets/<nhom>/`, export thêm 1 dòng trong `core/widgets/widgets.dart`. Nếu chỉ 1 feature dùng, để trong `features/<feature>/presentation/widgets/`.
