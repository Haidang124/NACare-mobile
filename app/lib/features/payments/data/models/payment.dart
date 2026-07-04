class PendingBill {
  const PendingBill({
    required this.id,
    required this.title,
    required this.invoiceCode,
    required this.dateLabel,
    required this.amountVnd,
  });

  final String id;
  final String title;
  final String invoiceCode;
  final String dateLabel;
  final int amountVnd;
}

class PaymentTransaction {
  const PaymentTransaction({
    required this.icon,
    required this.title,
    required this.dateLabel,
    required this.method,
    required this.amountVnd,
    required this.statusLabel,
  });

  final String icon;
  final String title;
  final String dateLabel;
  final String method;
  final int amountVnd;
  final String statusLabel;
}

class BillLineItem {
  const BillLineItem({required this.name, required this.priceVnd});
  final String name;
  final int priceVnd;
}

class PaymentMethod {
  const PaymentMethod(
      {required this.id, required this.name, required this.icon});
  final String id;
  final String name;
  final String icon;
}

class BillDetail {
  const BillDetail({
    required this.items,
    required this.insuranceCoveredVnd,
    required this.patientPaysVnd,
    required this.methods,
  });

  final List<BillLineItem> items;
  final int insuranceCoveredVnd;
  final int patientPaysVnd;
  final List<PaymentMethod> methods;
}
