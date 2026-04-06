import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dua_model.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState(); // Fixed name
}

class _DuaScreenState extends State<DuaScreen> { // Fixed: only one underscore
  String _searchQuery = "";
  static const List<DuaModel> _duas = [
    // 🌙 Ramadan / Existing
    DuaModel(id: 'suhoor', title: 'Suhoor (Starting Fast)', arabic: 'وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ', english: 'I intend to keep the fast for tomorrow in the month of Ramadan.'),
    DuaModel(id: 'iftar', title: 'Iftar (Breaking Fast)', arabic: 'اللَّهُمَّ لَكَ صُمْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ', english: 'O Allah, I fasted for You and I break my fast with Your sustenance.'),
    DuaModel(id: 'laylatul_qadr', title: 'Laylatul Qadr', arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي', english: 'O Allah, You are Most Forgiving and You love forgiveness, so forgive me.'),

    // 🌅 Daily Duas
    DuaModel(id: 'morning', title: 'Morning Dua', arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا', english: 'O Allah, by You we enter the morning and by You we enter the evening.'),
    DuaModel(id: 'evening', title: 'Evening Dua', arabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ نَحْيَا', english: 'O Allah, by You we enter the evening and by You we live.'),

    // 😴 Sleep
    DuaModel(id: 'sleep', title: 'Before Sleep', arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', english: 'In Your name O Allah, I die and I live.'),
    DuaModel(id: 'wakeup', title: 'After Waking Up', arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا', english: 'All praise is for Allah who gave us life after causing us to die.'),

    // 🍽 Food
    DuaModel(id: 'before_eating', title: 'Before Eating', arabic: 'بِسْمِ اللَّهِ', english: 'In the name of Allah.'),
    DuaModel(id: 'after_eating', title: 'After Eating', arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا', english: 'All praise is for Allah who fed us and gave us drink.'),

    // 🏠 Home
    DuaModel(id: 'enter_home', title: 'Entering Home', arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ', english: 'O Allah, I ask You for the best entrance and the best exit.'),
    DuaModel(id: 'leave_home', title: 'Leaving Home', arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ', english: 'In the name of Allah, I place my trust in Allah.'),

    // 🕌 Masjid
    DuaModel(id: 'enter_masjid', title: 'Entering Masjid', arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ', english: 'O Allah, open for me the doors of Your mercy.'),
    DuaModel(id: 'leave_masjid', title: 'Leaving Masjid', arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ', english: 'O Allah, I ask You from Your فضل (bounty).'),

    // ✈️ Travel
    DuaModel(id: 'travel', title: 'Travel Dua', arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ', english: 'Glory is to Him who has subjected this to us, and we could not have done it ourselves.'),

    // 🤲 Core Duas
    DuaModel(id: 'forgiveness', title: 'Seeking Forgiveness', arabic: 'أَسْتَغْفِرُ اللَّهَ', english: 'I seek forgiveness from Allah.'),
    DuaModel(id: 'protection', title: 'Protection', arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ', english: 'I seek refuge in the perfect words of Allah.'),
    DuaModel(id: 'parents', title: 'Dua for Parents', arabic: 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا', english: 'My Lord, have mercy upon them as they brought me up when I was small.'),
    DuaModel(id: 'knowledge', title: 'Seeking Knowledge', arabic: 'رَّبِّ زِدْنِي عِلْمًا', english: 'My Lord, increase me in knowledge.'),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDuas = _duas.where((dua) {
      final query = _searchQuery.toLowerCase();
      return dua.title.toLowerCase().contains(query) ||
          dua.english.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean White/Grey Background
      appBar: AppBar(
        title: const Text("Daily Duas", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search for a dua...",
                    hintStyle: const TextStyle(color: Colors.black38),
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // 📜 LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredDuas.length,
                itemBuilder: (context, index) {
                  return _duaCard(filteredDuas[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _duaCard(DuaModel dua) {
    bool isRamadan = ['suhoor', 'iftar', 'laylatul_qadr'].contains(dua.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRamadan ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
          width: isRamadan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isRamadan ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dua.title,
                  style: TextStyle(
                    color: isRamadan ? Colors.green.shade700 : Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.copy_rounded, color: Colors.black26, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "${dua.arabic}\n\n${dua.english}"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied"), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              dua.arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.redAccent, // Red Arabic Text
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dua.english,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}