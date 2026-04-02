class CallerProfile {
  final String name;
  final String number;

  const CallerProfile({required this.name, required this.number});

  static const defaultProfile = CallerProfile(name: '엄마', number: '010-0000-0000');

  CallerProfile copyWith({String? name, String? number}) {
    return CallerProfile(
      name: name ?? this.name,
      number: number ?? this.number,
    );
  }
}
