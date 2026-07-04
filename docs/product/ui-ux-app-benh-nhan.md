# UI/UX app mobile cho bệnh nhân

Tài liệu này mô tả thiết kế UI/UX cho app Flutter bệnh nhân, dùng kèm với `ke-hoach-20-chuc-nang-app-benh-nhan.md`. File kế hoạch trả lời "app có chức năng gì", file này trả lời "bệnh nhân đi qua app như thế nào và màn hình trông ra sao".

Phạm vi chi tiết: go-live 1 (Đợt 1–3). Các chức năng go-live 2 chỉ mô tả mức navigation, sẽ bổ sung flow chi tiết sau.

## 1. Nguyên tắc thiết kế

- **Người cao tuổi dùng được**: cỡ chữ tối thiểu 16sp cho nội dung chính, hỗ trợ font scale của hệ điều hành, nút bấm cao tối thiểu 48dp, tương phản đạt WCAG AA, không dựa vào màu sắc đơn thuần để truyền đạt trạng thái.
- **Mỗi màn hình có đủ 5 state**: normal, empty, loading, error, permission (chưa đăng nhập/chưa liên kết hồ sơ/chưa cấp quyền). Màn hình chưa đủ 5 state thì chưa được coi là xong.
- **Ít chữ, nhiều hành động rõ**: bệnh nhân đang lo lắng và vội. Mỗi màn hình có 1 hành động chính (primary button) duy nhất, đặt cố định dưới màn hình.
- **Không bắt đăng nhập để xem nội dung công khai**: danh sách chuyên khoa, bác sĩ, gói khám, địa chỉ bệnh viện xem được trước khi đăng nhập. Chỉ chạm vào dữ liệu cá nhân mới yêu cầu đăng nhập.
- **Dữ liệu y tế nhạy cảm**: không hiện chi tiết kết quả/chẩn đoán trên push notification, ẩn nội dung màn hình khi app vào background, màn hình kết quả yêu cầu PIN/sinh trắc học nếu bệnh nhân đã bật khóa app.
- **i18n-ready**: toàn bộ text qua ARB file ngay từ đầu, không hard-code, kể cả khi go-live 1 chỉ có tiếng Việt.
- **Offline nhất quán**: dữ liệu đã xem (lịch hẹn, kết quả đã mở) xem lại được khi mất mạng, kèm banner "đang xem bản lưu". Hành động ghi (đặt lịch, thanh toán) báo lỗi rõ và có nút thử lại.

## 2. Design system

### Màu sắc (cho đến khi có brand guideline của bệnh viện)
- Primary: xanh y tế (#0E7490 gợi ý) — dùng cho hành động chính, tab active.
- Secondary/accent: dùng hạn chế, cho badge và trạng thái.
- Semantic: success (kết quả bình thường, thanh toán xong), warning (sắp đến hạn, chờ xử lý), error (hủy, quá hạn, vượt ngưỡng), info.
- Nền sáng là mặc định. Dark mode chưa làm ở go-live 1 nhưng token màu phải đặt tên theo ngữ nghĩa (surface, on-surface...) để thêm sau.

### Typography
- 1 font chữ (gợi ý: Be Vietnam Pro hoặc Inter — hỗ trợ tiếng Việt tốt).
- Thang cỡ chữ: display 24, title 20, body 16, caption 13. Tất cả theo sp và respect font scale.

### Component cần có trong design system Flutter
- Button: primary, secondary, text, destructive; có trạng thái loading và disabled.
- Input: text, phone, OTP 6 ô, date picker, dropdown, search.
- Card: lịch hẹn, kết quả, đơn thuốc, hóa đơn, gói khám — cùng khung, khác nội dung.
- List item, section header, divider.
- Bottom navigation, app bar, tab bar phụ.
- Dialog xác nhận, bottom sheet chọn lựa, toast/snackbar.
- Trạng thái: empty state (hình + 1 câu + 1 nút), error state (hình + lý do + nút thử lại), skeleton loading.
- Badge trạng thái lịch hẹn/thanh toán/kết quả (màu + chữ, không chỉ màu).
- QR code hiển thị (check-in) và màn hình số thứ tự cỡ lớn.
- Profile switcher: chip/avatar chuyển hồ sơ người thân, xuất hiện ở mọi màn hình có dữ liệu theo hồ sơ.

## 3. Kiến trúc điều hướng

### Bottom navigation: 5 tab
1. **Trang chủ** — lời chào + hồ sơ đang chọn, lịch hẹn gần nhất, số thứ tự nếu đang chờ khám, shortcut 4 hành động (Đặt lịch, Kết quả, Đơn thuốc, Thanh toán), thông báo chưa đọc.
2. **Lịch khám** — danh sách lịch hẹn (sắp tới / đã qua), nút đặt lịch mới, vào chi tiết để đổi/hủy/check-in.
3. **Kết quả** — danh sách lần khám đã hoàn tất, vào chi tiết xem kết quả, xét nghiệm, đơn thuốc.
4. **Thông báo** — trung tâm thông báo, lọc theo loại.
5. **Cá nhân** — hồ sơ, người thân, bảo hiểm, thanh toán/lịch sử giao dịch, sổ tiêm chủng, chỉ số sức khỏe, cài đặt bảo mật, đồng ý, đăng xuất.

Các chức năng go-live 2 (gói khám, chat/tư vấn, upload hồ sơ, chăm sóc sau khám, đánh giá) treo dưới tab Cá nhân hoặc shortcut trang chủ, ẩn bằng feature flag cho đến khi bật.

### Quy tắc điều hướng
- Deep-link từ push notification mở thẳng màn hình chi tiết (lịch hẹn, kết quả, hóa đơn), back về tab tương ứng, không về trang trống.
- Luồng nhiều bước (đặt lịch, đăng ký) có step indicator và giữ được dữ liệu khi back từng bước.
- Thoát luồng nhiều bước giữa chừng phải có dialog xác nhận "hủy bỏ thông tin đã nhập?".

## 4. Luồng người dùng chính (user flows) — go-live 1

Mỗi luồng ghi rõ: bước, rẽ nhánh lỗi, và màn hình kết thúc.

### Flow A: Đăng ký lần đầu và liên kết hồ sơ
1. Onboarding 2–3 slide (bỏ qua được) → màn hình đăng nhập/đăng ký.
2. Nhập số điện thoại → nhận OTP → nhập OTP 6 số.
   - Lỗi: OTP sai (báo ngay tại ô nhập), hết hạn (nút gửi lại có đếm ngược), quá số lần (khóa tạm, hướng dẫn gọi hotline).
3. Hệ thống tìm hồ sơ theo số điện thoại trên HIS:
   - Tìm thấy 1 hồ sơ → xác nhận thông tin (che bớt: "Nguyễn Văn A***, sinh 19xx") → liên kết.
   - Tìm thấy nhiều hồ sơ → chọn đúng hồ sơ, xác minh thêm (ngày sinh/CCCD).
   - Không tìm thấy → tạo hồ sơ mới: họ tên, ngày sinh, giới tính, CCCD (tối thiểu).
4. Thiết lập PIN + gợi ý bật sinh trắc học (bỏ qua được).
5. Màn hình đồng ý sử dụng dữ liệu (bắt buộc đọc và đồng ý trước khi vào app — theo NĐ 13/2023).
6. Kết thúc: Trang chủ.

### Flow B: Đặt lịch khám
1. Vào từ: nút Đặt lịch (trang chủ) / tab Lịch khám / đặt lại từ lịch sử.
2. Chọn hồ sơ khám (mặc định là hồ sơ đang chọn; đổi được sang người thân).
3. Chọn chuyên khoa hoặc dịch vụ (tìm kiếm + danh sách).
4. Chọn bác sĩ (nếu bệnh viện cho phép) hoặc bỏ qua → chọn ngày (calendar, ngày hết slot bị mờ) → chọn khung giờ.
5. Nhập lý do khám/triệu chứng (tùy chọn nhưng khuyến khích).
6. Màn hình xác nhận: hồ sơ, chuyên khoa, bác sĩ, thời gian, địa điểm, phí dự kiến nếu có.
7. Xác nhận → loading → kết quả:
   - Thành công: màn hình thành công có mã lịch hẹn + QR + nút "Thêm vào lịch điện thoại" + hướng dẫn đến khám.
   - Slot vừa hết: báo rõ và đưa về bước chọn giờ với slot đã cập nhật.
   - Lỗi mạng: giữ nguyên dữ liệu, nút thử lại.

### Flow C: Đi khám trong ngày (check-in → hàng chờ)
1. Ngày khám, trang chủ hiện card lịch hẹn hôm nay (nổi bật nhất màn hình) → "Check-in".
2. Màn hình QR check-in: QR to, độ sáng màn hình tự tăng, kèm mã số dự phòng nếu quét lỗi.
3. Sau check-in: màn hình số thứ tự — số của tôi (rất to), số đang gọi, phòng/quầy, thời gian chờ dự kiến, các bước tiếp theo (khám → xét nghiệm → thanh toán → lấy thuốc) dạng timeline.
4. Push "sắp đến lượt" khi còn cách 2–3 số.
5. Lỡ lượt: trạng thái đổi sang hướng dẫn "liên hệ quầy tiếp nhận".
6. Nếu hệ thống queue chưa sẵn sàng (rủi ro đã nêu trong kế hoạch): màn hình này thay bằng hướng dẫn tĩnh — "đến quầy X, tầng Y" — UI vẫn giữ chỗ để ghép sau.

### Flow D: Nhận và xem kết quả
1. Push "Bạn có kết quả khám mới" (không ghi chi tiết chẩn đoán) → deep-link.
2. Nếu đã bật khóa app: yêu cầu PIN/sinh trắc học trước khi mở.
3. Chi tiết lần khám: chẩn đoán, lời dặn, danh sách xét nghiệm (có đánh dấu chỉ số ngoài ngưỡng tham chiếu), file PDF/hình ảnh, đơn thuốc.
4. Hành động: tải PDF, đặt lịch tái khám, tạo nhắc uống thuốc từ đơn.
5. Empty state tab Kết quả (bệnh nhân mới): giải thích "kết quả sẽ xuất hiện sau khi khám" + nút đặt lịch.

### Flow E: Đơn thuốc và nhắc uống thuốc
1. Từ kết quả khám hoặc tab Cá nhân → đơn thuốc.
2. Chi tiết đơn: từng thuốc — tên, hàm lượng, liều, thời điểm, số ngày.
3. Bật nhắc uống thuốc: app sinh lịch nhắc từ liều dùng, bệnh nhân chỉnh giờ cho hợp sinh hoạt.
4. Notification nhắc → mở app xác nhận "đã uống" / "bỏ qua".
5. Gần hết liệu trình + có hẹn tái khám → push nhắc đặt lịch tái khám, bấm vào đi thẳng Flow B với chuyên khoa điền sẵn.

### Flow F: Chuyển hồ sơ người thân
1. Profile switcher (avatar góc màn hình) có ở: Trang chủ, Lịch khám, Kết quả.
2. Bấm → bottom sheet danh sách hồ sơ + nút "Thêm người thân".
3. Chọn hồ sơ khác → toàn bộ dữ liệu các tab đổi theo, có indicator rõ đang xem hồ sơ của ai (màu viền avatar/tên hiển thị).
4. Thêm người thân: nhập thông tin hoặc liên kết mã bệnh nhân → xác thực theo quy định (OTP riêng nếu kế hoạch chốt vậy).

### Flow G: Quên mật khẩu / đổi thiết bị
1. Đăng nhập trên máy mới → OTP về số điện thoại → xác thực → thiết lập lại PIN.
2. Thiết bị cũ bị đăng xuất (hiện trong "Thiết bị đăng nhập" ở Cài đặt bảo mật).

## 5. Luồng go-live 2 (chỉ định hướng, chưa chi tiết)

- **Thanh toán**: từ chi tiết lịch khám/lần khám có khoản phí → chi tiết hóa đơn → chọn phương thức → cổng thanh toán → biên lai. Cần flow riêng khi thanh toán thất bại giữa chừng.
- **Chat/tư vấn**: entry từ tab Cá nhân và từ chi tiết lần khám ("hỏi về kết quả này").
- **Gói khám**: khám phá từ trang chủ (banner) → chi tiết gói → mua → quyền lợi gắn vào flow đặt lịch.
- **Upload hồ sơ cũ, chỉ số sức khỏe, chăm sóc sau khám, tiêm chủng, đánh giá**: đều treo dưới tab Cá nhân; đánh giá còn được mời qua push sau khi khám xong.

## 6. Màn hình theo đợt (screen inventory)

Danh sách màn hình chi tiết của từng chức năng đã có trong mục "Màn hình cần có" của file kế hoạch — không lặp lại ở đây. Bảng này chỉ để đếm và chia việc:

| Đợt | Nhóm màn hình | Ước lượng số màn hình |
|---|---|---|
| 1 | Onboarding, auth, OTP, PIN, đồng ý, trang chủ, hồ sơ, người thân, thông báo, cài đặt bảo mật | ~14 |
| 2 | Đặt lịch (5 bước), lịch hẹn, chi tiết, đổi/hủy, QR check-in, số thứ tự, chỉ đường | ~10 |
| 3 | Danh sách lần khám, chi tiết kết quả, xét nghiệm, xem PDF, đơn thuốc, nhắc uống thuốc | ~8 |
| 4–6 | Thanh toán, upload, chỉ số, biểu đồ, chăm sóc, tiêm chủng, gói khám, chat, đánh giá | ~20 |

Mỗi màn hình nhân 5 state → khối lượng thiết kế thực tế gấp ~3 lần số màn hình normal.

## 7. Checklist nghiệm thu UI mỗi màn hình

- [ ] Đủ 5 state: normal, empty, loading (skeleton), error (có nút thử lại), permission.
- [ ] Text qua ARB, không hard-code.
- [ ] Font scale 1.3x không vỡ layout; nút chạm tối thiểu 48dp.
- [ ] Hiện đúng hồ sơ đang chọn (với màn hình có dữ liệu theo hồ sơ).
- [ ] Back/thoát giữa luồng nhiều bước có xác nhận, không mất dữ liệu đã nhập.
- [ ] Mock data có cả trường hợp dài (tên dài, nhiều thuốc, nhiều kết quả) và trường hợp rỗng.
- [ ] Fake delay + fake error bật được từ mock repository để test loading/error.
- [ ] Màn hình chứa dữ liệu nhạy cảm: ẩn nội dung ở app switcher, không lộ trong push.

## 8. Việc cần làm tiếp cho UI/UX

1. Cho bệnh viện duyệt: bảng màu + navigation 5 tab + flow A–D (wireframe trước, hi-fi sau).
2. Xin brand guideline bệnh viện (logo, màu, font) — đang chờ, tạm dùng màu gợi ý ở mục 2.
3. Vẽ wireframe các flow go-live 1 (Figma), mỗi flow 1 page.
4. Chốt câu trả lời ảnh hưởng UI: đặt lịch theo bác sĩ hay chuyên khoa (Flow B bước 4), đổi lịch hay chỉ hủy–đặt lại (Flow C), queue realtime có kịp go-live 1 không (Flow C bước 6).
