class TenantUser {
  final String fullName;
  final String email;

  TenantUser({required this.fullName, required this.email});

  // Convert a TenantUser object into a Map
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
    };
  }

  // Create a TenantUser object from a Map
  factory TenantUser.fromMap(Map<String, dynamic> map) {
    return TenantUser(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
