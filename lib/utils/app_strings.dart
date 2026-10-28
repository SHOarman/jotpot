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
    'mymensingh': 'ময়মনসিংহ',
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
    // Barishal
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
    // Dhaka
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
    // Chattogram
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
    'কক্সবাজার সদর': 'Cox\'s Bazar Sadar',
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
    // Rajshahi
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
    // Khulna
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
    // Sylhet
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
    // Rangpur
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
    // Mymensingh
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
    'hiace': 'হায়াস',
    'private car': 'প্রাইভেট কার',
    'car': 'কার',
    'cng': 'সিএনজি',
    'auto': 'অটো',
    'auto rickshaw': 'অটো',
    'easy bike': 'ইজি বাইক',
    'mishuk': 'মিশুক',
    'leguna': 'লেগুনা',
    'truck': 'ট্রাক',
    'pickup': 'পিকআপ',
    'pick up': 'পিকআপ',
    'bus': 'বাস',
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
    'মিশুক': 'Mishuk',
    'লেগুনা': 'Leguna',
    'ট্রাক': 'Truck',
    'পিকআপ': 'Pickup',
    'পিক আপ': 'Pickup',
    'বাস': 'Bus',
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
      if (enToBnVehicles.containsKey(lower)) {
        return enToBnVehicles[lower]!;
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

  static String translateDivisionStatic(String raw, bool toBengali) {
    final clean = raw.trim();
    if (clean.isEmpty) return clean;
    final lower = clean.toLowerCase();

    if (toBengali) {
      if (enToBnDivisions.containsKey(lower)) {
        return enToBnDivisions[lower]!;
      }
      return clean;
    } else {
      if (bnToEnDivisions.containsKey(clean)) {
        return bnToEnDivisions[clean]!;
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

    if (toBengali) {
      if (enToBnDistricts.containsKey(lower)) {
        return enToBnDistricts[lower]!;
      }
      return clean;
    } else {
      if (bnToEnDistricts.containsKey(clean)) {
        return bnToEnDistricts[clean]!;
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

    if (toBengali) {
      if (enToBnUpazilas.containsKey(lower)) {
        return enToBnUpazilas[lower]!;
      }
      return clean;
    } else {
      if (bnToEnUpazilas.containsKey(clean)) {
        return bnToEnUpazilas[clean]!;
      }
      if (enToBnUpazilas.containsKey(lower)) {
        final bn = enToBnUpazilas[lower]!;
        if (bnToEnUpazilas.containsKey(bn)) {
          return bnToEnUpazilas[bn]!;
        }
      }
      return clean;
    }
  }

  static String toBengaliDivision(String raw) =>
      translateDivisionStatic(raw, true);
  static String toBengaliDistrict(String raw) =>
      translateDistrictStatic(raw, true);

  static bool areSameDivision(String a, String b) {
    if (a.toLowerCase().trim() == b.toLowerCase().trim()) return true;
    final bnA = toBengaliDivision(a);
    final bnB = toBengaliDivision(b);
    return bnA.isNotEmpty && bnA == bnB;
  }

  static bool areSameDistrict(String a, String b) {
    if (a.toLowerCase().trim() == b.toLowerCase().trim()) return true;
    final bnA = toBengaliDistrict(a);
    final bnB = toBengaliDistrict(b);
    return bnA.isNotEmpty && bnA == bnB;
  }

  static bool areSameUpazila(String a, String b) {
    if (a.toLowerCase().trim() == b.toLowerCase().trim()) return true;
    final bnA = translateUpazilaStatic(a, true);
    final bnB = translateUpazilaStatic(b, true);
    return bnA.isNotEmpty && bnA == bnB;
  }

  static bool areSameVehicleType(String a, String b) {
    if (a.toLowerCase().trim() == b.toLowerCase().trim()) return true;
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
      ? '© 2026 ঝটপট ডিরেক্টরি। সর্বস্বত্ব সংরক্ষিত।'
      : '© 2026 Jotpot Directory. All rights reserved.';
}
