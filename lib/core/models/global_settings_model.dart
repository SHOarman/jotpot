import '../../utils/app_strings.dart';

class GlobalSettingsModel {
  final String paymentInstructions;
  final bool automatedPayment;
  final String paymentGatewayName;
  final num discount3Months;
  final num discount6Months;
  final num discount1Year;
  final bool showLiveBanner;
  final String liveBannerText;
  final String liveBannerTextEn;
  final bool allVehiclesFree;

  // Dynamic Contact & Info
  final String contactPhone;
  final String contactEmail;
  final String contactAddress;

  // Custom Legal & Policy Content
  final String privacyPolicyCustomBn;
  final String privacyPolicyCustomEn;
  final String termsConditionsCustomBn;
  final String termsConditionsCustomEn;
  final String aboutUsCustomBn;
  final String aboutUsCustomEn;

  // Dynamic Footer & Policy Titles (from admin)
  final String footerCopyright;
  final String footerCopyrightBn;
  final String footerCopyrightEn;
  final String footerAboutText;
  final String footerAboutTextBn;
  final String footerAboutTextEn;
  final String privacyPolicyTitle;
  final String termsConditionsTitle;
  final String aboutUsTitle;

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
    this.liveBannerTextEn = '',
    this.allVehiclesFree = false,
    this.contactPhone = '01677234252',
    this.contactEmail = 'support@jotpot.com',
    this.contactAddress = 'Tangail / Dhaka, Bangladesh',
    this.privacyPolicyCustomBn = '',
    this.privacyPolicyCustomEn = '',
    this.termsConditionsCustomBn = '',
    this.termsConditionsCustomEn = '',
    this.aboutUsCustomBn = '',
    this.aboutUsCustomEn = '',
    this.footerCopyright = '',
    this.footerCopyrightBn = '',
    this.footerCopyrightEn = '',
    this.footerAboutText = '',
    this.footerAboutTextBn = '',
    this.footerAboutTextEn = '',
    this.privacyPolicyTitle = '',
    this.termsConditionsTitle = '',
    this.aboutUsTitle = '',
  });

  factory GlobalSettingsModel.fromMap(Map<String, dynamic> map) {
    final instructions = (map['paymentInstructions'] ?? '').toString().trim();
    final phone =
        (map['contactPhone'] ?? map['phone'] ?? '').toString().trim();
    final email =
        (map['contactEmail'] ?? map['email'] ?? '').toString().trim();
    final address =
        (map['contactAddress'] ?? map['address'] ?? '').toString().trim();

    final copyBn = (map['footerCopyrightBn'] ??
            map['footerCopyright'] ??
            map['copyrightText'] ??
            '')
        .toString()
        .trim();
    final copyEn = (map['footerCopyrightEn'] ?? '').toString().trim();

    final aboutBn = (map['footerAboutTextBn'] ??
            map['footerAboutText'] ??
            map['footerAbout'] ??
            '')
        .toString()
        .trim();
    final aboutEn = (map['footerAboutTextEn'] ??
            map['footerAboutEn'] ??
            '')
        .toString()
        .trim();

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
      liveBannerTextEn: (map['liveBannerTextEn'] ?? '').toString(),
      allVehiclesFree: map['allVehiclesFree'] == true || map['allVehiclesFree'] == 'true',
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
      footerCopyright: copyBn.isNotEmpty ? copyBn : copyEn,
      footerCopyrightBn: copyBn,
      footerCopyrightEn: copyEn,
      footerAboutText: aboutBn.isNotEmpty ? aboutBn : aboutEn,
      footerAboutTextBn: aboutBn,
      footerAboutTextEn: aboutEn,
      privacyPolicyTitle: (map['privacyPolicyTitleBn'] ??
              map['privacyPolicyTitle'] ??
              '')
          .toString()
          .trim(),
      termsConditionsTitle: (map['termsConditionsTitleBn'] ??
              map['termsConditionsTitle'] ??
              '')
          .toString()
          .trim(),
      aboutUsTitle: (map['aboutUsTitleBn'] ??
              map['aboutUsTitle'] ??
              '')
          .toString()
          .trim(),
    );
  }

  String getFooterAboutText(bool isBn, AppStrings strings) {
    if (isBn) {
      if (footerAboutTextBn.isNotEmpty) return footerAboutTextBn;
      if (footerAboutText.isNotEmpty) return footerAboutText;
      return strings.footerAboutText;
    } else {
      if (footerAboutTextEn.isNotEmpty) return footerAboutTextEn;
      return strings.footerAboutText;
    }
  }

  String getFooterCopyright(bool isBn, AppStrings strings) {
    if (isBn) {
      if (footerCopyrightBn.isNotEmpty) return footerCopyrightBn;
      if (footerCopyright.isNotEmpty) return footerCopyright;
      return strings.footerCopyright;
    } else {
      if (footerCopyrightEn.isNotEmpty) return footerCopyrightEn;
      return strings.footerCopyright;
    }
  }
}
