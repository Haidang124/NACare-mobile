import 'package:flutter/material.dart';

/// Chọn icon theo tên loại/phiếu (khớp từ khoá, không phân biệt hoa thường).
/// HIS trả nhiều tên loại khác nhau nên dùng keyword thay vì bảng cứng; không khớp
/// gì thì rơi về icon tài liệu chung.
IconData documentIconFor(String label) {
  final t = label.toLowerCase();
  bool has(String s) => t.contains(s);

  if (has('xét nghiệm') || has('xet nghiem')) return Icons.biotech_outlined;
  if (has('máu') ||
      has('mau') ||
      has('sinh hóa') ||
      has('sinh hoa') ||
      has('huyết học') ||
      has('huyet hoc')) {
    return Icons.science_outlined;
  }
  if (has('hình ảnh') ||
      has('hinh anh') ||
      has('x-quang') ||
      has('x quang') ||
      has('siêu âm') ||
      has('sieu am') ||
      has('chụp')) {
    return Icons.image_outlined;
  }
  if (has('điện tim') || has('dien tim') || has('điện não') || has('ecg')) {
    return Icons.monitor_heart_outlined;
  }
  if (has('hô hấp') ||
      has('ho hap') ||
      has('phế quản') ||
      has('phe quan') ||
      has('phổi') ||
      has('phoi') ||
      has('phục hồi') ||
      has('phuc hoi') ||
      has('chức năng') ||
      has('chuc nang')) {
    return Icons.air_outlined;
  }
  if (has('đơn thuốc') || has('don thuoc') || has('thuốc')) {
    return Icons.medication_outlined;
  }
  if (has('phẫu thuật') || has('thủ thuật') || has('phau thuat')) {
    return Icons.healing_outlined;
  }
  if (has('khám') || has('kham') || has('vào viện') || has('vao vien')) {
    return Icons.medical_services_outlined;
  }
  if (has('kết quả') || has('ket qua')) return Icons.fact_check_outlined;
  if (has('chỉ định') || has('chi dinh')) return Icons.assignment_outlined;
  if (has('bệnh án') || has('benh an')) {
    return Icons.medical_information_outlined;
  }
  return Icons.description_outlined;
}
