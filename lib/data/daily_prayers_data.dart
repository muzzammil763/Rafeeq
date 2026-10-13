import 'package:rafeeq/data/models/daily_prayer.dart';

// Categories for organizing prayers
const List<PrayerCategory> kPrayerCategories = [
  PrayerCategory(
    id: 'morning',
    nameEn: 'Morning Prayers',
    nameUr: 'صبح کی دعائیں',
    icon: 'wb_sunny',
    order: 1,
  ),
  PrayerCategory(
    id: 'evening',
    nameEn: 'Evening Prayers',
    nameUr: 'شام کی دعائیں',
    icon: 'nights_stay',
    order: 2,
  ),
  PrayerCategory(
    id: 'sleep',
    nameEn: 'Before Sleep',
    nameUr: 'سونے سے پہلے',
    icon: 'bedtime',
    order: 3,
  ),
  PrayerCategory(
    id: 'general',
    nameEn: 'Daily Supplications',
    nameUr: 'روزمرہ کی دعائیں',
    icon: 'prayer',
    order: 4,
  ),
];

// Morning Prayers (Subh)
final List<DailyPrayer> kMorningPrayers = [
  DailyPrayer(
    id: 'morning_1',
    category: 'morning',
    order: 1,
    arabicText:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        'Asbahna wa asbahal mulku lillahi walhamdu lillahi, la ilaha illallahu wahdahu la sharika lahu, lahul mulku wa lahul hamdu, wa huwa ala kulli shay\'in qadeer',
    englishTranslation:
        'We have reached the morning and at this very time all sovereignty belongs to Allah. All praise is for Allah. None has the right to be worshipped except Allah, alone, without partner, to Him belongs all sovereignty and praise and He is over all things omnipotent.',
    urduTranslation:
        'ہم نے صبح کی اور اس وقت ساری بادشاہت اللہ کے لیے ہے، ساری تعریف اللہ کے لیے ہے، اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، اسی کی بادشاہت ہے، اسی کی تعریف ہے، اور وہ ہر چیز پر قادر ہے',
    reference: 'Muslim 4:2083',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'morning_2',
    category: 'morning',
    order: 2,
    arabicText:
        'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    transliteration:
        'Allahumma bika asbahna, wa bika amsayna, wa bika nahya, wa bika namoot, wa ilaykan nushoor',
    englishTranslation:
        'O Allah, by Your leave we have reached the morning, and by Your leave we have reached the evening, by Your leave we live and die, and unto You is our resurrection.',
    urduTranslation:
        'اے اللہ! تیری ہی مدد سے ہم نے صبح کی، تیری ہی مدد سے شام کی، تیری ہی مدد سے ہم جیتے ہیں، تیری ہی مدد سے ہم مرتے ہیں، اور تیری ہی طرف ہمیں اٹھایا جائے گا',
    reference: 'Tirmidhi 5:466',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'morning_3',
    category: 'morning',
    order: 3,
    arabicText:
        'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ، فَمِنْكَ وَحْدَكَ، لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
    transliteration:
        'Allahumma ma asbaha bi min ni\'matin aw bi ahadin min khalqika, faminka wahdaka, la sharika lak, falakal hamdu walakash shukr',
    englishTranslation:
        'O Allah, what blessing I or any of Your creation have risen upon, is from You alone, without partner, so for You is all praise and unto You all thanks.',
    urduTranslation:
        'اے اللہ! جو نعمت مجھے یا تیری کسی مخلوق کو صبح کی ہے، وہ تیری ہی طرف سے ہے، تو اکیلا ہے، تیرا کوئی شریک نہیں، پس تیری ہی تعریف ہے اور تیرا ہی شکر ہے',
    reference: 'Abu Dawud 4:318',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'morning_4',
    category: 'morning',
    order: 4,
    arabicText:
        'أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ، حَنِيفًا مُسْلِمًا، وَمَا كَانَ مِنَ الْمُشْرِكِينَ',
    transliteration:
        'Asbahna ala fitratil Islam, wa ala kalimatil ikhlas, wa ala deeni nabiyyina Muhammadin sallallahu alayhi wa sallam, wa ala millati abeena Ibraheema, haneefan Musliman, wa ma kana minal mushrikeen',
    englishTranslation:
        'We have reached the morning upon the natural religion of Islam, the statement of pure faith, the religion of our Prophet Muhammad (peace be upon him), and the way of our father Abraham, a man of pure faith who was not of the polytheists.',
    urduTranslation:
        'ہم نے صبح کی فطرتِ اسلام پر، کلمہِ اخلاص پر، اپنے نبی محمد ﷺ کے دین پر، اپنے ابا ابراہیم کی ملت پر، جو یکسو مسلمان تھے اور مشرکوں میں سے نہیں تھے',
    reference: 'Muslim 4:2084',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'morning_5',
    category: 'morning',
    order: 5,
    arabicText:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ، وَهُوَ السَّمِيعُ الْعَلِيمُ',
    transliteration:
        'Bismillahilladhi la yadurru ma\'asmihi shay\'un fil ardi wa la fis sama\', wa huwas samee\'ul aleem',
    englishTranslation:
        'In the name of Allah, with whose name nothing can harm in the earth nor in the heavens, and He is the All-Hearing, the All-Knowing.',
    urduTranslation:
        'اللہ کے نام کے ساتھ جس کے نام کے ساتھ کوئی چیز زمین میں نہ آسمان میں نقصان نہیں پہنچا سکتی، اور وہ سننے والا جاننے والا ہے',
    reference: 'Tirmidhi 5:456, Ibn Majah 2:1131',
    recommendedCount: 3,
  ),
  DailyPrayer(
    id: 'morning_6',
    category: 'morning',
    order: 6,
    arabicText:
        'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    transliteration:
        'Radeetu billahi rabbam, wa bil Islami deenam, wa bi Muhammadin sallallahu alayhi wa sallama nabiyyan',
    englishTranslation:
        'I am pleased with Allah as a Lord, and Islam as a religion, and Muhammad (peace be upon him) as a Prophet.',
    urduTranslation:
        'میں اللہ کے رب ہونے پر، اسلام کے دین ہونے پر، اور محمد ﷺ کے نبی ہونے پر راضی ہوا',
    reference: 'Tirmidhi 5:465, Abu Dawud 4:318',
    recommendedCount: 3,
  ),
  DailyPrayer(
    id: 'morning_7',
    category: 'morning',
    order: 7,
    arabicText:
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةِ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
    transliteration:
        'Subhanallahi wa bihamdihi: \'adada khalqihi, wa rida nafsihi, wa zinati \'arshihi, wa midada kalimatihi',
    englishTranslation:
        'Glory is to Allah and praise is to Him, by the multitude of His creation, by His pleasure, by the weight of His Throne, and by the extent of His words.',
    urduTranslation:
        'اللہ پاک ہے اور اس کی تعریف ہے، اپنی مخلوق کی تعداد کے برابر، اپنی ذات کی رضا کے برابر، اپنے عرش کے وزن کے برابر، اور اپنے کلمات کی حد تک',
    reference: 'Muslim 4:2084',
    recommendedCount: 3,
  ),
  DailyPrayer(
    id: 'morning_8',
    category: 'morning',
    order: 8,
    arabicText: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: 'Hasbunallahu wa ni\'mal wakeel',
    englishTranslation:
        'Allah is sufficient for us, and He is the best Disposer of affairs.',
    urduTranslation: 'ہمارے لیے اللہ کافی ہے، اور وہ بہترین کارساز ہے',
    reference: 'Surah Aal-e-Imran 3:173',
    recommendedCount: 7,
  ),
  DailyPrayer(
    id: 'morning_9',
    category: 'morning',
    order: 9,
    arabicText:
        'يَا حَيُّ يَا قَيُّومُ، بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
    transliteration:
        'Ya Hayyu Ya Qayyoom, birahmatika astaghees, aslih li sha\'ni kullahu, wa la takilni ila nafsi tarfata \'ayn',
    englishTranslation:
        'O Living and Eternal Maintainer! By Your mercy I seek help, rectify for me all of my affairs and do not leave me to myself, even for the blink of an eye.',
    urduTranslation:
        'اے زندہ اور قائم رہنے والے! تیری رحمت سے میں فریاد کرتا ہوں، میرا سارا کام درست کر دے، اور مجھے پلک جھپکنے کے برابر بھی میرے نفس کے حوالے نہ کر',
    reference: 'Tirmidhi 5:474',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'morning_10',
    category: 'morning',
    order: 10,
    arabicText:
        'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'A\'oodhu bikalimatillahit tammati min sharri ma khalaq',
    englishTranslation:
        'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    urduTranslation:
        'میں اللہ کے کامل کلمات کی پناہ میں آتا ہوں اس کی مخلوق کی شر سے',
    reference: 'Muslim 4:2085',
    recommendedCount: 3,
  ),
];

// Evening Prayers (Evening - same as morning but with evening wording)
final List<DailyPrayer> kEveningPrayers = [
  DailyPrayer(
    id: 'evening_1',
    category: 'evening',
    order: 1,
    arabicText:
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        'Amsayna wa amsal mulku lillahi walhamdu lillahi, la ilaha illallahu wahdahu la sharika lahu, lahul mulku wa lahul hamdu, wa huwa ala kulli shay\'in qadeer',
    englishTranslation:
        'We have reached the evening and at this very time all sovereignty belongs to Allah. All praise is for Allah. None has the right to be worshipped except Allah, alone, without partner, to Him belongs all sovereignty and praise and He is over all things omnipotent.',
    urduTranslation:
        'ہم نے شام کی اور اس وقت ساری بادشاہت اللہ کے لیے ہے، ساری تعریف اللہ کے لیے ہے، اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، اسی کی بادشاہت ہے، اسی کی تعریف ہے، اور وہ ہر چیز پر قادر ہے',
    reference: 'Muslim 4:2083',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'evening_2',
    category: 'evening',
    order: 2,
    arabicText:
        'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
    transliteration:
        'Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika namoot, wa ilaykal maseer',
    englishTranslation:
        'O Allah, by Your leave we have reached the evening, and by Your leave we have reached the morning, by Your leave we live and die, and unto You is our return.',
    urduTranslation:
        'اے اللہ! تیری ہی مدد سے ہم نے شام کی، تیری ہی مدد سے صبح کی، تیری ہی مدد سے ہم جیتے ہیں، تیری ہی مدد سے ہم مرتے ہیں، اور تیری ہی طرف ہمیں لوٹنا ہے',
    reference: 'Tirmidhi 5:466',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'evening_3',
    category: 'evening',
    order: 3,
    arabicText:
        'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ، فَمِنْكَ وَحْدَكَ، لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
    transliteration:
        'Allahumma ma amsa bi min ni\'matin aw bi ahadin min khalqika, faminka wahdaka, la sharika lak, falakal hamdu walakash shukr',
    englishTranslation:
        'O Allah, what blessing I or any of Your creation have reached the evening upon, is from You alone, without partner, so for You is all praise and unto You all thanks.',
    urduTranslation:
        'اے اللہ! جو نعمت مجھے یا تیری کسی مخلوق کو شام کی ہے، وہ تیری ہی طرف سے ہے، تو اکیلا ہے، تیرا کوئی شریک نہیں، پس تیری ہی تعریف ہے اور تیرا ہی شکر ہے',
    reference: 'Abu Dawud 4:318',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'evening_4',
    category: 'evening',
    order: 4,
    arabicText:
        'أَمْسَيْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ، حَنِيفًا مُسْلِمًا، وَمَا كَانَ مِنَ الْمُشْرِكِينَ',
    transliteration:
        'Amsayna ala fitratil Islam, wa ala kalimatil ikhlas, wa ala deeni nabiyyina Muhammadin sallallahu alayhi wa sallam, wa ala millati abeena Ibraheema, haneefan Musliman, wa ma kana minal mushrikeen',
    englishTranslation:
        'We have reached the evening upon the natural religion of Islam, the statement of pure faith, the religion of our Prophet Muhammad (peace be upon him), and the way of our father Abraham, a man of pure faith who was not of the polytheists.',
    urduTranslation:
        'ہم نے شام کی فطرتِ اسلام پر، کلمہِ اخلاص پر، اپنے نبی محمد ﷺ کے دین پر، اپنے ابا ابراہیم کی ملت پر، جو یکسو مسلمان تھے اور مشرکوں میں سے نہیں تھے',
    reference: 'Muslim 4:2084',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'evening_5',
    category: 'evening',
    order: 5,
    arabicText:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ، وَهُوَ السَّمِيعُ الْعَلِيمُ',
    transliteration:
        'Bismillahilladhi la yadurru ma\'asmihi shay\'un fil ardi wa la fis sama\', wa huwas samee\'ul aleem',
    englishTranslation:
        'In the name of Allah, with whose name nothing can harm in the earth nor in the heavens, and He is the All-Hearing, the All-Knowing.',
    urduTranslation:
        'اللہ کے نام کے ساتھ جس کے نام کے ساتھ کوئی چیز زمین میں نہ آسمان میں نقصان نہیں پہنچا سکتی، اور وہ سننے والا جاننے والا ہے',
    reference: 'Tirmidhi 5:456, Ibn Majah 2:1131',
    recommendedCount: 3,
  ),
  DailyPrayer(
    id: 'evening_6',
    category: 'evening',
    order: 6,
    arabicText:
        'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    transliteration:
        'Radeetu billahi rabbam, wa bil Islami deenam, wa bi Muhammadin sallallahu alayhi wa sallama nabiyyan',
    englishTranslation:
        'I am pleased with Allah as a Lord, and Islam as a religion, and Muhammad (peace be upon him) as a Prophet.',
    urduTranslation:
        'میں اللہ کے رب ہونے پر، اسلام کے دین ہونے پر، اور محمد ﷺ کے نبی ہونے پر راضی ہوا',
    reference: 'Tirmidhi 5:465, Abu Dawud 4:318',
    recommendedCount: 3,
  ),
  DailyPrayer(
    id: 'evening_7',
    category: 'evening',
    order: 7,
    arabicText: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: 'Hasbunallahu wa ni\'mal wakeel',
    englishTranslation:
        'Allah is sufficient for us, and He is the best Disposer of affairs.',
    urduTranslation: 'ہمارے لیے اللہ کافی ہے، اور وہ بہترین کارساز ہے',
    reference: 'Surah Aal-e-Imran 3:173',
    recommendedCount: 7,
  ),
  DailyPrayer(
    id: 'evening_8',
    category: 'evening',
    order: 8,
    arabicText:
        'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'A\'oodhu bikalimatillahit tammati min sharri ma khalaq',
    englishTranslation:
        'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    urduTranslation:
        'میں اللہ کے کامل کلمات کی پناہ میں آتا ہوں اس کی مخلوق کی شر سے',
    reference: 'Muslim 4:2085',
    recommendedCount: 3,
  ),
];

// Before Sleep Prayers
final List<DailyPrayer> kSleepPrayers = [
  DailyPrayer(
    id: 'sleep_1',
    category: 'sleep',
    order: 1,
    arabicText: 'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا',
    transliteration: 'Allahumma bismika amootu wa ahya',
    englishTranslation: 'O Allah, in Your name I die and live.',
    urduTranslation: 'اے اللہ! تیرے نام پر میں مرتا ہوں اور جیتا ہوں',
    reference: 'Bukhari 11:113, Muslim 4:2083',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'sleep_2',
    category: 'sleep',
    order: 2,
    arabicText: 'سُبْحَانَ اللَّهِ',
    transliteration: 'Subhanallah',
    englishTranslation: 'Glory be to Allah',
    urduTranslation: 'اللہ پاک ہے',
    reference: 'Bukhari 11:113',
    recommendedCount: 33,
  ),
  DailyPrayer(
    id: 'sleep_3',
    category: 'sleep',
    order: 3,
    arabicText: 'الْحَمْدُ لِلَّهِ',
    transliteration: 'Alhamdulillah',
    englishTranslation: 'Praise be to Allah',
    urduTranslation: 'تمام تعریفیں اللہ کے لیے ہیں',
    reference: 'Bukhari 11:113',
    recommendedCount: 33,
  ),
  DailyPrayer(
    id: 'sleep_4',
    category: 'sleep',
    order: 4,
    arabicText: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    englishTranslation: 'Allah is the Greatest',
    urduTranslation: 'اللہ سب سے بڑا ہے',
    reference: 'Bukhari 11:113',
    recommendedCount: 34,
  ),
  DailyPrayer(
    id: 'sleep_5',
    category: 'sleep',
    order: 5,
    arabicText: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    transliteration: 'Bismika Allahumma amootu wa ahya',
    englishTranslation: 'In Your name, O Allah, I die and live.',
    urduTranslation: 'اے اللہ! تیرے نام پر میں مرتا ہوں اور جیتا ہوں',
    reference: 'Bukhari 11:126',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'sleep_6',
    category: 'sleep',
    order: 6,
    arabicText:
        'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
    transliteration:
        'Allahumma aslamtu nafsi ilayk, wa fawwadtu amri ilayk, wa wajjahtu wajhi ilayk, wa alja\'tu zahri ilayk, raghbatan wa rahbatan ilayk, la malja\'a wa la manja minka illa ilayk, amantu bikitabikalladhi anzalt, wa binabiyyikalladhi arsalt',
    englishTranslation:
        'O Allah, I submit myself to You, entrust my affairs to You, turn my face to You, lay myself down relying on You, hoping in Your mercy and fearing Your punishment. There is no refuge or escape from You except to You. I believe in Your Book which You sent down and Your Prophet whom You sent.',
    urduTranslation:
        'اے اللہ! میں نے اپنی جان تیرے حوالے کی، اپنا کام تیرے سپرد کیا، اپنا چہرہ تیری طرف کیا، اپنی پشت تیرے سہارے لگائی، تیری رحمت کی امید اور تیرے عذاب کے خوف سے، تیرے سوا میرا کوئی پناہ گاہ نہیں، نہ کوئی بچاؤ ہے، میں نے تیری کتاب پر ایمان لایا جسے تو نے اتارا اور تیرے نبی پر جو بھیجا',
    reference: 'Bukhari 11:126, Muslim 4:2083',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'sleep_7',
    category: 'sleep',
    order: 7,
    arabicText: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
    transliteration: 'Allahumma qinee \'adhabaka yawma tab\'athu \'ibadak',
    englishTranslation:
        'O Allah, protect me from Your punishment on the day You resurrect Your servants.',
    urduTranslation:
        'اے اللہ! اپنے عذاب سے بچا جس دن تو اپنے بندوں کو اٹھائے گا',
    reference: 'Tirmidhi 5:466, Abu Dawud 4:318',
    recommendedCount: 3,
  ),
  DailyPrayer(
    id: 'sleep_8',
    category: 'sleep',
    order: 8,
    arabicText:
        'اللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِي، وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
    transliteration:
        'Allahumma innaka khalaqta nafsi, wa anta tawaffaha, laka mamatoha wa mahyaha, in ahyaytaha fahfazha, wa in amattaha faghfir laha, Allahumma inni as\'alukal \'afiyah',
    englishTranslation:
        'O Allah, You created my soul and You take it back. Unto You is its death and its life. If You give it life then protect it, and if You cause it to die then forgive it. O Allah, I ask You for good health.',
    urduTranslation:
        'اے اللہ! تو نے میری جان پیدا کی، اور تو ہی اسے موت دے گا، تیرے لیے ہے اس کی موت اور زندگی، اگر تو نے اسے زندہ رکھا تو اس کی حفاظت کر، اور اگر تو نے اسے موت دی تو اسے معاف کر دے، اے اللہ! میں تیری عافیت مانگتا ہوں',
    reference: 'Muslim 4:2083',
    recommendedCount: 1,
  ),
];

// General Daily Supplications
final List<DailyPrayer> kGeneralPrayers = [
  DailyPrayer(
    id: 'general_1',
    category: 'general',
    order: 1,
    arabicText: 'بِسْمِ اللَّهِ',
    transliteration: 'Bismillah',
    englishTranslation: 'In the name of Allah',
    urduTranslation: 'اللہ کے نام سے',
    reference: 'General practice',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'general_2',
    category: 'general',
    order: 2,
    arabicText: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    transliteration: 'La hawla wa la quwwata illa billah',
    englishTranslation: 'There is no power and no strength except with Allah',
    urduTranslation: 'اللہ کے سوا کوئی طاقت اور قوت نہیں',
    reference: 'Bukhari 8:136',
    recommendedCount: 1,
  ),
  DailyPrayer(
    id: 'general_3',
    category: 'general',
    order: 3,
    arabicText: 'أَسْتَغْفِرُ اللَّهَ',
    transliteration: 'Astaghfirullah',
    englishTranslation: 'I seek forgiveness from Allah',
    urduTranslation: 'میں اللہ سے مغفرت مانگتا ہوں',
    reference: 'General practice',
    recommendedCount: 100,
  ),
  DailyPrayer(
    id: 'general_4',
    category: 'general',
    order: 4,
    arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    transliteration: 'Subhanallahi wa bihamdihi',
    englishTranslation: 'Glory be to Allah and praise be to Him',
    urduTranslation: 'اللہ پاک ہے اور اس کی تعریف ہے',
    reference: 'Muslim 4:2073',
    recommendedCount: 100,
  ),
  DailyPrayer(
    id: 'general_5',
    category: 'general',
    order: 5,
    arabicText: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    englishTranslation: 'Allah is the Greatest',
    urduTranslation: 'اللہ سب سے بڑا ہے',
    reference: 'Muslim 4:2073',
    recommendedCount: 100,
  ),
  DailyPrayer(
    id: 'general_6',
    category: 'general',
    order: 6,
    arabicText: 'لَا إِلَهَ إِلَّا اللَّهُ',
    transliteration: 'La ilaha illallah',
    englishTranslation: 'There is no god but Allah',
    urduTranslation: 'اللہ کے سوا کوئی معبود نہیں',
    reference: 'Muslim 4:2073',
    recommendedCount: 100,
  ),
  DailyPrayer(
    id: 'general_7',
    category: 'general',
    order: 7,
    arabicText:
        'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    transliteration:
        'Allahumma salli ala Muhammadin wa ala ali Muhammadin, kama sallayta ala Ibraheema wa ala ali Ibraheema, innaka hameedun majeed. Allahumma barik ala Muhammadin wa ala ali Muhammadin, kama barakta ala Ibraheema wa ala ali Ibraheema, innaka hameedun majeed',
    englishTranslation:
        'O Allah, send prayers upon Muhammad and upon the family of Muhammad, as You sent prayers upon Ibrahim and upon the family of Ibrahim. Verily You are full of praise and majesty. O Allah, send blessings upon Muhammad and upon the family of Muhammad, as You sent blessings upon Ibrahim and upon the family of Ibrahim. Verily You are full of praise and majesty.',
    urduTranslation:
        'اے اللہ! محمد اور آلِ محمد پر رحمتیں نازل فرما جیسے تو نے ابراہیم اور آلِ ابراہیم پر رحمتیں نازل کی، بےشک تو تعریف والا اور بزرگی والا ہے، اے اللہ! محمد اور آلِ محمد پر برکتیں نازل فرما جیسے تو نے ابراہیم اور آلِ ابراہیم پر برکتیں نازل کی، بےشک تو تعریف والا اور بزرگی والا ہے',
    reference: 'Bukhari 8:368, Muslim 4:2073',
    recommendedCount: 10,
  ),
  DailyPrayer(
    id: 'general_8',
    category: 'general',
    order: 8,
    arabicText:
        'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
    transliteration:
        'Subhanallah walhamdulillahi wa la ilaha illallahu wallahu akbar',
    englishTranslation:
        'Glory be to Allah, all praise is for Allah, there is no god but Allah, and Allah is the Greatest',
    urduTranslation:
        'اللہ پاک ہے، تمام تعریفیں اللہ کے لیے ہیں، اللہ کے سوا کوئی معبود نہیں، اور اللہ سب سے بڑا ہے',
    reference: 'Muslim 4:2073',
    recommendedCount: 100,
  ),
];

// Combined list of all prayers
final List<DailyPrayer> kAllDailyPrayers = [
  ...kMorningPrayers,
  ...kEveningPrayers,
  ...kSleepPrayers,
  ...kGeneralPrayers,
];

// Helper functions
List<DailyPrayer> getPrayersByCategory(String categoryId) {
  return kAllDailyPrayers.where((p) => p.category == categoryId).toList();
}

List<DailyPrayer> getAllPrayers() {
  return kAllDailyPrayers;
}

PrayerCategory? getCategoryById(String id) {
  try {
    return kPrayerCategories.firstWhere((c) => c.id == id);
  } catch (e) {
    return null;
  }
}
