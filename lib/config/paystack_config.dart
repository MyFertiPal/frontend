class PaystackConfig {
  static const String publicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: '',
  );
  static const String fallbackEmail = 'testuser@example.com';
}
