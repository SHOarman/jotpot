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
  final String addressBn;
  final String addressEn;

  // Public Content contract with Admin Dashboard
  final String brandNameBn;
  final String brandNameEn;
  final String noticeBn;
  final String noticeEn;
  final String supportPhone;
  final String supportEmail;

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
    this.contactEmail = 'support@jotpotapp.com',
    this.contactAddress = 'Tangail / Dhaka, Bangladesh',
    this.addressBn = 'ঢাকা, বাংলাদেশ',
    this.addressEn = 'Dhaka, Bangladesh',
    this.brandNameBn = 'ঝটপট',
    this.brandNameEn = 'Jotpot',
    this.noticeBn = '',
    this.noticeEn = '',
    this.supportPhone = '01677234297',
    this.supportEmail = 'support@jotpotapp.com',
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
    final instructions = (map['paymentInstructions'] ?? map['manualPaymentInstructions'] ?? '').toString().trim();
    final phone = (map['supportPhone'] ?? map['contactPhone'] ?? map['phone'] ?? '').toString().trim();
    final email = (map['supportEmail'] ?? map['contactEmail'] ?? map['email'] ?? '').toString().trim();
    final address = (map['contactAddress'] ?? map['address'] ?? '').toString().trim();
    final addressBn = (map['addressBn'] ?? map['contactAddressBn'] ?? (address.isNotEmpty ? address : '')).toString().trim();
    final addressEn = (map['addressEn'] ?? map['contactAddressEn'] ?? (address.isNotEmpty ? address : '')).toString().trim();

    String brandBn = (map['brandNameBn'] ?? map['brandName'] ?? '').toString().trim();
    String brandEn = (map['brandNameEn'] ?? map['brandName'] ?? '').toString().trim();
    if (brandBn.isEmpty || brandBn.toLowerCase().contains('.com')) {
      brandBn = 'ঝটপট';
    }
    if (brandEn.isEmpty || brandEn.toLowerCase().contains('.com')) {
      brandEn = 'Jotpot';
    }

    final noticeBn = (map['noticeBn'] ?? map['liveBannerText'] ?? map['noticeText'] ?? '').toString().trim();
    final noticeEn = (map['noticeEn'] ?? map['liveBannerTextEn'] ?? map['noticeTextEn'] ?? '').toString().trim();

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
      showLiveBanner: map['showLiveBanner'] != false,
      liveBannerText: noticeBn.isNotEmpty ? noticeBn : (map['liveBannerText'] ?? '').toString(),
      liveBannerTextEn: noticeEn.isNotEmpty ? noticeEn : (map['liveBannerTextEn'] ?? '').toString(),
      allVehiclesFree: map['allVehiclesFree'] == true || map['allVehiclesFree'] == 'true',
      contactPhone: phone.isNotEmpty ? phone : '01677234297',
      contactEmail: email.isNotEmpty ? email : 'support@jotpotapp.com',
      contactAddress: address.isNotEmpty ? address : 'Dhaka, Bangladesh',
      addressBn: addressBn.isNotEmpty ? addressBn : 'ঢাকা, বাংলাদেশ',
      addressEn: addressEn.isNotEmpty ? addressEn : 'Dhaka, Bangladesh',
      brandNameBn: brandBn.isNotEmpty ? brandBn : 'ঝটপট',
      brandNameEn: brandEn.isNotEmpty ? brandEn : 'Jotpot',
      noticeBn: noticeBn,
      noticeEn: noticeEn,
      supportPhone: phone.isNotEmpty ? phone : '01677234297',
      supportEmail: email.isNotEmpty ? email : 'support@jotpotapp.com',
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

  /// Dynamic brand display name based on current language
  String getBrandName(bool isBn) {
    if (isBn) {
      if (brandNameBn.isNotEmpty && !brandNameBn.toLowerCase().contains('.com')) {
        return brandNameBn;
      }
      return 'ঝটপট';
    } else {
      if (brandNameEn.isNotEmpty && !brandNameEn.toLowerCase().contains('.com')) {
        return brandNameEn;
      }
      return 'Jotpot';
    }
  }

  /// Dynamic notice message based on current language
  String getNoticeText(bool isBn) {
    if (isBn) {
      if (noticeBn.isNotEmpty) return noticeBn;
      if (liveBannerText.isNotEmpty) return liveBannerText;
      final phone = getSupportPhone();
      final brand = getBrandName(true);
      return 'যেকোনো প্রয়োজন বা সহায়তার জন্য $brand-এর সাথে সরাসরি যোগাযোগ করুন। কল করুন: $phone';
    } else {
      if (noticeEn.isNotEmpty) return noticeEn;
      if (liveBannerTextEn.isNotEmpty) return liveBannerTextEn;
      final phone = getSupportPhone();
      final brand = getBrandName(false);
      return 'For any inquiry or assistance, please contact $brand directly. Call: $phone';
    }
  }

  /// Dynamic support phone
  String getSupportPhone() {
    if (supportPhone.isNotEmpty) return supportPhone;
    if (contactPhone.isNotEmpty) return contactPhone;
    return '01677234297';
  }

  /// Dynamic support email
  String getSupportEmail() {
    if (supportEmail.isNotEmpty) return supportEmail;
    if (contactEmail.isNotEmpty) return contactEmail;
    return 'support@jotpotapp.com';
  }

  /// Dynamic address based on current language
  String getAddress(bool isBn) {
    if (isBn) {
      if (addressBn.isNotEmpty) return addressBn;
      if (contactAddress.isNotEmpty) return contactAddress;
      if (addressEn.isNotEmpty) return addressEn;
      return 'ঢাকা, বাংলাদেশ';
    } else {
      if (addressEn.isNotEmpty) return addressEn;
      if (contactAddress.isNotEmpty) return contactAddress;
      if (addressBn.isNotEmpty) return addressBn;
      return 'Dhaka, Bangladesh';
    }
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

  String getPrivacyPolicyTitle(bool isBn, AppStrings strings) {
    if (isBn) {
      if (privacyPolicyTitle.isNotEmpty) return privacyPolicyTitle;
      return strings.footerPrivacyPolicy;
    } else {
      return strings.footerPrivacyPolicy;
    }
  }

  String getAboutUsTitle(bool isBn, AppStrings strings) {
    if (isBn) {
      if (aboutUsTitle.isNotEmpty) return aboutUsTitle;
      return strings.footerAboutUs;
    } else {
      return strings.footerAboutUs;
    }
  }

  String getTermsConditionsTitle(bool isBn, AppStrings strings) {
    if (isBn) {
      if (termsConditionsTitle.isNotEmpty) return termsConditionsTitle;
      return strings.footerTermsConditions;
    } else {
      return strings.footerTermsConditions;
    }
  }

  /// Create a new instance merging additional fields (e.g. from settings/publicContent)
  GlobalSettingsModel merge(Map<String, dynamic> newMap) {
    final mergedMap = toMap()..addAll(newMap);
    return GlobalSettingsModel.fromMap(mergedMap);
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentInstructions': paymentInstructions,
      'automatedPayment': automatedPayment,
      'paymentGatewayName': paymentGatewayName,
      'discount3Months': discount3Months,
      'discount6Months': discount6Months,
      'discount1Year': discount1Year,
      'showLiveBanner': showLiveBanner,
      'liveBannerText': liveBannerText,
      'liveBannerTextEn': liveBannerTextEn,
      'allVehiclesFree': allVehiclesFree,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'contactAddress': contactAddress,
      'addressBn': addressBn,
      'addressEn': addressEn,
      'brandNameBn': brandNameBn,
      'brandNameEn': brandNameEn,
      'noticeBn': noticeBn,
      'noticeEn': noticeEn,
      'supportPhone': supportPhone,
      'supportEmail': supportEmail,
      'privacyPolicyCustomBn': privacyPolicyCustomBn,
      'privacyPolicyCustomEn': privacyPolicyCustomEn,
      'termsConditionsCustomBn': termsConditionsCustomBn,
      'termsConditionsCustomEn': termsConditionsCustomEn,
      'aboutUsCustomBn': aboutUsCustomBn,
      'aboutUsCustomEn': aboutUsCustomEn,
      'footerCopyright': footerCopyright,
      'footerCopyrightBn': footerCopyrightBn,
      'footerCopyrightEn': footerCopyrightEn,
      'footerAboutText': footerAboutText,
      'footerAboutTextBn': footerAboutTextBn,
      'footerAboutTextEn': footerAboutTextEn,
      'privacyPolicyTitle': privacyPolicyTitle,
      'termsConditionsTitle': termsConditionsTitle,
      'aboutUsTitle': aboutUsTitle,
    };
  }
}
