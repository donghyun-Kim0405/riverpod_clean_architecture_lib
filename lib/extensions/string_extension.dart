

extension StringExtension on String {

  bool get isValidEmail {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }

  bool get isValidPassword {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regex.hasMatch(this);
  }

  bool get isValidPhoneNumber {
    final regex = RegExp(r'^[0-9]{11}$');
    return regex.hasMatch(this);
  }

  bool get isValidNumber {
    final regex = RegExp(r'^[0-9]+$');
    return regex.hasMatch(this);
  }

  bool get isValidUrl {
    final regex = RegExp(r'^http(s)?://([\w-]+.)+[\w-]+(/[\w- ./?%&=])?$');
    return regex.hasMatch(this);
  }

  bool get isValidDate {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return regex.hasMatch(this);
  }

  bool get isValidTime {
    final regex = RegExp(r'^\d{2}:\d{2}$');
    return regex.hasMatch(this);
  }

  bool get isValidDateTime {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$');
    return regex.hasMatch(this);
  }

  int get number => int.tryParse(this) ?? 0;

}