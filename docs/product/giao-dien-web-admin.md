# Giao diện web admin (back-office)

Tài liệu này mô tả UI/UX cho **web admin/back-office** của NAHealth, dùng kèm với `chuc-nang-web-admin.md`. File chức năng trả lời "web admin làm được gì", file này trả lời "người vận hành đi qua web admin như thế nào và màn hình trông ra sao".

Đối tượng người dùng: nhân viên nội bộ bệnh viện (Super Admin, Content/Marketing, CSKH, Lễ tân/Điều dưỡng, Bác sĩ/QLCL) — làm việc trên desktop, không phải bệnh nhân.

## 1. Nguyên tắc thiết kế

- **Ưu tiên hiệu suất làm việc, không phải marketing**: web admin là công cụ nội bộ. Ưu tiên bảng dữ liệu dày, lọc mạnh, thao tác hàng loạt, phím tắt — không cần hiệu ứng đẹp.
- **Desktop-first**: layout tối ưu cho màn ≥1366px, dùng được tới ~1024px. Không cần responsive mobile (nhân viên dùng máy tính).
- **Nhất quán CRUD**: mọi danh mục theo cùng một khuôn — list có filter/search → form tạo/sửa → xác nhận xóa. Học 1 màn hình là dùng được mọi màn hình.
- **Phân quyền hiển thị theo vai trò**: menu và nút hành động ẩn/hiện theo RBAC. Không hiện nút mà vai trò không có quyền bấm.
- **An toàn thao tác ghi**: mọi hành động xóa/gửi hàng loạt/đổi cấu hình hệ thống đều có dialog xác nhận, ghi rõ hệ quả. Thao tác không thể hoàn tác phải cảnh báo rõ.
- **Minh bạch & audit**: màn hình chi tiết hiển thị "sửa lần cuối bởi ai, lúc nào"; dữ liệu bệnh nhân nhạy cảm luôn kèm nhắc "truy cập này được ghi log".
- **Trạng thái rõ ràng**: mỗi bảng/màn hình có đủ state loading (skeleton), empty (kèm nút tạo mới), error (nút thử lại), no-permission (giải thích thiếu quyền).

## 2. Design system

### Layout shell
- **Sidebar trái** (cố định): logo + điều hướng nhóm module (A–E), thu gọn được thành icon.
- **Topbar**: breadcrumb, ô tìm kiếm toàn cục, chuông thông báo nội bộ (chat mới, đánh giá tiêu cực mới), menu tài khoản + vai trò + đăng xuất, chọn môi trường (dev/staging/prod) cho Super Admin.
- **Content area**: tiêu đề trang + hành động chính (nút "Tạo mới") góc phải + vùng bảng/form.

### Màu sắc
- Dùng lại tông xanh y tế của app (primary #0E7490) cho nút chính, menu active.
- Semantic: success (đã gửi, đã duyệt), warning (chờ xử lý, sắp hết hạn), error (từ chối, đánh giá tiêu cực, vượt ngưỡng), info.
- Nền sáng, mật độ cao (compact table). Trạng thái dùng badge có chữ, không chỉ dựa màu.

### Component nền tảng (Refine + Ant Design)
- **Data table**: cột sắp xếp được, filter theo cột, phân trang, chọn dòng để thao tác hàng loạt, ẩn/hiện cột, export CSV.
- **Form**: input, select, multi-select, date/time picker, rich-text (cho CMS), upload ảnh/file, toggle, validate inline.
- **Filter bar**: search + bộ lọc theo trạng thái/thời gian/vai trò, đặt phía trên bảng.
- **Drawer/Modal**: xem nhanh chi tiết hoặc form tạo/sửa mà không rời danh sách.
- **Badge trạng thái**, **tag**, **empty/error/skeleton state**, **dialog xác nhận**, **toast**.
- **Audit panel**: khối "lịch sử thay đổi" ở cuối màn hình chi tiết.
- **Rich-text editor** cho FAQ, tin tức, văn bản pháp lý, mẫu chăm sóc.
- **Chat panel** 3 cột cho inbox tư vấn.

## 3. Kiến trúc điều hướng (sidebar)

Sidebar nhóm theo module chức năng, ẩn/hiện theo RBAC:

1. **Tổng quan** — Dashboard thống kê.
2. **Danh mục** — Chuyên khoa, Bác sĩ, Phòng khám/Địa điểm, Khung giờ/Slot, Gói khám & dịch vụ, Vaccine, Chỉ số sức khỏe, Danh mục phụ.
3. **Nội dung** — Push & Broadcast, Mẫu chăm sóc sau khám, Banner & Tin tức, FAQ, Văn bản pháp lý & Consent.
4. **Vận hành** — Inbox chat/tư vấn, Đánh giá & Phản hồi, Duyệt hồ sơ, Quản lý lịch hẹn, Bảng hàng chờ.
5. **Cấu hình** — Feature flags, Force update, Kênh gửi, Môi trường, Tài khoản admin & Phân quyền.
6. **Giám sát** — Audit log, Thiết bị/Phiên đăng nhập.

Quy tắc điều hướng: click dòng trong bảng → mở trang chi tiết hoặc drawer; breadcrumb cho phép quay lại danh sách; thao tác giữa chừng form chưa lưu mà rời trang phải hỏi "hủy thay đổi?".

## 4. Mô tả màn hình theo module

### 4.1 Dashboard (Tổng quan)
- Hàng thẻ KPI: đăng ký mới, đặt lịch thành công, tỷ lệ hủy lịch, lượt xem kết quả, điểm đánh giá TB, hội thoại chat đang mở.
- Biểu đồ xu hướng theo thời gian (7/30 ngày), lọc theo môi trường.
- Danh sách "việc cần xử lý": chat chưa trả lời, đánh giá tiêu cực mới, hồ sơ chờ duyệt — click đi thẳng màn hình liên quan.

### 4.2 Danh mục (khuôn CRUD chung)
Mọi màn hình danh mục theo cùng một khuôn:
- **List view**: filter bar (search + trạng thái hiện/ẩn) + data table (tên, trạng thái, thứ tự, sửa lần cuối) + nút "Tạo mới".
- **Form tạo/sửa** (drawer bên phải): các trường theo từng danh mục; validate inline; toggle hiện/ẩn; kéo-thả sắp thứ tự.
- Ví dụ trường đặc thù:
  - **Gói khám**: tên, giá, danh sách dịch vụ (thêm nhiều dòng), thời hạn, số lượt, trạng thái bán.
  - **Vaccine**: tên, số mũi, khoảng cách mũi, nhóm tuổi/đối tượng.
  - **Chỉ số sức khỏe**: loại, đơn vị, ngưỡng min/max cảnh báo, nhóm bệnh áp dụng.
  - **Slot đặt lịch**: chọn bác sĩ/chuyên khoa → lịch tuần dạng grid, đặt số chỗ mỗi khung giờ, mở/đóng nhanh. (Read-only nếu lấy từ HIS, kèm banner "đồng bộ từ HIS".)

### 4.3 Nội dung
- **Push & Broadcast**: list các chiến dịch (trạng thái nháp/đã lên lịch/đã gửi) + form soạn: tiêu đề, nội dung, loại, đối tượng (tất cả / nhóm / cá nhân qua tìm bệnh nhân), kênh (app/SMS/Zalo/email), gửi ngay hoặc hẹn giờ, **preview** dạng notification. Sau khi gửi có báo cáo: đã gửi/đã đọc.
- **Mẫu chăm sóc sau khám**: editor theo ngày (Ngày 1, Ngày 2…) với checklist và khối "dấu hiệu nguy hiểm"; gán mẫu theo loại lần khám; nếu cần bác sĩ duyệt thì có trạng thái nháp → chờ duyệt → xuất bản.
- **Banner & Tin tức**: upload ảnh, tiêu đề, link hành động, thời gian hiển thị, preview vị trí trên trang chủ app.
- **FAQ**: rich-text, phân nhóm, sắp thứ tự.
- **Văn bản pháp lý & Consent**: rich-text + **danh sách phiên bản** (v1, v2…), nút "Xuất bản phiên bản mới"; hiển thị bao nhiêu bệnh nhân đã đồng ý theo từng phiên bản. Cảnh báo rõ: xuất bản phiên bản mới có thể yêu cầu bệnh nhân đồng ý lại.

### 4.4 Vận hành
- **Inbox chat/tư vấn** (layout 3 cột): cột trái = danh sách hội thoại (lọc theo hàng đợi/chuyên khoa/trạng thái, badge chưa đọc); cột giữa = khung chat (tin nhắn, gửi text/file, realtime); cột phải = thông tin bệnh nhân + nút "gợi ý đặt lịch", gán nhân viên, đóng hội thoại. Thao tác nhạy cảm nhắc "truy cập được ghi log".
- **Đánh giá & Phản hồi**: bảng đánh giá (điểm sao, đối tượng bác sĩ/dịch vụ, nội dung, trạng thái xử lý), lọc nhanh "phản hồi tiêu cực"; mở chi tiết → workflow tiếp nhận → xử lý → đóng, ghi chú nội bộ; tab báo cáo tổng hợp điểm theo bác sĩ/dịch vụ.
- **Duyệt hồ sơ**: hàng đợi yêu cầu (liên kết hồ sơ, cập nhật thông tin, liên kết người thân); mỗi mục có nút Duyệt/Từ chối kèm lý do; đối chiếu dữ liệu bệnh nhân nhập với dữ liệu HIS.
- **Quản lý lịch hẹn**: bảng lịch hẹn theo ngày/bác sĩ/trạng thái; xác nhận/đổi/hủy yêu cầu từ app và phản hồi lại; chỉ hiện khi HIS vận hành theo mô hình "yêu cầu chờ duyệt".
- **Bảng hàng chờ**: bảng gọi số theo phòng/quầy, cập nhật realtime; nút gọi số tiếp theo; chỉ dùng nếu bệnh viện chưa có hệ thống lấy số riêng.

### 4.5 Cấu hình
- **Feature flags**: bảng cờ (tên chức năng, trạng thái theo môi trường dev/staging/prod, nhóm áp dụng), toggle nhanh; đổi cờ prod có dialog xác nhận. Nhóm cờ theo đợt go-live.
- **Force update**: form phiên bản tối thiểu theo nền tảng, nội dung màn hình ép cập nhật, preview.
- **Kênh gửi**: cấu hình FCM/SMS/Zalo/email, nút gửi thử.
- **Môi trường**: tham số theo dev/staging/prod — chỉ Super Admin, có cảnh báo khi sửa prod.
- **Tài khoản admin & Phân quyền**: bảng nhân viên (tên, email, vai trò, trạng thái, đăng nhập gần nhất); form tạo/khóa tài khoản, gán vai trò, reset mật khẩu, bắt buộc 2FA; ma trận quyền theo vai trò dạng bảng tick.

### 4.6 Giám sát
- **Audit log**: bảng log (actor, hành động, đối tượng, thời gian, before/after), filter mạnh theo actor/loại/khoảng thời gian, export. Highlight truy cập dữ liệu bệnh nhân nhạy cảm.
- **Thiết bị/Phiên đăng nhập**: bảng phiên (người dùng, thiết bị, IP, lần cuối), nút thu hồi phiên.

## 5. Pattern dùng lại toàn hệ thống

- **Bảng danh sách**: search + filter theo cột + phân trang + chọn nhiều dòng để thao tác hàng loạt (ẩn/hiện, xóa, xuất bản) + export CSV.
- **Form**: validate inline, nút Lưu cố định, nhắc "chưa lưu" khi rời trang, hiện "sửa lần cuối bởi ai".
- **Xác nhận thao tác nguy hiểm**: dialog ghi rõ hệ quả; thao tác gửi hàng loạt / đổi cấu hình prod / xóa cần gõ xác nhận hoặc tick "tôi hiểu".
- **Trạng thái**: loading skeleton, empty (kèm nút tạo mới), error (nút thử lại), no-permission (giải thích thiếu quyền, không ẩn trắng).
- **Audit panel**: khối lịch sử thay đổi ở cuối mọi màn hình chi tiết app-owned.

## 6. Checklist nghiệm thu UI mỗi màn hình

- [ ] Menu & nút hành động ẩn/hiện đúng theo vai trò RBAC.
- [ ] Đủ state: loading (skeleton), empty (có nút tạo), error (nút thử lại), no-permission.
- [ ] Bảng có search + filter + phân trang; danh sách dài không vỡ layout.
- [ ] Form validate inline, chặn rời trang khi chưa lưu, hiện người sửa cuối.
- [ ] Thao tác xóa/gửi hàng loạt/đổi cấu hình prod có dialog xác nhận rõ hệ quả.
- [ ] Màn hình chạm dữ liệu bệnh nhân nhạy cảm: nhắc ghi log và thực sự ghi audit.
- [ ] Text qua i18n (chuẩn bị song ngữ Việt–Anh như app), không hard-code.
- [ ] Dữ liệu HIS-owned hiển thị read-only kèm banner nguồn "đồng bộ từ HIS".

## 7. Việc cần làm tiếp cho UI web admin

1. Chốt wireframe layout shell (sidebar + topbar + khuôn CRUD) trước — vì mọi màn hình danh mục tái dùng.
2. Vẽ chi tiết 3 màn hình đặc thù không theo khuôn CRUD: Inbox chat (3 cột), Dashboard, Văn bản & Consent (versioning).
3. Chốt bảng ma trận RBAC (vai trò × quyền) để dựng phân quyền hiển thị.
4. Đồng bộ design token (màu, typography) với app để nhất quán thương hiệu.
