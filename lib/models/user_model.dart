class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? password;
  final String? photo;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? photo = json['photo'];

    // Ubah photo menjadi URL lengkap jika perlu
    if (photo != null && !photo.startsWith('http')) {
      photo =
          'https://backend-project-akhir-102601587611.asia-southeast2.run.app/$photo';
    }
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      photo: photo,
    );
  }

  Map<String, dynamic> toRegisterJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'photo': photo,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? photo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      photo: photo ?? this.photo,
    );
  }
}
