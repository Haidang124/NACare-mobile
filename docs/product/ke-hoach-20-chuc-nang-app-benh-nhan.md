# Kế hoạch 20 chức năng app mobile cho bệnh nhân

Tài liệu này chốt 20 chức năng chính cho app mobile Flutter dành cho bệnh nhân, được sắp xếp theo thứ tự quan trọng. Mỗi chức năng có mục tiêu, đối tượng sử dụng, màn hình, luồng xử lý, dữ liệu, MVP và ghi chú triển khai.

## Bối cảnh đã chốt

- Loại đơn vị: bệnh viện đơn lẻ, hiện tại chỉ một bệnh viện sử dụng.
- Hệ thống hiện có: đã có HIS/EMR và có thể có thêm LIS/PACS/pharmacy/queue/payment tùy theo hiện trạng.
- Tích hợp API: bệnh viện đã có API sẵn, app mobile sẽ chỉ gọi qua API, không truy cập trực tiếp database hay hệ thống nội bộ.
- Kênh đầu tiên: app mobile Flutter cho bệnh nhân.
- Kênh sau này: web admin/back-office cho lễ tân, bác sĩ, điều dưỡng, thu ngân, chăm sóc khách hàng và admin hệ thống.
- Phạm vi phase 1: lên plan và làm UI đầy đủ 20 chức năng, nhưng chia 2 lần go-live: go-live 1 gồm Đợt 1–3 (giá trị cốt lõi cho bệnh nhân), go-live 2 gồm Đợt 4–6 (các chức năng cần web admin vận hành).
- Nguồn lực: team 4+ dev (mobile, backend, tester/BA), lộ trình và cách chia việc trong tài liệu này căn theo quy mô team này.
- Nguyên tắc tích hợp: HIS/EMR là nguồn dữ liệu gốc cho hồ sơ, lịch khám, kết quả, đơn thuốc và viện phí; mobile app không thay thế HIS/EMR mà là lớp trải nghiệm bệnh nhân.
- Chiến lược triển khai hiện tại: làm UI/UX trước bằng mock data và mock API contract, sau đó ghép API thật.
- Nguyên tắc dữ liệu: dữ liệu y tế nhạy cảm chỉ hiển thị khi đã xác thực tài khoản, liên kết hồ sơ đúng và có quyền truy cập phù hợp.

## Thứ tự ưu tiên tổng quan

1. Đăng ký, đăng nhập và xác thực tài khoản
2. Hồ sơ bệnh nhân và thông tin cá nhân
3. Hồ sơ sức khỏe gia đình
4. Đặt lịch khám
5. Quản lý lịch hẹn và check-in
6. Quản lý hàng chờ và số thứ tự realtime
7. Thông báo, nhắc việc và trung tâm thông báo
8. Xem kết quả khám, xét nghiệm và chẩn đoán hình ảnh
9. Đơn thuốc, nhắc uống thuốc và tái khám
10. Thanh toán viện phí và tạm ứng online
11. Tải lên hồ sơ y tế cũ
12. Tư vấn trực tuyến và nhắn tin với cơ sở y tế
13. Theo dõi chỉ số sức khỏe cá nhân
14. Biểu đồ sức khỏe theo thời gian
15. Gói khám và dịch vụ y tế
16. Chăm sóc sau khám, sau phẫu thuật hoặc sau điều trị
17. Sổ tiêm chủng và nhắc lịch vaccine
18. Bản đồ cơ sở y tế và chỉ đường
19. Đánh giá bác sĩ và dịch vụ sau khám
20. Bảo mật, quyền riêng tư và quản lý đồng ý

## 1. Đăng ký, đăng nhập và xác thực tài khoản

### Mục tiêu
Cho phép bệnh nhân tạo tài khoản, đăng nhập an toàn và liên kết với hồ sơ y tế sẵn có.

### Đối tượng sử dụng
- Bệnh nhân mới.
- Bệnh nhân đã từng khám.
- Người nhà quản lý hồ sơ cho gia đình.

### Màn hình cần có
- Đăng nhập.
- Đăng ký.
- Xác thực OTP.
- Quên mật khẩu.
- Thiết lập PIN/sinh trắc học.

### Luồng xử lý chính
1. Bệnh nhân nhập số điện thoại.
2. Hệ thống gửi OTP.
3. Bệnh nhân xác thực OTP.
4. Hệ thống kiểm tra hồ sơ đã tồn tại theo số điện thoại/mã bệnh nhân/CCCD.
5. Nếu có hồ sơ, liên kết tài khoản với hồ sơ.
6. Nếu chưa có, tạo tài khoản mới.

### Dữ liệu cần quản lý
- Số điện thoại, email nếu có.
- Mật khẩu/PIN.
- Mã OTP và thời gian hết hạn.
- Mã bệnh nhân.
- Thiết bị đăng nhập.

### MVP
- Đăng ký/đăng nhập bằng số điện thoại và OTP.
- Đăng xuất.
- Quên mật khẩu.

### Cần quyết định
- Định danh chính là số điện thoại, CCCD hay mã bệnh nhân?
- Có bắt buộc liên kết với hồ sơ trên HIS/EMR ngay từ đầu không?

## 2. Hồ sơ bệnh nhân và thông tin cá nhân

### Mục tiêu
Quản lý thông tin hành chính và thông tin y tế nền tảng của bệnh nhân.

### Đối tượng sử dụng
- Bệnh nhân.
- Lễ tân/nhân viên tiếp nhận, nếu có admin.

### Màn hình cần có
- Hồ sơ cá nhân.
- Thông tin liên hệ.
- Thông tin bảo hiểm.
- Tiền sử bệnh và dị ứng.
- Thông tin liên hệ khẩn cấp.

### Luồng xử lý chính
1. Bệnh nhân mở hồ sơ.
2. Cập nhật thông tin cá nhân.
3. App validate trường bắt buộc.
4. Backend lưu và đồng bộ với hệ thống trung tâm nếu có.
5. Bệnh nhân xem trạng thái hồ sơ đã hoàn tất hay còn thiếu.

### Dữ liệu cần quản lý
- Họ tên, ngày sinh, giới tính.
- Địa chỉ, số điện thoại, email.
- CCCD/hộ chiếu.
- Bảo hiểm y tế/bảo hiểm tư nhân.
- Tiền sử bệnh, dị ứng, nhóm máu.

### MVP
- Xem/sửa thông tin cá nhân.
- Lưu thông tin bảo hiểm cơ bản.
- Lưu tiền sử bệnh và dị ứng.

### Cần quyết định
- Bệnh nhân có được sửa toàn bộ thông tin hay cần lễ tân duyệt?
- Có cần quét CCCD hoặc QR bảo hiểm không?

## 3. Hồ sơ sức khỏe gia đình

### Mục tiêu
Cho phép một tài khoản quản lý nhiều hồ sơ của người thân.

### Đối tượng sử dụng
- Cha mẹ đặt lịch cho con.
- Con cái quản lý lịch khám cho bố mẹ.
- Vợ/chồng đặt lịch hộ nhau.

### Màn hình cần có
- Danh sách người thân.
- Thêm người thân.
- Chọn người được khám.
- Phân quyền truy cập hồ sơ.

### Luồng xử lý chính
1. Người dùng thêm người thân.
2. Nhập thông tin cơ bản hoặc liên kết mã bệnh nhân.
3. Hệ thống xác thực mối quan hệ nếu cần.
4. Khi đặt lịch/xem kết quả, app yêu cầu chọn hồ sơ.
5. Tất cả dữ liệu được tách theo từng bệnh nhân.

### Dữ liệu cần quản lý
- Thông tin người thân.
- Mối quan hệ.
- Quyền xem kết quả, đặt lịch, thanh toán.
- Trạng thái xác thực liên kết.

### MVP
- Thêm/sửa/xóa người thân.
- Đặt lịch cho người thân.
- Chuyển hồ sơ đang xem trong app.

### Cần quyết định
- Có cần xác thực người thân bằng OTP riêng không?
- Có cho xem kết quả của người trên 18 tuổi không, hay cần đồng ý?

## 4. Đặt lịch khám

### Mục tiêu
Cho phép bệnh nhân đặt lịch theo chuyên khoa, bác sĩ, dịch vụ, ngày giờ và địa điểm.

### Đối tượng sử dụng
- Bệnh nhân mới.
- Bệnh nhân tái khám.
- Người nhà đặt lịch hộ.

### Màn hình cần có
- Chọn chuyên khoa/dịch vụ.
- Chọn bác sĩ.
- Chọn ngày giờ.
- Nhập lý do khám.
- Xác nhận lịch hẹn.

### Luồng xử lý chính
1. Chọn hồ sơ bệnh nhân.
2. Chọn chuyên khoa/dịch vụ.
3. App hiển thị lịch trống.
4. Bệnh nhân chọn khung giờ.
5. Nhập triệu chứng/lý do khám.
6. Backend tạo lịch hẹn và trả mã lịch hẹn.

### Dữ liệu cần quản lý
- Chuyên khoa, dịch vụ.
- Bác sĩ, phòng khám.
- Slot lịch.
- Lý do khám.
- Trạng thái lịch hẹn.

### MVP
- Đặt lịch theo chuyên khoa và khung giờ.
- Lưu lý do khám.
- Xác nhận lịch hẹn.

### Cần quyết định
- Đặt lịch theo bác sĩ hay chỉ theo chuyên khoa?
- Slot lịch do app quản lý riêng hay lấy từ HIS/phần mềm phòng khám?

## 5. Quản lý lịch hẹn và check-in

### Mục tiêu
Cho bệnh nhân xem, đổi, hủy lịch hẹn và check-in khi đến cơ sở y tế.

### Đối tượng sử dụng
- Bệnh nhân có lịch sắp tới.
- Lễ tân tiếp nhận.

### Màn hình cần có
- Lịch hẹn sắp tới.
- Chi tiết lịch hẹn.
- Đổi lịch.
- Hủy lịch.
- Mã QR check-in.

### Luồng xử lý chính
1. Bệnh nhân xem lịch sắp tới.
2. Chọn lịch hẹn cần thao tác.
3. Nếu đổi lịch, chọn slot mới.
4. Nếu hủy lịch, nhập lý do nếu cần.
5. Khi đến nơi, bệnh nhân dùng QR để check-in.

### Dữ liệu cần quản lý
- Mã lịch hẹn.
- Trạng thái: chờ xác nhận, đã xác nhận, đã check-in, đã hủy, đã khám.
- QR check-in.
- Quy định đổi/hủy.

### MVP
- Xem lịch hẹn.
- Hủy lịch.
- QR check-in.

### Cần quyết định
- Cho đổi lịch online hay chỉ hủy và đặt lại?
- Có thu phí hủy lịch/giữ chỗ không?

## 6. Quản lý hàng chờ và số thứ tự realtime

### Mục tiêu
Giảm thời gian chờ và giúp bệnh nhân biết khi nào đến lượt mình.

### Đối tượng sử dụng
- Bệnh nhân đã check-in.
- Lễ tân.
- Phòng khám/cận lâm sàng.

### Màn hình cần có
- Số thứ tự của tôi.
- Số đang gọi.
- Thời gian chờ dự kiến.
- Trạng thái từng bước: tiếp nhận, khám, xét nghiệm, thanh toán, lấy thuốc.

### Luồng xử lý chính
1. Bệnh nhân check-in.
2. Hệ thống cấp số thứ tự.
3. App nhận cập nhật realtime khi số thay đổi.
4. App thông báo khi sắp đến lượt.
5. Nếu bệnh nhân bị lỡ lượt, hệ thống hiện hướng dẫn tiếp theo.

### Dữ liệu cần quản lý
- Số thứ tự.
- Quầy/phòng đang phục vụ.
- Trạng thái hàng chờ.
- Thời gian dự kiến.

### MVP
- Hiện số của tôi và số đang gọi.
- Push notification khi sắp đến lượt.

### Cần quyết định
- Có hệ thống xếp hàng hiện tại chưa?
- Muốn realtime bằng WebSocket, Firebase hay polling API?

## 7. Thông báo, nhắc việc và trung tâm thông báo

### Mục tiêu
Thông báo đúng lúc về lịch hẹn, kết quả, thanh toán, thuốc, tái khám và tin quan trọng.

### Đối tượng sử dụng
- Tất cả bệnh nhân.
- Bộ phận chăm sóc khách hàng.

### Màn hình cần có
- Trung tâm thông báo.
- Chi tiết thông báo.
- Cài đặt nhận thông báo.
- Lọc thông báo theo loại.

### Luồng xử lý chính
1. Backend tạo thông báo theo sự kiện.
2. App nhận push notification.
3. Bệnh nhân bấm thông báo để mở màn hình liên quan.
4. App đánh dấu đã đọc.
5. Bệnh nhân tùy chỉnh loại thông báo muốn nhận.

### Dữ liệu cần quản lý
- Loại thông báo.
- Tiêu đề, nội dung.
- Trạng thái đã đọc.
- Link hành động.
- Kênh gửi: app, SMS, Zalo, email.

### MVP
- Push notification.
- Danh sách thông báo trong app.
- Thông báo lịch hẹn và kết quả mới.

### Cần quyết định
- Dùng Firebase Cloud Messaging hay dịch vụ khác?
- Có cần gửi thêm SMS/Zalo không?

## 8. Xem kết quả khám, xét nghiệm và chẩn đoán hình ảnh

### Mục tiêu
Cho bệnh nhân xem kết quả khám sau khi bác sĩ/cơ sở y tế công bố.

### Đối tượng sử dụng
- Bệnh nhân.
- Người nhà được ủy quyền.

### Màn hình cần có
- Danh sách lần khám.
- Chi tiết lần khám.
- Kết quả xét nghiệm.
- Chẩn đoán hình ảnh.
- Tải file PDF.

### Luồng xử lý chính
1. Bệnh nhân vào mục kết quả.
2. App hiện các lần khám đã hoàn tất.
3. Bệnh nhân chọn lần khám.
4. App chỉ hiện kết quả đã được duyệt/công bố.
5. Bệnh nhân tải file hoặc chia sẻ nếu được phép.

### Dữ liệu cần quản lý
- Lần khám.
- Chẩn đoán.
- Kết quả xét nghiệm.
- Kết quả hình ảnh/PDF.
- Đơn thuốc và lời dặn.

### MVP
- Xem kết quả dạng PDF/text.
- Tải kết quả.
- Thông báo khi có kết quả mới.

### Cần quyết định
- Kết quả hiện tại có từ HIS/LIS/PACS không?
- App cần xem ảnh DICOM hay chỉ xem PDF/ảnh đã xuất?

## 9. Đơn thuốc, nhắc uống thuốc và tái khám

### Mục tiêu
Hỗ trợ bệnh nhân dùng thuốc đúng lịch và không bỏ lỡ tái khám.

### Đối tượng sử dụng
- Bệnh nhân có đơn thuốc.
- Bệnh nhân điều trị dài ngày.

### Màn hình cần có
- Danh sách đơn thuốc.
- Chi tiết thuốc.
- Lịch nhắc uống thuốc.
- Xác nhận đã uống.
- Nhắc tái khám.

### Luồng xử lý chính
1. App nhận đơn thuốc sau lần khám.
2. Tạo lịch nhắc theo liều dùng.
3. Bệnh nhân xác nhận đã uống.
4. App nhắc khi sắp tái khám.
5. Bệnh nhân đặt lịch tái khám từ thông báo.

### Dữ liệu cần quản lý
- Tên thuốc, hàm lượng.
- Liều dùng, thời điểm dùng.
- Số ngày dùng.
- Lịch tái khám.
- Trạng thái đã uống.

### MVP
- Xem đơn thuốc.
- Nhắc uống thuốc.
- Nhắc tái khám.

### Cần quyết định
- Đơn thuốc lấy từ hệ thống nào?
- Có cần liên kết nhà thuốc/bán thuốc online không?

## 10. Thanh toán viện phí và tạm ứng online

### Mục tiêu
Cho phép bệnh nhân thanh toán phí khám, dịch vụ, tạm ứng và xem lịch sử giao dịch.

### Đối tượng sử dụng
- Bệnh nhân.
- Người nhà thanh toán hộ.
- Kế toán/thu ngân.

### Màn hình cần có
- Khoản cần thanh toán.
- Chi tiết hóa đơn.
- Phương thức thanh toán.
- Kết quả thanh toán.
- Lịch sử giao dịch.

### Luồng xử lý chính
1. Backend tạo khoản cần thanh toán.
2. App hiện chi tiết phí.
3. Bệnh nhân chọn phương thức thanh toán.
4. Cổng thanh toán xử lý giao dịch.
5. App cập nhật trạng thái và hiện biên lai.

### Dữ liệu cần quản lý
- Mã hóa đơn.
- Số tiền.
- Nội dung thu.
- Trạng thái thanh toán.
- Biên lai/hợp đồng dịch vụ nếu có.

### MVP
- Hiện phí cần thanh toán.
- Thanh toán qua QR hoặc cổng thanh toán.
- Lịch sử thanh toán.

### Cần quyết định
- Tích hợp cổng thanh toán nào?
- Có cần xuất hóa đơn điện tử không?

## 11. Tải lên hồ sơ y tế cũ

### Mục tiêu
Cho bệnh nhân lưu và chia sẻ kết quả khám cũ để bác sĩ có thêm thông tin khi khám.

### Đối tượng sử dụng
- Bệnh nhân mới.
- Bệnh nhân điều trị nhiều nơi.
- Bác sĩ cần xem tiền sử.

### Màn hình cần có
- Thư viện hồ sơ.
- Tải lên file.
- Phân loại tài liệu.
- Xem file.
- Chia sẻ với bác sĩ/cơ sở y tế.

### Luồng xử lý chính
1. Bệnh nhân chọn file/ảnh từ điện thoại.
2. Chọn loại tài liệu: xét nghiệm, đơn thuốc, chẩn đoán hình ảnh, giấy ra viện.
3. App upload file lên server.
4. Hệ thống scan virus/kiểm tra định dạng.
5. Bệnh nhân gắn file vào hồ sơ hoặc lần khám.

### Dữ liệu cần quản lý
- File tải lên.
- Loại tài liệu.
- Ngày phát hành.
- Cơ sở y tế phát hành.
- Quyền chia sẻ.

### MVP
- Upload PDF/ảnh.
- Phân loại tài liệu.
- Xem lại file.

### Cần quyết định
- Giới hạn dung lượng mỗi file là bao nhiêu?
- Có cần OCR đọc nội dung từ ảnh/PDF không?

## 12. Tư vấn trực tuyến và nhắn tin với cơ sở y tế

### Mục tiêu
Tạo kênh hỏi đáp và chăm sóc trước/sau khám giữa bệnh nhân và cơ sở y tế.

### Đối tượng sử dụng
- Bệnh nhân.
- Chăm sóc khách hàng.
- Bác sĩ/nhân viên y tế.

### Màn hình cần có
- Danh sách hội thoại.
- Chat chi tiết.
- Gửi file/ảnh.
- Tạo yêu cầu tư vấn.
- Gọi video nếu có.

### Luồng xử lý chính
1. Bệnh nhân tạo yêu cầu tư vấn.
2. Hệ thống phân loại theo chuyên khoa/mức độ.
3. Nhân viên y tế trả lời.
4. Nếu cần khám, app gợi ý đặt lịch.
5. Hội thoại được lưu theo hồ sơ nếu được phép.

### Dữ liệu cần quản lý
- Nội dung tin nhắn.
- Người gửi/nhận.
- File đính kèm.
- Trạng thái đã đọc.
- Mã yêu cầu tư vấn.

### MVP
- Chat text.
- Gửi ảnh/file.
- Push notification tin nhắn mới.

### Cần quyết định
- Chat với CSKH trước hay chat trực tiếp với bác sĩ?
- Có cần video call trong phase 1 không?

## 13. Theo dõi chỉ số sức khỏe cá nhân

### Mục tiêu
Cho bệnh nhân tự ghi nhận chỉ số sức khỏe hằng ngày hoặc theo đợt điều trị.

### Đối tượng sử dụng
- Bệnh nhân bệnh mạn tính.
- Thai phụ.
- Người cao tuổi.
- Người theo dõi sức khỏe định kỳ.

### Màn hình cần có
- Nhập chỉ số.
- Danh sách chỉ số.
- Cấu hình chỉ số theo dõi.
- Nhắc nhập chỉ số.

### Luồng xử lý chính
1. Bệnh nhân chọn loại chỉ số.
2. Nhập giá trị và thời gian đo.
3. App validate ngưỡng cơ bản.
4. Lưu chỉ số vào hồ sơ.
5. Nếu vượt ngưỡng, app hiện cảnh báo và gợi ý liên hệ cơ sở y tế.

### Dữ liệu cần quản lý
- Huyết áp.
- Đường huyết.
- Cân nặng, chiều cao, BMI.
- Nhiệt độ, SpO2, nhịp tim.
- Chỉ số tùy biến theo bệnh lý.

### MVP
- Nhập chỉ số thủ công.
- Lưu lịch sử.
- Cảnh báo ngưỡng cơ bản.

### Cần quyết định
- Theo dõi nhóm bệnh nào đầu tiên?
- Có cần kết nối thiết bị wearable/máy đo không?

## 14. Biểu đồ sức khỏe theo thời gian

### Mục tiêu
Giúp bệnh nhân và bác sĩ nhìn được xu hướng sức khỏe qua các lần đo và lần xét nghiệm.

### Đối tượng sử dụng
- Bệnh nhân.
- Bác sĩ khi xem hồ sơ.

### Màn hình cần có
- Biểu đồ chỉ số.
- Lọc theo thời gian.
- So sánh với ngưỡng bình thường.
- Chi tiết điểm dữ liệu.

### Luồng xử lý chính
1. App lấy dữ liệu chỉ số từ lần khám, xét nghiệm và tự nhập.
2. Nhóm dữ liệu theo loại chỉ số.
3. Hiện biểu đồ theo ngày/tháng/năm.
4. Đánh dấu điểm vượt ngưỡng.
5. Cho phép xuất/chia sẻ báo cáo.

### Dữ liệu cần quản lý
- Chỉ số theo thời gian.
- Đơn vị đo.
- Ngưỡng tham chiếu.
- Nguồn dữ liệu: tự nhập, xét nghiệm, thiết bị.

### MVP
- Biểu đồ huyết áp, đường huyết, cân nặng.
- Lọc 7 ngày/30 ngày/1 năm.

### Cần quyết định
- Cần biểu đồ cho xét nghiệm nào trước?
- Có cho bác sĩ xem dữ liệu bệnh nhân tự nhập không?

## 15. Gói khám và dịch vụ y tế

### Mục tiêu
Giới thiệu và cho phép bệnh nhân đăng ký các gói khám/dịch vụ của cơ sở y tế.

### Đối tượng sử dụng
- Bệnh nhân mới.
- Bệnh nhân có nhu cầu tầm soát/định kỳ.
- Bộ phận kinh doanh/chăm sóc khách hàng.

### Màn hình cần có
- Danh sách gói khám.
- Chi tiết gói.
- Đăng ký/mua gói.
- Lịch sử gói đã mua.
- Sử dụng quyền lợi trong gói.

### Luồng xử lý chính
1. Bệnh nhân xem danh sách gói.
2. Chọn gói và xem chi tiết dịch vụ.
3. Đăng ký hoặc thanh toán.
4. Hệ thống kích hoạt gói.
5. Bệnh nhân đặt lịch dựa trên quyền lợi của gói.

### Dữ liệu cần quản lý
- Tên gói, giá gói.
- Danh sách dịch vụ trong gói.
- Thời hạn sử dụng.
- Trạng thái gói.
- Lịch sử sử dụng dịch vụ.

### MVP
- Hiện danh sách gói.
- Đăng ký gói.
- Liên kết đặt lịch.

### Cần quyết định
- Có bán gói online và thanh toán online không?
- Gói khám có cần quản lý số lượt dịch vụ còn lại không?

## 16. Chăm sóc sau khám, sau phẫu thuật hoặc sau điều trị

### Mục tiêu
Hướng dẫn bệnh nhân tự chăm sóc tại nhà và phát hiện sớm dấu hiệu cần liên hệ y tế.

### Đối tượng sử dụng
- Bệnh nhân sau khám.
- Bệnh nhân sau thủ thuật/phẫu thuật.
- Bệnh nhân điều trị dài ngày.

### Màn hình cần có
- Hướng dẫn sau khám.
- Checklist việc cần làm.
- Dấu hiệu cần báo ngay.
- Nhật ký triệu chứng.
- Liên hệ hỗ trợ.

### Luồng xử lý chính
1. Sau khi kết thúc lần khám, hệ thống gán gói chăm sóc phù hợp.
2. App hiện hướng dẫn theo ngày.
3. Bệnh nhân tick việc đã làm hoặc nhập triệu chứng.
4. Nếu có dấu hiệu nguy cơ, app cảnh báo và gợi ý liên hệ.
5. App nhắc lịch tái khám.

### Dữ liệu cần quản lý
- Mẫu hướng dẫn chăm sóc.
- Checklist.
- Triệu chứng theo ngày.
- Mức độ nguy cơ.
- Lịch tái khám.

### MVP
- Hiện hướng dẫn sau khám.
- Checklist và nhắc việc.
- Cảnh báo dấu hiệu nguy hiểm.

### Cần quyết định
- Ưu tiên chăm sóc sau khám nào: tổng quát, sản khoa, hậu phẫu, nha khoa, mắt?
- Ai tạo nội dung hướng dẫn: bác sĩ hay admin?

## 17. Sổ tiêm chủng và nhắc lịch vaccine

### Mục tiêu
Theo dõi lịch tiêm, mũi đã tiêm và nhắc mũi sắp đến hạn.

### Đối tượng sử dụng
- Trẻ em.
- Thai phụ.
- Người cao tuổi.
- Bệnh nhân tiêm dịch vụ.

### Màn hình cần có
- Sổ tiêm chủng.
- Mũi đã tiêm.
- Lịch tiêm sắp tới.
- Nhắc tiêm.
- Chứng nhận tiêm nếu có.

### Luồng xử lý chính
1. Bệnh nhân thêm hồ sơ tiêm chủng.
2. App hiện lịch tiêm theo độ tuổi/nhóm nguy cơ.
3. Khi tiêm xong, cập nhật mũi đã tiêm.
4. App tính mũi tiếp theo.
5. Gửi thông báo trước ngày tiêm.

### Dữ liệu cần quản lý
- Tên vaccine.
- Mũi tiêm.
- Ngày tiêm.
- Lô sản xuất nếu cần.
- Cơ sở tiêm.

### MVP
- Ghi nhận mũi đã tiêm.
- Nhắc mũi sắp đến hạn.
- Gắn lịch tiêm với người thân.

### Cần quyết định
- Cơ sở y tế của bạn có dịch vụ tiêm chủng không?
- Cần theo lịch tiêm chuẩn nào?

## 18. Bản đồ cơ sở y tế và chỉ đường

### Mục tiêu
Giúp bệnh nhân tìm địa điểm, phòng khám, quầy tiếp nhận và các khu dịch vụ.

### Đối tượng sử dụng
- Bệnh nhân đến khám trực tiếp.
- Người nhà.

### Màn hình cần có
- Bản đồ cơ sở.
- Danh sách địa điểm.
- Chỉ đường bằng Google Maps/Apple Maps.
- Bản đồ nội bộ nếu có.
- Thông tin bãi xe, quầy tiếp nhận, nhà thuốc.

### Luồng xử lý chính
1. Bệnh nhân mở địa điểm từ lịch hẹn.
2. App hiện chi nhánh/phòng khám liên quan.
3. Bệnh nhân bấm chỉ đường.
4. Nếu có bản đồ nội bộ, app hiện đường đến phòng/khu dịch vụ.
5. App hiện thông tin liên hệ khi cần.

### Dữ liệu cần quản lý
- Chi nhánh/cơ sở.
- Tòa nhà, tầng, phòng.
- Tọa độ GPS.
- Giờ làm việc.
- Số điện thoại liên hệ.

### MVP
- Hiện địa chỉ cơ sở.
- Mở Google Maps/Apple Maps.
- Hiện giờ làm việc và hotline.

### Cần quyết định
- Có nhiều chi nhánh không?
- Có cần bản đồ nội bộ bệnh viện/phòng khám không?

## 19. Đánh giá bác sĩ và dịch vụ sau khám

### Mục tiêu
Thu thập phản hồi của bệnh nhân để cải thiện chất lượng dịch vụ.

### Đối tượng sử dụng
- Bệnh nhân sau khám.
- Quản lý chất lượng.
- Chăm sóc khách hàng.

### Màn hình cần có
- Form đánh giá sau khám.
- Chấm điểm sao.
- Nhận xét.
- Báo cáo vấn đề.
- Lịch sử phản hồi.

### Luồng xử lý chính
1. Sau khi hoàn tất khám, app gửi thông báo đánh giá.
2. Bệnh nhân chấm điểm và nhập nhận xét.
3. Hệ thống phân loại phản hồi tiêu cực.
4. Nếu cần, CSKH liên hệ xử lý.
5. Quản lý xem báo cáo tổng hợp.

### Dữ liệu cần quản lý
- Điểm đánh giá.
- Nội dung góp ý.
- Đối tượng được đánh giá: bác sĩ, dịch vụ, quy trình.
- Trạng thái xử lý phản hồi.

### MVP
- Đánh giá sao và nhận xét sau khám.
- Báo cáo đánh giá cơ bản.

### Cần quyết định
- Đánh giá có hiện công khai không hay chỉ nội bộ?
- Có cần workflow xử lý khiếu nại không?

## 20. Bảo mật, quyền riêng tư và quản lý đồng ý

### Mục tiêu
Bảo vệ dữ liệu y tế nhạy cảm và đảm bảo bệnh nhân kiểm soát việc chia sẻ thông tin.

### Đối tượng sử dụng
- Bệnh nhân.
- Người nhà.
- Quản trị hệ thống.

### Màn hình cần có
- Cài đặt bảo mật.
- Khóa app bằng PIN/sinh trắc học.
- Quản lý đồng ý.
- Lịch sử truy cập hồ sơ.
- Quản lý thiết bị đăng nhập.

### Luồng xử lý chính
1. Bệnh nhân mở cài đặt bảo mật.
2. Bật PIN/sinh trắc học.
3. Quản lý đồng ý xem/chia sẻ dữ liệu.
4. Hệ thống ghi nhận lịch sử thay đổi.
5. API kiểm tra quyền trước khi trả dữ liệu nhạy cảm.

### Dữ liệu cần quản lý
- Trạng thái khóa app.
- Đồng ý sử dụng/chia sẻ dữ liệu.
- Audit log.
- Thiết bị đăng nhập.
- Thời gian đồng ý/thu hồi đồng ý.

### MVP
- Khóa app bằng PIN/sinh trắc học.
- Ẩn nội dung nhạy cảm trên push notification.
- Quản lý đồng ý cơ bản.

### Cần quyết định
- Có cần audit log cho bệnh nhân xem không?
- Có chính sách xóa tài khoản/xóa dữ liệu không?

## Phase 1: làm UI đủ 20 chức năng, go-live thành 2 lần

Phase 1 vẫn thiết kế và làm UI đầy đủ 20 chức năng (theo chiến lược UI-first), nhưng không chờ đủ 20 chức năng mới ra mắt. Chia thành 2 lần go-live:

- **Go-live 1 (Đợt 1–3)**: chức năng 1–9, 18 và bản nền tảng của 20. Đây là giá trị cốt lõi cho bệnh nhân: đăng nhập, hồ sơ, đặt lịch, check-in, kết quả khám, đơn thuốc, thông báo. Bệnh viện có thể đưa app vào sử dụng sớm, thu phản hồi thật.
- **Go-live 2 (Đợt 4–6)**: chức năng 10–17 và 19. Lý do tách riêng: các chức năng chat/tư vấn, gói khám, đánh giá, chăm sóc sau khám **cần web admin để vận hành** (CSKH trả lời chat, admin tạo nội dung chăm sóc, quản lý gói khám, xử lý phản hồi). Chưa có tool vận hành thì bật chức năng lên bệnh nhân cũng không dùng được.

**Ghi chú rủi ro**: chức năng 6 (hàng chờ và số thứ tự realtime) là chức năng rủi ro cao nhất vì phụ thuộc hệ thống lấy số hiện có của bệnh viện. Nếu tích hợp queue chưa sẵn sàng, cho phép chức năng này trượt khỏi go-live 1 mà không chặn các chức năng khác.

## Chiến lược UI-first, ghép API sau

### Mục tiêu
Dựng đầy đủ giao diện, luồng màn hình và trải nghiệm người dùng trước khi ghép API thật. Việc này giúp bệnh viện duyệt nhanh UI/UX, phát hiện thiếu màn hình sớm và giảm rủi ro khi tích hợp HIS/EMR.

### Nguyên tắc thực hiện
- Mỗi chức năng cần có UI hoàn chỉnh trước: normal state, empty state, loading state, error state và permission state.
- Dữ liệu ban đầu dùng mock data nội bộ trong app hoặc mock JSON.
- Tách lớp UI khỏi lớp data bằng repository/service interface.
- Khi ghép API, chỉ thay mock repository bằng API repository, hạn chế sửa UI.
- Định nghĩa trước model dữ liệu và response mẫu cho từng chức năng.
- Tất cả màn hình cần có fake delay để test loading và fake error để test thông báo lỗi.

### Cấu trúc Flutter gợi ý
- `features/auth`: đăng nhập, OTP, session.
- `features/profile`: hồ sơ bệnh nhân, hồ sơ gia đình.
- `features/appointment`: đặt lịch, lịch hẹn, check-in.
- `features/queue`: số thứ tự realtime.
- `features/results`: kết quả khám, xét nghiệm, hình ảnh.
- `features/prescription`: đơn thuốc, nhắc uống thuốc.
- `features/payment`: viện phí, thanh toán, biên lai.
- `features/documents`: upload hồ sơ cũ.
- `features/chat`: tư vấn trực tuyến.
- `features/health_tracking`: chỉ số và biểu đồ sức khỏe.
- `features/care_plan`: chăm sóc sau khám.
- `features/vaccination`: sổ tiêm chủng.
- `features/services`: gói khám và dịch vụ.
- `features/feedback`: đánh giá sau khám.
- `features/security`: bảo mật và đồng ý.
- `core`: routing, theme, widgets chung, network, storage, error handling.

### Deliverable UI trước khi ghép API
- Design system Flutter: màu sắc, typography, button, input, card, bottom navigation, app bar, dialog, toast/snackbar.
- Prototype app chạy được trên Android/iOS emulator.
- Đầy đủ navigation cho 20 chức năng.
- Mock data cho tất cả màn hình.
- Danh sách API contract cần ghép sau, viết thành **OpenAPI/Swagger spec** (không chỉ là danh sách mô tả) — đây là điều kiện để team backend và team mobile làm song song thực sự với team 4+ dev.
- Checklist nghiệm thu UI cho từng chức năng.

### Thứ tự làm UI
1. App shell, design system, bottom navigation, auth flow.
2. Trang chủ bệnh nhân và hồ sơ.
3. Đặt lịch, lịch hẹn, check-in, hàng chờ.
4. Kết quả khám, đơn thuốc, thanh toán.
5. Upload hồ sơ, chỉ số sức khỏe, biểu đồ, chăm sóc sau khám.
6. Vaccine, gói khám, chat, đánh giá, bảo mật.

### Thứ tự ghép API sau
1. Auth và liên kết hồ sơ.
2. Hồ sơ bệnh nhân và người thân.
3. Đặt lịch và lịch hẹn.
4. Kết quả khám và đơn thuốc.
5. Thông báo push.
6. Hàng chờ realtime.
7. Viện phí/thanh toán.
8. Upload file.
9. Chat/tư vấn.
10. Các module chăm sóc liên tục và đánh giá.

### Workstream 1: Nền tảng tài khoản và bảo mật
- Chức năng liên quan: 1, 2, 3, 7, 20.
- Kết quả cần có: đăng nhập OTP, liên kết hồ sơ HIS/EMR, hồ sơ cá nhân, hồ sơ gia đình, push notification, khóa app, quản lý đồng ý cơ bản.
- Phụ thuộc: API tra cứu mã bệnh nhân, API cập nhật thông tin hành chính, dịch vụ OTP, Firebase Cloud Messaging hoặc dịch vụ push tương đương.
- Tiêu chí nghiệm thu: bệnh nhân đăng ký được, liên kết đúng hồ sơ, chuyển đổi giữa các hồ sơ người thân, nhận được thông báo, dữ liệu nhạy cảm không lộ trên màn hình khóa.

### Workstream 2: Hành trình đi khám tại bệnh viện
- Chức năng liên quan: 4, 5, 6, 18.
- Kết quả cần có: đặt lịch, quản lý lịch hẹn, QR check-in, số thứ tự realtime, hướng dẫn đến bệnh viện/phòng khám.
- Phụ thuộc: API lịch khám HIS, API danh mục chuyên khoa/bác sĩ/phòng khám, API queue hoặc tích hợp hệ thống lấy số, danh mục địa điểm trong bệnh viện.
- Tiêu chí nghiệm thu: đặt lịch thành công, hủy/đổi lịch theo quy định, check-in sinh số thứ tự, app cập nhật được số đang gọi, lịch hẹn mở đúng địa điểm khám.

### Workstream 3: Kết quả, đơn thuốc và viện phí
- Chức năng liên quan: 8, 9, 10.
- Kết quả cần có: xem lịch sử khám, xem kết quả xét nghiệm/chẩn đoán hình ảnh, xem đơn thuốc, nhắc uống thuốc, thanh toán viện phí/tạm ứng.
- Phụ thuộc: HIS/EMR cho lịch sử khám và chẩn đoán, LIS cho xét nghiệm, PACS hoặc file server cho hình ảnh/PDF, pharmacy cho đơn thuốc, billing/payment cho viện phí.
- Tiêu chí nghiệm thu: chỉ hiện kết quả đã công bố, tải được PDF nếu có, đơn thuốc tạo được nhắc đúng lịch, thanh toán cập nhật trạng thái về billing.

### Workstream 4: Hồ sơ bổ sung và chăm sóc liên tục
- Chức năng liên quan: 11, 13, 14, 16, 17.
- Kết quả cần có: upload hồ sơ cũ, nhập chỉ số sức khỏe, biểu đồ xu hướng, hướng dẫn sau khám, sổ tiêm chủng và nhắc vaccine.
- Phụ thuộc: file storage, quy định dung lượng file, danh mục chỉ số sức khỏe, ngưỡng cảnh báo, mẫu nội dung chăm sóc sau khám, danh mục vaccine.
- Tiêu chí nghiệm thu: upload và xem lại file, nhập chỉ số và xem biểu đồ, hiện cảnh báo khi vượt ngưỡng, nhắc việc sau khám và vaccine đúng lịch.

### Workstream 5: Tương tác, dịch vụ và phản hồi
- Chức năng liên quan: 12, 15, 19.
- Kết quả cần có: chat/tư vấn, danh sách gói khám, đăng ký gói khám, đánh giá sau khám.
- Phụ thuộc: kênh chat, quy trình tiếp nhận của CSKH/bác sĩ, danh mục gói khám, quy trình xử lý phản hồi.
- Tiêu chí nghiệm thu: bệnh nhân gửi được yêu cầu tư vấn, CSKH/bác sĩ nhận và trả lời được qua kênh quản trị tạm thời hoặc tool nội bộ, gói khám hiện đúng giá/dịch vụ, đánh giá gắn đúng lần khám.

## Đợt release nội bộ trong phase 1

Đợt 1–3 thuộc go-live 1, Đợt 4–6 thuộc go-live 2.

### Đợt 1: Foundation release (go-live 1)
- Mục tiêu: có app đăng nhập được, liên kết hồ sơ bệnh nhân và nhận thông báo.
- Chức năng: 1, 2, 3, 7, 20 bản nền tảng.
- Đầu ra: app skeleton Flutter, design system, navigation, auth, profile, family profile, notification center, privacy settings.

### Đợt 2: Appointment release (go-live 1)
- Mục tiêu: bệnh nhân đặt lịch và đi khám được từ app.
- Chức năng: 4, 5, 6, 18.
- Đầu ra: đặt lịch, quản lý lịch hẹn, QR check-in, số thứ tự, chỉ đường.

### Đợt 3: Clinical result release (go-live 1)
- Mục tiêu: bệnh nhân xem được kết quả và đơn thuốc sau khám.
- Chức năng: 8, 9.
- Đầu ra: lịch sử khám, kết quả, file PDF, đơn thuốc, nhắc uống thuốc, nhắc tái khám.

### Đợt 4: Payment and document release (go-live 2)
- Mục tiêu: hoàn thiện thanh toán và hồ sơ bổ sung.
- Chức năng: 10, 11.
- Đầu ra: viện phí/tạm ứng, biên lai, lịch sử thanh toán, upload hồ sơ cũ.

### Đợt 5: Continuous care release (go-live 2)
- Mục tiêu: mở rộng từ app đi khám thành app chăm sóc sức khỏe liên tục.
- Chức năng: 13, 14, 16, 17.
- Đầu ra: nhập chỉ số, biểu đồ sức khỏe, chăm sóc sau khám, sổ tiêm chủng.

### Đợt 6: Engagement release (go-live 2)
- Mục tiêu: hoàn thiện tương tác và tăng trải nghiệm dịch vụ.
- Chức năng: 12, 15, 19.
- Đầu ra: chat/tư vấn, gói khám, đánh giá sau khám.
- Điều kiện tiên quyết: có tool vận hành tối thiểu cho CSKH (web admin rút gọn hoặc kênh tạm) để tiếp nhận chat, quản lý gói khám và xử lý phản hồi. Chưa có tool thì không bật các chức năng này cho bệnh nhân.

## Kiến trúc tích hợp gợi ý

### Mobile app Flutter
- Flutter app cho iOS và Android.
- State management: chưa chốt, sẽ quyết định trước khi bắt đầu code. Khuyến nghị chọn giữa **Riverpod** (ít boilerplate, dễ test, hợp với kiến trúc repository/mock của plan này) và **Bloc** (chặt chẽ, hợp team đông đã quen Bloc). Không khuyến khích GetX cho dự án y tế dài hạn vì khó test và khó maintain.
- Local secure storage cho token, PIN và cấu hình bảo mật (dùng flutter_secure_storage, không lưu token trong SharedPreferences).
- Push notification qua Firebase Cloud Messaging hoặc dịch vụ tương đương.

### Backend/mobile API layer
- Nên có một lớp backend riêng cho mobile, không để app gọi trực tiếp vào HIS/EMR.
- Backend mobile xử lý auth, session, mapping hồ sơ, notification, file upload, consent, audit log và điều phối API sang HIS/EMR.
- Backend mobile giúp ẩn bớt phức tạp tích hợp, tránh lộ cấu trúc nội bộ của HIS/EMR ra app.

### Integration layer với hệ thống bệnh viện
- HIS/EMR: hồ sơ bệnh nhân, lịch khám, lần khám, chẩn đoán, đơn thuốc.
- LIS: kết quả xét nghiệm.
- PACS/file server: chẩn đoán hình ảnh, file PDF, ảnh kết quả.
- Queue system: số thứ tự và trạng thái hàng chờ.
- Billing/payment: viện phí, tạm ứng, hóa đơn, biên lai.
- SMS/Zalo/email: OTP và thông báo ngoài app nếu cần.

### Web admin sau này
- Phase sau sẽ cần web admin/back-office để quản lý nội dung, cấu hình, danh mục và vận hành các chức năng mà HIS/EMR không phụ trách.
- Các module web admin nên có sau: quản lý notification, gói khám, nội dung chăm sóc sau khám, chat/tư vấn, phản hồi/đánh giá, danh mục vaccine, cấu hình chỉ số sức khỏe, quản lý file upload và audit log.

## Yêu cầu phi chức năng và vận hành kỹ thuật

Các yêu cầu này áp dụng xuyên suốt, không thuộc riêng chức năng nào, và cần được chuẩn bị từ Đợt 1.

### Môi trường và release
- 3 môi trường: dev, staging, prod. API base URL và cấu hình cấu theo flavor của Flutter (dev/staging/prod build riêng).
- CI/CD: build tự động khi merge code, phân phối bản test nội bộ qua Firebase App Distribution (Android) và TestFlight (iOS).
- Force update: cơ chế kiểm tra phiên bản tối thiểu khi mở app, ép cập nhật khi backend thay đổi không tương thích.
- Phát hành store: app y tế có đăng ký tài khoản sẽ bị Apple review kỹ (cần chính sách quyền riêng tư công khai, chức năng xóa tài khoản bắt buộc). Chuẩn bị tài khoản Apple Developer và Google Play Console sớm, tính thời gian review vào lộ trình go-live.

### Testing
- Unit test cho repository và business logic (mock repository của chiến lược UI-first giúp việc này dễ dàng).
- Widget test cho các màn hình chính.
- Integration test cho các luồng vàng: đăng nhập OTP, đặt lịch, xem kết quả.

### Giám sát và đo lường
- Crash reporting: Firebase Crashlytics hoặc Sentry, bật từ bản release nội bộ đầu tiên.
- Analytics sự kiện chính: đăng ký, đặt lịch thành công, xem kết quả, hủy lịch — để đo mức độ sử dụng sau go-live.

### Offline và lỗi mạng
- Chuẩn hóa hành vi khi mất mạng: màn hình báo lỗi thống nhất, nút retry.
- Cache read-only cho dữ liệu đã xem (lịch hẹn, kết quả đã tải) để bệnh nhân xem lại được khi mạng yếu.
- Dữ liệu ghi (đặt lịch, thanh toán) không cache offline, luôn yêu cầu kết nối.

### Bảo mật kỹ thuật
- Token/PIN lưu bằng flutter_secure_storage.
- Cân nhắc SSL pinning cho API production.
- Ẩn nội dung màn hình khi app vào background/app switcher (dữ liệu y tế nhạy cảm).
- Refresh token và hết hạn phiên rõ ràng, đăng xuất khi token bị thu hồi.

### Trải nghiệm người dùng đặc thù
- Deep-link: bấm push notification phải mở đúng màn hình chi tiết (lịch hẹn, kết quả, hóa đơn), không chỉ mở trang chủ.
- Người cao tuổi là nhóm người dùng lớn của app bệnh viện: cỡ chữ điều chỉnh được (hỗ trợ font scale của hệ điều hành), tương phản cao, nút bấm lớn.
- Song ngữ Việt – Anh: chưa chốt, nhưng khuyến nghị setup i18n (flutter_localizations + ARB) từ đầu kể cả khi chỉ có tiếng Việt — thêm ngôn ngữ sau sẽ rất tốn kém nếu text hard-code.

## Căn cứ pháp lý và tuân thủ

- **Nghị định 13/2023/NĐ-CP** về bảo vệ dữ liệu cá nhân: dữ liệu sức khỏe là dữ liệu cá nhân nhạy cảm, yêu cầu sự đồng ý rõ ràng, cụ thể của chủ thể dữ liệu trước khi xử lý. Chức năng 20 (quản lý đồng ý) cần thiết kế bám theo căn cứ này: màn hình đồng ý khi đăng ký, ghi nhận thời điểm đồng ý, cho phép rút lại đồng ý.
- **Xóa tài khoản và xóa dữ liệu**: Apple bắt buộc app có đăng ký tài khoản phải có chức năng xóa tài khoản trong app. Cần làm rõ với bệnh viện chính sách xóa dữ liệu: dữ liệu tài khoản app có thể xóa, nhưng hồ sơ bệnh án trên HIS/EMR phải lưu theo quy định y tế — app chỉ xóa liên kết và dữ liệu phía app.
- Hội thoại tư vấn (chức năng 12) và dữ liệu tự nhập (chức năng 13) cũng là dữ liệu sức khỏe, áp dụng cùng mức bảo vệ.

## Câu hỏi cần bạn quyết định tiếp

### Nhóm 1: Kết nối HIS/EMR
1. HIS/EMR hiện tại có API sẵn không, hay phải kết nối qua database/file export?
2. HIS/EMR đang quản lý lịch khám theo bác sĩ, phòng khám, chuyên khoa hay theo dịch vụ?
3. HIS/EMR có cho phép app tạo lịch hẹn trực tiếp không, hay chỉ gửi yêu cầu để lễ tân xác nhận?
4. Kết quả xét nghiệm/chẩn đoán hình ảnh đã có API công bố kết quả cho bệnh nhân chưa?

### Nhóm 2: Định danh và liên kết hồ sơ
5. Bệnh nhân nên đăng nhập bằng số điện thoại OTP, CCCD, mã bệnh nhân hay kết hợp nhiều cách?
6. Khi số điện thoại trùng với nhiều hồ sơ trong HIS, app xử lý thế nào?
7. Người nhà xem kết quả của bệnh nhân trên 18 tuổi có cần bệnh nhân đồng ý riêng không?

### Nhóm 3: Vận hành trong bệnh viện
8. Bệnh viện đã có hệ thống lấy số/hàng chờ realtime chưa?
9. Check-in QR sẽ quét ở quầy tiếp đón, kiosk hay app của nhân viên?
10. Thanh toán online có bắt buộc trong phase 1 go-live không, hay có thể bắt đầu bằng hiển thị viện phí trước?
11. Kênh chat/tư vấn ai sẽ trực: CSKH, điều dưỡng hay bác sĩ?

### Nhóm 4: Sản phẩm và phạm vi go-live
12. ~~Go-live full 20 hay tách đợt?~~ **Đã chốt**: tách 2 lần go-live, go-live 1 = Đợt 1–3, go-live 2 = Đợt 4–6.
13. ~~Quy mô team?~~ **Đã chốt**: team 4+ dev (mobile, backend, tester/BA).
14. Mục tiêu thời gian cho go-live 1 là bao lâu: 3 tháng hay hơn?
15. App cần song ngữ Việt – Anh không? (khuyến nghị setup i18n từ đầu dù chưa cần tiếng Anh)
16. Bệnh viện đã có brand guideline, màu sắc, logo, font chữ và UI mẫu chưa?

### Nhóm 5: Kỹ thuật cần chốt trước khi code
17. Chọn state management: Riverpod hay Bloc? (chốt trước khi dựng app skeleton ở Đợt 1)
18. Ai viết OpenAPI spec cho mobile API: team backend hay team mobile draft trước rồi backend duyệt?
19. Bạn muốn mình tiếp tục tách tài liệu này thành PRD, backlog user story, database/API list hay roadmap sprint?
