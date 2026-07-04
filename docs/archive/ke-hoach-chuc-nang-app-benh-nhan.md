> **[DEPRECATED]** Tài liệu này là bản nháp 10 chức năng ban đầu, đã được thay thế bởi `../product/ke-hoach-20-chuc-nang-app-benh-nhan.md`. Giữ lại để tham khảo, không cập nhật tiếp.

# Kế hoạch chức năng app mobile cho bệnh nhân

Ứng dụng mobile Flutter dành cho bệnh nhân, hỗ trợ đăng ký khám, quản lý lịch hẹn, xem kết quả khám và tương tác với cơ sở y tế. Tài liệu này đề xuất 10 chức năng chính và plan triển khai cho từng chức năng.

## 1. Đăng ký, đăng nhập và xác thực tài khoản

### Mục tiêu
Cho phép bệnh nhân tạo tài khoản, đăng nhập an toàn và quản lý danh tính y tế của mình.

### Màn hình chính
- Màn hình đăng nhập.
- Màn hình đăng ký tài khoản.
- Màn hình xác thực OTP.
- Màn hình quên mật khẩu.
- Màn hình quản lý bảo mật tài khoản.

### Dữ liệu cần có
- Số điện thoại hoặc email.
- Mật khẩu hoặc mã OTP.
- Mã bệnh nhân, nếu đã có trên hệ thống HIS/EMR.
- Trạng thái xác thực tài khoản.

### Luồng xử lý
1. Bệnh nhân nhập số điện thoại/email.
2. Hệ thống gửi OTP.
3. Bệnh nhân xác thực OTP.
4. Hệ thống tạo tài khoản hoặc liên kết với hồ sơ bệnh nhân sẵn có.
5. Bệnh nhân thiết lập mật khẩu/PIN/sinh trắc học.

### MVP
- Đăng ký bằng số điện thoại.
- Đăng nhập bằng OTP hoặc mật khẩu.
- Quên mật khẩu.

### Mở rộng
- Đăng nhập bằng Face ID/Touch ID.
- Xác thực 2 lớp.
- Quản lý thiết bị đăng nhập.

## 2. Hồ sơ bệnh nhân và thông tin cá nhân

### Mục tiêu
Giúp bệnh nhân quản lý thông tin hành chính, thông tin bảo hiểm, người thân và thông tin y tế cơ bản.

### Màn hình chính
- Hồ sơ cá nhân.
- Thông tin bảo hiểm y tế/bảo hiểm tư nhân.
- Danh sách người thân.
- Thông tin liên hệ khẩn cấp.
- Tiền sử bệnh, dị ứng, thuốc đang sử dụng.

### Dữ liệu cần có
- Họ tên, ngày sinh, giới tính.
- CCCD/hộ chiếu.
- Địa chỉ, số điện thoại, email.
- Mã thẻ bảo hiểm.
- Tiền sử bệnh, dị ứng, nhóm máu.

### Luồng xử lý
1. Bệnh nhân mở hồ sơ cá nhân.
2. Cập nhật thông tin cần thiết.
3. Hệ thống kiểm tra dữ liệu bắt buộc.
4. Nếu có tích hợp HIS/EMR, đồng bộ thông tin về hệ thống trung tâm.
5. Bệnh nhân có thể thêm người thân để đặt lịch hộ.

### MVP
- Cập nhật thông tin cá nhân.
- Thêm/sửa/xóa người thân.
- Lưu thông tin bảo hiểm cơ bản.

### Mở rộng
- Quét CCCD/QR bảo hiểm.
- Kiểm tra trùng lặp hồ sơ.
- Phân quyền người thân xem hồ sơ.

## 3. Đặt lịch khám

### Mục tiêu
Cho phép bệnh nhân chủ động đăng ký khám theo chuyên khoa, bác sĩ, ngày giờ và địa điểm.

### Màn hình chính
- Tìm kiếm chuyên khoa/dịch vụ.
- Danh sách bác sĩ.
- Lịch trống của bác sĩ/phòng khám.
- Form thông tin lý do khám.
- Xác nhận lịch hẹn.

### Dữ liệu cần có
- Chuyên khoa.
- Bác sĩ hoặc phòng khám.
- Khung giờ khám.
- Lý do khám/triệu chứng.
- Đối tượng khám: bản thân hoặc người thân.

### Luồng xử lý
1. Bệnh nhân chọn chuyên khoa hoặc dịch vụ.
2. Hệ thống hiển thị bác sĩ và khung giờ còn trống.
3. Bệnh nhân chọn thời gian phù hợp.
4. Bệnh nhân nhập lý do khám và thông tin liên quan.
5. Hệ thống giữ chỗ, xác nhận và tạo mã lịch hẹn.

### MVP
- Đặt lịch theo chuyên khoa.
- Đặt lịch theo ngày giờ.
- Hiển thị trạng thái lịch hẹn.

### Mở rộng
- Gợi ý chuyên khoa theo triệu chứng.
- Đặt lịch tại nhà/telemedicine.
- Danh sách chờ nếu hết slot.

## 4. Quản lý lịch hẹn và check-in

### Mục tiêu
Giúp bệnh nhân xem, đổi, hủy lịch hẹn và check-in trước khi đến khám.

### Màn hình chính
- Danh sách lịch hẹn sắp tới.
- Chi tiết lịch hẹn.
- Đổi lịch/hủy lịch.
- Mã QR check-in.
- Hướng dẫn đến phòng khám.

### Dữ liệu cần có
- Mã lịch hẹn.
- Trạng thái lịch hẹn.
- Thời gian, địa điểm, phòng khám.
- Số thứ tự dự kiến.
- Quy định đổi/hủy lịch.

### Luồng xử lý
1. Bệnh nhân xem danh sách lịch hẹn.
2. Chọn lịch hẹn cần thao tác.
3. Nếu đổi lịch, hệ thống hiển thị các khung giờ thay thế.
4. Nếu check-in, app tạo QR hoặc mã check-in.
5. Hệ thống cập nhật trạng thái tại quầy tiếp đón/phòng khám.

### MVP
- Xem chi tiết lịch hẹn.
- Hủy lịch hẹn.
- QR check-in.

### Mở rộng
- Đổi lịch tự động.
- Ước tính thời gian chờ.
- Bản đồ nội bộ bệnh viện/phòng khám.

## 5. Thanh toán viện phí và tạm ứng online

### Mục tiêu
Giảm thời gian xếp hàng thanh toán bằng cách cho phép bệnh nhân thanh toán online các khoản phí.

### Màn hình chính
- Danh sách khoản cần thanh toán.
- Chi tiết hóa đơn.
- Chọn phương thức thanh toán.
- Kết quả thanh toán.
- Lịch sử giao dịch.

### Dữ liệu cần có
- Mã hóa đơn.
- Nội dung thu.
- Số tiền.
- Trạng thái thanh toán.
- Biên lai điện tử.

### Luồng xử lý
1. Hệ thống tạo khoản phí từ lịch khám/dịch vụ.
2. Bệnh nhân xem chi tiết phí.
3. Bệnh nhân chọn phương thức thanh toán.
4. Cổng thanh toán xử lý giao dịch.
5. App cập nhật trạng thái và hiển thị biên lai.

### MVP
- Xem phí cần thanh toán.
- Thanh toán bằng QR/chuyển khoản/cổng thanh toán.
- Lịch sử thanh toán.

### Mở rộng
- Hoàn tiền khi hủy lịch.
- Tách thanh toán bảo hiểm và tự chi trả.
- Xuất hóa đơn điện tử.

## 6. Xem kết quả khám, kết quả xét nghiệm và chẩn đoán hình ảnh

### Mục tiêu
Cho bệnh nhân xem kết quả khám, đơn thuốc, chỉ định, kết quả xét nghiệm và kết quả chẩn đoán sau khi được công bố.

### Màn hình chính
- Danh sách lần khám.
- Chi tiết lần khám.
- Kết quả xét nghiệm.
- Kết quả chẩn đoán hình ảnh.
- Đơn thuốc và lời dặn bác sĩ.

### Dữ liệu cần có
- Ngày khám.
- Bác sĩ/chuyên khoa.
- Chẩn đoán.
- Kết quả cận lâm sàng.
- Đơn thuốc.
- File PDF/hình ảnh đính kèm.

### Luồng xử lý
1. Bệnh nhân vào mục kết quả.
2. Hệ thống hiển thị các lần khám đã hoàn tất.
3. Bệnh nhân chọn một lần khám.
4. App hiển thị kết quả đã được duyệt/công bố.
5. Bệnh nhân có thể tải PDF hoặc chia sẻ cho bác sĩ khác.

### MVP
- Xem danh sách lần khám.
- Xem kết quả dạng text/PDF.
- Tải kết quả về máy.

### Mở rộng
- Thông báo khi có kết quả mới.
- Hiển thị biểu đồ chỉ số xét nghiệm theo thời gian.
- Chia sẻ kết quả bằng link có thời hạn.

## 7. Đơn thuốc, nhắc uống thuốc và tái khám

### Mục tiêu
Giúp bệnh nhân theo dõi đơn thuốc, uống thuốc đúng lịch và không bỏ lỡ lịch tái khám.

### Màn hình chính
- Danh sách đơn thuốc.
- Chi tiết cách dùng thuốc.
- Lịch nhắc uống thuốc.
- Nhắc tái khám.
- Trạng thái đã uống/chưa uống.

### Dữ liệu cần có
- Tên thuốc, hàm lượng, số lượng.
- Liều dùng, thời điểm dùng.
- Thời gian bắt đầu/kết thúc.
- Hướng dẫn đặc biệt.
- Lịch tái khám.

### Luồng xử lý
1. Hệ thống nhận đơn thuốc từ bác sĩ.
2. App tạo lịch nhắc dựa trên liều dùng.
3. Bệnh nhân xác nhận đã uống thuốc.
4. App thông báo nếu sắp hết liệu trình hoặc sắp đến lịch tái khám.
5. Bệnh nhân có thể đặt lịch tái khám từ thông báo.

### MVP
- Xem đơn thuốc.
- Tạo nhắc uống thuốc.
- Nhắc tái khám.

### Mở rộng
- Báo cáo tuân thủ dùng thuốc.
- Cảnh báo trùng lặp/dị ứng thuốc nếu có dữ liệu.
- Đặt mua thuốc hoặc gửi đơn đến nhà thuốc liên kết.

## 8. Tư vấn trực tuyến và nhắn tin với cơ sở y tế

### Mục tiêu
Tạo kênh tương tác giữa bệnh nhân và cơ sở y tế trước/sau khám, hỗ trợ hỏi đáp nhanh và tư vấn từ xa khi phù hợp.

### Màn hình chính
- Danh sách hội thoại.
- Chat với nhân viên y tế/bác sĩ.
- Gửi file ảnh, kết quả, đơn thuốc.
- Gọi video nếu có telemedicine.
- Câu hỏi thường gặp.

### Dữ liệu cần có
- Nội dung tin nhắn.
- Người gửi/người nhận.
- File đính kèm.
- Trạng thái đã đọc.
- Mã ca tư vấn nếu có.

### Luồng xử lý
1. Bệnh nhân tạo yêu cầu tư vấn.
2. Hệ thống phân loại yêu cầu theo chuyên khoa/mức độ ưu tiên.
3. Nhân viên y tế hoặc bác sĩ phản hồi.
4. Nếu cần khám, hệ thống gợi ý đặt lịch.
5. Lưu lịch sử hội thoại vào hồ sơ nếu được phép.

### MVP
- Chat text.
- Gửi hình ảnh/file.
- Thông báo tin nhắn mới.

### Mở rộng
- Gọi video.
- Bot sàng lọc câu hỏi cơ bản.
- Chuyển tiếp hội thoại đến bác sĩ phù hợp.

## 9. Thông báo, nhắc việc và trung tâm tin tức sức khỏe

### Mục tiêu
Đảm bảo bệnh nhân không bỏ lỡ lịch hẹn, kết quả mới, thanh toán, tái khám và các thông tin quan trọng.

### Màn hình chính
- Trung tâm thông báo.
- Cài đặt loại thông báo.
- Tin tức/hướng dẫn sức khỏe.
- Chương trình khuyến mãi/gói khám nếu có.
- Thông báo khẩn từ cơ sở y tế.

### Dữ liệu cần có
- Loại thông báo.
- Tiêu đề, nội dung.
- Trạng thái đã đọc.
- Thời gian gửi.
- Link hành động liên quan.

### Luồng xử lý
1. Backend tạo thông báo theo sự kiện.
2. App nhận push notification.
3. Bệnh nhân bấm vào thông báo để đến màn hình liên quan.
4. Hệ thống đánh dấu đã đọc.
5. Bệnh nhân tùy chỉnh kênh nhận thông báo.

### MVP
- Push notification cho lịch hẹn, kết quả, thanh toán.
- Trung tâm thông báo trong app.
- Đánh dấu đã đọc.

### Mở rộng
- Phân nhóm tin tức theo bệnh lý/sở thích.
- Chiến dịch chăm sóc sức khỏe.
- Gửi thông báo qua SMS/Zalo/email.

## 10. Bảo mật, quyền riêng tư và quản lý đồng ý

### Mục tiêu
Bảo vệ dữ liệu y tế nhạy cảm, cho bệnh nhân kiểm soát việc chia sẻ và sử dụng thông tin cá nhân.

### Màn hình chính
- Cài đặt bảo mật.
- Quản lý đồng ý sử dụng dữ liệu.
- Lịch sử truy cập hồ sơ.
- Khóa ứng dụng bằng PIN/sinh trắc học.
- Yêu cầu xóa/chặn chia sẻ dữ liệu nếu chính sách cho phép.

### Dữ liệu cần có
- Trạng thái đồng ý.
- Loại dữ liệu được chia sẻ.
- Bên nhận được chia sẻ.
- Lịch sử truy cập.
- Cấu hình khóa ứng dụng.

### Luồng xử lý
1. Bệnh nhân vào cài đặt quyền riêng tư.
2. Xem các mục đồng ý hiện tại.
3. Bật/tắt đồng ý theo từng mục.
4. Hệ thống ghi nhận thời gian và nội dung thay đổi.
5. Các API liên quan phải kiểm tra quyền trước khi trả dữ liệu.

### MVP
- Khóa app bằng PIN/sinh trắc học.
- Quản lý đồng ý cơ bản.
- Ẩn thông tin nhạy cảm trên màn hình khóa/thông báo.

### Mở rộng
- Audit log truy cập hồ sơ.
- Chia sẻ hồ sơ có thời hạn.
- Chính sách lưu trữ/xóa dữ liệu theo từng thị trường.

## Lộ trình triển khai gợi ý

### Giai đoạn 1: MVP cần có
- Đăng ký/đăng nhập.
- Hồ sơ bệnh nhân.
- Đặt lịch khám.
- Quản lý lịch hẹn và check-in.
- Xem kết quả khám.
- Thông báo cơ bản.

### Giai đoạn 2: Tăng trải nghiệm và vận hành
- Thanh toán online.
- Đơn thuốc và nhắc uống thuốc.
- Tư vấn trực tuyến.
- Quản lý người thân nâng cao.

### Giai đoạn 3: Nâng cao và tích hợp sâu
- Telemedicine.
- Biểu đồ theo dõi sức khỏe.
- Audit log và quản lý đồng ý nâng cao.
- Tích hợp HIS/EMR/LIS/PACS/pharmacy.

## Câu hỏi cần làm rõ

1. App này dùng cho phòng khám tư nhân, chuỗi phòng khám hay bệnh viện?
2. Bạn đã có hệ thống quản lý bệnh viện/phòng khám sẵn có chưa, ví dụ HIS, EMR, LIS, PACS?
3. Bạn muốn app chỉ cho bệnh nhân hay có thêm app/admin web cho lễ tân, bác sĩ, điều dưỡng?
4. Bệnh nhân có cần thanh toán online ngay trong app không?
5. Có cần đặt lịch cho người thân, trẻ em, người cao tuổi không?
6. Bạn muốn dùng số điện thoại, email hay CCCD làm định danh chính?
7. Kết quả khám hiện tại đang lưu ở dạng PDF, hình ảnh, hay dữ liệu có cấu trúc?
8. Có cần tích hợp Zalo/SMS/email để gửi OTP và thông báo không?
9. App có cần hỗ trợ song ngữ Anh – Việt không?
10. Mục tiêu ban đầu là làm MVP nhanh hay làm đầy đủ ngay từ phiên bản đầu?
