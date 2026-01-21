String? validateEmail(String? v) {
  if (v == null || v.isEmpty) return 'Email required';
  final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!pattern.hasMatch(v.trim())) return 'Invalid email';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.length < 6) return 'Password must be 6+ chars';
  return null;
}