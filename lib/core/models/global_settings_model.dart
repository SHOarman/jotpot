class GlobalSettingsModel {
  final String paymentInstructions;
  final bool automatedPayment;
  final String paymentGatewayName;
  final num discount3Months;
  final num discount6Months;
  final num discount1Year;
  final bool showLiveBanner;
  final String liveBannerText;

  // Dynamic Contact & Info
  final String contactPhone;
  final String contactEmail;
  final String contactAddress;

  // Dynamic Policies & Terms (custom content from admin)
  final String privacyPolicyCustomBn;
  final String privacyPolicyCustomEn;
  final String termsConditionsCustomBn;
  final String termsConditionsCustomEn;
  final String aboutUsCustomBn;
  final String aboutUsCustomEn;

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
    this.contactPhone = '01677234252',
    this.contactEmail = 'support@jotpot.com',
    this.contactAddress = 'Tangail / Dhaka, Bangladesh',
    this.privacyPolicyCustomBn = '',
    this.privacyPolicyCustomEn = '',
    this.termsConditionsCustomBn = '',
    this.termsConditionsCustomEn = '',
    this.aboutUsCustomBn = '',
    this.aboutUsCustomEn = '',
  });

  factory GlobalSettingsModel.fromMap(Map<String, dynamic> map) {
    final instructions = (map['paymentInstructions'] ?? '').toString().trim();
    final phone =
        (map['contactPhone'] ?? map['phone'] ?? '').toString().trim();
    final email =
        (map['contactEmail'] ?? map['email'] ?? '').toString().trim();
    final address =
        (map['contactAddress'] ?? map['address'] ?? '').toString().trim();

    return GlobalSettingsModel(
      paymentInstructions: instructions.isNotEmpty
          ? instructions
          : 'Please send the payment via bkash/nagad to jotpot personal account: 01677234297',
      automatedPayment: map['automatedPayment'] == true ||
          map['automatedPayment'] == 'true' ||
          map['automatedPayment'] == 1 ||
          map['automatedGateway'] == true ||
          map['automatedGateway'] == 'true' ||
          map['isAutomated'] == true ||
          map['paymentMethod'] == 'automated' ||
          map['paymentMethod'] == 'gateway',
      paymentGatewayName: (map['paymentGatewayName'] ?? 'bkash').toString(),
      discount3Months: (map['discount3Months'] as num?) ?? 0,
      discount6Months: (map['discount6Months'] as num?) ?? 0,
      discount1Year: (map['discount1Year'] as num?) ?? 0,
      showLiveBanner: map['showLiveBanner'] == true,
      liveBannerText: (map['liveBannerText'] ?? '').toString(),
      contactPhone: phone.isNotEmpty ? phone : '01677234252',
      contactEmail: email.isNotEmpty ? email : 'support@jotpot.com',
      contactAddress:
          address.isNotEmpty ? address : 'Tangail / Dhaka, Bangladesh',
      privacyPolicyCustomBn:
          (map['privacyPolicyBn'] ?? map['privacyPolicyCustomBn'] ?? '')
              .toString()
              .trim(),
      privacyPolicyCustomEn:
          (map['privacyPolicyEn'] ?? map['privacyPolicyCustomEn'] ?? '')
              .toString()
              .trim(),
      termsConditionsCustomBn:
          (map['termsConditionsBn'] ?? map['termsConditionsCustomBn'] ?? '')
              .toString()
              .trim(),
      termsConditionsCustomEn:
          (map['termsConditionsEn'] ?? map['termsConditionsCustomEn'] ?? '')
              .toString()
              .trim(),
      aboutUsCustomBn: (map['aboutUsBn'] ?? map['aboutUsCustomBn'] ?? '')
          .toString()
          .trim(),
      aboutUsCustomEn: (map['aboutUsEn'] ?? map['aboutUsCustomEn'] ?? '')
          .toString()
          .trim(),
    );
  }
}
