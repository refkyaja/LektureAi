class ProfileData {
  final String name;
  final String email;
  final String bio;
  final String school;
  final String grade;
  final List<String> subjects;

  ProfileData({
    required this.name,
    required this.email,
    required this.bio,
    required this.school,
    required this.grade,
    required this.subjects,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'bio': bio,
    'school': school,
    'grade': grade,
    'subjects': subjects,
  };

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    name: json['name'] as String? ?? 'Lekture User',
    email: json['email'] as String? ?? 'student@example.com',
    bio: json['bio'] as String? ?? '',
    school: json['school'] as String? ?? '',
    grade: json['grade'] as String? ?? '',
    subjects: List<String>.from(json['subjects'] ?? []),
  );

  factory ProfileData.defaultProfile() => ProfileData(
    name: 'Lekture User',
    email: 'student@example.com',
    bio: '',
    school: '',
    grade: '',
    subjects: [],
  );
}
