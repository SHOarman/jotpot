import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/driver_provider.dart';

class AppStrings {
  final bool isBn;

  const AppStrings(this.isBn);

  static AppStrings of(BuildContext context) {
    final isBn = Provider.of<DriverProvider>(context).isBengali;
    return AppStrings(isBn);
  }

  // --- Header & Brand ---
  String get appTitle => isBn ? 'ঝটপট' : 'Jotpot';
  String get appSubtitle =>
      isBn ? '- ভাড়ায় চালিত গাড়ির ডিরেক্টরি' : '- Rental Vehicle Directory';
  String get heroDescription => isBn
      ? 'আপনার এলাকার বিশ্বস্ত ড্রাইভার খুঁজে পেতে নিচের ফিল্টারগুলো ব্যবহার করুন।'
      : 'Use the filters below to find trusted drivers in your area.';
  String get registerAsDriver =>
      isBn ? 'ড্রাইভার হিসেবে নিবন্ধন করুন' : 'Register as Driver';
  String get languageSwitchLabel => isBn ? 'EN' : 'বাংলা';
  String get renewLicenseBtn =>
      isBn ? 'লাইসেন্স রিনিউ (Renew)' : 'Renew License';

  // --- Search Bar ---
  String get searchPlaceholder => isBn
      ? 'ইউনিয়ন, ওয়ার্ড বা উপজেলা খুঁজুন...'
      : 'Search Union, Ward or Upazila...';

  // --- Filters ---
  String get filterVehicleType => isBn ? 'গাড়ির ধরন' : 'Vehicle Type';
  String get selectVehicleType =>
      isBn ? 'গাড়ির ধরন নির্বাচন করুন' : 'Select Vehicle Type';
  String get filterDivision => isBn ? 'বিভাগ' : 'Division';
  String get selectDivision => isBn ? 'বিভাগ নির্বাচন করুন' : 'Select Division';
  String get filterDistrict => isBn ? 'জেলা' : 'District';
  String get selectDistrict =>
      isBn ? 'জেলা নির্বাচন করুন' : 'Select District';
  String get filterUpazila => isBn ? 'উপজেলা' : 'Upazila';
  String get selectUpazila =>
      isBn ? 'উপজেলা নির্বাচন করুন' : 'Select Upazila';
  String get filterUnion => isBn ? 'ইউনিয়ন/পৌরসভা' : 'Union/Municipality';
  String get filterUnionHint =>
      isBn ? 'ইউনিয়ন/পৌরসভা নির্বাচন করুন' : 'Enter Union/Municipality';
  String get filterWard => isBn ? 'ওয়ার্ড' : 'Ward';
  String get filterWardHint => isBn ? 'ওয়ার্ড নির্বাচন করুন' : 'Enter Ward';
  String get resetFilters => isBn ? 'রিসেট ফিল্টার' : 'Reset Filters';

  // --- Geolocation & Vehicle Translation ---
  String translateDivision(String raw) =>
      AppStrings.translateDivisionStatic(raw, isBn);
  String translateDistrict(String raw) =>
      AppStrings.translateDistrictStatic(raw, isBn);
  String translateUpazila(String raw) =>
      AppStrings.translateUpazilaStatic(raw, isBn);
  String translateUnion(String raw) =>
      AppStrings.translateUnionStatic(raw, isBn);
  String translateWard(String raw) =>
      AppStrings.translateWardStatic(raw, isBn);
  String vehicleCategoryName(String raw) =>
      AppStrings.translateVehicleTypeStatic(raw, isBn);

  // --- Static Geolocation & Vehicle Translation Dictionaries ---
  static const Map<String, String> bnToEnDivisions = {
    'বরিশাল': 'Barishal',
    'চট্টগ্রাম': 'Chattogram',
    'ঢাকা': 'Dhaka',
    'খুলনা': 'Khulna',
    'রাজশাহী': 'Rajshahi',
    'সিলেট': 'Sylhet',
    'রংপুর': 'Rangpur',
    'ময়মনসিংহ': 'Mymensingh',
    'ময়মনসিংহ': 'Mymensingh',
  };

  static const Map<String, String> enToBnDivisions = {
    'barishal': 'বরিশাল',
    'chattogram': 'চট্টগ্রাম',
    'chittagong': 'চট্টগ্রাম',
    'dhaka': 'ঢাকা',
    'khulna': 'খুলনা',
    'rajshahi': 'রাজশাহী',
    'sylhet': 'সিলেট',
    'rangpur': 'রংপুর',
    'mymensingh': 'ময়মনসিংহ',
  };

  static const Map<String, String> bnToEnDistricts = {
    // Barishal
    'ভোলা': 'Bhola',
    'বরিশাল': 'Barishal',
    'পটুয়াখালী': 'Patuakhali',
    'পটুয়াখালী': 'Patuakhali',
    'পিরোজপুর': 'Pirojpur',
    'বরগুনা': 'Barguna',
    'ঝালকাঠি': 'Jhalakathi',
    // Dhaka
    'ঢাকা': 'Dhaka',
    'গাজীপুর': 'Gazipur',
    'নারায়ণগঞ্জ': 'Narayanganj',
    'নারায়ণগঞ্জ': 'Narayanganj',
    'টাঙ্গাইল': 'Tangail',
    'নরসিংদী': 'Narsingdi',
    'মুন্সিগঞ্জ': 'Munshiganj',
    'মানিকগঞ্জ': 'Manikganj',
    'কিশোরগঞ্জ': 'Kishoreganj',
    'ফরিদপুর': 'Faridpur',
    'গোপালগঞ্জ': 'Gopalganj',
    'মাদারীপুর': 'Madaripur',
    'রাজবাড়ী': 'Rajbari',
    'রাজবাড়ী': 'Rajbari',
    'শরীয়তপুর': 'Shariatpur',
    'শরীয়তপুর': 'Shariatpur',
    // Chattogram
    'চট্টগ্রাম': 'Chattogram',
    'কক্সবাজার': 'Cox\'s Bazar',
    'কুমিল্লা': 'Cumilla',
    'ফেনী': 'Feni',
    'নোয়াখালী': 'Noakhali',
    'নোয়াখালী': 'Noakhali',
    'চাঁদপুর': 'Chandpur',
    'ব্রাহ্মণবাড়িয়া': 'Brahmanbaria',
    'ব্রাহ্মণবাড়িয়া': 'Brahmanbaria',
    'রাঙ্গামাটি': 'Rangamati',
    'বান্দরবান': 'Bandarban',
    'খাগড়াছড়ি': 'Khagrachhari',
    'খাগড়াছড়ি': 'Khagrachhari',
    'লক্ষ্মীপুর': 'Lakshmipur',
    // Rajshahi
    'রাজশাহী': 'Rajshahi',
    'বগুড়া': 'Bogura',
    'বগুড়া': 'Bogura',
    'পাবনা': 'Pabna',
    'সিরাজগঞ্জ': 'Sirajganj',
    'নাটোর': 'Natore',
    'নওগাঁ': 'Naogaon',
    'চাঁপাইনবাবগঞ্জ': 'Chapai Nawabganj',
    'জয়পুরহাট': 'Joypurhat',
    'জয়পুরহাট': 'Joypurhat',
    // Khulna
    'খুলনা': 'Khulna',
    'যশোর': 'Jashore',
    'কুষ্টিয়া': 'Kushtia',
    'কুষ্টিয়া': 'Kushtia',
    'সাতক্ষীরা': 'Satkhira',
    'ঝিনাইদহ': 'Jhenaidah',
    'চুয়াডাঙ্গা': 'Chuadanga',
    'চুয়াডাঙ্গা': 'Chuadanga',
    'মেহেরপুর': 'Meherpur',
    'নড়াইল': 'Narail',
    'নড়াইল': 'Narail',
    'বাগেরহাট': 'Bagerhat',
    'মাগুরা': 'Magura',
    // Sylhet
    'সিলেট': 'Sylhet',
    'মৌলভীবাজার': 'Moulvibazar',
    'হবিগঞ্জ': 'Habiganj',
    'সুনামগঞ্জ': 'Sunamganj',
    // Rangpur
    'রংপুর': 'Rangpur',
    'দিনাজপুর': 'Dinajpur',
    'কুড়িগ্রাম': 'Kurigram',
    'কুড়িগ্রাম': 'Kurigram',
    'গাইবান্ধা': 'Gaibandha',
    'নীলফামারী': 'Nilphamari',
    'পঞ্চগড়': 'Panchagarh',
    'পঞ্চগড়': 'Panchagarh',
    'ঠাকুরগাঁও': 'Thakurgaon',
    'লালমনিরহাট': 'Lalmonirhat',
    // Mymensingh
    'ময়মনসিংহ': 'Mymensingh',
    'ময়মনসিংহ': 'Mymensingh',
    'জামালপুর': 'Jamalpur',
    'শেরপুর': 'Sherpur',
    'নেত্রকোণা': 'Netrokona',
    'নেত্রকোনা': 'Netrokona',
  };

  static final Map<String, String> enToBnDistricts = {
    for (var entry in bnToEnDistricts.entries)
      entry.value.toLowerCase().trim(): entry.key,
    'chittagong': 'চট্টগ্রাম',
    'comilla': 'কুমিল্লা',
    'bogra': 'বগুড়া',
    'jessore': 'যশোর',
    'coxs bazar': 'কক্সবাজার',
    'cox\'s bazar': 'কক্সবাজার',
  };

  static const Map<String, String> bnToEnUpazilas = {
    'বোরহানউদ্দিন': 'Burhanuddin',
    'burhanuddin': 'Burhanuddin',
    'ভোলা সদর': 'Bhola Sadar',
    'দৌলতখান': 'Daulatkhan',
    'লালমোহন': 'Lalmohan',
    'চরফ্যাশন': 'Char Fasson',
    'তজুমদ্দিন': 'Tazumuddin',
    'মনপুরা': 'Monpura',
    'বরিশাল সদর': 'Barishal Sadar',
    'বাকেরগঞ্জ': 'Bakerganj',
    'বাবুগঞ্জ': 'Babuganj',
    'উজিরপুর': 'Wazirpur',
    'বানারীপাড়া': 'Banaripara',
    'বানারীপাড়া': 'Banaripara',
    'গৌরনদী': 'Gournadi',
    'মুলাদী': 'Muladi',
    'মেহেন্দিগঞ্জ': 'Mehendiganj',
    'হিজলা': 'Hizla',
    'পটুয়াখালী সদর': 'Patuakhali Sadar',
    'পটুয়াখালী সদর': 'Patuakhali Sadar',
    'বাউফল': 'Bauphal',
    'গলাচিপা': 'Galachipa',
    'দশমিনা': 'Dashmina',
    'কলাপাড়া': 'Kalapara',
    'কলাপাড়া': 'Kalapara',
    'মির্জাগঞ্জ': 'Mirzaganj',
    'দুমকি': 'Dumki',
    'রাঙ্গাবালী': 'Rangabali',
    'পিরোজপুর সদর': 'Pirojpur Sadar',
    'ভান্ডারিয়া': 'Bhandaria',
    'ভান্ডারিয়া': 'Bhandaria',
    'মঠবাড়িয়া': 'Mathbaria',
    'মঠবাড়িয়া': 'Mathbaria',
    'নাজিরপুর': 'Nazirpur',
    'কাউখালী': 'Kawkhali',
    'নেছারাবাদ': 'Nesarabad',
    'ইন্দুরকানী': 'Indurkani',
    'বরগুনা সদর': 'Barguna Sadar',
    'আমতলী': 'Amtali',
    'পাথরঘাটা': 'Patharghata',
    'বেতাগী': 'Betagi',
    'বামনা': 'Bamna',
    'তালতলী': 'Taltali',
    'ঝালকাঠি সদর': 'Jhalakathi Sadar',
    'নলছিটি': 'Nalchhiti',
    'রাজাপুর': 'Rajapur',
    'কাঠালিয়া': 'Kathalia',
    'কাঠালিয়া': 'Kathalia',
    'ধামরাই': 'Dhamrai',
    'সাভার': 'Savar',
    'মিরপুর': 'Mirpur',
    'উত্তরা': 'Uttara',
    'গুলশান': 'Gulshan',
    'কেরানীগঞ্জ': 'Keraniganj',
    'দোহার': 'Dohar',
    'নবাবগঞ্জ': 'Nawabganj',
    'টঙ্গী': 'Tongi',
    'গাজীপুর সদর': 'Gazipur Sadar',
    'কালিয়াকৈর': 'Kaliakair',
    'কালিয়াকৈর': 'Kaliakair',
    'শ্রীপুর': 'Sreepur',
    'কাপাসিয়া': 'Kapasia',
    'কাপাসিয়া': 'Kapasia',
    'নারায়ণগঞ্জ সদর': 'Narayanganj Sadar',
    'নারায়ণগঞ্জ সদর': 'Narayanganj Sadar',
    'রূপগঞ্জ': 'Rupganj',
    'সোনারগাঁও': 'Sonargaon',
    'আড়াইহাজার': 'Araihazar',
    'আড়াইহাজার': 'Araihazar',
    'বন্দর': 'Bandar',
    'টাঙ্গাইল সদর': 'Tangail Sadar',
    'মির্জাপুর': 'Mirzapur',
    'মধুপুর': 'Madhupur',
    'ঘাটাইল': 'Ghatail',
    'সখিপুর': 'Sakhipur',
    'গোপালপুর': 'Gopalpur',
    'নাগরপুর': 'Nagarpur',
    'নরসিংদী সদর': 'Narsingdi Sadar',
    'পলাশ': 'Palash',
    'বেলাব': 'Belabo',
    'শিবপুর': 'Shibpur',
    'রায়পুরা': 'Raipura',
    'রায়পুরা': 'Raipura',
    'মনোহরদী': 'Monohardi',
    'মুন্সিগঞ্জ সদর': 'Munshiganj Sadar',
    'সিরাজদিখান': 'Sirajdikhan',
    'শ্রীনগর': 'Sreenagar',
    'টঙ্গীবাড়ী': 'Tongibari',
    'টঙ্গীবাড়ী': 'Tongibari',
    'গজারিয়া': 'Gazaria',
    'গজারিয়া': 'Gazaria',
    'লৌহজং': 'Lohajang',
    'মানিকগঞ্জ সদর': 'Manikganj Sadar',
    'সিংগাইর': 'Singair',
    'সাটুরিয়া': 'Saturia',
    'সাটুরিয়া': 'Saturia',
    'শিবালয়': 'Shibalaya',
    'শিবালয়': 'Shibalaya',
    'ঘিওর': 'Ghior',
    'দৌলতপুর': 'Daulatpur',
    'হরিরামপুর': 'Harirampur',
    'কিশোরগঞ্জ সদর': 'Kishoreganj Sadar',
    'ভৈরব': 'Bhairab',
    'বাজিতপুর': 'Bajitpur',
    'হোসেনপুর': 'Hossainpur',
    'কটিয়াদী': 'Katiadi',
    'কটিয়াদী': 'Katiadi',
    'করিমগঞ্জ': 'Karimganj',
    'পতেঙ্গা': 'Patenga',
    'পাঁচলাইশ': 'Panchlaish',
    'পাহাড়তলী': 'Pahartali',
    'পাহাড়তলী': 'Pahartali',
    'কোতোয়ালী': 'Kotwali',
    'কোতোয়ালী': 'Kotwali',
    'সীতাকুণ্ড': 'Sitakunda',
    'মিরসরাই': 'Mirsarai',
    'হাটহাজারী': 'Hathazari',
    'রাউজান': 'Raozan',
    'কক্সবাজার সদর': "Cox's Bazar Sadar",
    'টেকনাফ': 'Teknaf',
    'উখিয়া': 'Ukhiya',
    'উখিয়া': 'Ukhiya',
    'রামু': 'Ramu',
    'মহেশখালী': 'Maheshkhali',
    'চকরিয়া': 'Chakaria',
    'চকরিয়া': 'Chakaria',
    'কুমিল্লা সদর': 'Cumilla Sadar',
    'লাকসাম': 'Laksam',
    'দাউদকান্দি': 'Daudkandi',
    'চৌদ্দগ্রাম': 'Chauddagram',
    'দেবীদ্বার': 'Debidwar',
    'মুরাদনগর': 'Muradnagar',
    'ফেনী সদর': 'Feni Sadar',
    'দাগনভূঞা': 'Daganbhuiyan',
    'সোনাগাজী': 'Sonagazi',
    'ছাগলনাইয়া': 'Chhagalnaiya',
    'ছাগলনাইয়া': 'Chhagalnaiya',
    'নোয়াখালী সদর': 'Noakhali Sadar',
    'নোয়াখালী সদর': 'Noakhali Sadar',
    'বেগমগঞ্জ': 'Begumganj',
    'চাটখিল': 'Chatkhil',
    'কোম্পানীগঞ্জ': 'Companiganj',
    'চাঁদপুর সদর': 'Chandpur Sadar',
    'হাজীগঞ্জ': 'Hajiganj',
    'মতলব': 'Matlab',
    'শাহরাস্তি': 'Shahrasti',
    'রাজশাহী সদর': 'Rajshahi Sadar',
    'বাঘা': 'Bagha',
    'চারঘাট': 'Charghat',
    'পুঠিয়া': 'Puthia',
    'পুঠিয়া': 'Puthia',
    'গোদাগাড়ী': 'Godagari',
    'গোদাগাড়ী': 'Godagari',
    'বগুড়া সদর': 'Bogura Sadar',
    'বগুড়া সদর': 'Bogura Sadar',
    'শেরপুর': 'Sherpur',
    'শিবগঞ্জ': 'Shibganj',
    'কাহালু': 'Kahalu',
    'ধুনট': 'Dhunat',
    'পাবনা সদর': 'Pabna Sadar',
    'ঈশ্বরদী': 'Ishwardi',
    'সাঁথিয়া': 'Santhia',
    'সাঁথিয়া': 'Santhia',
    'সুজানগর': 'Sujanagar',
    'বেড়া': 'Bera',
    'বেড়া': 'Bera',
    'সিরাজগঞ্জ সদর': 'Sirajganj Sadar',
    'শাহজাদপুর': 'Shahjadpur',
    'উল্লাপাড়া': 'Ullapara',
    'উল্লাপাড়া': 'Ullapara',
    'বেলকুচি': 'Belkuchi',
    'নাটোর সদর': 'Natore Sadar',
    'সিংড়া': 'Singra',
    'সিংড়া': 'Singra',
    'বড়াইগ্রাম': 'Baraigram',
    'বড়াইগ্রাম': 'Baraigram',
    'গুরুদাসপুর': 'Gurudaspur',
    'খুলনা সদর': 'Khulna Sadar',
    'খালিশপুর': 'Khalishpur',
    'ডুমুরিয়া': 'Dumuria',
    'ডুমুরিয়া': 'Dumuria',
    'বটিয়াঘাটা': 'Batiaghata',
    'বটিয়াঘাটা': 'Batiaghata',
    'যশোর সদর': 'Jashore Sadar',
    'ঝিকরগাছা': 'Jhikargachha',
    'অভয়নগর': 'Abhaynagar',
    'অভয়নগর': 'Abhaynagar',
    'কেশবপুর': 'Keshabpur',
    'কুষ্টিয়া সদর': 'Kushtia Sadar',
    'কুষ্টিয়া সদর': 'Kushtia Sadar',
    'কুমারখালী': 'Kumarkhali',
    'ভেড়ামারা': 'Bheramara',
    'ভেড়ামারা': 'Bheramara',
    'সাতক্ষীরা সদর': 'Satkhira Sadar',
    'কালীগঞ্জ': 'Kaliganj',
    'শ্যামনগর': 'Shyamnagar',
    'সিলেট সদর': 'Sylhet Sadar',
    'বিয়ানীবাজার': 'Beanibazar',
    'বিয়ানীবাজার': 'Beanibazar',
    'গোলাপগঞ্জ': 'Golapganj',
    'জৈন্তাপুর': 'Jaintiapur',
    'বিশ্বনাথ': 'Bishwanath',
    'মৌলভীবাজার সদর': 'Moulvibazar Sadar',
    'শ্রীমঙ্গল': 'Sreemangal',
    'কমলগঞ্জ': 'Kamalganj',
    'কুলাউড়া': 'Kulaura',
    'কুলাউড়া': 'Kulaura',
    'হবিগঞ্জ সদর': 'Habiganj Sadar',
    'মাধবপুর': 'Madhabpur',
    'চুনারুঘাট': 'Chunarughat',
    'নবীগঞ্জ': 'Nabiganj',
    'সুনামগঞ্জ সদর': 'Sunamganj Sadar',
    'ছাতক': 'Chhatak',
    'জগন্নাথপুর': 'Jagannathpur',
    'তাহিরপুর': 'Tahirpur',
    'রংপুর সদর': 'Rangpur Sadar',
    'বদরগঞ্জ': 'Badarganj',
    'পীরগঞ্জ': 'Pirganj',
    'মিঠাপুকুর': 'Mithapukur',
    'দিনাজপুর সদর': 'Dinajpur Sadar',
    'বীরগঞ্জ': 'Birganj',
    'বিরামপুর': 'Birampur',
    'পার্বতীপুর': 'Parbatipur',
    'কুড়িগ্রাম সদর': 'Kurigram Sadar',
    'কুড়িগ্রাম সদর': 'Kurigram Sadar',
    'নাগেশ্বরী': 'Nageshwari',
    'উলিপুর': 'Ulipur',
    'ময়মনসিংহ সদর': 'Mymensingh Sadar',
    'ময়মনসিংহ সদর': 'Mymensingh Sadar',
    'ত্রিশাল': 'Trishal',
    'ভালুকা': 'Bhaluka',
    'মুক্তাগাছা': 'Muktagachha',
    'গফরগাঁও': 'Gafargaon',
    'জামালপুর সদর': 'Jamalpur Sadar',
    'মেলান্দহ': 'Melandaha',
    'মাদারগঞ্জ': 'Madarganj',
    'সরিষাবাড়ী': 'Sarishabari',
    'সরিষাবাড়ী': 'Sarishabari',
    'শেরপুর সদর': 'Sherpur Sadar',
    'নকলা': 'Nakla',
    'নালিতাবাড়ী': 'Nalitabari',
    'নালিতাবাড়ী': 'Nalitabari',
    'শ্রীবরদী': 'Sreebardi',
    'নেত্রকোণা সদর': 'Netrokona Sadar',
    'নেত্রকোনা সদর': 'Netrokona Sadar',
    'কেন্দুয়া': 'Kendua',
    'কেন্দুয়া': 'Kendua',
    'পূর্বধলা': 'Purbadhala',
    'দুর্গাপুর': 'Durgapur',
    'উত্তরা পূর্ব': 'Uttara East',
    'উত্তরা পশ্চিম': 'Uttara West',
    'উত্তরখান': 'Uttar Khan',
    'দক্ষিণখান': 'Dakshin Khan',
    'বিমানবন্দর': 'Airport',
    'তুরাগ': 'Turag',
    'খিলক্ষেত': 'Khilkhet',
    'ক্যান্টনমেন্ট': 'Cantonment',
    'বনানী': 'Banani',
    'বাড্ডা': 'Badda',
    'ভাটারা': 'Vatara',
    'রামপুরা': 'Rampura',
    'হাতিরঝিল': 'Hatirjheel',
    'ধানমন্ডি': 'Dhanmondi',
    'কলাবাগান': 'Kalabagan',
    'নিউমার্কেট': 'New Market',
    'হাজারীবাগ': 'Hazaribagh',
    'মোহাম্মদপুর': 'Mohammadpur',
    'আদাবর': 'Adabor',
    'তেজগাঁও': 'Tejgaon',
    'তেজগাঁও শিল্পাঞ্চল': 'Tejgaon Industrial',
    'শেরেবাংলা নগর': 'Sher-e-Bangla Nagar',
    'পল্লবী': 'Pallabi',
    'রূপনগর': 'Rupnagar',
    'কাফরুল': 'Kafrul',
    'শাহআলী': 'Shah Ali',
    'দারুস সালাম': 'Darus-Salam',
    'খিলগাঁও': 'Khilgaon',
    'সবুজবাগ': 'Sabujbag',
    'মুগদা': 'Mugda',
    'মতিঝিল': 'Motijheel',
    'পল্টন': 'Paltan Model',
    'শাহজাহানপুর': 'Shahjahanpur',
    'রমনা': 'Ramna Model',
    'শাহবাগ': 'Shahbag',
    'সূত্রাপুর': 'Sutrapur',
    'ওয়ারী': 'Wari',
    'গেন্ডারিয়া': 'Gandaria',
    'লালবাগ': 'Lalbagh',
    'চকবাজার': 'Chakbazar',
    'বংশাল': 'Bangshal',
    'কামরাঙ্গীরচর': 'Kamrangirchar',
    'যাত্রাবাড়ী': 'Jatrabari',
    'ডেমরা': 'Demra',
    'কদমতলী': 'Kadamtoli',
    'শ্যামপুর': 'Shyampur',
    'ভাসানটেক': 'Bhashantek',
    'কোটালীপাড়া': 'Kotalipara',
    'মুকসুদপুর': 'Muksudpur',
    'কাশিয়ানী': 'Kashiani',
    'টুঙ্গিপাড়া': 'Tungipara',
    'ডাসার': 'Dasar',
    'সদরপুর': 'Sadarpur',
    'চরভদ্রাসন': 'Charbhadrasan',
    'নগরকান্দা': 'Nagarkanda',
    'সালথা': 'Saltha',
    'বোয়ালমারী': 'Boalmari',
    'মধুখালী': 'Madhukhali',
    'আলফাডাঙ্গা': 'Alfadanga',
    'ভাঙ্গা': 'Bhanga',
    'গোয়ালন্দ': 'Goalanda',
    'পাংশা': 'Pangsha',
    'বালিয়াকান্দি': 'Baliakandi',
    'কালুখালী': 'Kalukhali',
    'শরীয়তপুর সদর': 'Shariatpur Sadar',
    'নড়িয়া': 'Naria',
    'জাজিরা': 'Zajira',
    'ডামুড্যা': 'Damudya',
    'ভেদরগঞ্জ': 'Bhedarganj',
    'গোসাইরহাট': 'Gosairhat',
    'খুলশী': 'Khulshi',
    'চান্দগাঁও': 'Chandgaon',
    'বাকলিয়া': 'Bakalia',
    'বায়েজিদ বোস্তামী': 'Bayazid Bostami',
    'ডবলমুরিং': 'Double Mooring',
    'হালিশহর': 'Halishahar',
    'ইপিজেড': 'EPZ',
    'আকবর শাহ': 'Akbar Shah',
    'কর্ণফুলী': 'Karnaphuli',
    'সদরঘাট': 'Sadarghat',
    'বাগাতিপাড়া': 'Bagatipara',
    'লালপুর': 'Lalpur',
    'নলডাঙ্গা': 'Naldanga',
    'নীলফামারী সদর': 'Nilphamari Sadar',
    'সৈয়দপুর': 'Saidpur',
    'ডোমার': 'Domar',
    'ডিমলা': 'Dimla',
    'জলঢাকা': 'Jaldhaka',
    'কিশোরগঞ্জ': 'Kishoreganj',
    'চিলমারী': 'Chilmari',
    'রৌমারী': 'Raomari',
    'চর রাজীবপুর': 'Char Rajibpur',
    'ভূরুঙ্গামারী': 'Bhurungamari',
    'রাজারহাট': 'Rajarhat',
    'ফুলবাড়ী': 'Phulbari',
    'ফুলবাড়ীয়া': 'Fulbaria',
    'নান্দাইল': 'Nandail',
    'ঈশ্বরগঞ্জ': 'Ishwarganj',
    'গৌরীপুর': 'Gauripur',
    'ফুলপুর': 'Phulpur',
    'তারাকান্দা': 'Tara Khanda',
    'হালুয়াঘাট': 'Haluaghat',
    'ধোবাউড়া': 'Dhobaura',
    'ইসলামপুর': 'Islampur',
    'দেওয়ানগঞ্জ': 'Dewanganj',
    'বকশীগঞ্জ': 'Baksiganj',
    'বারহাট্টা': 'Barhatta',
    'কলমাকান্দা': 'Kalmakanda',
    'মদন': 'Madan',
    'মোহনগঞ্জ': 'Mohanganj',
    'খালিয়াজুড়ি': 'Khaliajuri',
    'আটপাড়া': 'Atpara',
    'ঝিনাইগাতী': 'Jhenaigati',
    'টঙ্গী পূর্ব': 'Tanggi East',
    'টঙ্গী পশ্চিম': 'Tanggi West',
    'বাসন': 'Basan',
    'কোনাবাড়ী': 'Konabari',
    'কাশিমপুর': 'Kashimapur',
    'গাছা': 'Gachha',
    'পূবাইল': 'Pubail',
    'ফতুল্লা': 'Phatulla',
    'সিদ্ধিরগঞ্জ': 'Siddhiraganj',
    'দেলদুয়ার': 'Deladuyar',
    'সখীপুর': 'Sakhipur',
    'বাসাইল': 'Basail',
    'ধনবাড়ী': 'Dhanbari',
    'ভূঞাপুর': 'Bhunapur',
    'কালিহাতী': 'Kalihati',
    'কুলিয়ারচর': 'Kuliyarachar',
    'পাকুন্দিয়া': 'Pakundia',
    'তাড়াইল': 'Tarail',
    'ইটনা': 'Itna',
    'মিঠামইন': 'Mithamain',
    'অষ্টগ্রাম': 'Austagram',
    'নিকলী': 'Nikli',
    'মুন্সীগঞ্জ সদর': 'Munshiganj Sadar',
    'বেলাবো': 'Belabo',
    'ফরিদপুর সদর': 'Faridpur Sadar',
    'গোপালগঞ্জ সদর': 'Gopalganj Sadar',
    'মাদারীপুর সদর': 'Madaripur Sadar',
    'শিবচর': 'Shibchar',
    'কালকিনি': 'Kalkini',
    'রাজৈর': 'Rajoir',
    'রাজবাড়ী সদর': 'Rajbari Sadar',
    'মীরসরাই': 'Mirsharai',
    'ফটিকছড়ি': 'Phatikachhari',
    'রাঙ্গুনিয়া': 'Rangguniya',
    'পটিয়া': 'Patiya',
    'বোয়ালখালী': 'Boyalakhali',
    'আনোয়ারা': 'Anoyara',
    'চন্দনাইশ': 'Chandanaish',
    'সাতকানিয়া': 'Satkania',
    'লোহাগাড়া': 'Lohagara',
    'বাঁশখালী': 'BaঁShakhali',
    'সন্দ্বীপ': 'Sandbip',
    'ঈদগাঁও': 'IdagaঁO',
    'পেকুয়া': 'Ukhia',
    'কুতুবদিয়া': 'Kutubdia',
    'আদর্শ সদর': 'Comilla Adarsha Sadar',
    'সদর দক্ষিণ': 'Comilla Adarsha Sadar',
    'বরুড়া': 'Barura',
    'চান্দিনা': 'Chandina',
    'হোমনা': 'Homna',
    'মেঘনা': 'Meghna',
    'তিতাস': 'Titas',
    'দেবিদ্বার': 'Debidbar',
    'ব্রাহ্মণপাড়া': 'Brahmanpara',
    'বুড়িচং': 'Burichang',
    'মনোহরগঞ্জ': 'Monohargonj',
    'নাঙ্গলকোট': 'Nanggalakot',
    'লালমাই': 'Lalamai',
    'পরশুরাম': 'Parshuram',
    'ফুলগাজী': 'Phulagaji',
    'ব্রাহ্মণবাড়িয়া সদর': 'Brahmanbaria Sadar',
    'আশুগঞ্জ': 'Ashuganj',
    'সরাইল': 'Sarail',
    'নাসিরনগর': 'Nasirnagar',
    'নবীনগর': 'Nabinagar',
    'বাঞ্ছারামপুর': 'Bancharampur',
    'কসবা': 'Kasba',
    'আখাউড়া': 'Akhaura',
    'বিজয়নগর': 'Bijoynagar',
    'সেনবাগ': 'Senbagh',
    'সোনাইমুড়ী': 'Sonaimuri',
    'কবিরহাট': 'Kabirhat',
    'সুবর্ণচর': 'Subarnachar',
    'হাতিয়া': 'Hatiya',
    'লক্ষ্মীপুর সদর': 'Lakshmipur Sadar',
    'রায়পুর': 'Rayapur',
    'রামগঞ্জ': 'Ramganj',
    'রামগতি': 'Ramgati',
    'কমলনগর': 'Kamalnagar',
    'মতলব উত্তর': 'Matalab North',
    'মতলব দক্ষিণ': 'Matalab South',
    'ফরিদগঞ্জ': 'Pharidaganj',
    'কচুয়া': 'Kachua',
    'হাইমচর': 'Haimchar',
    'রাঙ্গামাটি সদর': 'Rangamati Sadar',
    'কাপ্তাই': 'Kaptai',
    'নানিয়ারচর': 'Naniyarachar',
    'বাঘাইছড়ি': 'Baghaichhari',
    'বরকল': 'Barkal',
    'জুরাছড়ি': 'Jurachhari',
    'লংগদু': 'Langagadu',
    'বিলাইছড়ি': 'Bilaichhari',
    'রাজস্থলী': 'Rajasthali',
    'বান্দরবান সদর': 'Bandarban Sadar',
    'রুমা': 'Ruma',
    'থানচি': 'Thanchi',
    'রোয়াংছড়ি': 'Royangachhari',
    'লামা': 'Lama',
    'আলীকদম': 'Ali Kadam',
    'নাইক্ষ্যংছড়ি': 'Naikshjangachhari',
    'খাগড়াছড়ি সদর': 'Khagarachhari Sadar',
    'মাটিরাঙ্গা': 'Matiranga',
    'রামগড়': 'Ramgarh',
    'মানিকছড়ি': 'Manikachhari',
    'মহালছড়ি': 'Mahalachhari',
    'পানছড়ি': 'Panachhari',
    'দীঘিনালা': 'Dighinala',
    'লক্ষ্মীছড়ি': 'Lakshmichhari',
    'গুইমারা': 'Guimara',
    'বোয়ালিয়া': 'Boyaliya',
    'রাজপাড়া': 'Rajpara',
    'মতিহার': 'Matihar',
    'শাহ মখদুম': 'Shah Makhdum',
    'চন্দ্রিমা': 'Chandrima',
    'কাটাখালী': 'Katakhali',
    'বেলপুকুর': 'Belpukur',
    'এয়ারপোর্ট': 'Eyaraport',
    'পবা': 'Paba',
    'তানোর': 'Tanore',
    'মোহনপুর': 'Mohanpur',
    'বাগমারা': 'Bagmara',
    'শাজাহানপুর': 'Shajahanapur',
    'সারিয়াকান্দি': 'Sariyakandi',
    'সোনাতলা': 'Sonatola',
    'গাবতলী': 'Gabtali',
    'আদমদীঘি': 'Adamdighi',
    'দুপচাঁচিয়া': 'DupachaঁChiya',
    'নন্দীগ্রাম': 'Nandigram',
    'আটঘরিয়া': 'Atgharia',
    'চাটমোহর': 'Chatmohar',
    'ভাঙ্গুড়া': 'Bhanggura',
    'ফরিদপুর': 'Pharidapur',
    'কামারখন্দ': 'Kamarkhanda',
    'কাজিপুর': 'Kajipur',
    'রায়গঞ্জ': 'Rayaganj',
    'চৌহালী': 'Chauhali',
    'তাড়াশ': 'Tarash',
    'নওগাঁ সদর': 'Naogaon Sadar',
    'রানীনগর': 'Raninagar',
    'আত্রাই': 'Atrai',
    'মহাদেবপুর': 'Mohadevpur',
    'মান্দা': 'Manda',
    'বদলগাছী': 'Badalgachhi',
    'পত্নীতলা': 'Patnitala',
    'ধামইরহাট': 'Dhamoirhat',
    'নিয়ামতপুর': 'Niyamatapur',
    'সাপাহার': 'Sapahar',
    'পোরশা': 'Porsha',
    'চাঁপাইনবাবগঞ্জ সদর': 'Nawabganj Sadar',
    'নাচোল': 'Nachole',
    'গোমস্তাপুর': 'Gomastapur',
    'ভোলাহাট': 'Bholahat',
    'জয়পুরহাট সদর': 'Joypurhat Sadar',
    'পাঁচবিবি': 'PaঁChabibi',
    'কালাই': 'Kalai',
    'ক্ষেতলাল': 'Kshetalal',
    'আক্কেলপুর': 'Akkelpur',
    'সোনাডাঙ্গা': 'Sonadanga',
    'খানজাহান আলী': 'Khanajahan Ali',
    'হরিণটানা': 'Harintana',
    'লবণচরা': 'Lobonchora',
    'আড়ংঘাটা': 'Arongghata',
    'রূপসা': 'Rupsha',
    'তেরখাদা': 'Terokhada',
    'দিঘলিয়া': 'Dighalia',
    'ফুলতলা': 'Phultala',
    'দাকোপ': 'Dakop',
    'পাইকগাছা': 'Paikgachha',
    'কয়রা': 'Koyra',
    'শার্শা': 'Sharsha',
    'মণিরামপুর': 'Manirampur',
    'চৌগাছা': 'Chaugachha',
    'বাঘারপাড়া': 'Bagherpara',
    'খোকসা': 'Khoksa',
    'ঝিনাইদহ সদর': 'Jhenaidah Sadar',
    'শৈলকুপা': 'Shailkupa',
    'হরিণাকুণ্ডু': 'Harinakunda',
    'কোটচাঁদপুর': 'KotachaঁDapur',
    'মহেশপুর': 'Maheshpur',
    'কলারোয়া': 'Kalaroa',
    'তালা': 'Tala',
    'দেবহাটা': 'Debahata',
    'আশাশুনি': 'Assasuni',
    'বাগেরহাট সদর': 'Bagerhat Sadar',
    'ফকিরহাট': 'Phakirahat',
    'মোল্লাহাট': 'Mollahat',
    'চিতলমারী': 'Chitalmari',
    'রামপাল': 'Rampal',
    'মোংলা': 'Mongla',
    'মোরেলগঞ্জ': 'Morelaganj',
    'শরণখোলা': 'Sarankhola',
    'চুয়াডাঙ্গা সদর': 'Chuadanga Sadar',
    'আলমডাঙ্গা': 'Alamdanga',
    'দামুড়হুদা': 'Damurhuda',
    'জীবননগর': 'Jibannagar',
    'মেহেরপুর সদর': 'Meherpur Sadar',
    'গাংনী': 'Gangni',
    'মুজিবনগর': 'Mujibnagar',
    'মাগুরা সদর': 'Magura Sadar',
    'মহম্মদপুর': 'Mohammadpur',
    'শালিখা': 'Shalikha',
    'নড়াইল সদর': 'Narail Sadar',
    'লোহাগড়া': 'Lohagara',
    'কালিয়া': 'Kalia',
    'কাউনিয়া': 'Kaunia',
    'ভাণ্ডারিয়া': 'Bhandaria',
    'নেছারাবাদ (স্বরূপকাঠি)': 'Nechharabad (Sbarupakathi)',
    'কাঁঠালিয়া': 'Kathalia',
    'জালালাবাদ': 'Jalalabad',
    'শাহপরাণ': 'Shah Poran',
    'মোগলাবাজার': 'Mogalabajar',
    'দক্ষিণ সুরমা': 'South Surama',
    'ওসমানীনগর': 'Osmaninagar',
    'বালাগঞ্জ': 'Balaganj',
    'ফেঞ্চুগঞ্জ': 'Phenchuganj',
    'জকিগঞ্জ': 'Jakiganj',
    'কানাইঘাট': 'Kanaighat',
    'গোয়াইনঘাট': 'Goyainaghat',
    'রাজনগর': 'Rajnagar',
    'বড়লেখা': 'Barlekha',
    'জুড়ী': 'Juri',
    'শায়েস্তাগঞ্জ': 'Shayestaganj',
    'বাহুবল': 'Bahubal',
    'বানিয়াচং': 'Baniyachong',
    'আজমিরীগঞ্জ': 'Ajmiriganj',
    'লাখাই': 'Lakhai',
    'শান্তিগঞ্জ': 'Shantiganj',
    'দোয়ারাবাজার': 'Doyarabajar',
    'দিরাই': 'Derai',
    'শাল্লা': 'Sullah',
    'ধর্মপাশা': 'Dharampasha',
    'মধ্যনগর': 'Centralnagar',
    'জামালগঞ্জ': 'Jamalganj',
    'বিশ্বম্ভরপুর': 'Bishbambharapur',
    'তাজহাট': 'Tajahat',
    'মাহিগঞ্জ': 'Mahiganj',
    'হারাগাছ': 'Haragach',
    'হাজীরহাট': 'Hajirahat',
    'গঙ্গাচড়া': 'Ganggachara',
    'তারাগঞ্জ': 'Taraganj',
    'পীরগাছা': 'Pirgachha',
    'বিরল': 'Biral',
    'বোচাগঞ্জ': 'Bochaganj',
    'কাহারোল': 'Kaharol',
    'খানসামা': 'Khansama',
    'চিরিরবন্দর': 'Chirirbandar',
    'হাকিমপুর': 'Hakimpur',
    'ঘোড়াঘাট': 'Ghoraghat',
    'গাইবান্ধা সদর': 'Gaibandha Sadar',
    'সাদুল্লাপুর': 'Sadullapur',
    'সুন্দরগঞ্জ': 'Sundarganj',
    'গোবিন্দগঞ্জ': 'Gobindaganj',
    'পলাশবাড়ী': 'Palashbari',
    'সাঘাটা': 'Sughatta',
    'ফুলছড়ি': 'Phulachhari',
    'ঠাকুরগাঁও সদর': 'Thakurgaon Sadar',
    'রাণীশংকৈল': 'Ranishangakoil',
    'বালিয়াডাঙ্গী': 'Baliyadanggi',
    'হরিপুর': 'Haripur',
    'পঞ্চগড় সদর': 'Panchagarh Sadar',
    'বোদা': 'Boda',
    'দেবীগঞ্জ': 'Debiganj',
    'তেঁতুলিয়া': 'Tetulia',
    'আটোয়ারী': 'Atoyari',
    'লালমনিরহাট সদর': 'Lalmonirhat Sadar',
    'আদিতমারী': 'Aditmari',
    'হাতীবান্ধা': 'Hatibandha',
    'পাটগ্রাম': 'Patgram',
  };

  static final Map<String, String> enToBnUpazilas = {
    for (var entry in bnToEnUpazilas.entries)
      entry.value.toLowerCase().trim(): entry.key,
  };

  static const Map<String, String> enToBnVehicles = {
    'tractor / votvoti': 'ট্রাক্টর / ভটভটি',
    'tractor/votvoti': 'ট্রাক্টর / ভটভটি',
    'votvoti': 'ভটভটি',
    'tractor': 'ট্রাক্টর',
    'motorcycle': 'মোটরসাইকেল',
    'motor cycle': 'মোটরসাইকেল',
    'bike': 'বাইক',
    'noah': 'নোহা',
    'van': 'ভ্যান',
    'covered van': 'কাভার্ড ভ্যান',
    'helicopter': 'হেলিকপ্টার',
    'air ambulance': 'এয়ার অ্যাম্বুলেন্স',
    'microbus': 'মাইক্রোবাস',
    'micro bus': 'মাইক্রোবাস',
    'hiace': 'হায়েস',
    'hayes': 'হায়েস',
    'private car': 'প্রাইভেট কার',
    'car': 'কার',
    'cng': 'সিএনজি',
    'auto': 'অটো',
    'auto rickshaw': 'অটো',
    'easy bike': 'ইজি বাইক',
    'easy bike / tomtom': 'ইজি বাইক / টমটম',
    'easy bike/tomtom': 'ইজি বাইক / টমটম',
    'tomtom': 'টমটম',
    'mishuk': 'মিশুক',
    'leguna': 'লেগুনা',
    'truck': 'ট্রাক',
    'pickup': 'পিকআপ',
    'pick up': 'পিকআপ',
    'bus': 'বাস',
    'mini bus': 'মিনি বাস',
    'minibus': 'মিনি বাস',
    'ambulance': 'অ্যাম্বুলেন্স',
    'self driving': 'সেলফ ড্রাইভিং',
    'boat': 'নৌকা',
    'launch': 'লঞ্চ',
    'speedboat': 'স্পিডবোট',
    'trolley': 'ট্রলি',
    'rickshaw': 'রিকশা',
  };

  static const Map<String, String> bnToEnVehicles = {
    'ট্রাক্টর / ভটভটি': 'Tractor / Votvoti',
    'ট্রাক্টর/ভটভটি': 'Tractor / Votvoti',
    'ভটভটি': 'Votvoti',
    'ট্রাক্টর': 'Tractor',
    'মোটরসাইকেল': 'Motorcycle',
    'মোটর সাইকেল': 'Motorcycle',
    'বাইক': 'Bike',
    'নোহা': 'Noah',
    'ভ্যান': 'Van',
    'কাভার্ড ভ্যান': 'Covered Van',
    'কাভার্ডভ্যান': 'Covered Van',
    'হেলিকপ্টার': 'Helicopter',
    'এয়ার অ্যাম্বুলেন্স': 'Air Ambulance',
    'এয়ার এ্যাম্বুলেন্স': 'Air Ambulance',
    'মাইক্রোবাস': 'Microbus',
    'মাইক্রো বাস': 'Microbus',
    'হায়েস': 'Hiace',
    'হায়েস': 'Hiace',
    'হায়াস': 'Hiace',
    'হায়াস': 'Hiace',
    'প্রাইভেট কার': 'Private Car',
    'প্রাইভেটকার': 'Private Car',
    'কার': 'Car',
    'সিএনজি': 'CNG',
    'অটো': 'Auto',
    'অটোরিকশা': 'Auto',
    'ইজি বাইক': 'Easy Bike',
    'ইজিবাইক': 'Easy Bike',
    'ইজি বাইক / টমটম': 'Easy Bike / Tomtom',
    'টমটম': 'Tomtom',
    'মিশুক': 'Mishuk',
    'লেগুনা': 'Leguna',
    'ট্রাক': 'Truck',
    'পিকআপ': 'Pickup',
    'পিক আপ': 'Pickup',
    'বাস': 'Bus',
    'মিনি বাস': 'Mini Bus',
    'মিনিবাস': 'Mini Bus',
    'অ্যাম্বুলেন্স': 'Ambulance',
    'এ্যাম্বুলেন্স': 'Ambulance',
    'সেলফ ড্রাইভিং': 'Self Driving',
    'নৌকা': 'Boat',
    'লঞ্চ': 'Launch',
    'স্পিডবোট': 'Speedboat',
    'ট্রলি': 'Trolley',
    'রিকশা': 'Rickshaw',
  };

  static String translateVehicleTypeStatic(String raw, bool toBengali) {
    final clean = raw.trim();
    if (clean.isEmpty) return clean;
    final lower = clean.toLowerCase();

    if (toBengali) {
      if (clean == 'হায়াস' || clean == 'হায়াস' || clean == 'হায়েস' || lower == 'hayes') {
        return 'হায়েস';
      }
      if (lower == 'easy bike / tomtom' || lower == 'easy bike/tomtom') {
        return 'ইজি বাইক / টমটম';
      }
      if (enToBnVehicles.containsKey(lower)) {
        return enToBnVehicles[lower]!;
      }
      final key = getCanonicalVehicleKey(clean);
      switch (key) {
        case 'motorcycle': return 'মোটরসাইকেল';
        case 'car': return 'প্রাইভেট কার';
        case 'microbus': return 'মাইক্রোবাস';
        case 'noah': return 'নোয়া';
        case 'pickup': return 'পিকআপ';
        case 'truck': return 'ট্রাক';
        case 'cng': return 'সিএনজি';
        case 'easy_bike': return 'ইজি বাইক';
        case 'air_ambulance': return 'এয়ার অ্যাম্বুলেন্স';
        case 'ambulance': return 'অ্যাম্বুলেন্স';
        case 'helicopter': return 'হেলিকপ্টার';
        case 'covered_van': return 'কাভার্ড ভ্যান';
        case 'van': return 'ভ্যান';
        case 'minibus': return 'মিনি বাস';
        case 'bus': return 'বাস';
        case 'leguna': return 'লেগুনা';
        case 'tractor': return 'ট্রাক্টর';
        case 'boat': return 'নৌকা';
        case 'launch': return 'লঞ্চ';
        case 'speedboat': return 'স্পিডবোট';
        case 'trolley': return 'ট্রলি';
        case 'rickshaw': return 'রিকশা';
      }
      return clean;
    } else {
      if (bnToEnVehicles.containsKey(clean)) {
        return bnToEnVehicles[clean]!;
      }
      for (var entry in enToBnVehicles.entries) {
        if (entry.key == lower) {
          // Find standard title-cased English name from bnToEnVehicles
          final bn = entry.value;
          if (bnToEnVehicles.containsKey(bn)) {
            return bnToEnVehicles[bn]!;
          }
          return clean;
        }
      }
      return clean;
    }
  }

    static String normalizeBn(String input) {
    return input
        .replaceAll('\u09af\u09bc', '\u09df') // য + nukta -> য়
        .replaceAll('\u09b0\u09bc', '\u09dc') // র + nukta -> ড়
        .replaceAll('\u09a1\u09bc', '\u09dc') // ড + nukta -> ড়
        .replaceAll('\u09a2\u09bc', '\u09dd') // ঢ + nukta -> ঢ়
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String transliterateBnToEn(String raw) {
    if (raw.trim().isEmpty) return raw;
    String str = raw
        .replaceAll('পৌরসভা', 'Pourashava')
        .replaceAll('ইউনিয়ন', 'Union')
        .replaceAll(RegExp(r'ওয়ার্ড|ওয়ার্ড|ওয়র্ড|ওয়াড'), 'Ward')
        .replaceAll('সদর', 'Sadar')
        .replaceAll('উত্তর', 'North')
        .replaceAll('দক্ষিণ', 'South')
        .replaceAll('পূর্ব', 'East')
        .replaceAll('পশ্চিম', 'West')
        .replaceAll('মধ্য', 'Central');

    const bnDigits = {
      '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
      '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9'
    };
    bnDigits.forEach((k, v) => str = str.replaceAll(k, v));

    const kar = {
      'া': 'a', 'ি': 'i', 'ী': 'i', 'ু': 'u', 'ূ': 'u',
      'ৃ': 'ri', 'ে': 'e', 'ৈ': 'oi', 'ো': 'o', 'ৌ': 'ou'
    };

    const swara = {
      'অ': 'o', 'আ': 'a', 'ই': 'i', 'ঈ': 'i', 'উ': 'u',
      'ঊ': 'u', 'ঋ': 'ri', 'এ': 'e', 'ঐ': 'oi', 'ও': 'o', 'ঔ': 'ou'
    };

    const byanjan = {
      'ক': 'k', 'খ': 'kh', 'গ': 'g', 'ঘ': 'gh', 'ঙ': 'ng',
      'চ': 'ch', 'ছ': 'chh', 'জ': 'j', 'ঝ': 'jh', 'ঞ': 'n',
      'ট': 't', 'ঠ': 'th', 'ড': 'd', 'ঢ': 'dh', 'ণ': 'n',
      'ত': 't', 'থ': 'th', 'দ': 'd', 'ধ': 'dh', 'ন': 'n',
      'প': 'p', 'ফ': 'ph', 'ব': 'b', 'ভ': 'bh', 'ম': 'm',
      'য': 'j', 'র': 'r', 'ল': 'l', 'শ': 'sh', 'ষ': 'sh', 'স': 's',
      'হ': 'h', 'ড়': 'r', 'ঢ়': 'rh', 'য়': 'y', 'ৎ': 't',
      'ং': 'ng', 'ঃ': 'h', 'ঁ': ''
    };

    str = normalizeBn(str);

    final sb = StringBuffer();
    final runes = str.runes.toList();
    final len = runes.length;

    for (int i = 0; i < len; i++) {
      final ch = String.fromCharCode(runes[i]);
      if (swara.containsKey(ch)) {
        sb.write(swara[ch]);
      } else if (byanjan.containsKey(ch)) {
        final cons = byanjan[ch]!;
        final next = (i + 1 < len) ? String.fromCharCode(runes[i + 1]) : '';
        if (next == '্') {
          sb.write(cons);
          i++;
        } else if (kar.containsKey(next)) {
          sb.write(cons);
          sb.write(kar[next]);
          i++;
        } else if (byanjan.containsKey(next) || swara.containsKey(next) || next == ' ' || next == '' || next == ',' || next == '-' || next == '.') {
          if (next == ' ' || next == '' || next == ',' || next == '-' || next == '.') {
            sb.write(cons);
          } else {
            sb.write('${cons}a');
          }
        } else {
          sb.write(cons);
        }
      } else if (kar.containsKey(ch)) {
        sb.write(kar[ch]);
      } else {
        sb.write(ch);
      }
    }

    final words = sb.toString().split(' ');
    final capitalized = words.map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : '');
    }).join(' ');

    return capitalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String translateDivisionStatic(String raw, bool toBengali) {
    final clean = raw.trim();
    if (clean.isEmpty) return clean;
    final lower = clean.toLowerCase();
    final norm = normalizeBn(clean);

    if (toBengali) {
      if (enToBnDivisions.containsKey(lower)) {
        return enToBnDivisions[lower]!;
      }
      if (bnToEnDivisions.containsKey(clean) || bnToEnDivisions.containsKey(norm)) {
        final en = (bnToEnDivisions[clean] ?? bnToEnDivisions[norm])!.toLowerCase();
        if (enToBnDivisions.containsKey(en)) {
          return enToBnDivisions[en]!;
        }
      }
      return norm;
    } else {
      if (bnToEnDivisions.containsKey(clean)) {
        return bnToEnDivisions[clean]!;
      }
      if (bnToEnDivisions.containsKey(norm)) {
        return bnToEnDivisions[norm]!;
      }
      if (enToBnDivisions.containsKey(lower)) {
        final bn = enToBnDivisions[lower]!;
        if (bnToEnDivisions.containsKey(bn)) {
          return bnToEnDivisions[bn]!;
        }
      }
      return clean;
    }
  }

  static String translateDistrictStatic(String raw, bool toBengali) {
    final clean = raw.trim();
    if (clean.isEmpty) return clean;
    final lower = clean.toLowerCase();
    final norm = normalizeBn(clean);

    if (toBengali) {
      if (enToBnDistricts.containsKey(lower)) {
        return enToBnDistricts[lower]!;
      }
      for (final entry in bnToEnDistricts.entries) {
        if (normalizeBn(entry.key) == norm) {
          final en = entry.value.toLowerCase();
          if (enToBnDistricts.containsKey(en)) {
            return enToBnDistricts[en]!;
          }
        }
      }
      return norm;
    } else {
      if (bnToEnDistricts.containsKey(clean)) {
        return bnToEnDistricts[clean]!;
      }
      if (bnToEnDistricts.containsKey(norm)) {
        return bnToEnDistricts[norm]!;
      }
      for (final entry in bnToEnDistricts.entries) {
        if (normalizeBn(entry.key) == norm) {
          return entry.value;
        }
      }
      if (enToBnDistricts.containsKey(lower)) {
        final bn = enToBnDistricts[lower]!;
        if (bnToEnDistricts.containsKey(bn)) {
          return bnToEnDistricts[bn]!;
        }
      }
      return clean;
    }
  }

  static String translateUpazilaStatic(String raw, bool toBengali) {
    final clean = raw.trim();
    if (clean.isEmpty) return clean;
    final lower = clean.toLowerCase();
    final norm = normalizeBn(clean);

    if (toBengali) {
      if (enToBnUpazilas.containsKey(lower)) {
        return enToBnUpazilas[lower]!;
      }
      for (final entry in enToBnUpazilas.entries) {
        if (entry.key == lower || entry.key.replaceAll('-', ' ') == lower.replaceAll('-', ' ')) {
          return entry.value;
        }
      }
      return norm;
    } else {
      if (bnToEnUpazilas.containsKey(clean)) {
        return bnToEnUpazilas[clean]!;
      }
      if (bnToEnUpazilas.containsKey(norm)) {
        return bnToEnUpazilas[norm]!;
      }
      for (final entry in bnToEnUpazilas.entries) {
        if (normalizeBn(entry.key) == norm) {
          return entry.value;
        }
      }
      // If still not matched, check if input is already English
      final hasBengali = RegExp(r'[\u0980-\u09FF]').hasMatch(clean);
      if (!hasBengali) {
        return clean;
      }
      // Guaranteed transliteration fallback so NO Bengali script is shown in English mode
      return transliterateBnToEn(clean);
    }
  }

  static String translateUnionStatic(String raw, bool toBengali) {
    final clean = raw.trim();
    if (clean.isEmpty) return clean;

    if (!toBengali) {
      // Bengali to English
      String u = clean
          .replaceAll('পৌরসভা', 'Pourashava')
          .replaceAll('ইউনিয়ন', 'Union')
          .replaceAll(RegExp(r'ওয়ার্ড|ওয়ার্ড|ওয়র্ড|ওয়াড'), 'Ward')
          .replaceAll('সদর', 'Sadar')
          .replaceAll('উত্তর', 'North')
          .replaceAll('দক্ষিণ', 'South')
          .replaceAll('পূর্ব', 'East')
          .replaceAll('পশ্চিম', 'West')
          .replaceAll('মধ্য', 'Central');

      const bnDigits = {
        '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
        '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9'
      };
      bnDigits.forEach((k, v) => u = u.replaceAll(k, v));

      final hasBengali = RegExp(r'[\u0980-\u09FF]').hasMatch(u);
      if (hasBengali) {
        return transliterateBnToEn(u);
      }
      return u;
    } else {
      // English to Bengali
      String u = clean
          .replaceAll(RegExp(r'\bPourashava\b', caseSensitive: false), 'পৌরসভা')
          .replaceAll(RegExp(r'\bMunicipality\b', caseSensitive: false), 'পৌরসভা')
          .replaceAll(RegExp(r'\bUnion\b', caseSensitive: false), 'ইউনিয়ন')
          .replaceAll(RegExp(r'\bWard\b', caseSensitive: false), 'ওয়ার্ড')
          .replaceAll(RegExp(r'\bSadar\b', caseSensitive: false), 'সদর')
          .replaceAll(RegExp(r'\bNorth\b', caseSensitive: false), 'উত্তর')
          .replaceAll(RegExp(r'\bSouth\b', caseSensitive: false), 'দক্ষিণ')
          .replaceAll(RegExp(r'\bEast\b', caseSensitive: false), 'পূর্ব')
          .replaceAll(RegExp(r'\bWest\b', caseSensitive: false), 'পশ্চিম')
          .replaceAll(RegExp(r'\bCentral\b', caseSensitive: false), 'মধ্য');

      const enDigits = {
        '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
        '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'
      };
      enDigits.forEach((k, v) => u = u.replaceAll(k, v));
      return u;
    }
  }

  static String translateWardStatic(String raw, bool toBengali) {
    final clean = raw.trim();
    if (clean.isEmpty) return clean;

    if (!toBengali) {
      String w = clean
          .replaceAll('ওয়ার্ড', 'Ward')
          .replaceAll('ওয়ার্ড', 'Ward')
          .replaceAll('ওয়র্ড', 'Ward')
          .replaceAll('ওয়াড', 'Ward');
      const bnDigits = {
        '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
        '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9'
      };
      bnDigits.forEach((k, v) => w = w.replaceAll(k, v));
      return w;
    } else {
      String w = clean.replaceAll(RegExp(r'\bWard\b', caseSensitive: false), 'ওয়ার্ড');
      const enDigits = {
        '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
        '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'
      };
      enDigits.forEach((k, v) => w = w.replaceAll(k, v));
      return w;
    }
  }

  static String toBengaliDivision(String raw) =>
      translateDivisionStatic(raw, true);
  static String toBengaliDistrict(String raw) =>
      translateDistrictStatic(raw, true);

  static bool areSameDivision(String a, String b) {
    if (a.toLowerCase().trim() == b.toLowerCase().trim()) return true;
    final bnA = normalizeBn(toBengaliDivision(a));
    final bnB = normalizeBn(toBengaliDivision(b));
    return bnA.isNotEmpty && bnA == bnB;
  }

  static bool areSameDistrict(String a, String b) {
    if (a.toLowerCase().trim() == b.toLowerCase().trim()) return true;
    final bnA = normalizeBn(toBengaliDistrict(a));
    final bnB = normalizeBn(toBengaliDistrict(b));
    return bnA.isNotEmpty && bnA == bnB;
  }

  static bool areSameUpazila(String a, String b) {
    if (a.toLowerCase().trim() == b.toLowerCase().trim()) return true;
    final bnA = normalizeBn(translateUpazilaStatic(a, true));
    final bnB = normalizeBn(translateUpazilaStatic(b, true));
    return bnA.isNotEmpty && bnA == bnB;
  }

  static String getCanonicalVehicleKey(String raw) {
    final clean = raw.trim().toLowerCase();
    if (clean.isEmpty) return '';

    if (clean.contains('bike') || clean.contains('motorcycle') || clean.contains('motor cycle') ||
        clean.contains('বাইক') || clean.contains('মোটরসাইকেল') || clean.contains('মোটর সাইকেল')) {
      return 'motorcycle';
    }
    if (clean.contains('private car') || clean.contains('car') || clean.contains('sedan') ||
        clean.contains('প্রাইভেট কার') || clean.contains('কার') || clean.contains('প্রাইভেটকার')) {
      return 'car';
    }
    if (clean.contains('microbus') || clean.contains('micro bus') || clean.contains('hiace') || clean.contains('hayes') ||
        clean.contains('মাইক্রোবাস') || clean.contains('মাইক্রো বাস') || clean.contains('হায়েস') || clean.contains('হায়স') || clean.contains('হায়িস')) {
      return 'microbus';
    }
    if (clean.contains('noah') || clean.contains('voxy') || clean.contains('নোহা') || clean.contains('নোয়া') || clean.contains('নয়া')) {
      return 'noah';
    }
    if (clean.contains('pickup') || clean.contains('pick up') || clean.contains('পিকআপ') || clean.contains('পিক আপ')) {
      return 'pickup';
    }
    if (clean.contains('truck') || clean.contains('ট্রাক')) {
      return 'truck';
    }
    if (clean.contains('cng') || clean.contains('সিএনজি') || clean.contains('সি এন জি')) {
      return 'cng';
    }
    if (clean.contains('easy bike') || clean.contains('easybike') || clean.contains('tomtom') || clean.contains('mishuk') || clean.contains('auto') ||
        clean.contains('ইজি বাইক') || clean.contains('ইজিবাইক') || clean.contains('টমটম') || clean.contains('মিশুক') || clean.contains('অটো')) {
      return 'easy_bike';
    }
    if (clean.contains('air ambulance') || clean.contains('এয়ার অ্যাম্বুলেন্স')) {
      return 'air_ambulance';
    }
    if (clean.contains('ambulance') || clean.contains('অ্যাম্বুলেন্স')) {
      return 'ambulance';
    }
    if (clean.contains('helicopter') || clean.contains('হেলিকপ্টার')) {
      return 'helicopter';
    }
    if (clean.contains('covered van') || clean.contains('কাভার্ড ভ্যান')) {
      return 'covered_van';
    }
    if (clean.contains('van') || clean.contains('ভ্যান')) {
      return 'van';
    }
    if (clean.contains('mini bus') || clean.contains('minibus') || clean.contains('মিনি বাস') || clean.contains('মিনিবাস')) {
      return 'minibus';
    }
    if (clean.contains('bus') || clean.contains('বাস')) {
      return 'bus';
    }
    if (clean.contains('leguna') || clean.contains('লেগুনা')) {
      return 'leguna';
    }
    if (clean.contains('tractor') || clean.contains('votvoti') || clean.contains('ট্রাক্টর') || clean.contains('ভটভটি')) {
      return 'tractor';
    }
    if (clean.contains('speed') || clean.contains('স্পিডবোট')) return 'speedboat';
    if (clean.contains('launch') || clean.contains('লঞ্চ')) return 'launch';
    if (clean.contains('boat') || clean.contains('নৌকা')) return 'boat';
    if (clean.contains('trolley') || clean.contains('ট্রলি')) return 'trolley';
    if (clean.contains('rickshaw') || clean.contains('রিকশা')) return 'rickshaw';

    return clean;
  }

  static bool areSameVehicleType(String a, String b) {
    if (a.toLowerCase().trim() == b.toLowerCase().trim()) return true;
    final keyA = getCanonicalVehicleKey(a);
    final keyB = getCanonicalVehicleKey(b);
    if (keyA.isNotEmpty && keyA == keyB) return true;
    final bnA = translateVehicleTypeStatic(a, true).toLowerCase();
    final bnB = translateVehicleTypeStatic(b, true).toLowerCase();
    return bnA.isNotEmpty && bnA == bnB;
  }

  // --- Driver Card ---
  String get callNow => isBn ? 'কল করুন' : 'Call Now';
  String get seatingCountPrefix => isBn ? 'আসন সংখ্যা: ' : 'Seat count: ';
  String get regPrefix => 'Reg: ';
  String validDaysBadge(int days) =>
      isBn ? 'মেয়াদ আছে $days দিন' : 'Valid for $days days';
  String get expiredBadge => isBn ? 'মেয়াদ শেষ (Expired)' : 'Expired';
  String get unlimitedBadge => isBn ? 'অসীম (Unlimited)' : 'Unlimited';

  // --- Empty State ---
  String get noDriversFound =>
      isBn ? 'এই এলাকায় কোনো ড্রাইভার পাওয়া যায়নি।' : 'No drivers found in this area.';
  String get noDriversSubtitle => isBn
      ? 'ফিল্টার পরিবর্তন করে আবার চেষ্টা করুন।'
      : 'Try changing your filters to find more drivers.';

  // --- Renew License Dialog ---
  String get renewDialogTitle =>
      isBn ? 'লাইসেন্স রিনিউ করুন (Renew License)' : 'Renew Driver License';
  String get renewDialogSubtitle => isBn
      ? 'আপনার অ্যাকাউন্ট খুঁজে পেতে আপনার নিবন্ধিত মোবাইল নম্বর লিখুন।'
      : 'Enter your registered mobile number to find your account.';
  String get phoneLabel =>
      isBn ? 'মোবাইল নম্বর (Phone Number)' : 'Mobile Phone Number';
  String get phonePlaceholder => 'e.g. 017XXXXXXXX';
  String get searchDriverBtn =>
      isBn ? 'ড্রাইভার খুঁজুন (Search Driver)' : 'Search Driver';
  String get searching => isBn ? 'খোঁজা হচ্ছে...' : 'Searching...';
  String get driverNotFound => isBn
      ? 'এই নম্বরে কোনো ড্রাইভার পাওয়া যায়নি। নম্বরটি পুনরায় পরীক্ষা করুন।'
      : 'No driver found with this phone number. Please check again.';
  String get searchErrorGeneric => isBn
      ? 'ড্রাইভার খুঁজতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'
      : 'Error searching for driver. Please try again.';
  String get changeDriver => isBn ? 'পরিবর্তন' : 'Change';
  String get unlimitedVehicleNotice => isBn
      ? 'এই গাড়ির জন্য কোনো নবায়ন ফি প্রয়োজন নেই। এর মেয়াদ অসীম।'
      : 'No renewal fee is required for this vehicle. Its validity is unlimited.';
  String get paymentInstructionsTitle =>
      isBn ? 'পেমেন্ট নির্দেশিকা (Payment Instructions)' : 'Payment Instructions';
  String get durationLabel => isBn ? 'মেয়াদ (Duration)' : 'Duration';
  String get amountLabel => isBn ? 'পরিমাণ (Amount)' : 'Amount';
  String get duration1Month => isBn ? '১ মাস (1 Month)' : '1 Month (30 Days)';
  String get duration3Months => isBn ? '৩ মাস (3 Months)' : '3 Months (90 Days)';
  String get duration6Months => isBn ? '৬ মাস (6 Months)' : '6 Months (180 Days)';
  String get duration1Year => isBn ? '১ বছর (1 Year)' : '1 Year (365 Days)';
  String amountWithCurrency(int amount) =>
      isBn ? '$amount টাকা' : 'BDT $amount';
  String saveTag(int amount) => 'Save ৳$amount';
  String get autoPayCheckbox => isBn
      ? 'Auto Pay via Automated Payment Gateway (অটো পে)'
      : 'Auto Pay via Automated Payment Gateway';
  String get transactionIdLabel =>
      isBn ? 'ট্রানজেকশন আইডি (Transaction ID)' : 'Transaction ID';
  String get manualPaymentSub =>
      isBn ? ' (ম্যানুয়াল পেমেন্টের জন্য)' : ' (For manual payment)';
  String get transactionIdPlaceholder => 'e.g. 8N7A6B5C4D';
  String get trxRequiredError => isBn
      ? 'অনুগ্রহ করে ট্রানজেকশন আইডি (Transaction ID) লিখুন'
      : 'Please enter the transaction ID';
  String payWithGateway(String gateway) => 'Pay with $gateway';
  String get submitRenewalRequest =>
      isBn ? 'লাইসেন্স নবায়ন রিকোয়েস্ট পাঠান' : 'Submit Renewal Request';
  String get completeRenewal =>
      isBn ? 'লাইসেন্স নবায়ন সম্পন্ন করুন' : 'Complete Renewal';
  String get renewSuccessTitle =>
      isBn ? 'নবায়ন রিকোয়েস্ট সফল হয়েছে!' : 'Renewal Request Successful!';
  String get renewSuccessSubtitle => isBn
      ? 'আপনার নবায়ন রিকোয়েস্ট সফলভাবে জমা হয়েছে এবং অ্যাডমিন প্যানেলে পাঠানো হয়েছে। অ্যাডমিন অ্যাপ্রুভ করার সাথে সাথে লাইসেন্সের মেয়াদ বাড়ানো হবে।'
      : 'Your renewal request has been submitted to the admin dashboard. The license expiry will be updated once approved by admin.';
  String get closeButton => isBn ? 'বন্ধ করুন (Close)' : 'Close';

  // --- bKash Payment Strings ---
  String get bkashPaymentTitle =>
      isBn ? 'বিকাশ পেমেন্ট (bKash Payment)' : 'bKash Payment';
  String get bkashPaymentSubtitle => isBn
      ? 'ঝটপট সার্ভিসের জন্য সহজে ও নিরাপদে বিকাশ দিয়ে পেমেন্ট করুন।'
      : 'Pay easily and securely with bKash for Jotpot services.';
  String get bkashAccountLabel =>
      isBn ? 'পেমেন্ট বিকাশ নম্বর (bKash Number)' : 'Payment bKash Number';
  String get bkashSavedBadge =>
      isBn ? 'সংরক্ষিত নম্বর' : 'Saved Number';
  String get bkashDriverBadge =>
      isBn ? 'ড্রাইভারের নম্বর' : 'Driver Phone';
  String get bkashMerchantAccount =>
      isBn ? 'ঝটপট বিকাশ একাউন্ট' : 'Jotpot bKash Account';
  String get copiedToClipboard =>
      isBn ? 'বিকাশ নম্বরটি কপি করা হয়েছে!' : 'bKash number copied to clipboard!';
  String payWithBkashBtn(int amount) => isBn
      ? 'বিকাশ দিয়ে ৳$amount পেমেন্ট করুন'
      : 'Pay BDT $amount with bKash';
  String get openBkashApp =>
      isBn ? 'বিকাশ অ্যাপ ওপেন করুন' : 'Open bKash App';
  String get dialUssd =>
      isBn ? '*247# ডায়াল করুন' : 'Dial *247#';
  String get bkashOtpStep =>
      isBn ? 'ভেরিফিকেশন কোড (OTP)' : 'Verification Code (OTP)';
  String bkashOtpPrompt(String phone) => isBn
      ? '$phone নম্বরে পাঠানো ভেরিফিকেশন কোড লিখুন'
      : 'Enter the verification code sent to $phone';
  String get bkashPinStep =>
      isBn ? 'বিকাশ পিন (PIN)' : 'bKash PIN';
  String get bkashPinPrompt =>
      isBn ? 'আপনার বিকাশ অ্যাকাউন্টের গোপন পিন লিখুন' : 'Enter your bKash secret PIN';
  String get confirmBkashPay =>
      isBn ? 'পেমেন্ট নিশ্চিত করুন' : 'Confirm Payment';
  String get savedBkashNotice => isBn
      ? 'এই বিকাশ নম্বরটি পরবর্তী পেমেন্টের জন্য সংরক্ষিত থাকবে।'
      : 'This bKash number will be remembered for next renewals.';
  String get nextStep => isBn ? 'পরবর্তী ধাপ' : 'Next';
  String get backStep => isBn ? 'পূর্ববর্তী' : 'Back';
  String get manualSendOption =>
      isBn ? 'ম্যানুয়াল বিকাশ (App / USSD)' : 'Manual (App / USSD)';
  String get autoGatewayOption =>
      isBn ? 'সরাসরি গেটওয়ে (Instant Checkout)' : 'Instant Checkout';
  String get invalidPhone => isBn
      ? 'সঠিক ১১-সংখ্যার মোবাইল নম্বর দিন'
      : 'Please enter a valid 11-digit mobile number';
  String get fillOtpFirst => isBn
      ? 'অনুগ্রহ করে ভেরিফিকেশন কোড লিখুন'
      : 'Please enter verification code';
  String get fillPinFirst => isBn
      ? 'অনুগ্রহ করে বিকাশ পিন লিখুন'
      : 'Please enter bKash PIN';
  String get autoFillDemoOtp =>
      isBn ? 'টেস্ট কোড (১২৩৪৫৬)' : 'Test OTP (123456)';

  // --- Registration Dialog ---
  String get regDialogTitle =>
      isBn ? 'ড্রাইভার হিসেবে নিবন্ধন করুন' : 'Register as a Driver';
  String get regDialogSubtitle => isBn
      ? 'আপনার সঠিক তথ্য প্রদান করে আমাদের নেটওয়ার্কে যুক্ত হোন'
      : 'Join our network by providing your accurate vehicle and contact details';
  String get driverName => isBn ? 'ড্রাইভারের নাম' : 'Driver Name';
  String get driverNamePlaceholder =>
      isBn ? 'আপনার পুরো নাম লিখুন' : 'Enter full name';
  String get mobileNumber => isBn ? 'মোবাইল নম্বর' : 'Mobile Number';
  String get vehicleModel => isBn ? 'গাড়ির মডেল' : 'Vehicle Model';
  String get vehicleModelPlaceholder => 'e.g. Toyota Allion 2004';
  String get regNumber => isBn ? 'রেজিস্ট্রেশন নম্বর' : 'Registration Number';
  String get regNumberPlaceholder =>
      isBn ? 'e.g. ঢাকা মেট্রো-গ ১২-৩৪৫৬' : 'e.g. Dhaka Metro-GA 12-3456';
  String get modelLabel => isBn ? 'মডেল' : 'Model';
  String get registrationLabel => isBn ? 'রেজিস্ট্রেশন' : 'Registration';

  String localizeDetails(String details) {
    if (details.isEmpty) return '';
    if (isBn) {
      return details
          .replaceAll(RegExp(r'\bModel\s*:', caseSensitive: false), 'মডেল:')
          .replaceAll(RegExp(r'\bRegistration\s*:', caseSensitive: false), 'রেজিস্ট্রেশন:')
          .replaceAll(RegExp(r'\bReg\s*:', caseSensitive: false), 'রেজিস্ট্রেশন:');
    } else {
      return details
          .replaceAll(RegExp(r'মডেল\s*:'), 'Model:')
          .replaceAll(RegExp(r'রেজিস্ট্রেশন\s*:'), 'Registration:');
    }
  }
  String get locationSectionTitle =>
      isBn ? 'ঠিকানা ও এলাকা নির্বাচন' : 'Address & Location Selection';
  String get selectDivisionFirst =>
      isBn ? 'প্রথমে বিভাগ নির্বাচন করুন' : 'Select division first';
  String get selectDistrictFirst =>
      isBn ? 'প্রথমে জেলা নির্বাচন করুন' : 'Select district first';
  String get unionPlaceholder =>
      isBn ? 'ইউনিয়ন/পৌরসভা লিখুন' : 'Enter union or municipality';
  String get wardPlaceholder => isBn ? 'ওয়ার্ড লিখুন' : 'Enter ward number/name';
  String get specialFeaturesTitle =>
      isBn ? 'বিশেষ সুবিধাসমূহ' : 'Special Features';
  String get isCovered => isBn ? 'কাভার্ড ভ্যান' : 'Covered Van';
  String get isAirAmbulance => isBn ? 'এয়ার অ্যাম্বুলেন্স' : 'Air Ambulance';
  String get isSelfDriving =>
      isBn ? 'সেলফ ড্রাইভিং (ড্রাইভার ছাড়া)' : 'Self Driving (Without driver)';

  // Vehicle-specific Registration Form Strings
  String get seatingCapacityLabel =>
      isBn ? 'আসন সংখ্যা (Seating Capacity)' : 'Seating Capacity';
  String get seatingCapacityPlaceholder =>
      isBn ? 'যেমন: ২৫ জন, ৪০ জন' : 'e.g. 25 Persons, 40 Persons';
  String get truckCoveredLabel =>
      isBn ? 'গাড়ির কভার (Covered status)' : 'Covered status';
  String get truckCoveredCheckbox =>
      isBn ? 'আপনার কি Covered Truck? (হলে টিক দিন, না হলে দেওয়ার প্রয়োজন নেই)'
           : 'Is your truck a Covered Truck? (Check if yes, leave unchecked if not)';
  String get vehicleLengthLabel =>
      isBn ? 'গাড়ি কত ফিট লম্বা? (Vehicle Length)' : 'Vehicle Length';
  String get vehicleLengthPlaceholder =>
      isBn ? 'যেমন: ৭ ফিট, ১২ ফিট' : 'e.g. 7 Feet, 12 Feet';
  String get vehicleCapacityLabel =>
      isBn ? 'গাড়ির ধারন ক্ষমতা (Capacity)' : 'Vehicle Capacity';
  String get vehicleCapacityPlaceholder =>
      isBn ? 'যেমন: ১ টন, ১.৫ টন' : 'e.g. 1 Ton, 1.5 Ton';
  String get airAmbulanceLabel =>
      isBn ? 'এয়ার অ্যাম্বুলেন্স হিসেবে ব্যবহৃত হবে? (Use as Air Ambulance?)'
           : 'Use as Air Ambulance?';
  String get airAmbulanceCheckbox =>
      isBn ? 'হ্যাঁ, এয়ার অ্যাম্বুলেন্স (Yes)' : 'Yes, Air Ambulance';
  String get drivingOptionLabel =>
      isBn ? 'ড্রাইভিং অপশন (Driving Option)' : 'Driving Option';
  String get drivingOptionCheckbox =>
      isBn ? 'উইথআউট ড্রাইভার রেন্ট বা সেলফ ড্রাইভিং? (Rent without driver?)'
           : 'Rent without driver / Self Driving?';

  String get registerNowBtn => isBn ? 'নিবন্ধন করুন' : 'Register Now';
  String get regSuccessSnackbar => isBn
      ? 'ড্রাইভার হিসেবে সফলভাবে নিবন্ধন করা হয়েছে! অ্যাডমিন অ্যাপ্রুভালের জন্য অপেক্ষমান।'
      : 'Driver registered successfully! Waiting for admin approval.';
  String get pleaseFillAllFields =>
      isBn ? 'অনুগ্রহ করে সকল আবশ্যক ঘর পূরণ করুন' : 'Please fill all required fields';
  String get vehicleTypeRequired =>
      isBn ? 'অনুগ্রহ করে গাড়ির ধরন নির্বাচন করুন' : 'Please select vehicle type';
  String get divisionRequired =>
      isBn ? 'অনুগ্রহ করে বিভাগ নির্বাচন করুন' : 'Please select division';

  // --- Footer ---
  String get footerAboutTitle => isBn ? 'আমাদের সম্পর্কে' : 'About Us';
  String get footerAboutText => isBn
      ? 'ঝটপট হলো বাংলাদেশের সকল জেলার জন্য ভাড়ায় চালিত গাড়ির উন্মুক্ত ডিরেক্টরি। আপনার প্রয়োজনে সহজেই সরাসরি ড্রাইভারের সাথে যোগাযোগ করুন।'
      : 'Jotpot is Bangladesh\'s premier open directory for rental vehicles. Connect directly with trusted drivers across all districts.';
  String get footerQuickLinks => isBn ? 'প্রয়োজনীয় লিংক' : 'Quick Links';
  String get footerHome => isBn ? 'হোম' : 'Home';
  String get footerRegister =>
      isBn ? 'ড্রাইভার নিবন্ধন' : 'Driver Registration';
  String get footerRenew => isBn ? 'লাইসেন্স নবায়ন' : 'Renew License';
  String get footerPrivacyPolicy => isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy';
  String get footerTermsConditions =>
      isBn ? 'শর্তাবলী ও নিয়মাবলী' : 'Terms & Conditions';
  String get footerAboutUs => isBn ? 'আমাদের সম্পর্কে' : 'About Us';
  String get footerLegalTitle => isBn ? 'পলিসি ও নির্দেশিকা' : 'Policies & Legal';
  String get footerHelplineTitle => isBn ? 'সহায়তা ও যোগাযোগ' : 'Help & Contact';
  String get footerHelplineNumber => '01677234252';
  String get footerCopyright => isBn
      ? '©  ঝটপট ডিরেক্টরি। সর্বস্বত্ব সংরক্ষিত।'
      : '©  Jotpot Directory. All rights reserved.';
}
