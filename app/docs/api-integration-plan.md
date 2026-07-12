# Kế hoạch ghép API vào Mobile (NAHealth patient app)

> Mục tiêu: thay dần các `Mock*Repository` bằng `Api*Repository` gọi thật tới BE, **không sửa
> UI / provider / model**. Kiến trúc mock-first đã đặt sẵn "đường may" (seam) để làm việc này —
> kế hoạch này chỉ điền vào phần còn thiếu và lật công tắc từng feature một.

---

## 0. Bối cảnh & nguyên tắc

**Cái đã có sẵn (không phải làm lại):**
- `core/network/result.dart` — `Result<T>` + `AppFailure` (lỗi đã chuẩn hoá, UI chỉ switch trên đó).
- `core/network/error_mapper.dart` — `mapHttpError(error, statusCode)` viết sẵn, **chưa dùng**; sẽ gọi ở đúng 1 chỗ (interceptor).
- Mỗi feature: `abstract *Repository` (interface) + `Mock*Repository` (impl giả).
- Provider mỗi feature wire repo trong **đúng 1 dòng** (vd `auth_providers.dart:9`), có comment sẵn: *"Switch to the real API: change only this line."*

**Cái còn thiếu (phần việc của plan này):**
- HTTP client + secure storage (chưa có trong `pubspec.yaml`).
- Tầng `ApiClient` (dio) + interceptors: base URL, header `tenant`, `Authorization`, map lỗi, refresh 401.
- Quản lý token (lưu / nạp / refresh / logout).
- Với mỗi feature: một class `Api*Repository implements *Repository` + hàm map JSON → model.
- Cấu hình môi trường (base URL theo dev/staging/prod) + công tắc `useMock`.

**Nguyên tắc bất di bất dịch:**
1. UI và provider **không được import** `Api*Repository` hay dio. Chỉ đổi dòng khởi tạo trong file `*_providers.dart`.
2. Mọi lỗi kỹ thuật (status code, JSON lỗi, timeout) phải bị chặn ở tầng network và biến thành `AppFailure`. UI không bao giờ thấy `DioException`.
3. **Giữ lại** `Mock*Repository` — không xoá. Chúng là fallback để chạy offline/demo và là "spec" của hợp đồng dữ liệu.
4. Map JSON ↔ model chỉ nằm trong tầng data. HIS đổi field → chỉ sửa hàm `fromJson`, UI không đụng.

---

## 1. Bản đồ endpoint BE ↔ repository Mobile

BE: base `/api/v1`, **đa tenant → mọi request gửi header `tenant: root`**. Auth bệnh nhân dùng token
"audience bệnh nhân" (policy `PatientOnly`), khác token nhân viên.

| Mobile feature / repo | BE endpoint (đã xác nhận trong code) | Ghi chú |
|---|---|---|
| `auth` → `AuthRepository.sendOtp` | `POST /api/v1/patient/auth/otp` | public, rate-limited |
| `auth` → `verifyOtp` | `POST /api/v1/patient/auth/otp/verify` | trả `PatientAuthResultDto` (access + refresh token); tạo tài khoản lần đầu |
| `auth` → refresh | `POST /api/v1/patient/auth/refresh` *(xác nhận path)* | dùng refresh token |
| `auth` → `GetPatientMe` | `GET /api/v1/patient/me` | cần token bệnh nhân |
| `personal_info` | `GET /api/v1/patient/profiles/{profileId}/personal-info` | đọc HIS qua BE |
| `patient_profiles` / `profile` | `GET/POST .../profiles`, link, add-family | module `Patients` |
| `appointments` | `GET /appointments`, `/appointments/{id}`, `POST cancel` | module `Appointments` |
| booking flow | `GET specialties / doctors / available-dates / available-times`, `POST submit-booking` | |
| `checkin` / queue | `POST checkin`, `GET queue-status` | |
| `results` | `GET results`, `/results/{id}`, `/prescription` | module `Results` (đọc LIS) |
| `prescriptions` | `GET reminders / today-doses`, `POST add-reminder / mark-dose-taken` | module `Medication` |
| `home` dashboard | `GET /api/v1/patient/dashboard` *(xác nhận)* | module `Dashboard` |
| `notifications` | module `PatientNotifications` | |
| `payments` | `GET my-invoices`, `/invoices/{id}`, invoice pdf | module `Billing` |
| `security` / `consent` | module `Security` | |

> ⚠️ **Việc cần làm trước tiên:** chạy BE, mở Swagger (`/swagger`) và **chép chính xác path + shape
> JSON** của từng endpoint patient-facing vào bảng này. Vài path ở trên là suy ra từ tên feature,
> phải đối chiếu route thật (nhất là nhóm `/api/v1/patient/...` vs route trong module).

---

## 2. Phase 0 — Dependencies & cấu hình môi trường

**2.1. Thêm vào `pubspec.yaml`:**
```yaml
dependencies:
  dio: ^5.7.0                    # HTTP client + interceptors
  flutter_secure_storage: ^9.2.2 # lưu access/refresh token an toàn
  # (tuỳ chọn) pretty_dio_logger: ^1.4.0  # log request khi dev
```

**2.2. Cấu hình môi trường** — `lib/core/config/app_env.dart`:
```dart
class AppEnv {
  final String apiBaseUrl;   // vd http://10.0.2.2:5xxx/api/v1 (Android emulator → host)
  final String tenant;       // 'root'
  final bool useMock;        // true = vẫn chạy mock, false = gọi API thật
  const AppEnv({required this.apiBaseUrl, required this.tenant, this.useMock = false});
}

// Nạp từ --dart-define để không hardcode URL:
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5080/api/v1 --dart-define=USE_MOCK=false
const appEnv = AppEnv(
  apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:5080/api/v1'),
  tenant: String.fromEnvironment('TENANT', defaultValue: 'root'),
  useMock: bool.fromEnvironment('USE_MOCK', defaultValue: true),
);
```
> Lưu ý địa chỉ: Android emulator gọi host qua `10.0.2.2`, iOS simulator qua `localhost`, thiết bị
> thật qua IP LAN của máy chạy BE. Bọc trong env để không phải sửa code.

**2.3. Provider công tắc mock/real** — `lib/core/config/config_providers.dart`:
```dart
final appEnvProvider = Provider<AppEnv>((ref) => appEnv);
final useMockProvider = Provider<bool>((ref) => ref.watch(appEnvProvider).useMock);
```

---

## 3. Phase 1 — Tầng network core (làm 1 lần, dùng chung)

Tạo thư mục `lib/core/network/` (đã có `result.dart`, `error_mapper.dart`).

**3.1. Token storage** — `token_store.dart`:
```dart
class TokenStore {
  final _s = const FlutterSecureStorage();
  Future<String?> get accessToken => _s.read(key: 'access_token');
  Future<String?> get refreshToken => _s.read(key: 'refresh_token');
  Future<void> save({required String access, required String refresh}) async {
    await _s.write(key: 'access_token', value: access);
    await _s.write(key: 'refresh_token', value: refresh);
  }
  Future<void> clear() => _s.deleteAll();
}
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
```

**3.2. ApiClient (dio + interceptors)** — `api_client.dart`. Đây là chỗ tập trung mọi thứ:
```dart
Dio buildDio(AppEnv env, TokenStore tokens, ref) {
  final dio = Dio(BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'tenant': env.tenant},          // 🔑 BẮT BUỘC cho đa tenant
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final t = await tokens.accessToken;
      if (t != null) options.headers['Authorization'] = 'Bearer $t';
      handler.next(options);
    },
    onError: (e, handler) async {
      // 401 → thử refresh 1 lần rồi retry; thất bại → logout
      if (e.response?.statusCode == 401 && !_isAuthPath(e.requestOptions.path)) {
        final ok = await _tryRefresh(dio, tokens);
        if (ok) return handler.resolve(await _retry(dio, e.requestOptions));
        ref.read(sessionControllerProvider.notifier).logout();
      }
      handler.next(e);
    },
  ));
  return dio;
}
```
> - Header `tenant` set ở BaseOptions → không lặp lại ở từng repo.
> - Refresh token: dùng cờ chống lặp vô hạn (không refresh cho chính path `patient/auth/*`), và
>   khoá tuần tự để nhiều request 401 cùng lúc chỉ refresh 1 lần.

**3.3. Helper gọi API trả `Result<T>`** — để mọi repo không lặp try/catch:
```dart
Future<Result<T>> apiCall<T>(Future<Response> Function() run, T Function(dynamic json) parse) async {
  try {
    final res = await run();
    return Result.success(parse(res.data));
  } on DioException catch (e) {
    return Result.failure(mapHttpError(e, statusCode: e.response?.statusCode)); // ← error_mapper có sẵn
  } catch (_) {
    return Result.failure(AppFailure.server());
  }
}
```

**3.4. Provider dio** — `api_client_provider.dart`:
```dart
final dioProvider = Provider<Dio>((ref) =>
    buildDio(ref.watch(appEnvProvider), ref.watch(tokenStoreProvider), ref));
```

---

## 4. Phase 2 — Auth & vòng đời token (LÀM ĐẦU TIÊN)

Đây là mắt xích chặn: chưa có token thì mọi endpoint khác 401. Thứ tự:

1. `ApiAuthRepository implements AuthRepository`:
   - `sendOtp(phone)` → `POST /patient/auth/otp`.
   - `verifyOtp(phone, otp)` → `POST /patient/auth/otp/verify`; **lưu access + refresh token** vào
     `TokenStore`; map phần "HIS match" trong `PatientAuthResultDto` → `LinkedPatientMatch?`.
   - `linkProfile` / `createNewProfile` → gọi endpoint tương ứng module `Patients`.
   - `setPin` → xác định lưu PIN ở đâu (local secure storage hay BE); nếu chỉ để mở khoá app → local.
2. Lật `authRepositoryProvider` (`auth_providers.dart:9`) sang `ApiAuthRepository` khi `useMock=false`:
   ```dart
   final authRepositoryProvider = Provider<AuthRepository>((ref) {
     return ref.watch(useMockProvider)
         ? MockAuthRepository(ref.watch(mockConfigProvider))
         : ApiAuthRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider));
   });
   ```
3. Khởi động app: đọc token trong `TokenStore` → set `SessionState.isAuthenticated` để router điều
   hướng (đã có `sessionControllerProvider`). Logout = `tokens.clear()` + `logout()`.
4. `kMockValidOtp = '123456'` trong `mock_config.dart` chỉ dùng cho mock — khi gọi thật OTP tới từ SMS.

**Xong Phase 2 là verify được luồng đăng nhập thật đầu-cuối trước khi đụng feature khác.**

---

## 5. Phase 3 — Ghép từng feature (lặp lại theo khuôn)

Với **mỗi** feature làm đúng 4 bước:
1. Đọc Swagger endpoint → biết path + JSON shape.
2. Viết `Api<Feature>Repository implements <Feature>Repository` trong `data/repositories/`,
   dùng `dioProvider` + `apiCall(...)`, map JSON → model đã có (`data/models/*.dart`).
3. Lật dòng provider trong `presentation/providers/<feature>_providers.dart` theo mẫu ở §4.2.
4. Verify feature đó trên thiết bị/emulator với BE thật.

**Thứ tự đề xuất** (theo phụ thuộc + giá trị demo):
1. `auth` (đã ở Phase 2) → 2. `personal_info` / `patient_profiles` (đơn giản, GET) →
3. `home` dashboard → 4. `appointments` + booking → 5. `checkin`/queue →
6. `results` → 7. `prescriptions` → 8. `notifications` → 9. `payments` → 10. `security`/`consent`.

> Mỗi feature là một PR/commit độc lập, ít rủi ro — vì chỉ thêm 1 file repo và đổi 1 dòng provider.

---

## 6. Chiến lược cutover (mock ↔ real)

- Giữ **cả hai** impl; provider chọn theo `useMockProvider`. Có thể ghép dần: auth + home gọi thật,
  phần chưa xong vẫn mock — app vẫn chạy.
- Có thể làm 1 màn hình debug đổi `useMock` runtime (nâng cao, tuỳ chọn).
- Khi tất cả feature đã ghép và ổn định: đổi `USE_MOCK` mặc định = false; **vẫn giữ** file mock cho test.

---

## 7. Kiểm thử & nghiệm thu

- **Verify thủ công**: chạy BE (mock HIS bật sẵn phía BE), `flutter run --dart-define=USE_MOCK=false`,
  đi hết luồng từng feature, quan sát loading/empty/error thật.
- **Test loading/error**: `MockConfig.forceError/forceEmpty` vẫn dùng được cho nhánh mock; nhánh real
  test bằng cách tắt BE (network error) và gọi endpoint sai (4xx) để chắc `mapHttpError` chạy đúng.
- **Test map JSON**: mỗi model nên có unit test `fromJson` với 1 payload mẫu chép từ Swagger — đây là
  chỗ dễ vỡ nhất khi HIS/BE đổi field.

---

## 8. Rủi ro & điểm dễ vấp (đọc kỹ)

| Rủi ro | Cách xử lý |
|---|---|
| **Quên header `tenant`** → 400/không tìm thấy tenant | Set 1 lần ở `BaseOptions.headers` (§3.2). |
| **Casing JSON** (BE trả camelCase vs PascalCase) | Chốt theo Swagger; viết `fromJson` khớp đúng, có unit test. |
| **Định dạng ngày/giờ** (UTC vs local, ISO 8601) | Parse ở tầng data về `DateTime`, format hiển thị bằng `intl` (đã có). |
| **Shape phân trang** khác giữa các list endpoint | Xem Swagger: `{items, total, page}` hay mảng thuần; thống nhất 1 model `Paged<T>`. |
| **Vòng lặp refresh 401** | Không refresh cho path `patient/auth/*`; refresh tối đa 1 lần; khoá tuần tự. |
| **Token audience sai** (dùng token nhân viên cho app bệnh nhân) | Chỉ dùng token từ `patient/auth/*`; policy BE là `PatientOnly`. |
| **Địa chỉ base URL theo môi trường** | `--dart-define`, không hardcode; nhớ `10.0.2.2` cho Android emulator. |
| **Lỗi kỹ thuật lọt lên UI** | Mọi call qua `apiCall(...)` → luôn trả `AppFailure`; cấm bắt `DioException` trong presentation. |

---

## 9. Checklist tổng

- [ ] Phase 0: thêm dio + secure_storage; `AppEnv` + `--dart-define`; provider `useMock`.
- [ ] Phase 1: `TokenStore`, `ApiClient` (tenant header, auth header, 401 refresh), `apiCall()`, `dioProvider`.
- [ ] Phase 2: `ApiAuthRepository`; lật `authRepositoryProvider`; nạp token lúc mở app; logout.
- [ ] Đối chiếu toàn bộ path + JSON với Swagger, cập nhật bảng §1.
- [ ] Phase 3: ghép lần lượt personal_info → profiles → home → appointments → checkin → results →
      prescriptions → notifications → payments → security (mỗi cái: repo + đổi provider + verify).
- [ ] Unit test `fromJson` cho các model chính.
- [ ] Cutover: đổi mặc định `USE_MOCK=false`, giữ lại mock cho test.

---

### Phụ lục — khuôn `Api*Repository` mẫu (personal_info)
```dart
class ApiPersonalInfoRepository implements PersonalInfoRepository {
  ApiPersonalInfoRepository(this._dio);
  final Dio _dio;

  @override
  Future<Result<PersonalInfo>> getPersonalInfo(String profileId) {
    return apiCall(
      () => _dio.get('/patient/profiles/$profileId/personal-info'),
      (json) => PersonalInfo.fromJson(json as Map<String, dynamic>),
    );
  }
}
```
Nhân bản khuôn này cho mọi feature — chỉ đổi path, kiểu trả về, và hàm `fromJson`.
