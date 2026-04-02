class CallerProfile {
  final String name;

  const CallerProfile({required this.name});

  static const defaultProfile = CallerProfile(name: '엄마');

  CallerProfile copyWith({String? name}) {
    return CallerProfile(name: name ?? this.name);
  }
}
