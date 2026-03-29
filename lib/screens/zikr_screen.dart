import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/zikr_model.dart';
import '../services/zikr_service.dart';

class ZikrScreen extends StatefulWidget {
  const ZikrScreen({super.key});

  @override
  State<ZikrScreen> createState() => _ZikrScreenState();
}

class _ZikrScreenState extends State<ZikrScreen>
    with SingleTickerProviderStateMixin {
  final List<ZikrModel> _zikrList = const [
    ZikrModel(id: 'subhanallah', arabic: 'سُبْحَانَ ٱللَّٰه', english: 'SubhanAllah'),
    ZikrModel(id: 'alhamdulillah', arabic: 'ٱلْحَمْدُ لِلَّٰه', english: 'Alhamdulillah'),
    ZikrModel(id: 'allahuakbar', arabic: 'ٱللَّٰهُ أَكْبَر', english: 'Allahu Akbar'),
    ZikrModel(id: 'astaghfirullah', arabic: 'أَسْتَغْفِرُ ٱللَّٰه', english: 'Astaghfirullah'),
    ZikrModel(id: 'lailahaillallah', arabic: 'لَا إِلَٰهَ إِلَّا ٱللَّٰه', english: 'La ilaha illallah'),
    ZikrModel(id: 'other', arabic: '—', english: 'Other'),
  ];

  late ZikrModel _currentZikr;
  int _count = 0;
  int _target = 33;
  bool _completed = false;
  bool _loading = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(_pulseController);
    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final savedCount = await ZikrService.loadCount();
    final savedZikrId = await ZikrService.loadZikrId();
    final savedTarget = await ZikrService.loadTarget();

    setState(() {
      _count = savedCount;
      _target = savedTarget;
      _completed = _count >= _target;
      _currentZikr = _zikrList.firstWhere(
            (z) => z.id == savedZikrId,
        orElse: () => _zikrList.first,
      );
      _loading = false;
    });
  }

  void _increment() {
    if (_completed) return;
    _pulseController.forward(from: 0);
    setState(() {
      _count++;
      if (_count >= _target) {
        _completed = true;
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    });
    ZikrService.saveCount(_count);
  }

  void _reset() {
    setState(() {
      _count = 0;
      _completed = false;
    });
    HapticFeedback.heavyImpact();
    ZikrService.reset();
  }

  void _changeZikr(ZikrModel zikr) {
    setState(() {
      _currentZikr = zikr;
      _count = 0;
      _completed = false;
    });
    ZikrService.saveZikrId(zikr.id);
    ZikrService.reset();
  }

  void _editTarget() async {
    final controller = TextEditingController(text: _target.toString());
    final newValue = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Target Count"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newValue != null && newValue > 0) {
      setState(() {
        _target = newValue;
        _completed = _count >= _target;
      });
      ZikrService.saveTarget(_target);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dhikr Counter", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white54,
        foregroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // colors: [Color(0xFF102027), Color(0xFF1E3C45), Color(0xFF2E5964)],
            colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
             begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder( // ⭐ Added LayoutBuilder to handle dynamic heights
            builder: (context, constraints) {
              return SingleChildScrollView( // ⭐ Added scrolling to prevent 85px overflow
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Arabic Text
                          Text(
                            _currentZikr.arabic,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 38, // Slightly reduced to save space
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Dropdown
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: DropdownButtonFormField<ZikrModel>(
                              value: _currentZikr,
                              isExpanded: true, // Prevents horizontal overflow
                              dropdownColor: const Color(0xFFE0E0E0),
                              style: const TextStyle(color: Colors.black54, fontSize: 18),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.tealAccent, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
                                ),
                              ),
                              items: _zikrList.map((z) => DropdownMenuItem(
                                value: z,
                                child: Text(z.english, overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (value) {
                                if (value != null) _changeZikr(value);
                              },
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Target Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Set Target:", style: TextStyle(color: Colors.black54)),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _editTarget,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.lightGreen,

                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _target.toString(),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Counter Button (Responsive Size)
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: GestureDetector(
                              onTap: _increment,
                              child: Container(
                                width: constraints.maxWidth * 0.45, // Responsive width
                                height: constraints.maxWidth * 0.45, // Responsive height
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _completed ? Colors.greenAccent : Colors.teal.withOpacity(0.3),
                                      blurRadius: 5,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _count.toString(),
                                      style: TextStyle(
                                          fontSize: constraints.maxWidth * 0.12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal
                                      ),
                                    ),
                                    if (_completed)
                                      const Icon(Icons.check_circle, color: Colors.green, size: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Reset
                          TextButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.refresh, color: Colors.black45),
                            label: const Text("Reset Counter", style: TextStyle(color: Colors.black45)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}