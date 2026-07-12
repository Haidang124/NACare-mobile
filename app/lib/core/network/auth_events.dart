import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tín hiệu "phiên đăng nhập không còn hợp lệ" (vd BE trả 401 và refresh thất bại).
///
/// Tầng network (interceptor trong [dioProvider]) tăng giá trị này khi phát hiện
/// mất phiên. `SessionController` (feature auth) lắng nghe và tự logout. Cách này
/// giữ core **không import** feature nào và tránh vòng import với auth providers.
final unauthorizedSignalProvider = StateProvider<int>((ref) => 0);
