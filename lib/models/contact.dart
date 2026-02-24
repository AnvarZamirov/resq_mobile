class Contact {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final ContactRole role;
  final bool isActive;
  final DateTime? lastAlerted;
  final bool receivesSOS;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.isActive = true,
    this.lastAlerted,
    this.receivesSOS = true,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    ContactRole? role,
    bool? isActive,
    DateTime? lastAlerted,
    bool? receivesSOS,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastAlerted: lastAlerted ?? this.lastAlerted,
      receivesSOS: receivesSOS ?? this.receivesSOS,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.toString().split('.').last,
      'isActive': isActive,
      'lastAlerted': lastAlerted?.toIso8601String(),
      'receivesSOS': receivesSOS,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: ContactRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => ContactRole.secondary,
      ),
      isActive: json['isActive'] as bool? ?? true,
      lastAlerted: json['lastAlerted'] != null
          ? DateTime.parse(json['lastAlerted'] as String)
          : null,
      receivesSOS: json['receivesSOS'] as bool? ?? true,
    );
  }
}

enum ContactRole {
  primary,
  secondary,
  autoAdded, // e.g., local police
}

