class Failure {
  const Failure(this.message, {this.code, this.title, this.warning = false});

  final String message;
  final String? code;
  final String? title;
  final bool warning;
}
