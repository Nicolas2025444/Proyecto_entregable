enum UserRole {
  paciente,
  medico;

  static UserRole fromJson(dynamic value) {
    final normalized = value.toString().trim().toLowerCase();

    switch (normalized) {
      case 'medico':
      case 'médico':
      case 'doctor':
        return UserRole.medico;
      case 'paciente':
      default:
        return UserRole.paciente;
    }
  }

  String toJson() => name;
}

class User {
  final int id;
  final String email;
  final String? nombre;
  final String? apellido;
  final UserRole rol;

  const User({
    required this.id,
    required this.email,
    this.nombre,
    this.apellido,
    required this.rol,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseId(json['id']),
      email: json['email']?.toString() ?? '',
      nombre: json['nombre']?.toString(),
      apellido: json['apellido']?.toString(),
      rol: UserRole.fromJson(json['rol'] ?? json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol.toJson(),
    };
  }

  bool get isPaciente => rol == UserRole.paciente;

  bool get isMedico => rol == UserRole.medico;

  String get nombreCompleto {
    final partes = [nombre, apellido]
        .where((parte) => parte != null && parte.trim().isNotEmpty)
        .map((parte) => parte!.trim())
        .toList();

    return partes.isEmpty ? email : partes.join(' ');
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class LoginResponse {
  final String token;
  final User user;

  const LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json['usuario'] ?? json;

    return LoginResponse(
      token: _extractToken(json),
      user: User.fromJson(Map<String, dynamic>.from(userJson as Map)),
    );
  }

  static String _extractToken(Map<String, dynamic> json) {
    const tokenKeys = ['token', 'accessToken', 'access_token', 'jwt'];

    for (final key in tokenKeys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }

    throw FormatException(
      'La respuesta de login no incluye un token JWT válido.',
    );
  }
}
