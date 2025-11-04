class Profile {
  const Profile({
    required this.id,
    this.cpf,
    this.phone,
    this.profileImageUrl,
  });

  final String id;
  final String? cpf;
  final String? phone;
  final String? profileImageUrl;

  Profile copyWith({
    String? cpf,
    String? phone,
    String? profileImageUrl,
  }) {
    return Profile(
      id: id,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      cpf: map['cpf'] as String?,
      phone: map['phone'] as String?,
      profileImageUrl: map['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      if (cpf != null) 'cpf': cpf,
      if (phone != null) 'phone': phone,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    };
  }
}
