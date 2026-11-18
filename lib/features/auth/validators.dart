class Validators {
  Validators._();
  static final _email = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');

  static String? name(String? v) {
    if (v == null || v.trim().length < 2) return 'Nama minimal 2 karakter';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    if (!_email.hasMatch(v.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }
}
