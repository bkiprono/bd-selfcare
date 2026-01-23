import 'package:bdcomputing/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bdcomputing/core/navigation/adaptive_page_route.dart';
import 'package:bdcomputing/screens/auth/presentation/auth_guard.dart';
import 'package:bdcomputing/screens/auth/presentation/auth_switch.dart';
import 'package:bdcomputing/screens/auth/presentation/login_screen_email.dart';
import 'package:bdcomputing/screens/auth/presentation/login_screen_phone.dart';
import 'package:bdcomputing/screens/auth/presentation/mfa_verification_screen.dart';
import 'package:bdcomputing/screens/auth/presentation/signup_screen.dart';
import 'package:bdcomputing/screens/auth/domain/mfa_models.dart';
import 'package:bdcomputing/screens/auth/presentation/update_password.dart';
import 'package:bdcomputing/screens/contact/get_help_screen.dart';
import 'package:bdcomputing/screens/onboarding_screen.dart';
import 'package:bdcomputing/screens/payments/mpesa_payment_status.dart';
import 'package:bdcomputing/screens/payments/initiate_payment_screen.dart';
import 'package:bdcomputing/screens/payments/paybill_screen.dart';
import 'package:bdcomputing/screens/payments/payments_screen.dart';
import 'package:bdcomputing/screens/help/privacy_policy_screen.dart';
import 'package:bdcomputing/screens/wrapper.dart';
import 'package:bdcomputing/screens/help/terms_screen.dart';
import 'package:bdcomputing/screens/no_internet.dart';

class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String noInternet = '/no-internet';
  static const String onboarding = '/onboarding';
  static const String loginWithEmail = '/login-with-email';
  static const String loginWithPhone = '/login-with-phone';
  static const String register = '/register';
  static const String checkoutAddress = '/checkout-address';
  static const String checkoutPayment = '/checkout-payment';
  static const String checkoutConfirmation = '/checkout-confirmation';
  static const String profile = '/profile';
  static const String forgotPassword = '/forgot-password';
  static const String updatePassword = '/update-password';
  static const String mfaVerification = '/mfa-verification';


  // Payment
  static const String payment = '/payment';
  static const String paybill = '/paybill';
  static const String mpesaPaymentStatus = '/mpesa-payment-status';
  static const String allPayments = '/all-payments';

  // Profile
  static const String getHelp = '/get_help';
  static const String storeSetup = '/store-setup';

  // Support
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';
  

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      /// Core routes
      case home:
        return AdaptivePageRoute(builder: (_) => const HomeWrapper());
      case auth:
        return AdaptivePageRoute(builder: (_) => const AuthSwitchScreen());
      case noInternet:
        return AdaptivePageRoute(builder: (_) => const NoInternetScreen());
      case onboarding:
        return AdaptivePageRoute(builder: (_) => const OnboardingScreen());
      case loginWithEmail:
        return AdaptivePageRoute(builder: (_) => const LoginWithEmailScreen());
      case loginWithPhone:
        return AdaptivePageRoute(builder: (_) => const LoginWithPhoneScreen());
      case register:
        return AdaptivePageRoute(builder: (_) => const SignupScreen());

      case updatePassword:
        return AdaptivePageRoute(builder: (_) => const UpdatePasswordScreen());
      case mfaVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return AdaptivePageRoute(
          builder: (_) => MfaVerificationScreen(
            mfaToken: args?['mfaToken'] as String? ?? '',
            methods: args?['methods'] as List<MfaMethod>? ?? [],
          ),
        );

      case profile:
        return AdaptivePageRoute(
          builder: (_) => const AuthGuard(child: ProfileScreen()),
        );

      case payment:
        final args = settings.arguments as Map<String, dynamic>?;
        final invoiceId = args?['invoiceId'] as String? ?? '';
        return AdaptivePageRoute(
          builder: (_) => InitiatePaymentScreen(invoiceId: invoiceId),
        );
      case paybill:
        final args = settings.arguments as Map<String, dynamic>?;
        final invoiceId = args?['invoiceId'] as String? ?? '';
        return AdaptivePageRoute(
          builder: (_) => PaybillScreen(invoiceId: invoiceId),
        );
      case mpesaPaymentStatus:
        final args = settings.arguments as Map<String, dynamic>?;
        final checkoutRequestID = args?['checkoutRequestID'] as String? ?? '';
        final orderId = args?['orderId'] as String? ?? '';
        return AdaptivePageRoute(
          builder: (_) => MpesaPaymentStatusScreen(
            checkoutRequestID: checkoutRequestID,
            orderId: orderId,
          ),
        );
      case allPayments:
        return AdaptivePageRoute(
          builder: (_) => const AuthGuard(child: PaymentsScreen()),
        );

      case privacyPolicy:
        return AdaptivePageRoute(builder: (_) => const PrivacyPolicyScreen());

      case terms:
        return AdaptivePageRoute(builder: (_) => const TermsScreen());

      case getHelp:
        return AdaptivePageRoute(builder: (_) => const GetHelpScreen());


      /// Fallback
      default:
        return AdaptivePageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
