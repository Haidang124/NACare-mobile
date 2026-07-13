# Tổng quan kiến trúc app Flutter NACare

Tài liệu này giải thích **vì sao** app được tổ chức như hiện tại. Xem thêm `01-cau-truc-thu-muc.md` (cây thư mục), `02-danh-sach-man-hinh.md` (route → file), `03-mock-api-va-repository.md` (cách tách UI khỏi gọi API), `04-viec-con-lai.md` (việc chưa làm).

## 1. Lựa chọn công nghệ

| Quyết định | Lý do |
|---|---|
| **Flutter + Riverpod (không dùng code generator)** | Tách UI khỏi gọi API rõ ràng qua provider; không cần `build_runner` nên compile được ngay cả khi chưa cài Flutter SDK để chạy codegen. |
| **go_router + `StatefulShellRoute.indexedStack`** | 5 tab (Trang chủ, Lịch khám, Kết quả, Thông báo, Cá nhân) giữ state/scroll riêng khi chuyển tab, đúng yêu cầu điều hướng ở `docs/product/ui-ux-app-benh-nhan.md` mục 3. |
| **google_fonts (Be Vietnam Pro)** | Đúng font trong mockup, không cần tự bundle file `.ttf`. |
| **Không dùng freezed/json_serializable** | Cả hai cần `build_runner` sinh file `.g.dart`/`.freezed.dart`. Model ở đây viết tay (immutable, `copyWith` thủ công) để project luôn compile được ngay sau `flutter pub get`, không phụ thuộc bước generate riêng. Khi ghép API thật và model phức tạp hơn, có thể cân nhắc thêm lại. |
| **Mock repository thay vì gọi API thật** | Bệnh viện chưa cung cấp API (xem `docs/product/ke-hoach-20-chuc-nang-app-benh-nhan.md`). Kiến trúc repository interface + implementation cho phép thay mock bằng API thật mà **không đổi bất kỳ widget nào** — xem `03-mock-api-va-repository.md`. |

## 2. Nguyên tắc tách lớp

Mỗi feature chia 2 tầng:

```
feature/
  data/            <- Model + Repository (nói chuyện với "nguồn dữ liệu")
    models/
    repositories/
  presentation/    <- UI + state điều khiển UI
    providers/     <- Riverpod provider/notifier, gọi repository
    screens/       <- Widget toàn màn hình, chỉ đọc provider
    widgets/       <- Widget con dùng riêng trong feature
```

Quy tắc:
- **`screens/` không bao giờ gọi trực tiếp `MockXxxRepository`.** Luôn qua `xxxRepositoryProvider` (kiểu trả về là interface `XxxRepository`, không phải class mock) rồi qua 1 `FutureProvider`/`Notifier` ở `providers/`.
- **`data/` không import gì từ `presentation/`.** Chiều phụ thuộc luôn là `presentation → data`, không ngược lại.
- Model ở `data/models/` là dữ liệu thuần (không có logic điều hướng, không có `BuildContext`).
- Đổi mock → API thật: chỉ sửa **1 dòng** trong file `xxx_providers.dart` của feature đó (dòng tạo `MockXxxRepository(...)` → `ApiXxxRepository(...)`).

## 3. Vì sao feature-first, không phải layer-first

Cấu trúc theo feature (không gom hết `screens/` toàn app vào 1 thư mục, hết `models/` vào 1 thư mục khác) để:
- Xoá/thêm 1 chức năng (ví dụ bỏ "Sổ tiêm chủng" ở go-live sau) chỉ động vào 1 thư mục `features/immunization/`.
- Dễ giao việc: mỗi lập trình viên nhận 1-2 thư mục `features/*`, ít đụng code nhau.
- `core/` chỉ chứa thứ **thật sự dùng chung** (theme, router, network, design-system widget) — tránh biến `core/` thành nơi chứa mọi thứ không rõ thuộc về đâu.

## 4. State cho 1 màn hình dữ liệu điển hình

```
FutureProvider  →  AsyncValue<T>  →  AsyncValueView<T>  →  loading / error / empty / data
```

`AsyncValueView` (`lib/core/widgets/states/async_value_view.dart`) là điểm nối UI ↔ dữ liệu: mọi màn hình danh sách/chi tiết dùng chung widget này để tự động vẽ đúng skeleton loading, `ErrorStateView` (có nút "Thử lại"), hoặc `EmptyStateView`, theo đúng checklist 5-state ở `docs/product/ui-ux-app-benh-nhan.md` mục 7. State "permission" (chưa đăng nhập) được xử lý ở tầng router (`redirect`), không phải trong từng widget.
