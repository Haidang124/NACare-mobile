# Mock repository & cách ghép API thật sau này

## Vì sao mock ngay từ đầu

Theo `docs/product/CHUC_NANG_NGHIEP_VU.md`: bệnh viện đã có HIS/EMR nhưng API cho app **chưa sẵn sàng** — giai đoạn hiện tại làm UI trước bằng mock data, ghép API sau. Kiến trúc ở đây được thiết kế để việc ghép API sau **không phải sửa lại UI**.

## Cấu trúc 1 feature bất kỳ

```
features/appointments/
  data/
    models/               <- Appointment, Specialty, BookingDraft, QueueStatus...
    repositories/
      appointments_repository.dart        <- abstract class (hợp đồng)
      mock_appointments_repository.dart   <- implementation giả lập
  presentation/
    providers/
      appointments_providers.dart  <- appointmentsRepositoryProvider trỏ vào Mock*
```

Ví dụ `appointmentsRepositoryProvider`:

```dart
final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return MockAppointmentsRepository(ref.watch(mockConfigProvider));
});
```

**Khi có API thật**, tạo `ApiAppointmentsRepository implements AppointmentsRepository` (gọi `dio`/`http` thật) rồi đổi provider trên thành:

```dart
final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return ApiAppointmentsRepository(ref.watch(apiClientProvider));
});
```

Không cần sửa bất kỳ file nào trong `presentation/screens/` hay `presentation/providers/` khác — vì chúng chỉ biết đến interface `AppointmentsRepository`, không biết đến `Mock...`/`Api...`.

## `Result<T>` — hợp đồng trả về chung

Mọi method repository trả `Future<Result<T>>` (`lib/core/network/result.dart`) thay vì ném exception thẳng:

```dart
sealed class Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;
}
```

`AppFailure` chỉ chứa thông điệp **hiển thị được cho bệnh nhân** (không lộ chi tiết kỹ thuật/stack trace), đúng nguyên tắc an toàn dữ liệu y tế. Khi ghép API thật, tầng `Api*Repository` chịu trách nhiệm bắt lỗi HTTP/timeout và chuyển thành `AppFailure` phù hợp (`AppFailure.network()`, `AppFailure.server()`, `AppFailure.notFound()`, hoặc thông điệp nghiệp vụ cụ thể như OTP sai).

## `MockConfig` — bật fake delay/fake error để test state

`lib/core/network/mock_config.dart`, provider `mockConfigProvider` (`StateProvider<MockConfig>`). Mọi mock repository nhận `MockConfig` qua constructor và dùng:

```dart
await _config.simulateDelay();      // random 400–900ms mặc định
if (_config.shouldFail) return Result.failure(AppFailure.server());
if (_config.forceEmpty) return const Result.success([]);
```

Cách bật khi cần soi trạng thái loading/error/empty (đúng yêu cầu checklist ở `docs/product/ui-ux-app-benh-nhan.md` mục 7):

```dart
// Ở đâu đó có ProviderContainer/WidgetRef, ví dụ 1 màn hình debug riêng cho QA:
ref.read(mockConfigProvider.notifier).state = const MockConfig(forceError: true);
ref.read(mockConfigProvider.notifier).state = const MockConfig(forceEmpty: true);
ref.read(mockConfigProvider.notifier).state = const MockConfig(
  minDelay: Duration(seconds: 2),
  maxDelay: Duration(seconds: 4),
);
```

Vì đây là 1 provider toàn cục, đổi 1 chỗ là ảnh hưởng **toàn bộ** mock repository trong app — không phải bật từng feature riêng.

## Danh sách interface repository hiện có

| Feature | Interface | Method chính |
|---|---|---|
| auth | `AuthRepository` | `sendOtp`, `verifyOtp`, `linkProfile`, `createNewProfile`, `setPin` |
| patient_profiles | `PatientProfilesRepository` | `getProfiles`, `addFamilyMember` |
| home | `HomeRepository` | `getDashboard` |
| notifications | `NotificationsRepository` | `getNotifications` |
| appointments | `AppointmentsRepository` | `getAppointments`, `getAppointmentDetail`, `cancelAppointment`, `getSpecialties`, `getDoctors`, `getAvailableDates`, `getAvailableTimes`, `submitBooking` |
| checkin | `CheckinRepository` | `checkin`, `getQueueStatus` |
| results | `ResultsRepository` | `getResults`, `getResultDetail` |
| prescriptions | `PrescriptionsRepository` | `getPrescription`, `getTodayDoses`, `markDoseTaken` |
| personal_info | `PersonalInfoRepository` | `getPersonalInfo` |
| payments | `PaymentsRepository` | `getPendingBills`, `getTransactions`, `getBillDetail`, `confirmPayment` |
| immunization | `ImmunizationRepository` | `getRecord` |
| health_metrics | `HealthMetricsRepository` | `getMetrics`, `getBloodPressureTrend` |
| security | `SecurityRepository` | `getToggles`, `setToggle`, `getDevices`, `logoutDevice`, `getConsentItems`, `setConsent`, `requestDataDeletion` |

`home/data/repositories/mock_home_repository.dart` gộp sẵn dữ liệu như 1 API dashboard tổng hợp (thường gặp ở backend thật để Trang chủ không phải gọi 3-4 API riêng lẻ) — khi có API thật, nên giữ nguyên kiểu gộp này ở phía backend nếu có thể, hoặc gộp ở `ApiHomeRepository` bằng cách gọi song song các API con.
