class SecurityToggle {
  const SecurityToggle({
    required this.id,
    required this.icon,
    required this.label,
    required this.sub,
    required this.enabled,
  });

  final String id;
  final String icon;
  final String label;
  final String sub;
  final bool enabled;

  SecurityToggle copyWith({bool? enabled}) {
    return SecurityToggle(
        id: id,
        icon: icon,
        label: label,
        sub: sub,
        enabled: enabled ?? this.enabled);
  }
}

class LoggedInDevice {
  const LoggedInDevice({
    required this.id,
    required this.icon,
    required this.name,
    required this.info,
    required this.isCurrent,
  });

  final String id;
  final String icon;
  final String name;
  final String info;
  final bool isCurrent;
}

class ConsentItem {
  const ConsentItem({
    required this.id,
    required this.label,
    required this.sub,
    required this.enabled,
    this.locked = false,
  });

  final String id;
  final String label;
  final String sub;
  final bool enabled;

  /// A mandatory purpose (e.g. medical care) — cannot be turned off.
  final bool locked;

  ConsentItem copyWith({bool? enabled}) {
    return ConsentItem(
        id: id,
        label: label,
        sub: sub,
        enabled: enabled ?? this.enabled,
        locked: locked);
  }
}
