class AdhkarData {
  AdhkarData._();

  static final List<Map<String, dynamic>> morningAdhkar = List.unmodifiable(
    _buildAdhkar(isMorning: true),
  );

  static final List<Map<String, dynamic>> eveningAdhkar = List.unmodifiable(
    _buildAdhkar(isMorning: false),
  );

  static List<Map<String, dynamic>> _buildAdhkar({required bool isMorning}) {
    final entryDhikrArabic = isMorning
        ? 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلّٰهِ وَالْحَمْدُ لِلّٰهِ لَا شَرِيكَ لَهُ لَا إِلٰهَ إِلَّا هُوَ وَإِلَيْهِ النُّشُورُ'
        : 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلّٰهِ وَالْحَمْدُ لِلّٰهِ لَا شَرِيكَ لَهُ لَا إِلٰهَ إِلَّا هُوَ وَإِلَيْهِ الْمَصِيرُ';

    final fitrahArabic = isMorning
        ? 'أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ وَكَلِمَةِ الْإِخْلَاصِ وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ'
        : 'أَمْسَيْنَا عَلَى فِطْرَةِ الْإِسْلَامِ وَكَلِمَةِ الْإِخْلَاصِ وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ';

    final gratitudeArabic = isMorning
        ? 'اللَّهُمَّ إِنِّي أَصْبَحْتُ مِنْكَ فِي نِعْمَةٍ وَعَافِيَةٍ وَسِتْرٍ فَأَتِمَّ عَلَيَّ نِعْمَتَكَ وَعَافِيَتَكَ وَسِتْرَكَ فِي الدُّنْيَا وَالآخِرَةِ'
        : 'اللَّهُمَّ إِنِّي أَمْسَيْتُ مِنْكَ فِي نِعْمَةٍ وَعَافِيَةٍ وَسِتْرٍ فَأَتِمَّ عَلَيَّ نِعْمَتَكَ وَعَافِيَتَكَ وَسِتْرَكَ فِي الدُّنْيَا وَالآخِرَةِ';

    final blessingsArabic = isMorning
        ? 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ'
        : 'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ';

    return [
      _entry(
        title: 'Surah Al-Fatihah',
        arabic: '''
بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ ﴿١﴾
ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ ﴿٢﴾
ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ ﴿٣﴾
مَٰلِكِ يَوۡمِ ٱلدِّينِ ﴿٤﴾
إِيَّاكَ نَعۡبُدُ وَإِيَّاكَ نَسۡتَعِينُ ﴿٥﴾
ٱهۡدِنَا ٱلصِّرَٰطَ ٱلۡمُسۡتَقِيمَ ﴿٦﴾
صِرَٰطَ ٱلَّذِينَ أَنۡعَمۡتَ عَلَيۡهِمۡ غَيۡرِ ٱلۡمَغۡضُوبِ عَلَيۡهِمۡ وَلَا ٱلضَّآلِّينَ ﴿٧﴾
''',
        transliteration: 'Recite the Arabic verses above.',
        translation: '''
(1) In the name of Allāh, the Entirely Merciful, the Especially Merciful.
(2) [All] praise is [due] to Allāh, Lord of the worlds -
(3) The Entirely Merciful, the Especially Merciful,
(4) Sovereign of the Day of Recompense.
(5) It is You we worship and You we ask for help.
(6) Guide us to the straight path -
(7) The path of those upon whom You have bestowed favor, not of those who have earned [Your] anger or of those who are astray.
        ''',
        repetitions: 1,
        source: 'QuranEnc API (english_saheeh): https://quranenc.com/api/v1/',
      ),
      _entry(
        title: 'Surah Al-Baqarah (1-5)',
        arabic: '''
الٓمٓ ﴿١﴾
ذَٰلِكَ ٱلۡكِتَٰبُ لَا رَيۡبَۛ فِيهِۛ هُدٗى لِّلۡمُتَّقِينَ ﴿٢﴾
ٱلَّذِينَ يُؤۡمِنُونَ بِٱلۡغَيۡبِ وَيُقِيمُونَ ٱلصَّلَوٰةَ وَمِمَّا رَزَقۡنَٰهُمۡ يُنفِقُونَ ﴿٣﴾
وَٱلَّذِينَ يُؤۡمِنُونَ بِمَآ أُنزِلَ إِلَيۡكَ وَمَآ أُنزِلَ مِن قَبۡلِكَ وَبِٱلۡأٓخِرَةِ هُمۡ يُوقِنُونَ ﴿٤﴾
أُوْلَٰٓئِكَ عَلَىٰ هُدٗى مِّن رَّبِّهِمۡۖ وَأُوْلَٰٓئِكَ هُمُ ٱلۡمُفۡلِحُونَ ﴿٥﴾
''',
        transliteration: 'Recite the Arabic verses above.',
        translation: '''
(1) Alif, Lām, Meem.
(2) This is the Book about which there is no doubt, a guidance for those conscious of Allāh -
(3) Who believe in the unseen, establish prayer, and spend out of what We have provided for them,
(4) And who believe in what has been revealed to you, [O Muḥammad], and what was revealed before you, and of the Hereafter they are certain [in faith].
(5) Those are upon [right] guidance from their Lord, and it is those who are the successful.
        ''',
        repetitions: 1,
        source: 'QuranEnc API (english_saheeh): https://quranenc.com/api/v1/',
      ),
      _entry(
        title: 'Ayatul Kursi (2:255)',
        arabic:
            'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ ﴿٢٥٥﴾',
        transliteration: 'Recite the Arabic verse above.',
        translation:
            '(255) Allāh - there is no deity except Him, the Ever-Living, the Self-Sustaining. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursī extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
        repetitions: 1,
        source: 'QuranEnc API (english_saheeh): https://quranenc.com/api/v1/',
      ),
      _entry(
        title: 'Surah Al-Baqarah (256-257)',
        arabic: '''
لَآ إِكۡرَاهَ فِي ٱلدِّينِۖ قَد تَّبَيَّنَ ٱلرُّشۡدُ مِنَ ٱلۡغَيِّۚ فَمَن يَكۡفُرۡ بِٱلطَّٰغُوتِ وَيُؤۡمِنۢ بِٱللَّهِ فَقَدِ ٱسۡتَمۡسَكَ بِٱلۡعُرۡوَةِ ٱلۡوُثۡقَىٰ لَا ٱنفِصَامَ لَهَاۗ وَٱللَّهُ سَمِيعٌ عَلِيمٌ ﴿٢٥٦﴾
ٱللَّهُ وَلِيُّ ٱلَّذِينَ ءَامَنُواْ يُخۡرِجُهُم مِّنَ ٱلظُّلُمَٰتِ إِلَى ٱلنُّورِۖ وَٱلَّذِينَ كَفَرُوٓاْ أَوۡلِيَآؤُهُمُ ٱلطَّٰغُوتُ يُخۡرِجُونَهُم مِّنَ ٱلنُّورِ إِلَى ٱلظُّلُمَٰتِۗ أُوْلَٰٓئِكَ أَصۡحَٰبُ ٱلنَّارِۖ هُمۡ فِيهَا خَٰلِدُونَ ﴿٢٥٧﴾
''',
        transliteration: 'Recite the Arabic verses above.',
        translation: '''
(256) There shall be no compulsion in [acceptance of] the religion. The right course has become distinct from the wrong. So whoever disbelieves in ṭāghūt and believes in Allāh has grasped the most trustworthy handhold with no break in it. And Allāh is Hearing and Knowing.
(257) Allāh is the Ally of those who believe. He brings them out from darknesses into the light. And those who disbelieve - their allies are ṭāghūt. They take them out of the light into darknesses. Those are the companions of the Fire; they will abide eternally therein.
        ''',
        repetitions: 1,
        source: 'QuranEnc API (english_saheeh): https://quranenc.com/api/v1/',
      ),
      _entry(
        title: 'Surah Al-Baqarah (284-286)',
        arabic: '''
لِّلَّهِ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ وَإِن تُبۡدُواْ مَا فِيٓ أَنفُسِكُمۡ أَوۡ تُخۡفُوهُ يُحَاسِبۡكُم بِهِ ٱللَّهُۖ فَيَغۡفِرُ لِمَن يَشَآءُ وَيُعَذِّبُ مَن يَشَآءُۗ وَٱللَّهُ عَلَىٰ كُلِّ شَيۡءٖ قَدِيرٌ ﴿٢٨٤﴾
ءَامَنَ ٱلرَّسُولُ بِمَآ أُنزِلَ إِلَيۡهِ مِن رَّبِّهِۦ وَٱلۡمُؤۡمِنُونَۚ كُلٌّ ءَامَنَ بِٱللَّهِ وَمَلَٰٓئِكَتِهِۦ وَكُتُبِهِۦ وَرُسُلِهِۦ لَا نُفَرِّقُ بَيۡنَ أَحَدٖ مِّن رُّسُلِهِۦۚ وَقَالُواْ سَمِعۡنَا وَأَطَعۡنَاۖ غُفۡرَانَكَ رَبَّنَا وَإِلَيۡكَ ٱلۡمَصِيرُ ﴿٢٨٥﴾
لَا يُكَلِّفُ ٱللَّهُ نَفۡسًا إِلَّا وُسۡعَهَاۚ لَهَا مَا كَسَبَتۡ وَعَلَيۡهَا مَا ٱكۡتَسَبَتۡۗ رَبَّنَا لَا تُؤَاخِذۡنَآ إِن نَّسِينَآ أَوۡ أَخۡطَأۡنَاۚ رَبَّنَا وَلَا تَحۡمِلۡ عَلَيۡنَآ إِصۡرٗا كَمَا حَمَلۡتَهُۥ عَلَى ٱلَّذِينَ مِن قَبۡلِنَاۚ رَبَّنَا وَلَا تُحَمِّلۡنَا مَا لَا طَاقَةَ لَنَا بِهِۦۖ وَٱعۡفُ عَنَّا وَٱغۡفِرۡ لَنَا وَٱرۡحَمۡنَآۚ أَنتَ مَوۡلَىٰنَا فَٱنصُرۡنَا عَلَى ٱلۡقَوۡمِ ٱلۡكَٰفِرِينَ ﴿٢٨٦﴾
''',
        transliteration: 'Recite the Arabic verses above.',
        translation: '''
(284) To Allāh belongs whatever is in the heavens and whatever is in the earth. Whether you show what is within yourselves or conceal it, Allāh will bring you to account for it. Then He will forgive whom He wills and punish whom He wills, and Allāh is over all things competent.
(285) The Messenger has believed in what was revealed to him from his Lord, and [so have] the believers. All of them have believed in Allāh and His angels and His books and His messengers, [saying], "We make no distinction between any of His messengers." And they say, "We hear and we obey. [We seek] Your forgiveness, our Lord, and to You is the [final] destination."
(286) Allāh does not charge a soul except [with that within] its capacity. It will have [the consequence of] what [good] it has gained, and it will bear [the consequence of] what [evil] it has earned. "Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us. Our Lord, and burden us not with that which we have no ability to bear. And pardon us; and forgive us; and have mercy upon us. You are our protector, so give us victory over the disbelieving people."
        ''',
        repetitions: 1,
        source: 'QuranEnc API (english_saheeh): https://quranenc.com/api/v1/',
      ),
      _entry(
        title: 'Surah Al-Ikhlas',
        arabic: '''
قُلۡ هُوَ ٱللَّهُ أَحَدٌ ﴿١﴾
ٱللَّهُ ٱلصَّمَدُ ﴿٢﴾
لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ﴿٣﴾
وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدُۢ ﴿٤﴾
''',
        transliteration: 'Recite the Arabic verses above.',
        translation: '''
(1) Say, "He is Allāh, [who is] One,
(2) Allāh, the Eternal Refuge.
(3) He neither begets nor is born,
(4) Nor is there to Him any equivalent."
        ''',
        repetitions: 3,
        source: 'QuranEnc API (english_saheeh): https://quranenc.com/api/v1/',
      ),
      _entry(
        title: 'Surah Al-Falaq',
        arabic: '''
قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ﴿١﴾
مِن شَرِّ مَا خَلَقَ ﴿٢﴾
وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿٣﴾
وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِي ٱلۡعُقَدِ ﴿٤﴾
وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴿٥﴾
''',
        transliteration: 'Recite the Arabic verses above.',
        translation: '''
(1) Say, "I seek refuge in the Lord of daybreak
(2) From the evil of that which He created
(3) And from the evil of darkness when it settles
(4) And from the evil of the blowers in knots
(5) And from the evil of an envier when he envies."
        ''',
        repetitions: 3,
        source: 'QuranEnc API (english_saheeh): https://quranenc.com/api/v1/',
      ),
      _entry(
        title: 'Surah An-Nas',
        arabic: '''
قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ﴿١﴾
مَلِكِ ٱلنَّاسِ ﴿٢﴾
إِلَٰهِ ٱلنَّاسِ ﴿٣﴾
مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ﴿٤﴾
ٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ ﴿٥﴾
مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ ﴿٦﴾
''',
        transliteration: 'Recite the Arabic verses above.',
        translation: '''
(1) Say, "I seek refuge in the Lord of mankind,
(2) The Sovereign of mankind,
(3) The God of mankind,
(4) From the evil of the retreating whisperer -
(5) Who whispers [evil] into the breasts of mankind -
(6) From among the jinn and mankind."
        ''',
        repetitions: 3,
        source: 'QuranEnc API (english_saheeh): https://quranenc.com/api/v1/',
      ),
      _entry(
        title: 'Praise of Allah (SWT)',
        arabic: entryDhikrArabic,
        transliteration: 'Recite the Arabic text above.',
        translation: isMorning
            ? 'We have entered the morning, and all dominion belongs to Allah. All praise is for Allah. He has no partner. There is no deity except Him, and to Him is the resurrection.'
            : 'We have entered the evening, and all dominion belongs to Allah. All praise is for Allah. He has no partner. There is no deity except Him, and to Him is the final return.',
        repetitions: 3,
        source:
            'Al-Ma\'thurat Sughra (JAKIM PDF p.30); cf. Hisn al-Muslim 77 (Muslim).',
      ),
      _entry(
        title: 'Steadfastness in Islam',
        arabic: fitrahArabic,
        transliteration: 'Recite the Arabic text above.',
        translation: isMorning
            ? 'We have entered the morning upon the fitrah of Islam, upon the word of sincerity, upon the religion of our Prophet Muhammad, and upon the creed of our father Ibrahim, upright and submitting, and he was not of the polytheists.'
            : 'We have entered the evening upon the fitrah of Islam, upon the word of sincerity, upon the religion of our Prophet Muhammad, and upon the creed of our father Ibrahim, upright and submitting, and he was not of the polytheists.',
        repetitions: 1,
        source: 'Hisn al-Muslim 90 (Ahmad and others).',
      ),
      _entry(
        title: 'Gratitude for Blessings',
        arabic: gratitudeArabic,
        transliteration: 'Recite the Arabic text above.',
        translation: isMorning
            ? 'O Allah, this morning I am in blessing, well-being, and covering from You; so complete upon me Your blessing, Your well-being, and Your covering in this world and the Hereafter.'
            : 'O Allah, this evening I am in blessing, well-being, and covering from You; so complete upon me Your blessing, Your well-being, and Your covering in this world and the Hereafter.',
        repetitions: 3,
        source:
            'Ibn al-Sunni, `Amal al-Yawm wa al-Laylah no. 55 (chain graded weak); used in Al-Ma\'thurat Sughra p.31.',
      ),
      _entry(
        title: 'Acknowledging All Blessings from Allah',
        arabic: blessingsArabic,
        transliteration: 'Recite the Arabic text above.',
        translation: isMorning
            ? 'O Allah, whatever blessing I or any of Your creation have reached this morning, it is from You alone, without partner. So to You belongs all praise and all thanks.'
            : 'O Allah, whatever blessing I or any of Your creation have reached this evening, it is from You alone, without partner. So to You belongs all praise and all thanks.',
        repetitions: 1,
        source: 'Hisn al-Muslim 81 (Abu Dawud 5073).',
      ),
      _entry(
        title: 'Praise Be to Allah',
        arabic:
            'يَا رَبِّ لَكَ الْحَمْدُ كَمَا يَنْبَغِي لِجَلَالِ وَجْهِكَ وَعَظِيمِ سُلْطَانِكَ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'My Lord, to You belongs all praise, as befits the majesty of Your Face and the greatness of Your authority.',
        repetitions: 1,
        source:
            'Sunan Ibn Majah 3801 (wording basis; graded weak by Darussalam).',
      ),
      _entry(
        title: 'Declaration',
        arabic:
            'رَضِيتُ بِاللَّهِ رَبًّا وَبِالإِسْلَامِ دِينًا وَبِمُحَمَّدٍ نَبِيًّا وَرَسُولًا',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad as my Prophet and Messenger.',
        repetitions: 3,
        source: 'Hisn al-Muslim 87 (al-Tirmidhi 3389; Ibn Majah 3870).',
      ),
      _entry(
        title: 'Glorifying Allah',
        arabic:
            'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'Glory and praise are to Allah by the number of His creation, by His pleasure, by the weight of His Throne, and by the ink of His words.',
        repetitions: 3,
        source: 'Hisn al-Muslim 94 (Sahih Muslim 2726).',
      ),
      _entry(
        title: 'Exalting the Name of Allah',
        arabic:
            'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'In the Name of Allah, with whose Name nothing in the earth or in the heaven can cause harm, and He is the All-Hearing, the All-Knowing.',
        repetitions: 3,
        source: 'Hisn al-Muslim 86 (Abu Dawud 5088; al-Tirmidhi 3388).',
      ),
      _entry(
        title: 'Protection from Shirk',
        arabic:
            'اللَّهُمَّ إِنَّا نَعُوذُ بِكَ مِنْ أَنْ نُشْرِكَ بِكَ شَيْئًا نَعْلَمُهُ وَنَسْتَغْفِرُكَ لِمَا لَا نَعْلَمُهُ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'O Allah, we seek refuge in You from knowingly associating anything with You, and we seek Your forgiveness for what we do not know.',
        repetitions: 3,
        source:
            'Hisn al-Muslim 203 (reported in al-Adab al-Mufrad 716 in singular form; Al-Ma\'thurat uses plural wording).',
      ),
      _entry(
        title: 'Protection from the Evil of Creation',
        arabic:
            'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'I seek refuge in the perfect words of Allah from the evil of what He has created.',
        repetitions: 3,
        source: 'Hisn al-Muslim 97 (Sahih Muslim 2708).',
      ),
      _entry(
        title: 'Protection from Debt Burden',
        arabic:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'O Allah, I seek refuge in You from anxiety and grief, from inability and laziness, from cowardice and miserliness, and from being overpowered by debt and by men.',
        repetitions: 3,
        source: 'Hisn al-Muslim 137 (Sahih al-Bukhari 6369).',
      ),
      _entry(
        title: 'Supplication for Health',
        arabic:
            'اللَّهُمَّ عَافِنِي فِي بَدَنِي اللَّهُمَّ عَافِنِي فِي سَمْعِي اللَّهُمَّ عَافِنِي فِي بَصَرِي',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'O Allah, grant me well-being in my body. O Allah, grant me well-being in my hearing. O Allah, grant me well-being in my sight.',
        repetitions: 1,
        source: 'Hisn al-Muslim 82 (Abu Dawud 5090).',
      ),
      _entry(
        title: 'Protection from Poverty',
        arabic:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ لَا إِلٰهَ إِلَّا أَنْتَ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'O Allah, I seek refuge in You from disbelief and poverty. O Allah, I seek refuge in You from the punishment of the grave. There is no deity except You.',
        repetitions: 3,
        source: 'Hisn al-Muslim 82 (Abu Dawud 5090).',
      ),
      _entry(
        title: 'Supplication for Forgiveness',
        arabic:
            'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلٰهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'O Allah, You are my Lord. There is no deity except You. You created me and I am Your servant, and I remain upon Your covenant and promise as best as I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me and I acknowledge my sin, so forgive me, for none forgives sins except You.',
        repetitions: 3,
        source: 'Sahih al-Bukhari 6306; Hisn al-Muslim 79.',
      ),
      _entry(
        title: 'Istighfar - Seeking Forgiveness',
        arabic:
            'أَسْتَغْفِرُ اللَّهَ الَّذِي لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'I seek forgiveness from Allah, besides whom there is no deity, the Ever-Living, the Sustainer, and I repent to Him.',
        repetitions: 3,
        source: 'Hisn al-Muslim 250 (Abu Dawud; al-Tirmidhi).',
      ),
      _entry(
        title: 'Salawat upon Prophet Muhammad (SAW)',
        arabic:
            'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى سَيِّدِنَا إِبْرَاهِيمَ وَعَلَى آلِ سَيِّدِنَا إِبْرَاهِيمَ وَبَارِكْ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى سَيِّدِنَا إِبْرَاهِيمَ وَعَلَى آلِ سَيِّدِنَا إِبْرَاهِيمَ فِي الْعَالَمِينَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'O Allah, send prayers upon our master Muhammad and upon the family of our master Muhammad, as You sent prayers upon our master Ibrahim and upon the family of our master Ibrahim; and bless our master Muhammad and the family of our master Muhammad, as You blessed our master Ibrahim and the family of our master Ibrahim. Truly, You are Praiseworthy and Glorious.',
        repetitions: 1,
        source:
            'Sahih al-Bukhari 6357 / Sahih Muslim 406 (Salat Ibrahimiyyah basis), with Al-Ma\'thurat wording variant.',
      ),
      _entry(
        title: 'All Praise Is for Allah',
        arabic:
            'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'Glory be to Allah, praise be to Allah, there is no deity except Allah, and Allah is the Greatest.',
        repetitions: 100,
        source: 'Sahih Muslim 2137a (the four most beloved statements).',
      ),
      _entry(
        title: 'Oneness of Allah',
        arabic:
            'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'There is no deity except Allah alone, without partner. To Him belongs dominion and to Him belongs praise, and He is over all things capable.',
        repetitions: 1,
        source: 'Hisn al-Muslim 92 (Sahih al-Bukhari and Sahih Muslim).',
      ),
      _entry(
        title: 'Praise and Repentance',
        arabic:
            'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا أَنْتَ أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'Glory and praise are Yours, O Allah. I testify that there is no deity except You. I seek Your forgiveness and repent to You.',
        repetitions: 1,
        source: 'Hisn al-Muslim 196 (Abu Dawud 4859; al-Tirmidhi 3433).',
      ),
      _entry(
        title: 'Salawat upon the Prophet',
        arabic:
            'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ عَبْدِكَ وَنَبِيِّكَ وَرَسُولِكَ النَّبِيِّ الْأُمِّيِّ وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ تَسْلِيمًا عَدَدَ مَا أَحَاطَ بِهِ عِلْمُكَ وَخَطَّ بِهِ قَلَمُكَ وَأَحْصَاهُ كِتَابُكَ\nوَارْضَ اللَّهُمَّ عَنْ سَادَاتِنَا أَبِي بَكْرٍ وَعُمَرَ وَعُثْمَانَ وَعَلِيٍّ وَعَنِ الصَّحَابَةِ أَجْمَعِينَ وَعَنِ التَّابِعِينَ وَتَابِعِيهِمْ بِإِحْسَانٍ إِلَى يَوْمِ الدِّينِ\nسُبْحَانَ رَبِّكَ رَبِّ الْعِزَّةِ عَمَّا يَصِفُونَ وَسَلَامٌ عَلَى الْمُرْسَلِينَ وَالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        transliteration: 'Recite the Arabic text above.',
        translation:
            'O Allah, send prayers upon our master Muhammad, Your servant, Your Prophet, and Your unlettered Messenger, and upon his family and companions, and grant abundant peace, by the number of what Your knowledge has encompassed, what Your pen has written, and what Your Book has counted. O Allah, be pleased with our masters Abu Bakr, Umar, Uthman, Ali, all companions, and the followers and those who follow them with excellence until the Day of Judgment. Glory be to Your Lord, Lord of Might, above what they describe. Peace be upon the messengers. And all praise is for Allah, Lord of the worlds.',
        repetitions: 1,
        source:
            'Al-Ma\'thurat Sughra (JAKIM PDF p.38-39); direct Arabic-to-English translation.',
      ),
    ];
  }

  static Map<String, dynamic> _entry({
    required String title,
    required String arabic,
    required String transliteration,
    required String translation,
    required int repetitions,
    String? source,
  }) {
    return {
      'title': title,
      'arabic': arabic,
      'transliteration': transliteration,
      'translation': translation,
      'repetitions': repetitions,
      'source': ?source,
    };
  }
}
