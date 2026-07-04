class AdminInfoItem {
  const AdminInfoItem({required this.label, required this.value});
  final String label;
  final String value;
}

class InsuranceCard {
  const InsuranceCard({
    required this.number,
    required this.registeredHospital,
    required this.validUntil,
    required this.isValid,
  });

  final String number;
  final String registeredHospital;
  final String validUntil;
  final bool isValid;
}

class MedicalBackground {
  const MedicalBackground(
      {required this.allergies,
      required this.chronicConditions,
      required this.bloodType});
  final List<String> allergies;
  final String chronicConditions;
  final String bloodType;
}

class PersonalInfo {
  const PersonalInfo(
      {required this.adminItems,
      required this.insurance,
      required this.medical});
  final List<AdminInfoItem> adminItems;
  final InsuranceCard insurance;
  final MedicalBackground medical;
}
