# Chuc nang nghiep vu app benh nhan

## Boi canh

- Ung dung mobile Flutter cho benh nhan cua mot benh vien don le.
- Benh vien da co HIS/EMR va API san.
- Giai doan hien tai lam UI truoc bang mock data, ghep API sau.
- App can co dashboard ro rang, bottom tabs de dieu huong nhanh va mau xanh la cay la mau chu dao.

## Kien truc app khuyen nghi

Nen dung **Riverpod + go_router**.

### Ly do

- Phu hop voi app lon co nhieu feature va nhieu man hinh.
- De tach UI khoi API bang repository/service.
- De mock data trong giai doan UI-first, sau nay thay bang API that.
- It boilerplate hon Bloc/Cubit.
- De test tung provider, tung repository va tung flow.
- go_router phu hop voi app co nhieu luong: auth, dashboard, lich kham, ket qua, ho so, cai dat.

### Nhuoc diem

- Can thong nhat convention tu dau de tranh provider bi dat lung tung.
- Team moi hoc Riverpod se can thoi gian lam quen.
- Neu khong chia feature ro, app van co the roi khi lon dan.

## 1. Dang ky, dang nhap va xac thuc tai khoan

Benh nhan dang ky va dang nhap bang so dien thoai/OTP. Sau khi dang nhap, app lien ket tai khoan voi ma benh nhan tren HIS/EMR. Chuc nang nay la cua ngo vao toan bo du lieu y te, nen can xu ly bao mat, token, het phien va dang xuat ro rang.

## 2. Ho so benh nhan

Benh nhan xem va cap nhat thong tin ca nhan nhu ho ten, ngay sinh, gioi tinh, so dien thoai, dia chi, CCCD, bao hiem, tien su benh va di ung. Du lieu goc dong bo voi HIS/EMR, app chi la kenh hien thi va cap nhat theo quyen.

## 3. Ho so suc khoe gia dinh

Mot tai khoan co the quan ly nhieu ho so nguoi than. Nguoi dung co the dat lich, xem lich hen, thanh toan hoac xem ket qua cho nguoi than neu co quyen phu hop.

## 4. Dat lich kham

Benh nhan chon chuyen khoa, bac si/dich vu, ngay gio va ly do kham. App tao lich hen qua API va nhan ma lich hen tu he thong benh vien.

## 5. Quan ly lich hen va check-in

Benh nhan xem lich hen sap toi, chi tiet lich hen, huy/doi lich neu duoc phep va dung QR de check-in khi den benh vien.

## 6. Hang cho va so thu tu realtime

Sau khi check-in, app hien thi so thu tu cua benh nhan, so dang goi, phong/quay tiep theo va thoi gian cho du kien neu API ho tro.

## 7. Thong bao va nhac viec

App gui thong bao ve lich hen, ket qua moi, thanh toan, uong thuoc, tai kham, vaccine va tin quan trong tu benh vien.

## 8. Xem ket qua kham, xet nghiem va chan doan hinh anh

Benh nhan xem lich su kham, chan doan, ket qua xet nghiem, file PDF, hinh anh va loi dan bac si sau khi ket qua da duoc cong bo.

## 9. Don thuoc, nhac uong thuoc va tai kham

Benh nhan xem don thuoc, cach dung, tao lich nhac uong thuoc va nhan thong bao tai kham.

## 10. Thanh toan vien phi online

Benh nhan xem cac khoan can thanh toan, thanh toan online, xem trang thai giao dich va bien lai.

## 11. Tai len ho so y te cu

Benh nhan upload anh/PDF cua ket qua kham cu, don thuoc, giay ra vien hoac ho so benh an ngoai vien de bac si tham khao.

## 12. Tu van truc tuyen va nhan tin

Benh nhan tao yeu cau tu van, chat voi CSKH/nhan vien y te/bac si theo quy trinh cua benh vien va gui file dinh kem khi can.

## 13. Theo doi chi so suc khoe ca nhan

Benh nhan nhap cac chi so nhu huyet ap, duong huyet, can nang, nhip tim, SpO2, nhiet do. App luu lich su va canh bao neu vuot nguong.

## 14. Bieu do suc khoe theo thoi gian

App hien thi xu huong chi so suc khoe va mot so ket qua xet nghiem theo thoi gian de benh nhan de theo doi.

## 15. Goi kham va dich vu y te

Benh nhan xem danh sach goi kham, chi tiet dich vu, gia, thoi han va dang ky goi neu benh vien cho phep.

## 16. Cham soc sau kham/sau dieu tri

App hien thi huong dan cham soc tai nha, checklist viec can lam, dau hieu can lien he y te va lich tai kham.

## 17. So tiem chung va nhac vaccine

Benh nhan theo doi mui vaccine da tiem, lich tiem sap toi va nhan nhac tiem cho ban than hoac nguoi than.

## 18. Ban do benh vien va chi duong

App hien dia chi benh vien, phong/khu can den, hotline, gio lam viec va mo ban do de chi duong.

## 19. Danh gia bac si va dich vu

Sau khi kham, benh nhan danh gia trai nghiem, cham diem va gui gop y de benh vien cai tien dich vu.

## 20. Bao mat, quyen rieng tu va quan ly dong y

Benh nhan cau hinh khoa app, sinh trac hoc, an noi dung nhay cam tren thong bao, quan ly dong y chia se du lieu va thiet bi dang nhap.

