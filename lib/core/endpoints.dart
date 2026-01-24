import 'package:bdcomputing/core/config/env_config.dart';

class ApiEndpoints {
  static const String domainUrl = EnvConfig.domainUrl;
  static const String baseUrl = EnvConfig.baseUrl;
  static const String serverUrl = domainUrl;

  // Auth endpoints
  static const String loginWithEmailEndpoint = '$baseUrl/auth/sign-in';
  static const String loginWithPhoneEndpoint = '$baseUrl/auth/sign-in/phone';
  static const String refreshTokenEndpoint = '$baseUrl/auth/refresh-token';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String mfaVerifyEndpoint = '$baseUrl/auth/mfa-verify';
  static const String mfaResendEndpoint = '$baseUrl/auth/mfa-resend';
  static const String mfaStatusEndpoint = '$baseUrl/auth/mfa/status';
  static const String mfaTotpDisableEndpoint = '$baseUrl/auth/mfa/totp-disable';
  static const String mfaToggleMethodEndpoint = '$baseUrl/auth/mfa/toggle-method';
  static const String mfaStartTotpSetupEndpoint = '$baseUrl/auth/mfa/start-totp-setup';
  static const String mfaCompleteTotpSetupEndpoint = '$baseUrl/auth/mfa/complete-totp-setup';
  static const String addresses = '$baseUrl/addresses';
  static const String resetPasswordEndpoint = '$baseUrl/auth/password/reset';
  static const String loginWithGoogleEndpoint = '$baseUrl/auth/sign-in/google';
  static const String confirmGoogleLoginEndpoint = '$baseUrl/auth/sign-in/google/confirm';
  static const String updatePasswordWithOTPEndpoint =
      '$baseUrl/auth/password/update-with-otp';
  static const String requestVerificationEndpoint =
      '$baseUrl/auth/account/verification/request-otp';
  static const String verifyAccountEndpoint =
      '$baseUrl/auth/account/verification/validate-otp';
  static const String getProfile = '$baseUrl/auth/me';

  // Vendors
  static const String vendors = '$baseUrl/vendors';


  // Files
  static const String uploadFile = '$baseUrl/files';
  static const String uploadMultipleFiles = '$baseUrl/files/multiple';

  // Orders
  static const String orders = '$baseUrl/orders';

  //Terms
  static const String terms = '$baseUrl/terms';

  // Currencies
  static const String currencies = '$baseUrl/currencies';

  // Invoices
  static const String invoices = '$baseUrl/invoices';


  // Settings
  static const String settings = '$baseUrl/settings';

  // Payment
  static const String mpesaStkPush = '$baseUrl/payments/mpesa';
  static const String mpesaPaymentStatus = '$baseUrl/payments/mpesa/stk-push';
  static const String pesapalPayment = '$baseUrl/payments/pesapal';
  static const String payments = '$baseUrl/payments';

  // Quotes
  static const String quotes = '$baseUrl/quotes';

  // Projects
  static const String projects = '$baseUrl/projects';

  // Lead Projects
  static const String leadProjects = '$baseUrl/lead-projects';

  // Products and Services
  static const String products = '$baseUrl/products';
  static const String services = '$baseUrl/services';
}
