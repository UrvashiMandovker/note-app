class AppConstants {
  // App Info
  static const String appName = 'Notes App';
  
  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String addNoteRoute = '/add-note';
  static const String editNoteRoute = '/edit-note';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String notesCollection = 'notes';
  
  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String titleRequired = 'Title is required';
  static const String contentRequired = 'Content is required';
  
  // Error Messages
  static const String somethingWentWrong = 'Something went wrong';
  static const String loginFailed = 'Login failed';
  static const String signupFailed = 'Signup failed';
  static const String noteSaveFailed = 'Failed to save note';
  static const String noteDeleteFailed = 'Failed to delete note';
  
  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String signupSuccess = 'Signup successful';
  static const String noteSaved = 'Note saved successfully';
  static const String noteDeleted = 'Note deleted successfully';
} 