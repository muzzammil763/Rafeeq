const String namazPrayersJson = r'''
[
  {
    "id": "fajr",
    "nameEn": "Fajr",
    "nameUr": "نماز فجر",
    "arabicName": "الصلاة الفجر",
    "rakaatFard": 2,
    "rakaatSunnah": 2,
    "timing": "Dawn - Sunrise",
    "descriptionEn": "The dawn prayer performed before sunrise",
    "descriptionUr": "طلوع آفتاب سے پہلے ادا ہونے والی نماز",
    "components": [
      {
        "id": "takbeer",
        "type": "takbeer",
        "titleEn": "Takbeer (Starting Prayer)",
        "titleUr": "تکبیر (نماز شروع کرنا)",
        "arabicText": "اللهُ أَكْبَرْ",
        "urduTranslation": "اللہ سب سے بڑا ہے",
        "transliteration": "Allahu Akbar",
        "description": "Raise hands to ears, palms facing Qibla",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "thana",
        "type": "thana",
        "titleEn": "Thana (Opening Supplication)",
        "titleUr": "ثناء (افتتاحی دعا)",
        "arabicText": "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ",
        "urduTranslation": "اے اللہ! تو پاک ہے اور تیری تعریف ہے، تیرا نام بابرکت ہے، تیری عظمت بلند ہے، اور تیرے سوا کوئی معبود نہیں",
        "transliteration": "Subhanaka Allahumma wa bihamdika, wa tabarakasmuka, wa taala jadduka, wa la ilaha ghairuk",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "tauz",
        "type": "protection",
        "titleEn": "Ta'awwuz (Seeking Refuge)",
        "titleUr": "تعوذ (اللہ کی پناہ)",
        "arabicText": "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
        "urduTranslation": "میں شیطان مردود سے اللہ کی پناہ مانگتا ہوں",
        "transliteration": "Aoozu billahi minash shaitanir rajeem",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "tasmiah",
        "type": "bismillah",
        "titleEn": "Tasmiah (Bismillah)",
        "titleUr": "تسمیہ (بسم اللہ)",
        "arabicText": "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
        "urduTranslation": "شروع اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے",
        "transliteration": "Bismillahir Rahmanir Rahim",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "fatiha",
        "type": "surah",
        "titleEn": "Surah Al-Fatiha",
        "titleUr": "سورہ الفاتحہ",
        "arabicText": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ، الرَّحْمَنِ الرَّحِيمِ، مَالِكِ يَوْمِ الدِّينِ، إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ، اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ، صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ، غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
        "urduTranslation": "تمام تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا پروردگار ہے، بڑا مہربان نہایت رحم والا، جزا و سزا کے دن کا مالک، تجھ ہی کی عبادت کرتے ہیں اور تجھ ہی سے مدد مانگتے ہیں، ہمیں سیدھا راستہ دکھا، ان لوگوں کا راستہ جن پر تو نے انعام کیا، نہ ان کا جن پر غصہ کیا اور نہ گمراہوں کا",
        "transliteration": "Alhamdu lillahi Rabbil alameen, ar-Rahmanir Rahim, Maliki yawmid deen, Iyyaka naabudu wa Iyyaka nastaeen, Ihdinas siratal mustaqeem, Siratal ladheena anamta alayhim, ghayril maghdhubi alayhim walad dalleen",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "ameen",
        "type": "response",
        "titleEn": "Ameen",
        "titleUr": "آمین",
        "arabicText": "آمِينْ",
        "urduTranslation": "اے اللہ! اس دعا کو قبول فرما",
        "transliteration": "Ameen",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "surah_ikhlas",
        "type": "surah",
        "titleEn": "Surah Al-Ikhlas (Optional Short Surah)",
        "titleUr": "سورہ الاخلاص (مختصر سورت)",
        "arabicText": "قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ",
        "urduTranslation": "کہہ دو کہ وہ اللہ ایک ہے، اللہ بے نیاز ہے، نہ اس کی کوئی اولاد ہے اور نہ وہ کسی کی اولاد ہے، اور نہ اس کا کوئی ہمسر ہے",
        "transliteration": "Qul huwallahu ahad, Allahu samad, Lam yalid walam yulad, Walam yakun lahu kufuwan ahad",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "ruku",
        "type": "ruku",
        "titleEn": "Ruku (Bowing)",
        "titleUr": "رکوع (جھکنا)",
        "arabicText": "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
        "urduTranslation": "میرے بڑے پروردگار پاک ہے",
        "transliteration": "Subhana Rabbiyal Azeem",
        "description": "Bend forward, place hands on knees",
        "repeatCount": 3,
        "isOptional": false
      },
      {
        "id": "qiyam_ruku",
        "type": "qiyam",
        "titleEn": "Standing from Ruku",
        "titleUr": "رکوع سے کھڑے ہونا",
        "arabicText": "سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ",
        "urduTranslation": "اللہ نے اس کی سنی جس نے اس کی تعریف کی",
        "transliteration": "Sami Allahu liman hamidah",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "response_qiyam",
        "type": "response",
        "titleEn": "Response",
        "titleUr": "جواب",
        "arabicText": "رَبَّنَا وَلَكَ الْحَمْدُ",
        "urduTranslation": "اے ہمارے رب! تیرے لیے تعریف ہے",
        "transliteration": "Rabbana wa lakal hamd",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "sajdah_1",
        "type": "sujood",
        "titleEn": "First Sajdah (Prostration)",
        "titleUr": "پہلا سجدہ",
        "arabicText": "سُبْحَانَ رَبِّيَ الْأَعْلَى",
        "urduTranslation": "میرے سب سے بلند پروردگار پاک ہے",
        "transliteration": "Subhana Rabbiyal Aala",
        "description": "Prostrate with forehead, nose, palms, knees, and toes touching ground",
        "repeatCount": 3,
        "isOptional": false
      },
      {
        "id": "jalsa_1",
        "type": "jalsa",
        "titleEn": "Jalsa (Sitting between Sajdahs)",
        "titleUr": "جلسہ (سجدوں کے درمیان بیٹھنا)",
        "arabicText": "اللَّهُ أَكْبَرْ",
        "urduTranslation": "اللہ سب سے بڑا ہے",
        "transliteration": "Allahu Akbar",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "sajdah_2",
        "type": "sujood",
        "titleEn": "Second Sajdah (Prostration)",
        "titleUr": "دوسرا سجدہ",
        "arabicText": "سُبْحَانَ رَبِّيَ الْأَعْلَى",
        "urduTranslation": "میرے سب سے بلند پروردگار پاک ہے",
        "transliteration": "Subhana Rabbiyal Aala",
        "repeatCount": 3,
        "isOptional": false
      },
      {
        "id": "second_rakat",
        "type": "qiyam",
        "titleEn": "Second Rakat - Standing",
        "titleUr": "دوسری رکعت - کھڑے ہونا",
        "arabicText": "اللَّهُ أَكْبَرْ",
        "urduTranslation": "اللہ سب سے بڑا ہے",
        "transliteration": "Allahu Akbar",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "fatiha_2",
        "type": "surah",
        "titleEn": "Surah Al-Fatiha (2nd Rakat)",
        "titleUr": "سورہ الفاتحہ (دوسری رکعت)",
        "arabicText": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ، الرَّحْمَنِ الرَّحِيمِ، مَالِكِ يَوْمِ الدِّينِ، إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ، اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ، صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ، غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
        "urduTranslation": "تمام تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا پروردگار ہے، بڑا مہربان نہایت رحم والا، جزا و سزا کے دن کا مالک، تجھ ہی کی عبادت کرتے ہیں اور تجھ ہی سے مدد مانگتے ہیں، ہمیں سیدھا راستہ دکھا، ان لوگوں کا راستہ جن پر تو نے انعام کیا، نہ ان کا جن پر غصہ کیا اور نہ گمراہوں کا",
        "transliteration": "Alhamdu lillahi Rabbil alameen, ar-Rahmanir Rahim, Maliki yawmid deen, Iyyaka naabudu wa Iyyaka nastaeen, Ihdinas siratal mustaqeem, Siratal ladheena anamta alayhim, ghayril maghdhubi alayhim walad dalleen",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "surah_falaq",
        "type": "surah",
        "titleEn": "Surah Al-Falaq (2nd Rakat)",
        "titleUr": "سورہ الفلق (دوسری رکعت)",
        "arabicText": "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، مِنْ شَرِّ مَا خَلَقَ، وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ، وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ",
        "urduTranslation": "کہہ دو کہ میں صبح کے رب کی پناہ مانگتا ہوں، اس چیز کی شر سے جو اس نے پیدا کی، اور اندھیرے کی شر سے جب وہ چھا جائے، اور گانٹھوں میں پھونک مارنے والیوں کی شر سے، اور حسد کرنے والے کی شر سے جب وہ حسد کرے",
        "transliteration": "Qul aoozu birabbil falak, min sharri ma khalaq, wa min sharri ghasikin idha waqab, wa min sharrin naffathati fil uqad, wa min sharri hasidin idha hasad",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "ruku_2",
        "type": "ruku",
        "titleEn": "Ruku (2nd Rakat)",
        "titleUr": "رکوع (دوسری رکعت)",
        "arabicText": "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
        "urduTranslation": "میرے بڑے پروردگار پاک ہے",
        "transliteration": "Subhana Rabbiyal Azeem",
        "repeatCount": 3,
        "isOptional": false
      },
      {
        "id": "qiyam_ruku_2",
        "type": "qiyam",
        "titleEn": "Standing from Ruku (2nd)",
        "titleUr": "رکوع سے کھڑے ہونا (دوسری)",
        "arabicText": "سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ",
        "urduTranslation": "اللہ نے اس کی سنی جس نے اس کی تعریف کی",
        "transliteration": "Sami Allahu liman hamidah",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "response_qiyam_2",
        "type": "response",
        "titleEn": "Response",
        "titleUr": "جواب",
        "arabicText": "رَبَّنَا وَلَكَ الْحَمْدُ",
        "urduTranslation": "اے ہمارے رب! تیرے لیے تعریف ہے",
        "transliteration": "Rabbana wa lakal hamd",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "sajdah_1_2",
        "type": "sujood",
        "titleEn": "First Sajdah (2nd Rakat)",
        "titleUr": "پہلا سجدہ (دوسری رکعت)",
        "arabicText": "سُبْحَانَ رَبِّيَ الْأَعْلَى",
        "urduTranslation": "میرے سب سے بلند پروردگار پاک ہے",
        "transliteration": "Subhana Rabbiyal Aala",
        "repeatCount": 3,
        "isOptional": false
      },
      {
        "id": "jalsa_2",
        "type": "jalsa",
        "titleEn": "Jalsa",
        "titleUr": "جلسہ",
        "arabicText": "اللَّهُ أَكْبَرْ",
        "urduTranslation": "اللہ سب سے بڑا ہے",
        "transliteration": "Allahu Akbar",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "sajdah_2_2",
        "type": "sujood",
        "titleEn": "Second Sajdah (2nd Rakat)",
        "titleUr": "دوسرا سجدہ (دوسری رکعت)",
        "arabicText": "سُبْحَانَ رَبِّيَ الْأَعْلَى",
        "urduTranslation": "میرے سب سے بلند پروردگار پاک ہے",
        "transliteration": "Subhana Rabbiyal Aala",
        "repeatCount": 3,
        "isOptional": false
      },
      {
        "id": "tashahhud",
        "type": "tashahhud",
        "titleEn": "Tashahhud (Testification)",
        "titleUr": "تشہد (گواہی)",
        "arabicText": "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
        "urduTranslation": "تمام تعریفیں، نمازیں، اور پاکیزہ عمل اللہ کے لیے ہیں، اے نبی! تم پر اللہ کی رحمتیں اور برکتیں، ہم پر اور اللہ کے نیک بندوں پر سلام، میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، اور میں گواہی دیتا ہوں کہ محمد ﷺ اس کے بندے اور رسول ہیں",
        "transliteration": "Attahiyyatulillahi wassalawatu wattayyibat, as-salamu alayka ayyuhan nabiyyu wa rahmatullahi wa barakatuhu, as-salamu alayna wa ala ibadillahis saliheen, ash-hadu an la ilaha illallahu, wa ash-hadu anna muhammadan abduhu wa rasuluh",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "darood",
        "type": "darood",
        "titleEn": "Darood Sharif (Blessings on Prophet)",
        "titleUr": "درود شریف",
        "arabicText": "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
        "urduTranslation": "اے اللہ! محمد اور آل محمد پر رحمتیں نازل فرما جیسے تو نے ابراہیم اور آل ابراہیم پر رحمتیں نازل کی، بےشک تو تعریف والا اور بزرگی والا ہے، اے اللہ! محمد اور آل محمد پر برکتیں نازل فرما جیسے تو نے ابراہیم اور آل ابراہیم پر برکتیں نازل کی، بےشک تو تعریف والا اور بزرگی والا ہے",
        "transliteration": "Allahumma salli ala Muhammadin wa ala ali Muhammadin kama sallayta ala Ibraheema wa ala ali Ibraheema innaka hameedum majeed. Allahumma barik ala Muhammadin wa ala ali Muhammadin kama barakta ala Ibraheema wa ala ali Ibraheema innaka hameedum majeed",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "dua",
        "type": "dua",
        "titleEn": "Dua",
        "titleUr": "دعا",
        "arabicText": "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ",
        "urduTranslation": "اے اللہ! میں تیری پناہ مانگتا ہوں جہنم کے عذاب سے، قبر کے عذاب سے، زندگی اور موت کے فتنے سے، اور دجjal کے فتنے کے شر سے",
        "transliteration": "Allahumma inni aoozu bika min adhabil jahannam, wa min adhabil qabr, wa min fitnatil mahya wal mamat, wa min sharri fitnatil masihid dajjal",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "salam_right",
        "type": "salam",
        "titleEn": "Salam (Turn Right)",
        "titleUr": "سلام (دائیں طرف)",
        "arabicText": "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ",
        "urduTranslation": "تم پر سلامتی ہو اور اللہ کی رحمت",
        "transliteration": "Assalamu alaykum wa rahmatullah",
        "description": "Turn face to right",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "salam_left",
        "type": "salam",
        "titleEn": "Salam (Turn Left)",
        "titleUr": "سلام (بائیں طرف)",
        "arabicText": "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ",
        "urduTranslation": "تم پر سلامتی ہو اور اللہ کی رحمت",
        "transliteration": "Assalamu alaykum wa rahmatullah",
        "description": "Turn face to left",
        "repeatCount": 1,
        "isOptional": false
      }
    ],
    "notes": [
      "Sunnah: 2 Rakaat before Fard",
      "Fard: 2 Rakaat"
    ]
  },
  {
    "id": "duhr",
    "nameEn": "Duhr",
    "nameUr": "نماز ظہر",
    "arabicName": "الصلاة الظهر",
    "rakaatFard": 4,
    "rakaatSunnah": 4,
    "timing": "Noon - Afternoon",
    "descriptionEn": "The noon prayer performed after the sun passes its zenith",
    "descriptionUr": "زوال آفتاب کے بعد ادا ہونے والی نماز",
    "components": [
      {
        "id": "sunnah_intro",
        "type": "intro",
        "titleEn": "Sunnah Prayer (4 Rakaat)",
        "titleUr": "سنت نماز (4 رکعات)",
        "arabicText": "",
        "urduTranslation": "دو دو رکعت کر کے چار رکعت سنت ادا کریں",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "fard_intro",
        "type": "intro",
        "titleEn": "Fard Prayer (4 Rakaat)",
        "titleUr": "فرض نماز (4 رکعات)",
        "arabicText": "",
        "urduTranslation": "دو دو رکعت کر کے چار رکعت فرض ادا کریں، ہر رکعت میں سورہ فاتحہ اور کوئی سورت پڑھیں",
        "repeatCount": 1,
        "isOptional": false
      }
    ],
    "notes": [
      "Sunnah: 4 Rakaat before Fard",
      "Fard: 4 Rakaat",
      "Sunnah: 2 Rakaat after Fard (or 4)"
    ]
  },
  {
    "id": "asr",
    "nameEn": "Asr",
    "nameUr": "نماز عصر",
    "arabicName": "الصلاة العصر",
    "rakaatFard": 4,
    "rakaatSunnah": 0,
    "timing": "Afternoon - Sunset",
    "descriptionEn": "The afternoon prayer performed before sunset",
    "descriptionUr": "غروب آفتاب سے پہلے ادا ہونے والی نماز",
    "components": [
      {
        "id": "sunnah_asr",
        "type": "intro",
        "titleEn": "Sunnah Prayer (4 Rakaat)",
        "titleUr": "سنت نماز (4 رکعات)",
        "arabicText": "",
        "urduTranslation": "دو دو رکعت کر کے چار رکعت سنت ادا کریں",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "fard_asr",
        "type": "intro",
        "titleEn": "Fard Prayer (4 Rakaat)",
        "titleUr": "فرض نماز (4 رکعات)",
        "arabicText": "",
        "urduTranslation": "دو دو رکعت کر کے چار رکعت فرض ادا کریں",
        "repeatCount": 1,
        "isOptional": false
      }
    ],
    "notes": [
      "Sunnah: 4 Rakaat before Fard",
      "Fard: 4 Rakaat"
    ]
  },
  {
    "id": "maghrib",
    "nameEn": "Maghrib",
    "nameUr": "نماز مغرب",
    "arabicName": "الصلاة المغرب",
    "rakaatFard": 3,
    "rakaatSunnah": 2,
    "timing": "Just after Sunset",
    "descriptionEn": "The sunset prayer performed immediately after sunset",
    "descriptionUr": "غروب آفتاب کے فوراً بعد ادا ہونے والی نماز",
    "components": [
      {
        "id": "fard_maghrib",
        "type": "intro",
        "titleEn": "Fard Prayer (3 Rakaat)",
        "titleUr": "فرض نماز (3 رکعات)",
        "arabicText": "",
        "urduTranslation": "پہلے دو رکعت پھر اکیلی تیسری رکعت جس میں تشہد پڑھ کر سلام پھیریں",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "sunnah_maghrib",
        "type": "intro",
        "titleEn": "Sunnah Prayer (2 Rakaat)",
        "titleUr": "سنت نماز (2 رکعات)",
        "arabicText": "",
        "urduTranslation": "فرض کے بعد دو رکعت سنت",
        "repeatCount": 1,
        "isOptional": false
      }
    ],
    "notes": [
      "Fard: 3 Rakaat (3rd rakat with Tashahhud)",
      "Sunnah: 2 Rakaat after Fard"
    ]
  },
  {
    "id": "isha",
    "nameEn": "Isha",
    "nameUr": "نماز عشاء",
    "arabicName": "الصلاة العشاء",
    "rakaatFard": 4,
    "rakaatSunnah": 2,
    "timing": "Night - Midnight",
    "descriptionEn": "The night prayer performed after twilight disappears",
    "descriptionUr": "شام کے بعد ادا ہونے والی نماز",
    "components": [
      {
        "id": "sunnah_isha",
        "type": "intro",
        "titleEn": "Sunnah Prayer (4 Rakaat)",
        "titleUr": "سنت نماز (4 رکعات)",
        "arabicText": "",
        "urduTranslation": "دو دو رکعت کر کے چار رکعت سنت ادا کریں",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "fard_isha",
        "type": "intro",
        "titleEn": "Fard Prayer (4 Rakaat)",
        "titleUr": "فرض نماز (4 رکعات)",
        "arabicText": "",
        "urduTranslation": "دو دو رکعت کر کے چار رکعت فرض ادا کریں",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "sunnah_after",
        "type": "intro",
        "titleEn": "Sunnah After Fard (2 Rakaat)",
        "titleUr": "فرض کے بعد سنت (2 رکعات)",
        "arabicText": "",
        "urduTranslation": "فرض کے بعد دو رکعت سنت",
        "repeatCount": 1,
        "isOptional": false
      },
      {
        "id": "witr",
        "type": "intro",
        "titleEn": "Witr Prayer (3 Rakaat)",
        "titleUr": "وتر نماز (3 رکعات)",
        "arabicText": "",
        "urduTranslation": "دو رکعت سنت کے بعد تین رکعت وتر نماز ادا کریں",
        "repeatCount": 1,
        "isOptional": false
      }
    ],
    "notes": [
      "Sunnah: 4 Rakaat before Fard",
      "Fard: 4 Rakaat",
      "Sunnah: 2 Rakaat after Fard",
      "Witr: 3 Rakaat"
    ]
  }
]''';
