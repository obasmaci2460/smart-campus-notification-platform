class SimpleUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final int departmentId;
  final String role;
  final bool isSuperAdmin;

  const SimpleUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
    required this.role,
    required this.isSuperAdmin,
  });
}
