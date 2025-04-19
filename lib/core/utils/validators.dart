class Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? positiveNumber(String? value, String fieldName) {
    final num? number = num.tryParse(value ?? '');
    if (number == null || number < 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }
}