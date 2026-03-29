import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final Map<String, Map<String, String>> islamicEvents = {
    "1-1": {
      "title": "Islamic New Year",
      "description":
      "The beginning of the new Hijri year. A time for reflection, gratitude, and new intentions."
    },
    "1-10": {
      "title": "Day of Ashura",
      "description":
      "A blessed day in Muharram. Many Muslims fast on this day following the Sunnah."
    },
    "3-12": {
      "title": "Mawlid al-Nabi",
      "description":
      "A day remembered by many Muslims as the birth of Prophet Muhammad ﷺ."
    },
    "7-27": {
      "title": "Isra and Mi'raj",
      "description":
      "The miraculous Night Journey and Ascension of Prophet Muhammad ﷺ."
    },
    "8-15": {
      "title": "Mid-Sha'ban",
      "description":
      "A spiritually important night before Ramadan, observed by many with prayer and reflection."
    },
    "9-1": {
      "title": "Beginning of Ramadan",
      "description":
      "The start of the holy month of fasting, mercy, Qur'an, and worship."
    },
    "9-27": {
      "title": "Laylat al-Qadr",
      "description":
      "The Night of Power — one of the holiest nights in Islam, better than a thousand months."
    },
    "10-1": {
      "title": "Eid al-Fitr",
      "description":
      "The blessed festival celebrating the end of Ramadan."
    },
    "12-8": {
      "title": "Day of Tarwiyah",
      "description":
      "A significant day during the days of Hajj."
    },
    "12-9": {
      "title": "Day of Arafah",
      "description":
      "One of the most important days in Islam. Fasting this day is highly recommended for non-pilgrims."
    },
    "12-10": {
      "title": "Eid al-Adha",
      "description":
      "The Festival of Sacrifice, celebrated during the days of Hajj."
    },
    "12-11": {
      "title": "Tashreeq Days",
      "description":
      "Blessed days following Eid al-Adha."
    },
    "12-12": {
      "title": "Tashreeq Days",
      "description":
      "Blessed days following Eid al-Adha."
    },
    "12-13": {
      "title": "Tashreeq Days",
      "description":
      "Blessed days following Eid al-Adha."
    },
  };

  final List<Map<String, String>> holyMonths = [
    {
      "name": "Muharram",
      "desc": "The first month of the Islamic year and one of the sacred months."
    },
    {
      "name": "Rajab",
      "desc": "A sacred month known for increased worship and reflection."
    },
    {
      "name": "Sha'ban",
      "desc": "The month before Ramadan, a time for spiritual preparation."
    },
    {
      "name": "Ramadan",
      "desc": "The holiest month of fasting, prayer, mercy, and Qur'an."
    },
    {
      "name": "Shawwal",
      "desc": "The month of Eid al-Fitr and the six recommended fasts."
    },
    {
      "name": "Dhul-Hijjah",
      "desc": "The month of Hajj, Arafah, and Eid al-Adha."
    },
  ];

  final List<Map<String, String>> holyNights = [
    {
      "date": "27 Rajab",
      "title": "Isra and Mi'raj",
      "desc": "The Night Journey of Prophet Muhammad ﷺ."
    },
    {
      "date": "15 Sha'ban",
      "title": "Mid-Sha'ban",
      "desc": "A spiritually important night before Ramadan."
    },
    {
      "date": "27 Ramadan",
      "title": "Laylat al-Qadr",
      "desc": "The Night of Power, better than a thousand months."
    },
  ];

  String getHijriMonthName(int month) {
    const months = [
      "Muharram",
      "Safar",
      "Rabi' al-Awwal",
      "Rabi' al-Thani",
      "Jumada al-Awwal",
      "Jumada al-Thani",
      "Rajab",
      "Sha'ban",
      "Ramadan",
      "Shawwal",
      "Dhul-Qa'dah",
      "Dhul-Hijjah",
    ];
    return months[month - 1];
  }

  bool isFriday(DateTime day) => day.weekday == DateTime.friday;

  bool isRamadan(DateTime day) {
    final hijri = HijriCalendar.fromDate(day);
    return hijri.hMonth == 9;
  }

  Map<String, String>? getIslamicEvent(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final key = "${hijri.hMonth}-${hijri.hDay}";
    return islamicEvents[key];
  }

  String getTodayInIslamMessage(HijriCalendar hijri) {
    switch (hijri.hMonth) {
      case 1:
        return "Muharram is one of the sacred months in Islam.";
      case 7:
        return "Rajab is a sacred month for reflection and worship.";
      case 8:
        return "Sha'ban is the month of preparation before Ramadan.";
      case 9:
        return "Ramadan is the month of fasting, mercy, and Qur'an.";
      case 10:
        return "Shawwal begins with Eid al-Fitr and includes six Sunnah fasts.";
      case 12:
        return "Dhul-Hijjah is the month of Hajj, Arafah, and Eid al-Adha.";
      default:
        return "Every day is a chance to remember Allah and increase in worship.";
    }
  }

  List<Map<String, dynamic>> getUpcomingIslamicEvents() {
    final today = DateTime.now();
    final List<Map<String, dynamic>> upcoming = [];

    for (final entry in islamicEvents.entries) {
      final parts = entry.key.split('-');
      final hMonth = int.parse(parts[0]);
      final hDay = int.parse(parts[1]);

      DateTime? foundDate;

      for (int i = 0; i < 400; i++) {
        final date = today.add(Duration(days: i));
        final hijri = HijriCalendar.fromDate(date);

        if (hijri.hMonth == hMonth && hijri.hDay == hDay) {
          foundDate = date;
          break;
        }
      }

      if (foundDate != null) {
        upcoming.add({
          "title": entry.value["title"],
          "description": entry.value["description"],
          "date": foundDate,
          "daysLeft": foundDate.difference(today).inDays,
        });
      }
    }

    upcoming.sort((a, b) => a["date"].compareTo(b["date"]));

    return upcoming.take(3).toList();
  }

  void showEventPopup(BuildContext context, DateTime day) {
    final event = getIslamicEvent(day);
    if (event == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              event["title"] == "Laylat al-Qadr"
                  ? Icons.auto_awesome
                  : Icons.star,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                event["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          event["description"]!,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hijriSelected = HijriCalendar.fromDate(_selectedDay);
    final selectedEvent = getIslamicEvent(_selectedDay);
    final upcomingEvents = getUpcomingIslamicEvents();
    final screenWidth = MediaQuery.of(context).size.width;
    final holyNightCardWidth = screenWidth < 380 ? 220.0 : 245.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("Islamic Calendar"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),

              // Top Selected Date Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mosque, color: Colors.white, size: 34),
                      const SizedBox(height: 10),
                      Text(
                        "${hijriSelected.hDay} ${getHijriMonthName(hijriSelected.hMonth)} ${hijriSelected.hYear} AH",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat("EEEE, MMMM d, y").format(_selectedDay),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14.5,
                        ),
                      ),
                      if (selectedEvent != null) ...[
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => showEventPopup(context, _selectedDay),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selectedEvent["title"] == "Laylat al-Qadr"
                                      ? Icons.auto_awesome
                                      : Icons.star,
                                  color: Colors.amberAccent,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedEvent["title"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Today in Islam
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb, color: Colors.green),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today in Islam",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              getTodayInIslamMessage(hijriSelected),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      rowHeight: 58,
                      daysOfWeekHeight: 26,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });

                        final event = getIslamicEvent(selectedDay);
                        if (event != null) {
                          Future.delayed(const Duration(milliseconds: 180), () {
                            if (mounted) {
                              showEventPopup(context, selectedDay);
                            }
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronPadding: const EdgeInsets.all(8),
                        rightChevronPadding: const EdgeInsets.all(8),
                        titleTextFormatter: (date, locale) {
                          final hijri = HijriCalendar.fromDate(date);
                          return "${DateFormat("MMMM y").format(date)} • ${getHijriMonthName(hijri.hMonth)}";
                        },
                      ),
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        cellMargin: EdgeInsets.all(2),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final hijri = HijriCalendar.fromDate(day);
                          final event = getIslamicEvent(day);
                          final friday = isFriday(day);
                          final ramadan = isRamadan(day);

                          return Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: ramadan
                                  ? Colors.orange.shade50
                                  : friday
                                  ? Colors.green.shade50
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: event != null
                                  ? Border.all(
                                  color: Colors.orange, width: 1.3)
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: friday
                                              ? Colors.green.shade800
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${hijri.hDay}',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (event != null)
                                  Positioned(
                                    bottom: 5,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: event["title"] ==
                                              "Laylat al-Qadr"
                                              ? Colors.amber
                                              : Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (event?["title"] == "Laylat al-Qadr")
                                  const Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 12,
                                      color: Colors.amber,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          final hijri = HijriCalendar.fromDate(day);
                          return Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${hijri.hDay}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          final hijri = HijriCalendar.fromDate(day);
                          return Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade200,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${hijri.hDay}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Holy Nights
              _sectionTitle("Holy Nights"),
              SizedBox(
                height: 185,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: holyNights.length,
                  itemBuilder: (context, index) {
                    final item = holyNights[index];
                    return Container(
                      width: holyNightCardWidth,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.nightlight_round,
                              color: Colors.deepOrange),
                          const SizedBox(height: 10),
                          Text(
                            item["title"]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item["desc"]!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item["date"]!,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // Upcoming Islamic Events
              _sectionTitle("Upcoming Islamic Events"),
              ListView.builder(
                itemCount: upcomingEvents.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final item = upcomingEvents[index];
                  final eventDate = item["date"] as DateTime;
                  final daysLeft = item["daysLeft"] as int;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.event_available,
                              color: Colors.orange),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["description"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13.8,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat("MMMM d, y").format(eventDate),
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            daysLeft == 0 ? "Today" : "$daysLeft d",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              // Holy Months
              _sectionTitle("Holy Months"),
              ListView.builder(
                itemCount: holyMonths.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final month = holyMonths[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mosque, color: Colors.green),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                month["name"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                month["desc"]!,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13.8,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}