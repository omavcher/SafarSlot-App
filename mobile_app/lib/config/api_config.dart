class ApiConfig {
  // If running on an Android emulator, 10.0.2.2 points to your PC's localhost.
  // If running on a physical device, replace this with your PC's actual local IP address (e.g., 192.168.1.5).
  // If iOS Simulator, you can use 127.0.0.1 or localhost.
  static const String baseUrl = 'http://10.0.2.2:8080';
  
  static const String sendOtp = '$baseUrl/api/v1/user/send-otp';
  static const String signup = '$baseUrl/api/v1/user/sign-up';
  static const String login = '$baseUrl/api/v1/user/log-in';
  static const String getProfile = '$baseUrl/api/v1/user/profile';
  static const String updateLanguage = '$baseUrl/api/v1/user/language';
  static const String updateLocation = '$baseUrl/api/v1/user/location';
  static const String getNearbyStations = '$baseUrl/api/v1/user/get-nearby-stations';
}
