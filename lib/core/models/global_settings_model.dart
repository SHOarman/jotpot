class GlobalSettingsModel {
  final String paymentInstructions;
  final bool automatedPayment;
  final String paymentGatewayName;
  final num discount3Months;
  final num discount6Months;
  final num discount1Year;
  final bool showLiveBanner;
  final String liveBannerText;

  GlobalSettingsModel({
    this.paymentInstructions =
        'Please send the payment via bkash/nagad to jotpot personal account: 01677234297',
    this.automatedPayment = false,
    this.paymentGatewayName = 'bkash',
    this.discount3Months = 0,
    this.discount6Months = 0,
    this.discount1Year = 0,
    this.showLiveBanner = false,
    this.liveBannerText = '',
  });

  factory GlobalSettingsModel.fromMap(Map<String, dynamic> map) {
    final instructions = (map['paymentInstructions'] ?? '').toString().trim();
    return GlobalSettingsModel(
      paymentInstructions: instructions.isNotEmpty
          ? instructions
          : 'Please send the payment via bkash/nagad to jotpot personal account: 01677234297',
      automatedPayment: map['automatedPayment'] == true,
      paymentGatewayName: (map['paymentGatewayName'] ?? 'bkash').toString(),
      discount3Months: (map['discount3Months'] as num?) ?? 0,
      discount6Months: (map['discount6Months'] as num?) ?? 0,
      discount1Year: (map['discount1Year'] as num?) ?? 0,
      showLiveBanner: map['showLiveBanner'] == true,
      liveBannerText: (map['liveBannerText'] ?? '').toString(),
    );
  }
}
