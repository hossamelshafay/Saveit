class UserProfile {
  final String uid;
  final String email;
  final String username;
  final String currency;
  final double balance;
  final double income;
  final double expenses;
  final double savings;
  final double totalInstallments;
  final double paidInstallments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? photoUrl;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.currency,
    required this.balance,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.createdAt,
    this.updatedAt,
    this.photoUrl,
  });
}
