import 'package:flutter/material.dart';

enum EisenhowerQuadrant {
  urgentImportant,     // هام وعاجل
  notUrgentImportant,  // هام وغير عاجل
  urgentNotImportant,  // عاجل وغير هام
  notUrgentNotImportant // غير هام وغير عاجل
}

class ScheduledTask {
  final String id;
  final String title;
  final String category; // جامعة، مشروع تخرج، شغل، برمجة، ثندر، كنيسة
  final EisenhowerQuadrant quadrant;
  final int estimatedMinutes;
  int actualMinutes;
  bool isCompleted;
  DateTime scheduledStart;
  DateTime scheduledEnd;

  ScheduledTask({
    required this.id,
    required this.title,
    required this.category,
    required this.quadrant,
    required this.estimatedMinutes,
    this.actualMinutes = 0,
    this.isCompleted = false,
    required this.scheduledStart,
    required this.scheduledEnd,
  });
}

class EisenhowerScreen extends StatefulWidget {
  const EisenhowerScreen({super.key});

  @override
  State<EisenhowerScreen> createState() => _EisenhowerScreenState();
}

class _EisenhowerScreenState extends State<EisenhowerScreen> {
  final List<ScheduledTask> _tasks = [];
  int _activeQuadrantTab = 0; // 0: All, 1: Q1, 2: Q2, 3: Q3, 4: Q4

  // Smart break reminder
  String? _suggestedBreakActivity;
  int _savedMinutesToday = 0;

  @override
  void initState() {
    super.initState();
    _initDefaultTasks();
  }

  void _initDefaultTasks() {
    final now = DateTime.now();
    _tasks.addAll([
      ScheduledTask(
        id: '1',
        title: 'تسليم فيتشر الباك إند لمشروع التخرج (CS)',
        category: 'مشروع التخرج',
        quadrant: EisenhowerQuadrant.urgentImportant,
        estimatedMinutes: 60,
        scheduledStart: now.add(const Duration(minutes: 10)),
        scheduledEnd: now.add(const Duration(minutes: 70)),
      ),
      ScheduledTask(
        id: '2',
        title: 'صلاة الساعة الثالثة بالأجبية والتأمل في مزمور',
        category: 'خدمة وكنيسة',
        quadrant: EisenhowerQuadrant.notUrgentImportant,
        estimatedMinutes: 15,
        scheduledStart: now.add(const Duration(minutes: 80)),
        scheduledEnd: now.add(const Duration(minutes: 95)),
      ),
      ScheduledTask(
        id: '3',
        title: 'مراجعة أداء محفظة Thndr وسهم EFG Hermes',
        category: 'استثمار Thndr',
        quadrant: EisenhowerQuadrant.notUrgentImportant,
        estimatedMinutes: 20,
        scheduledStart: now.add(const Duration(minutes: 100)),
        scheduledEnd: now.add(const Duration(minutes: 120)),
      ),
      ScheduledTask(
        id: '4',
        title: 'حل مشكلة في كود الـ State Management بشركة العمل',
        category: 'شغل وبرمجة',
        quadrant: EisenhowerQuadrant.urgentImportant,
        estimatedMinutes: 45,
        scheduledStart: now.add(const Duration(minutes: 130)),
        scheduledEnd: now.add(const Duration(minutes: 175)),
      ),
    ]);
  }

  // Real-time Dynamic Rescheduling Logic
  void _completeTaskEarly(ScheduledTask task, int minutesSpent) {
    setState(() {
      task.isCompleted = true;
      task.actualMinutes = minutesSpent;
      final savedMinutes = task.estimatedMinutes - minutesSpent;

      if (savedMinutes > 0) {
        _savedMinutesToday += savedMinutes;

        // Auto reschedule remaining tasks forward by savedMinutes
        final taskIndex = _tasks.indexOf(task);
        for (int i = taskIndex + 1; i < _tasks.length; i++) {
          final nextTask = _tasks[i];
          if (!nextTask.isCompleted) {
            nextTask.scheduledStart = nextTask.scheduledStart.subtract(Duration(minutes: savedMinutes));
            nextTask.scheduledEnd = nextTask.scheduledEnd.subtract(Duration(minutes: savedMinutes));
          }
        }

        // Recommend smart break
        if (savedMinutes >= 15) {
          _suggestedBreakActivity = '🌟 وفّرت $savedMinutes دقيقة! وقت مثالي لصلاة الأجبية (صلاة الساعة الثالثة أو السادسة) وشرب كوب ماء لصفاء ذهنك.';
        } else {
          _suggestedBreakActivity = '🌟 وفّرت $savedMinutes دقيقة! وقت استراحة 5 دقائق لتمارين التمدد وإراحة عينيك من الشاشة.';
        }
      }
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    EisenhowerQuadrant selectedQuad = EisenhowerQuadrant.urgentImportant;
    String selectedCat = 'مشروع التخرج';
    int minutes = 30;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text('إضافة مهمة ذكية في مصفوفة أيزنهاور', style: TextStyle(color: Colors.white, fontSize: 15)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'عنوان المهمة (مثال: كود الـ API لـ Thndr)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('المجال:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  DropdownButton<String>(
                    value: selectedCat,
                    dropdownColor: const Color(0xFF1E293B),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
                    items: ['مشروع التخرج', 'جامعة وحاسبات', 'شغل وبرمجة', 'استثمار Thndr', 'خدمة وكنيسة']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedCat = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('تصنيف أيزنهاور:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  DropdownButton<EisenhowerQuadrant>(
                    value: selectedQuad,
                    dropdownColor: const Color(0xFF1E293B),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.amber, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: EisenhowerQuadrant.urgentImportant, child: Text('🟥 عاجل وهام (Do First)')),
                      DropdownMenuItem(value: EisenhowerQuadrant.notUrgentImportant, child: Text('🟦 غير عاجل وهام (Schedule)')),
                      DropdownMenuItem(value: EisenhowerQuadrant.urgentNotImportant, child: Text('🟨 عاجل وغير هام (Delegate)')),
                      DropdownMenuItem(value: EisenhowerQuadrant.notUrgentNotImportant, child: Text('🟩 غير عاجل وغير هام (Eliminate)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedQuad = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المدة المقدرة:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('$minutes دقيقة', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: minutes.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    activeColor: Colors.blueAccent,
                    onChanged: (val) => setModalState(() => minutes = val.toInt()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    final now = DateTime.now();
                    setState(() {
                      _tasks.add(ScheduledTask(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text.trim(),
                        category: selectedCat,
                        quadrant: selectedQuad,
                        estimatedMinutes: minutes,
                        scheduledStart: now,
                        scheduledEnd: now.add(Duration(minutes: minutes)),
                      ));
                    });
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text('إضافة المهمة', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getQuadrantColor(EisenhowerQuadrant q) {
    switch (q) {
      case EisenhowerQuadrant.urgentImportant:
        return const Color(0xFFEF4444); // Red
      case EisenhowerQuadrant.notUrgentImportant:
        return const Color(0xFF3B82F6); // Blue
      case EisenhowerQuadrant.urgentNotImportant:
        return const Color(0xFFF59E0B); // Amber
      case EisenhowerQuadrant.notUrgentNotImportant:
        return const Color(0xFF10B981); // Green
    }
  }

  String _getQuadrantTitle(EisenhowerQuadrant q) {
    switch (q) {
      case EisenhowerQuadrant.urgentImportant:
        return 'عاجل وهام (Do First)';
      case EisenhowerQuadrant.notUrgentImportant:
        return 'غير عاجل وهام (Schedule)';
      case EisenhowerQuadrant.urgentNotImportant:
        return 'عاجل وغير هام (Delegate)';
      case EisenhowerQuadrant.notUrgentNotImportant:
        return 'غير عاجل وغير هام (Eliminate)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF090D16),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          title: const Row(
            children: [
              Icon(Icons.grid_view_rounded, color: Colors.blueAccent, size: 22),
              SizedBox(width: 8),
              Text(
                'مدير المهام الديناميكي (أيزنهاور)',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
              onPressed: _showAddTaskDialog,
              tooltip: 'إضافة مهمة',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saved Time & Dynamic Rescheduling Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x333B82F6), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x663B82F6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_mode_rounded, color: Colors.blueAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الجدولة الحية وإعادة الترتيب التلقائي (Real-Time)',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _savedMinutesToday > 0
                                ? 'أنت سابق جدولك بـ $_savedMinutesToday دقيقة اليوم! تم تقديم باقي المهام تلقائياً.'
                                : 'عند إتمام أي مهمة قبل وقتها، يُعاد ترتيب باقي مهام اليوم وتوليد فترات راحة وصلاة بالأجبية.',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Smart Break Activity (If triggered)
              if (_suggestedBreakActivity != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.church_rounded, color: Colors.greenAccent, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _suggestedBreakActivity!,
                          style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _suggestedBreakActivity = null),
                        icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Quadrants Matrix Grid (Mini Visualizer)
              const Text(
                'مصفوفة أيزنهاور الرباعية:',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniQuadCard(
                      '🟥 عاجل وهام',
                      _tasks.where((t) => t.quadrant == EisenhowerQuadrant.urgentImportant).length,
                      const Color(0xFFEF4444),
                      1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniQuadCard(
                      '🟦 غير عاجل وهام',
                      _tasks.where((t) => t.quadrant == EisenhowerQuadrant.notUrgentImportant).length,
                      const Color(0xFF3B82F6),
                      2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniQuadCard(
                      '🟨 عاجل وغير هام',
                      _tasks.where((t) => t.quadrant == EisenhowerQuadrant.urgentNotImportant).length,
                      const Color(0xFFF59E0B),
                      3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniQuadCard(
                      '🟩 غير عاجل وغير هام',
                      _tasks.where((t) => t.quadrant == EisenhowerQuadrant.notUrgentNotImportant).length,
                      const Color(0xFF10B981),
                      4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tasks List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المهام المجدولة اليوم (${_tasks.length})',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showAddTaskDialog,
                    icon: const Icon(Icons.add, size: 16, color: Colors.blueAccent),
                    label: const Text('مهمة جديدة', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                  ),
                ],
              ),
              // Task Cards
              ..._tasks.where((t) {
                if (_activeQuadrantTab == 1) return t.quadrant == EisenhowerQuadrant.urgentImportant;
                if (_activeQuadrantTab == 2) return t.quadrant == EisenhowerQuadrant.notUrgentImportant;
                if (_activeQuadrantTab == 3) return t.quadrant == EisenhowerQuadrant.urgentNotImportant;
                if (_activeQuadrantTab == 4) return t.quadrant == EisenhowerQuadrant.notUrgentNotImportant;
                return true;
              }).map((task) {
                final color = _getQuadrantColor(task.quadrant);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: task.isCompleted ? Colors.greenAccent.withValues(alpha: 0.3) : color.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getQuadrantTitle(task.quadrant),
                              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.category,
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.title,
                        style: TextStyle(
                          color: task.isCompleted ? Colors.white38 : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.white38, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${task.estimatedMinutes} دقيقة',
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                          if (!task.isCompleted) ...[
                            ElevatedButton.icon(
                              onPressed: () {
                                // Simulate finishing early (e.g. half duration)
                                final spent = (task.estimatedMinutes * 0.6).toInt();
                                _completeTaskEarly(task, spent);
                              },
                              icon: const Icon(Icons.check, size: 14, color: Colors.black),
                              label: const Text('أنهيت بدري', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: const Size(60, 30),
                              ),
                            ),
                          ] else ...[
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                                SizedBox(width: 4),
                                Text('مكتملة', style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniQuadCard(String label, int count, Color color, int quadId) {
    final isSelected = _activeQuadrantTab == quadId;
    return InkWell(
      onTap: () {
        setState(() {
          _activeQuadrantTab = isSelected ? 0 : quadId;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
