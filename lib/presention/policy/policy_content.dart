import 'package:flutter/material.dart';
import '../../core/models/global_settings_model.dart';

enum PolicyType {
  privacyPolicy,
  termsAndConditions,
  aboutUs,
}

class PolicySection {
  final String titleBn;
  final String titleEn;
  final IconData icon;
  final List<String> bulletPointsBn;
  final List<String> bulletPointsEn;
  final String? noteBn;
  final String? noteEn;

  const PolicySection({
    required this.titleBn,
    required this.titleEn,
    required this.icon,
    required this.bulletPointsBn,
    required this.bulletPointsEn,
    this.noteBn,
    this.noteEn,
  });
}

class PolicyData {
  final PolicyType type;
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final IconData icon;
  final String lastUpdatedBn;
  final String lastUpdatedEn;
  final String summaryBn;
  final String summaryEn;
  final List<PolicySection> sections;

  const PolicyData({
    required this.type,
    required this.titleBn,
    required this.titleEn,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.icon,
    required this.lastUpdatedBn,
    required this.lastUpdatedEn,
    required this.summaryBn,
    required this.summaryEn,
    required this.sections,
  });

  static PolicyData getByType(PolicyType type) {
    switch (type) {
      case PolicyType.privacyPolicy:
        return privacyPolicyData;
      case PolicyType.termsAndConditions:
        return termsAndConditionsData;
      case PolicyType.aboutUs:
        return aboutUsData;
    }
  }

  String? getCustomContent({
    required GlobalSettingsModel settings,
    required bool isBn,
  }) {
    switch (type) {
      case PolicyType.privacyPolicy:
        final custom = isBn
            ? settings.privacyPolicyCustomBn
            : settings.privacyPolicyCustomEn;
        return custom.isNotEmpty ? custom : null;
      case PolicyType.termsAndConditions:
        final custom = isBn
            ? settings.termsConditionsCustomBn
            : settings.termsConditionsCustomEn;
        return custom.isNotEmpty ? custom : null;
      case PolicyType.aboutUs:
        final custom = isBn
            ? settings.aboutUsCustomBn
            : settings.aboutUsCustomEn;
        return custom.isNotEmpty ? custom : null;
    }
  }

  // --- 1. PRIVACY POLICY ---
  static const PolicyData privacyPolicyData = PolicyData(
    type: PolicyType.privacyPolicy,
    titleBn: 'গোপনীয়তা নীতি',
    titleEn: 'Privacy Policy',
    subtitleBn: 'ঝটপট ডিরেক্টরি ব্যবহারকারী ও ড্রাইভারদের তথ্যের সুরক্ষা নীতিমালা',
    subtitleEn: 'User and driver data protection policy for Jotpot Directory',
    icon: Icons.shield_outlined,
    lastUpdatedBn: 'সর্বশেষ সংস্করণ: অক্টোবর ২০২৬',
    lastUpdatedEn: 'Last Updated: October 2026',
    summaryBn:
        'ঝটপট (Jotpot) আপনার তথ্যের গোপনীয়তাকে সর্বোচ্চ গুরুত্ব দিয়ে থাকে। এই নীতিমালায় ব্যাখ্যা করা হয়েছে কীভাবে আমরা আপনার তথ্য সংগ্রহ, সংরক্ষণ ও উন্মুক্ত ডিরেক্টরিতে উপস্থাপন করি। ঝটপট প্ল্যাটফর্ম ব্যবহার করে আপনি এই গোপনীয়তা নীতি মেনে নিচ্ছেন।',
    summaryEn:
        'Jotpot places the utmost importance on your privacy. This policy explains how we collect, store, and display information across our open vehicle rental directory. By using Jotpot, you accept the practices outlined here.',
    sections: [
      PolicySection(
        titleBn: '১. যেসকল তথ্য আমরা সংগ্রহ করি',
        titleEn: '1. Information We Collect',
        icon: Icons.folder_shared_outlined,
        bulletPointsBn: [
          'ড্রাইভার বা গাড়ি মালিকদের তথ্য: ড্রাইভার নিবন্ধনের সময় পুরো নাম, সচল মোবাইল ফোন নম্বর, গাড়ির ধরন (কার, মাইক্রো, হাইয়েস, অ্যাম্বুলেন্স ইত্যাদি), গাড়ির মডেল, রেজিস্ট্রেশন নম্বর এবং ভৌগোলিক এলাকা (বিভাগ, জেলা, উপজেলা, ইউনিয়ন, ওয়ার্ড)।',
          'পরিচয় ও ভেরিফিকেশন তথ্য: চালকের প্রোফাইল ছবি এবং ড্রাইভিং লাইসেন্স সংক্রান্ত তথ্য, যা কেবল অ্যাকাউন্ট বৈধতা নিশ্চিত করতে ব্যবহৃত হয়।',
          'সাধারণ ব্যবহারকারী ও যাত্রী তথ্য: সাধারণ যাত্রী বা ভিজিটরদের গাড়ি খোঁজার জন্য কোনো অ্যাকাউন্ট খোলা বা ব্যক্তিগত গোপনীয় তথ্য দিতে হয় না। কেবল সার্চ ফিল্টার ও লোকেশন সাময়িকভাবে ব্যবহৃত হয়।',
          'প্রযুক্তিগত তথ্য: ব্রাউজার ও ডিভাইসের সাধারণ টেকনিক্যাল তথ্য (যেমন ডিসপ্লে রেজোলিউশন ও নেটওয়ার্ক স্ট্যাটাস), যা কেবল লোডিং গতি ও ইউজার এক্সপেরিয়েন্স উন্নত করতে কাজে লাগে।',
        ],
        bulletPointsEn: [
          'Driver & Vehicle Information: Full name, active mobile number, vehicle category (Car, Microbus, Hiace, Ambulance, etc.), vehicle model, registration number, and operating area (Division, District, Upazila, Union, Ward) collected during registration.',
          'Identity & Verification Data: Driver profile photos and license references utilized solely to verify authentic directory listings.',
          'General Users & Passengers: Passengers are NOT required to register an account or disclose sensitive personal data to search rental vehicles. Only temporary query filters are processed.',
          'Technical & Usage Metrics: Standard technical analytics (browser type, device resolution, network performance) strictly to optimize app responsiveness and speed.',
        ],
        noteBn:
            'বিশেষ দ্রষ্টব্য: আমরা যাত্রীদের কোনো ব্যক্তিগত ব্যাংকিং তথ্য বা পাসওয়ার্ড সংগ্রহ করি না।',
        noteEn:
            'Note: We never ask passengers for sensitive banking credentials or account passwords.',
      ),
      PolicySection(
        titleBn: '২. তথ্যের ব্যবহার ও উন্মুক্ত ডিরেক্টরি নীতিমালা',
        titleEn: '2. How Information Is Used',
        icon: Icons.visibility_outlined,
        bulletPointsBn: [
          'যাত্রী ও চালকের সরাসরি যোগাযোগ: নিবন্ধিত ড্রাইভারদের যোগাযোগের নম্বর ও গাড়ির বিবরণ ওয়েবসাইটে উন্মুক্তভাবে প্রদর্শন করা হয় যাতে যাত্রী প্রয়োজনে সরাসরি ফোনে বা হোয়াটসঅ্যাপে যোগাযোগ করতে পারেন।',
          'লাইসেন্স ও ডিরেক্টরি সক্রিয়তা: ড্রাইভারদের লাইসেন্স মেয়াদ ও সাবস্ক্রিপশন স্ট্যাটাস যাচাই এবং রিনিউয়াল নিশ্চিত করার জন্য।',
          'প্ল্যাটফর্ম নিরাপত্তা: ভুয়া আইডি, ভুল তথ্য বা অসদুপায় রোধ করে ডিরেক্টরির বিশ্বাসযোগ্যতা বজায় রাখার কাজে।',
          'জরুরি ঘোষণা ও নোটিশ: প্ল্যাটফর্মের গুরুত্বপূর্ণ আপডেট বা নোটিশ স্ক্রলিং বারে প্রদর্শন করতে।',
        ],
        bulletPointsEn: [
          'Direct Passenger-Driver Communication: Registered drivers\' contact numbers and vehicle information are publicly displayed on driver cards to facilitate direct phone and WhatsApp contact without middlemen.',
          'License & Directory Maintenance: Checking driver validity, subscription status, and periodic license renewals.',
          'Platform Safety & Verification: Preventing counterfeit listings, duplicate profiles, and ensuring directory integrity.',
          'Service Updates: Notifying users of new features, policy changes, and crucial notices.',
        ],
      ),
      PolicySection(
        titleBn: '৩. তথ্য বিক্রয় না করা ও তৃতীয় পক্ষের গোপনীয়তা',
        titleEn: '3. Zero Data Sale & Third-Party Protection',
        icon: Icons.lock_person_outlined,
        bulletPointsBn: [
          'আমরা কখনোই কোনো ব্যবহারকারী বা ড্রাইভারের ব্যক্তিগত তথ্য কোনো তৃতীয় পক্ষ বা বিজ্ঞাপন সংস্থার কাছে বিক্রয় বা ভাড়া দিই না।',
          'ড্রাইভার লাইসেন্স নবায়নের জন্য বিকাশ পেমেন্ট ট্রানজেকশন আইডি ড্রাইভার নিজেই প্রদান করেন। আমরা কোনো পিন (PIN) বা ওটিপি (OTP) চাই না এবং সংরক্ষণ করি না।',
          'আইনগত বাধ্যবাধকতা: দেশের প্রচলিত আইন প্রয়োগকারী সংস্থা আইনসম্মত তদন্তে কোনো তথ্য তলব করলে কেবল তখনই প্রয়োজনীয় তথ্য যাচাই সাপেক্ষে শেয়ার করা হতে পারে।',
        ],
        bulletPointsEn: [
          'Zero Data Commercialization: We NEVER sell, lease, or distribute personal phone numbers or records to third-party marketing brokers or advertisers.',
          'Secure Mobile Payments: License renewal payments via bKash rely on driver-submitted transaction IDs. We never request, capture, or store your bKash PIN or OTP.',
          'Legal Compliance: Disclosures are strictly limited to lawful requests mandated by recognized law enforcement agencies of Bangladesh.',
        ],
      ),
      PolicySection(
        titleBn: '৪. ক্লাউড স্টোরেজ ও ডাটা সিকিউরিটি',
        titleEn: '4. Cloud Storage & Data Security',
        icon: Icons.security_rounded,
        bulletPointsBn: [
          'ক্লাউড ফায়ারবেস ডেটাবেজ: ডিরেক্টরির সকল তথ্য গুগল ক্লাউড ফায়ারবেস (Cloud Firestore) এর শক্তিশালী এনক্রিপ্টেড সার্ভারে সুরক্ষিত থাকে।',
          'লোকাল ক্যাশিং: দ্রুত লোডিং এবং ইন্টারনেট সাশ্রয়ের জন্য ডিভাইসে হাইভ (Hive) লোকাল ডাটাবেস ব্যবহার করা হয়।',
          'অ্যাডমিন অনুমোদন: নতুন ড্রাইভার নিবন্ধন করার পর অ্যাডমিন দ্বারা প্রাথমিক যাচাই সম্পন্ন হলেই কেবল তথ্য প্রদর্শিত হয়।',
        ],
        bulletPointsEn: [
          'Encrypted Cloud Infrastructure: All listing records are securely housed on Google Cloud Firebase Firestore with modern encryption protocols.',
          'High-Speed Caching: Local caching via Hive ensures fast responsiveness on mobile and web while maintaining device security.',
          'Admin Review & Moderation: New driver submissions undergo administrative review before appearing in public directory results.',
        ],
      ),
      PolicySection(
        titleBn: '৫. ড্রাইভারের অধিকার ও প্রোফাইল মুছে ফেলার নীতি',
        titleEn: '5. Driver Rights & Profile Removal',
        icon: Icons.manage_accounts_outlined,
        bulletPointsBn: [
          'তথ্য সংশোধন: ড্রাইভার যেকোনো সময় ফোন নম্বর, গাড়ির মডেল বা এলাকা হালনাগাদ করার জন্য আমাদের হেল্পলাইনে যোগাযোগ করতে পারেন।',
          'প্রোফাইল অপসারণ: কোনো ড্রাইভার যদি তাঁর নম্বর বা গাড়ি ডিরেক্টরি থেকে স্থায়ীভাবে মুছে ফেলতে চান, তিনি হেল্পলাইনে কল বা ইমেইল করে তাৎক্ষণিক রিমুভ করাতে পারবেন।',
          'সহায়তা কেন্দ্র: ইমেইল support@jotpot.com অথবা হটলাইন 01677234252 নম্বরে যোগাযোগ করুন।',
        ],
        bulletPointsEn: [
          'Information Updating: Drivers can request updates to their vehicle type, mobile number, or operational area at any time.',
          'Profile Deletion / Opt-Out: Any driver may request permanent de-listing and removal of their telephone number from Jotpot by contacting support.',
          'Support Channels: Reach us anytime at support@jotpot.com or dial 01677234252.',
        ],
      ),
    ],
  );

  // --- 2. TERMS & CONDITIONS ---
  static const PolicyData termsAndConditionsData = PolicyData(
    type: PolicyType.termsAndConditions,
    titleBn: 'শর্তাবলী ও ব্যবহার বিধি',
    titleEn: 'Terms & Conditions',
    subtitleBn: 'ঝটপট প্ল্যাটফর্ম ব্যবহারের সার্বিক নিয়মাবলী ও নীতিমালা',
    subtitleEn: 'Comprehensive terms of service for Jotpot Directory platform',
    icon: Icons.gavel_rounded,
    lastUpdatedBn: 'সর্বশেষ সংস্করণ: অক্টোবর ২০২৬',
    lastUpdatedEn: 'Last Updated: October 2026',
    summaryBn:
        'ঝটপট (Jotpot) প্ল্যাটফর্মে আপনাকে স্বাগতম। এই প্ল্যাটফর্ম ব্যবহার করে অথবা ড্রাইভার হিসেবে নিবন্ধন করে আপনি আমাদের এই ব্যবহারের শর্তাবলী মেনে নিচ্ছেন। প্ল্যাটফর্মের স্বচ্ছতা, নিরাপত্তা ও সুষ্ঠু ব্যবস্থাপনা বজায় রাখতে সকল ব্যবহারকারীর এই শর্তগুলো মেনে চলা আবশ্যক।',
    summaryEn:
        'Welcome to Jotpot. By accessing our platform or registering as a driver, you agree to be bound by these Terms and Conditions. These rules ensure a secure, transparent, and fair environment for all passengers and vehicle operators.',
    sections: [
      PolicySection(
        titleBn: '১. প্ল্যাটফর্মের ধরন ও উন্মুক্ত ডিরেক্টরি ডিসক্লেইমার',
        titleEn: '1. Platform Nature & Direct Connection Disclaimer',
        icon: Icons.info_outline_rounded,
        bulletPointsBn: [
          'উন্মুক্ত ডিরেক্টরি সার্ভিস: ঝটপট কোনো রেন্ট-এ-কার কোম্পানি, পরিবহন সংস্থা বা গাড়ির মালিক নয়। এটি কেবল ভাড়ায় চালিত গাড়ির চালক ও যাত্রীদের সরাসরি সংযোগ ঘটিয়ে দেওয়ার একটি উন্মুক্ত ডিজিটাল ডিরেক্টরি।',
          'শূন্য কমিশন (০% কমিশন): ঝটপট কোনো ট্রিপের ভাড়ার ওপর কমিশন গ্রহণ করে না। যাত্রার ভাড়া ও শর্তাবলী সম্পূর্ণভাবে যাত্রী ও চালকের সরাসরি আলোচনার ভিত্তিতে নির্ধারিত হয়।',
          'স্বাধীন পেশাজীবী: তালিকায় থাকা চালকবৃন্দ স্বাধীন পরিবহন পেশাজীবী। তাঁরা ঝটপটের কোনো বেতনভুক্ত বা চুক্তিভিত্তিক কর্মচারী নন।',
        ],
        bulletPointsEn: [
          'Open Directory Service: Jotpot is NOT a taxi service, car-rental company, or transportation operator. Jotpot operates solely as an open digital directory facilitating direct communication between rental vehicle drivers and passengers.',
          'Zero Commission (0% Commission): Jotpot charges 0% commission on passenger rides. Fares, schedules, routes, and arrangements are negotiated directly between passenger and operator.',
          'Independent Operators: Listed drivers are self-employed independent operators and are not employees, agents, or representatives of Jotpot.',
        ],
        noteBn:
            'যাত্রার ভাড়া নির্ধারণ ও পরিশোধ সম্পূর্ণভাবে আপনার এবং ড্রাইভারের নিজস্ব সিদ্ধান্তের ওপর নির্ভরশীল।',
        noteEn:
            'Fare negotiations and payments remain strictly an agreement between passenger and driver.',
      ),
      PolicySection(
        titleBn: '২. চালকদের জন্য আবশ্যকীয় নিয়ম ও শর্তাবলী',
        titleEn: '2. Driver Rules & Registration Obligations',
        icon: Icons.drive_eta_outlined,
        bulletPointsBn: [
          'সঠিক তথ্য প্রদান: নিবন্ধনের সময় নিজের সঠিক নাম, আসল মোবাইল নম্বর, সঠিক গাড়ি ও রেজিস্ট্রেশন নম্বর প্রদান করা বাধ্যতামূলক। ভুল বা প্রতারণামূলক তথ্য দেওয়া দণ্ডনীয় অপরাধ।',
          'বিআরটিএ (BRTA) কাগজপত্র: চালকের অবশ্যই বৈধ ড্রাইভিং লাইসেন্স এবং গাড়ির হালনাগাদ রেজিস্ট্রেশন ও ফিটনেস সনদ থাকতে হবে। লাইসেন্সবিহীন বা ফিটনেসবিহীন গাড়ি তালিকাভুক্ত করা নিষিদ্ধ।',
          'লাইসেন্স নবায়ন ও ফি: ডিরেক্টরিতে নাম সক্রিয় রাখতে নির্ধারিত সাবস্ক্রিপশন বা লাইসেন্স নবায়ন ফি (বিকাশের মাধ্যমে পরিশোধিত) সম্পূর্ণ অফেরতযোগ্য (non-refundable), যা ওয়েবসাইট রক্ষণাবেক্ষণে ব্যবহৃত হয়।',
          'যাত্রী সেবা ও আচরণ: যাত্রীদের সাথে ভদ্র ও পেশাদার আচরণ করতে হবে। কোনো প্রকার দুর্ব্যবহার, অতিরিক্ত ভাড়া নিয়ে জোরজবরদস্তি বা অসদাচরণের অভিযোগ প্রমাণিত হলে আইডি স্থায়ীভাবে বাতিল করা হবে।',
        ],
        bulletPointsEn: [
          'Authentic Details: Drivers must submit accurate legal names, working telephone numbers, and verified vehicle registrations. Submitting false data is strictly prohibited.',
          'Valid BRTA Documentation: Every driver must maintain a valid BRTA driving license and current vehicle fitness documents. Driving without valid documents is strictly disallowed.',
          'Non-Refundable Listing Fee: Subscription and license renewal fees paid via bKash are non-refundable as they cover technical maintenance and directory listing services.',
          'Professional Conduct: Drivers must maintain courteous, lawful, and professional conduct. Validated complaints of passenger harassment or extortion will result in immediate permanent expulsion.',
        ],
      ),
      PolicySection(
        titleBn: '৩. যাত্রী ও সাধারণ ব্যবহারকারীদের দায়িত্ব ও সতর্কতা',
        titleEn: '3. Passenger Guidelines & Due Diligence',
        icon: Icons.person_pin_circle_outlined,
        bulletPointsBn: [
          'যাত্রার পূর্বে ভাড়া চূড়ান্ত করা: ভ্রমণের পূর্বে ফোনে কথা বলে রুট, সম্ভাব্য টোল খরচ এবং ভাড়ার পরিমাণ স্পষ্টভাবে জেনে নেওয়ার দায়িত্ব যাত্রীর।',
          'নিরাপত্তা যাচাই: গাড়িতে ওঠার পূর্বে গাড়ির নম্বর প্লেট ও চালকের পরিচিতি নিশ্চিত করে নেওয়া বুদ্ধিমানের কাজ।',
          'ফোন নম্বরের সদ্ব্যবহার: ডিরেক্টরিতে প্রকাশিত চালকদের ফোন নম্বর কেবল গাড়ি ভাড়ার উদ্দেশ্যেই ব্যবহার করা যাবে। অহেতুক ফোন দেওয়া, বিরক্ত করা বা প্রচারণামূলক কাজে নম্বর ব্যবহার করা বেআইনি।',
        ],
        bulletPointsEn: [
          'Pre-Trip Fare Confirmation: Passengers are advised to clarify complete route expectations, toll fees, and total hiring charges prior to travel.',
          'Personal Due Diligence: Verify vehicle condition and registration plates prior to boarding for personal safety and peace of mind.',
          'Strictly Anti-Spam: Publicly displayed driver phone numbers must be used exclusively for transport hiring. Nuisance calls, unsolicited marketing, or harassment will invite legal action.',
        ],
      ),
      PolicySection(
        titleBn: '৪. দায়বদ্ধতার সীমাবদ্ধতা (Limitation of Liability)',
        titleEn: '4. Limitation of Liability',
        icon: Icons.warning_amber_rounded,
        bulletPointsBn: [
          'দুর্ঘটনা ও ক্ষয়ক্ষতি: ঝটপট কোনো পরিবহন সেবাদাতা নয়, তাই রাস্তায় কোনো সড়ক দুর্ঘটনা, যানজট, বিলম্ব, যাত্রীর মালামাল খোয়া যাওয়া বা ব্যক্তিগত আর্থিক লেনদেনের বিরোধের জন্য ঝটপট কোনো আর্থিক বা আইনি দায় বহন করে না।',
          'প্রাকৃতিক দুর্যোগ ও হরতাল: আবহাওয়া, বন্যা, হরতাল বা অনাকাঙ্ক্ষিত পরিস্থিতিতে গাড়ি উপস্থিত না হওয়া সংক্রান্ত বিরোধ সংশ্লিষ্ট চালক ও যাত্রীর পারস্পরিক সমঝোতার বিষয়।',
        ],
        bulletPointsEn: [
          'Direct Service Limitation: As an open directory, Jotpot assumes zero legal or financial liability for road accidents, travel delays, lost luggage, mechanical failures, or monetary disputes between riders and drivers.',
          'Unforeseen Disruptions: Travel disruptions stemming from extreme weather, political blockades, or breakdowns are subject to mutual resolution between passenger and operator.',
        ],
      ),
      PolicySection(
        titleBn: '৫. অ্যাকাউন্ট বাতিল ও কপিরাইট স্বত্বাধিকার',
        titleEn: '5. Account Suspension & Intellectual Property',
        icon: Icons.shield_moon_outlined,
        bulletPointsBn: [
          'অ্যাকাউন্ট বাতিল: কোনো ড্রাইভার বা ব্যবহারকারী প্ল্যাটফর্মের নীতি ভঙ্গ করলে পূর্ব নোটিশ ছাড়াই তাঁর প্রোফাইল স্থগিত বা স্থায়ীভাবে মুছে ফেলার পূর্ণ অধিকার ঝটপট কর্তৃপক্ষের রয়েছে।',
          'মেধা ও কপিরাইট স্বত্ব: ঝটপট লোগো, ওয়েবসাইট ও অ্যাপের সফটওয়্যার কোড, ডিজাইন ও কনটেন্ট বাংলাদেশের কপিরাইট আইনের আওতায় সংরক্ষিত।',
          'শর্তাবলী সংশোধন: ঝটপট যেকোনো সময় এই নিয়মাবলী পরিবর্তন বা সংশোধন করতে পারে, যা প্রকাশের সাথে সাথে কার্যকর হবে।',
        ],
        bulletPointsEn: [
          'Right to Suspend: Jotpot reserves full authority to suspend or remove any driver or listing without prior notice upon policy breach or fraudulent conduct.',
          'Intellectual Property: The Jotpot trademark, logo, website architecture, mobile apps, and designs are fully protected under Bangladesh copyright laws.',
          'Modifications: Jotpot reserves the right to amend these terms at any time; changes take effect immediately upon posting.',
        ],
      ),
    ],
  );

  // --- 3. ABOUT US ---
  static const PolicyData aboutUsData = PolicyData(
    type: PolicyType.aboutUs,
    titleBn: 'আমাদের সম্পর্কে',
    titleEn: 'About Us',
    subtitleBn: 'ঝটপট ডিরেক্টরি — বাংলাদেশের ভাড়ায় চালিত গাড়ির উন্মুক্ত নেটওয়ার্ক',
    subtitleEn: 'Jotpot Directory — Bangladesh\'s open rental vehicle network',
    icon: Icons.info_outline_rounded,
    lastUpdatedBn: 'সর্বশেষ সংস্করণ: অক্টোবর ২০২৬',
    lastUpdatedEn: 'Last Updated: October 2026',
    summaryBn:
        'ঝটপট (Jotpot) হলো বাংলাদেশের সকল বিভাগ, জেলা ও উপজেলার ভাড়ায় চালিত গাড়ির সবচেয়ে সহজ ও উন্মুক্ত ডিজিটাল ডিরেক্টরি প্ল্যাটফর্ম। মধ্যস্বত্বভোগী বা দালালের ঝামেলা ছাড়াই সহজেই যে কেউ সরাসরি এলাকার বিশ্বস্ত ড্রাইভারের সাথে যোগাযোগ করে গাড়ি ভাড়া করতে পারেন।',
    summaryEn:
        'Jotpot is Bangladesh\'s premier open digital directory for rental vehicles across all 64 districts. We connect passengers directly with reliable local drivers without brokers, middlemen, or commission markups.',
    sections: [
      PolicySection(
        titleBn: '১. আমাদের লক্ষ্য ও ভিশন',
        titleEn: '1. Our Mission & Vision',
        icon: Icons.flag_circle_outlined,
        bulletPointsBn: [
          'সহজ ও সরাসরি সংযোগ: কোনো বুকিং চার্জ বা মধ্যস্বত্বভোগী ছাড়াই দেশের যেকোনো প্রান্তের মানুষ যাতে সহজে নির্ভরযোগ্য ভাড়ার গাড়ি পান, সেই লক্ষ্যেই ঝটপটের সূচনা।',
          'চালক ও মালিকদের ক্ষমতায়ন: স্থানীয় অভিজ্ঞ ড্রাইভারদের ডিজিটাল উপস্থিতির সুযোগ করে দিয়ে তাঁদের কর্মসংস্থান ও নিয়মিত ট্রিপের নিশ্চয়তা বৃদ্ধি করা।',
          'উন্মুক্ত ও স্বচ্ছ প্ল্যাটফর্ম: কোনো লুকানো খরচ নেই। উন্মুক্ত ফোন নম্বর ও এলাকাভিত্তিক ফিল্টারিংয়ের মাধ্যমে তাৎক্ষণিক গাড়ি ভাড়া করার সুবিধা।',
        ],
        bulletPointsEn: [
          'Direct & Fair Mobility: Empowering anyone in Bangladesh to find reliable rental vehicles instantly with zero booking fees or middleman commissions.',
          'Empowering Local Drivers: Providing professional vehicle owners and drivers with a digital listing to showcase services and secure frequent trips.',
          'Transparent & Open: Free, public contact details with deep local search across districts and upazilas.',
        ],
      ),
      PolicySection(
        titleBn: '২. আমরা কী কী সেবা ও সুবিধা দিই',
        titleEn: '2. What We Offer',
        icon: Icons.local_taxi_rounded,
        bulletPointsBn: [
          'সকল ধরনের যানবাহন: প্রাইভেট কার, মাইক্রোবাস, নোয়া/হাইয়েস, অ্যাম্বুলেন্স, পিকআপ/ট্রাক, সিএনজি/অটোরিকশা এবং মোটরবাইক।',
          '৬৪ জেলার গভীর অনুসন্ধান: বিভাগ থেকে শুরু করে জেলা, উপজেলা, ইউনিয়ন এবং ওয়ার্ড পর্যায় পর্যন্ত নির্দিষ্ট ড্রাইভার খোঁজার সুবিধা।',
          'ড্রাইভারদের সহজ রিনিউয়াল: ঘরে বসেই বিকাশ মোবাইল ব্যাংকিংয়ের মাধ্যমে নিজের অ্যাকাউন্ট ও লাইসেন্স সক্রিয় রাখার ব্যবস্থা।',
          'এক ক্লিকে সরাসরি কল: কোনো জটিল রেজিস্ট্রেশন বা অপেক্ষা ছাড়াই সরাসরি চালককে কল বা হোয়াটসঅ্যাপ মেসেজ দেওয়ার সুবিধা।',
        ],
        bulletPointsEn: [
          'All Vehicle Categories: Sedans, Microbuses, Noah/Hiace, Ambulances, Pickups/Trucks, CNG/Auto-rickshaws, and Motorbikes.',
          'Granular Hyper-Local Filtering: Search drivers precisely by Division, District, Upazila, Union, and Ward.',
          'Effortless Renewals: Smooth license renewal for drivers using bKash mobile banking from the comfort of their home.',
          'One-Tap Direct Calling: Dial or WhatsApp drivers in a single click with zero waiting time.',
        ],
      ),
      PolicySection(
        titleBn: '৩. আমাদের মূল অঙ্গীকারসমূহ',
        titleEn: '3. Our Core Values',
        icon: Icons.verified_outlined,
        bulletPointsBn: [
          'নির্ভরযোগ্যতা: নিয়মিত ড্রাইভার তথ্য যাচাই এবং মেয়াদোত্তীর্ণ তথ্য দূরীকরণে নিরবচ্ছিন্ন কাজ করা।',
          'জরুরি প্রয়োজনে পাশে থাকা: অ্যাম্বুলেন্স বা মধ্যরাতে জরুরি যাত্রার মুহূর্তে সাধারণ মানুষের পাশে দাঁড়ানো।',
          'প্রযুক্তিগত উৎকর্ষ: মোবাইল ও কম্পিউটারে দ্রুততম স্পিডে লোড হওয়া আধুনিক ও দৃষ্টিনন্দন ইউজার ইন্টারফেস।',
        ],
        bulletPointsEn: [
          'Reliability: Continuous data moderation ensuring active, dependable driver listings.',
          'Emergency Ready: Providing instant access to ambulance and critical rental services 24/7.',
          'Engineering Excellence: Fast, modern, and beautifully responsive user interfaces for both mobile and web.',
        ],
      ),
      PolicySection(
        titleBn: '৪. হেল্পলাইন ও অফিসিয়াল যোগাযোগ',
        titleEn: '4. Helpline & Official Contact',
        icon: Icons.contact_phone_outlined,
        bulletPointsBn: [
          'হটলাইন / মোবাইল: 01677234252 (সকাল ৮:০০ টা থেকে রাত ১০:০০ টা)',
          'ইমেইল: support@jotpot.com',
          'অফিসিয়াল ঠিকানা: টাঙ্গাইল / ঢাকা, বাংলাদেশ',
          'ওয়েবসাইট: www.jotpot.com',
        ],
        bulletPointsEn: [
          'Helpline / Phone: 01677234252 (8:00 AM – 10:00 PM)',
          'Email: support@jotpot.com',
          'Office Address: Tangail / Dhaka, Bangladesh',
          'Website: www.jotpot.com',
        ],
      ),
    ],
  );
}
