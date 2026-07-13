import 'package:flutter/foundation.dart';

/// File PDF của một phiếu EMR đã tải về (map từ `EmrFileDto`) — sẵn sàng đưa vào
/// PDF viewer. Endpoint BE trả binary `application/pdf` nên [bytes] là nội dung file.
@immutable
class EmrFile {
  const EmrFile({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}
