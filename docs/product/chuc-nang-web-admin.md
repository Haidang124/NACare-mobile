# Kế hoạch chức năng web admin (back-office)

Tài liệu này chốt các chức năng cho **web admin/back-office** vận hành và cấu hình app bệnh nhân NAHealth. Dùng kèm với `ke-hoach-20-chuc-nang-app-benh-nhan.md` (app có gì) và `giao-dien-web-admin.md` (web admin trông ra sao). File kế hoạch app trả lời "bệnh nhân dùng gì", file này trả lời "ai vận hành và config những gì phía sau".

## Bối cảnh đã chốt

- Web admin là kênh back-office đã dự trù trong kế hoạch app (mục "Web admin sau này", `ke-hoach-20-chuc-nang-app-benh-nhan.md` dòng 979–981).
- Web admin và app mobile **dùng chung một backend (BFF)** đứng giữa app/web ↔ HIS/EMR. App và web không gọi thẳng HIS/EMR.
- Web admin là **điều kiện chặn go-live 2**: các chức năng chat/tư vấn (12), gói khám (15), đánh giá (19), chăm sóc sau khám (16) chỉ bật được cho bệnh nhân khi đã có tool vận hành tương ứng (kế hoạch app dòng 956).
- App hiện chạy mock data, chưa có backend thật. Web admin gần như là nơi backend thật "đẻ" ra dữ liệu app-owned đầu tiên.
- Mục tiêu đợt này: **quản lý full** — cấu hình danh mục, quản lý nội dung, vận hành hằng ngày, cấu hình hệ thống và giám sát.

## Nguyên tắc dữ liệu: app-owned vs HIS-owned

Phân loại nguồn dữ liệu quyết định web admin được **ghi** hay chỉ được **đọc/đồng bộ**:

- **App-owned** (web admin toàn quyền CRUD, lưu trong DB của backend mobile): nội dung CMS, push/broadcast, gói khám, mẫu chăm sóc sau khám, danh mục vaccine, cấu hình chỉ số sức khỏe, hội thoại chat, đánh giá, consent text, feature flags, tài khoản admin, audit log.
- **HIS-owned** (nguồn gốc ở HIS/EMR/LIS/PACS/billing — web admin chỉ đọc hoặc gửi yêu cầu, không ghi đè): hồ sơ bệnh án, lịch khám gốc, kết quả xét nghiệm/chẩn đoán hình ảnh, đơn thuốc, viện phí.
- **Hybrid** (app tạo yêu cầu, HIS xác nhận): đặt lịch khi HIS chỉ nhận "yêu cầu chờ lễ tân duyệt", liên kết hồ sơ bệnh nhân.

## Kiến trúc & quyết định đề xuất

| Hạng mục | Đề xuất | Lý do |
|---|---|---|
| Backend | **ASP.NET Core Web API + SQL Server (EF Core)**, đóng vai trò BFF chung cho app & web | Team chọn hệ .NET; tách app khỏi HIS. Chi tiết ở repo BE riêng: `../../../NAHealth-BE/docs/ke-hoach-backend-dotnet.md`. |
| Frontend admin | React + TypeScript + Refine (Ant Design) | Sinh nhanh CRUD danh mục — đúng nhu cầu config; tách FE/BE rõ. |
| Auth admin | Tài khoản riêng cho nhân viên (không dùng OTP bệnh nhân) + RBAC + 2FA | Nhân viên nội bộ, cần audit và phân quyền chặt. |
| Realtime | **SignalR** cho chat (12) và bảng hàng chờ (6) | Hai chức năng cần đẩy realtime; SignalR là chuẩn realtime của ASP.NET Core. |
| API contract | Dùng chung OpenAPI spec (Swagger) với app | Cho 3 team (BE/mobile/admin) chạy song song. |

## Vai trò và phân quyền (RBAC)

| Vai trò | Phạm vi chính |
|---|---|
| **Super Admin** | Toàn quyền: danh mục, cấu hình hệ thống, feature flags, quản lý tài khoản admin, xem audit log. |
| **Content/Marketing** | CMS nội dung, push/broadcast, gói khám, banner, tin tức, FAQ. |
| **CSKH** | Inbox chat/tư vấn, xử lý đánh giá & phản hồi, gửi thông báo tới bệnh nhân. |
| **Lễ tân/Điều dưỡng** | Duyệt liên kết/cập nhật hồ sơ, xác nhận/đổi/hủy lịch hẹn, bảng hàng chờ, hỗ trợ check-in. |
| **Bác sĩ/Quản lý chất lượng** | Đọc & phản hồi đánh giá, tư vấn chuyên môn, duyệt nội dung y khoa (mẫu chăm sóc, cấu hình chỉ số). |

Nguyên tắc: mọi hành động ghi đều gắn `actor` (ai), `timestamp`, `before/after` để đưa vào audit log. Truy cập dữ liệu bệnh nhân nhạy cảm phải ghi log kể cả thao tác đọc.

---

## Nhóm A — Danh mục / Master data

### Mục tiêu
Quản lý dữ liệu danh mục nuôi các màn hình app (dropdown, danh sách). Đây là phần "config" cốt lõi nhất; app đang hardcode/mock các danh mục này.

### Chức năng
- **Chuyên khoa**: tên, mô tả, icon, trạng thái hiện/ẩn, thứ tự sắp xếp. (App đã có model `specialty`.)
- **Bác sĩ**: họ tên, chuyên khoa, chức danh, ảnh, mô tả, trạng thái nhận lịch.
- **Phòng khám/địa điểm**: tòa nhà, tầng, phòng, tọa độ GPS, giờ làm việc, hotline (nuôi chức năng 18 bản đồ).
- **Khung giờ/slot đặt lịch**: cấu hình slot theo bác sĩ/chuyên khoa/ngày, số lượng chỗ, quy tắc mở-đóng slot. (Nếu slot lấy từ HIS thì màn hình này chỉ hiển thị read-only.)
- **Gói khám & dịch vụ** (chức năng 15): tên, giá, danh sách dịch vụ trong gói, thời hạn, số lượt còn lại, trạng thái bán.
- **Danh mục vaccine + lịch tiêm chuẩn** (chức năng 17): tên vaccine, số mũi, khoảng cách mũi, nhóm tuổi/đối tượng.
- **Danh mục chỉ số sức khỏe** (chức năng 13/14): loại chỉ số, đơn vị, ngưỡng min/max cảnh báo, nhóm bệnh áp dụng.
- **Danh mục phụ**: loại tài liệu upload, loại thông báo, lý do hủy/đổi lịch.

### Nguồn dữ liệu
Chủ yếu app-owned. Riêng bác sĩ/chuyên khoa/slot có thể đồng bộ từ HIS (khi đó web admin chỉ bổ sung thông tin hiển thị: ảnh, mô tả).

### MVP
CRUD chuyên khoa, bác sĩ, gói khám, danh mục vaccine, danh mục chỉ số + ngưỡng. Bật/tắt hiện-ẩn và sắp xếp thứ tự.

### Cần quyết định
- Slot lịch do app tự quản hay lấy từ HIS? (ảnh hưởng chức năng 4)
- Danh mục bác sĩ/chuyên khoa nhập tay ở admin hay đồng bộ tự động từ HIS?

## Nhóm B — CMS nội dung

### Mục tiêu
Quản lý nội dung hiển thị trong app mà không cần release app mới.

### Chức năng
- **Push notification & broadcast** (chức năng 7): soạn tiêu đề/nội dung, chọn loại, chọn đối tượng (tất cả / theo nhóm / cá nhân), chọn kênh (app/SMS/Zalo/email), gửi ngay hoặc lên lịch, xem trạng thái gửi/đã đọc.
- **Mẫu chăm sóc sau khám** (chức năng 16): soạn hướng dẫn theo ngày, checklist việc cần làm, danh sách dấu hiệu nguy hiểm; gán mẫu theo loại lần khám/thủ thuật; ai tạo là bác sĩ hay admin cần chốt.
- **Banner trang chủ, tin tức**: ảnh, tiêu đề, link hành động, thời gian hiển thị.
- **FAQ**: câu hỏi/trả lời, phân nhóm.
- **Văn bản pháp lý & consent** (chức năng 20): điều khoản sử dụng, chính sách quyền riêng tư, nội dung màn hình đồng ý; có **versioning** — mỗi lần sửa tạo phiên bản mới, ghi nhận thời điểm bệnh nhân đồng ý theo từng phiên bản (bám Nghị định 13/2023/NĐ-CP).

### Nguồn dữ liệu
App-owned toàn bộ.

### MVP
Soạn & gửi push/broadcast, quản lý banner, quản lý văn bản consent có versioning.

### Cần quyết định
- Push dùng Firebase Cloud Messaging; có gửi thêm SMS/Zalo trong phase 1 không?
- Nội dung chăm sóc sau khám do bác sĩ soạn (cần vai trò bác sĩ duyệt) hay admin soạn?

## Nhóm C — Vận hành

### Mục tiêu
Công cụ làm việc hằng ngày để bật được các chức năng go-live 2 và xử lý tương tác bệnh nhân.

### Chức năng
- **Inbox chat/tư vấn** (chức năng 12): danh sách hội thoại, hàng đợi theo chuyên khoa/mức độ, trả lời text, gửi/nhận file, gán hội thoại cho nhân viên, trạng thái (mới/đang xử lý/đã đóng), gợi ý đặt lịch.
- **Xử lý đánh giá & phản hồi** (chức năng 19): danh sách đánh giá theo bác sĩ/dịch vụ, lọc phản hồi tiêu cực, workflow xử lý khiếu nại (tiếp nhận → xử lý → đóng), báo cáo tổng hợp điểm.
- **Duyệt hồ sơ** (chức năng 2/3): duyệt yêu cầu liên kết hồ sơ bệnh nhân, duyệt cập nhật thông tin hành chính nếu bệnh nhân không được tự sửa, xác thực liên kết người thân.
- **Quản lý lịch hẹn** (chức năng 4/5): nếu HIS chỉ nhận "yêu cầu đặt", màn hình cho lễ tân xác nhận/đổi/hủy và phản hồi về app.
- **Bảng hàng chờ / gọi số** (chức năng 6): nếu bệnh viện chưa có hệ thống lấy số, cung cấp bảng gọi số tối thiểu; nếu đã có, chỉ hiển thị/giám sát.

### Nguồn dữ liệu
Chat, đánh giá: app-owned. Lịch hẹn, hồ sơ: hybrid/HIS-owned (web admin gửi yêu cầu, HIS xác nhận).

### MVP (điều kiện go-live 2)
Inbox chat trả lời được, xử lý đánh giá cơ bản. Duyệt hồ sơ và quản lý lịch hẹn tùy theo cách HIS vận hành.

### Cần quyết định
- Ai trực chat: CSKH, điều dưỡng hay bác sĩ? (kế hoạch app câu hỏi 11)
- Bệnh nhân tự sửa thông tin hành chính hay cần lễ tân duyệt? (kế hoạch app mục 2)
- HIS cho app tạo lịch trực tiếp hay chỉ gửi yêu cầu chờ duyệt? (kế hoạch app câu hỏi 3)

## Nhóm D — Cấu hình hệ thống

### Mục tiêu
Điều khiển hành vi app từ xa và quản trị chính web admin.

### Chức năng
- **Feature flags**: bật/tắt từng chức năng của app theo đợt go-live, theo môi trường, theo nhóm người dùng (rollout dần). Trực tiếp phục vụ chiến lược 2 lần go-live.
- **Force update / phiên bản tối thiểu**: cấu hình version tối thiểu theo nền tảng iOS/Android, nội dung thông báo ép cập nhật.
- **Cấu hình kênh gửi**: khóa/khai báo FCM, SMS, Zalo, email.
- **Cấu hình môi trường**: quản lý base URL/tham số dev/staging/prod (chỉ Super Admin).
- **Quản lý tài khoản admin & RBAC**: tạo/khóa tài khoản nhân viên, gán vai trò, reset mật khẩu, bắt buộc 2FA.

### Nguồn dữ liệu
App-owned.

### MVP
Feature flags, force update, quản lý tài khoản admin + phân quyền.

### Cần quyết định
- Feature flag theo môi trường thôi hay có cả rollout theo % người dùng?

## Nhóm E — Giám sát

### Mục tiêu
Nhìn được sức khỏe vận hành và đảm bảo tuân thủ.

### Chức năng
- **Dashboard thống kê**: số đăng ký mới, đặt lịch thành công, tỷ lệ hủy lịch, lượt xem kết quả, điểm đánh giá trung bình, số hội thoại chat đang mở (khớp analytics kế hoạch app dòng 1000).
- **Audit log** (chức năng 20): ai truy cập hồ sơ nào, khi nào; mọi thao tác ghi của admin; tra cứu theo actor/đối tượng/thời gian. Cân nhắc cho bệnh nhân xem phần liên quan tới mình.
- **Quản lý thiết bị/phiên đăng nhập**: xem và thu hồi phiên của bệnh nhân/nhân viên khi cần.

### Nguồn dữ liệu
App-owned (log sinh từ chính backend BFF).

### MVP
Dashboard cơ bản + audit log truy cập dữ liệu nhạy cảm.

---

## Roadmap (bám go-live của app)

### Phase 0 — Nền tảng (2–3 tuần)
Dựng backend BFF + PostgreSQL, auth admin + RBAC, khung Refine, 1 CRUD mẫu (chuyên khoa). Đây cũng là lúc chuyển module đầu tiên của app từ mock sang API thật.

### Phase 1 — Hỗ trợ go-live 1
Danh mục đặt lịch (chuyên khoa/bác sĩ/slot/địa điểm), push & broadcast, văn bản consent có versioning, feature flags, audit log, dashboard cơ bản.

### Phase 2 — Hỗ trợ go-live 2 (bắt buộc trước khi bật chức năng cho bệnh nhân)
Inbox chat, gói khám, xử lý đánh giá, mẫu chăm sóc sau khám, danh mục vaccine, cấu hình chỉ số sức khỏe.

### Phase 3 — Hoàn thiện
Quản lý file upload, đối soát/xem viện phí, thống kê nâng cao, quản lý thiết bị/phiên, quản lý lịch hẹn nâng cao.

## Yêu cầu phi chức năng & tuân thủ

- **Bảo mật**: auth admin tách khỏi bệnh nhân, bắt buộc 2FA cho vai trò có quyền ghi, HTTPS, phân quyền chặt theo RBAC.
- **Audit**: mọi thao tác ghi và mọi truy cập dữ liệu nhạy cảm phải log (Nghị định 13/2023).
- **Consent & xóa dữ liệu**: consent có versioning; hỗ trợ xử lý yêu cầu xóa tài khoản/dữ liệu phía app (hồ sơ bệnh án trên HIS giữ theo quy định y tế, app chỉ xóa liên kết & dữ liệu phía app).
- **Môi trường**: dev/staging/prod, CI/CD, phân tách cấu hình.
- **Sao lưu**: backup DB app-owned định kỳ.

## Câu hỏi cần chốt tiếp

1. Slot lịch và danh mục bác sĩ/chuyên khoa: app tự quản hay đồng bộ từ HIS?
2. HIS cho app tạo lịch trực tiếp hay chỉ gửi yêu cầu chờ lễ tân duyệt?
3. Bệnh nhân tự sửa thông tin hành chính hay cần lễ tân duyệt?
4. Ai trực chat/tư vấn: CSKH, điều dưỡng hay bác sĩ?
5. Nội dung chăm sóc sau khám do bác sĩ soạn (cần workflow duyệt) hay admin soạn?
6. Ngoài push app, có gửi SMS/Zalo trong phase 1 không?
7. Audit log có cho bệnh nhân xem phần liên quan tới mình không?
