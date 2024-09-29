class InputValidator {
  static String? validateEmail(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        !RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    var passwordToCheck = value;
    if (passwordToCheck != null) {
      passwordToCheck = passwordToCheck.trim();
      if (passwordToCheck.isEmpty || passwordToCheck.length < 6) {
        return 'Password must be at least 6 characters';
      }
    } else {
      return 'Password cannot be null';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    return null;
  }

  static String? validateFitnessPlanName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Fitness Plan Name cannot be empty';
    } else if (value.trim().length < 3) {
      return 'Fitness Plan Name must be at least 3 characters';
    }
    return null;
  }

  static String? validateNumericalValue(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      // If the value is empty or null, return null for weight
      if (fieldName.toLowerCase() == 'weight') {
        return null;
      } else {
        return '$fieldName cannot be empty';
      }
    } else {
      try {
        double parsedValue = double.parse(value);
        if (parsedValue <= 0) {
          if (fieldName.toLowerCase() == 'weight' && parsedValue == 0) {
            return null;
          }
          return '$fieldName must be greater than 0';
        }
      } catch (e) {
        // Check if the value is not a valid number
        if (!RegExp(r'^[0-9]*(\.[0-9]+)?$').hasMatch(value)) {
          return 'Invalid $fieldName';
        }
      }
    }
    return null;
  }

  static bool containsSpecialCharacters(String value) {
    final specialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return specialCharacters.hasMatch(value);
  }

  // Validation function to check if a string is empty
  static bool isEmpty(String value) {
    return value.trim().isEmpty;
  }
}
