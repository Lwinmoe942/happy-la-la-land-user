import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import 'widgets.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late DateTime _day;
  late TimeOfDay _time;
  int _children = 0;
  int _adults = 0;
  List<TimeSlot> _slots = const [];

  int get _people => _children + _adults;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
    final hour = now.hour < 9 ? 9 : (now.hour > 17 ? 17 : now.hour);
    _time = TimeOfDay(hour: hour, minute: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    try {
      final slots = await context.read<AppState>().slotsOn(_day);
      if (!mounted) {
        return;
      }
      setState(() => _slots = slots);
    } catch (_) {}
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: today,
      lastDate: today.add(const Duration(days: 13)),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _day = DateTime(picked.year, picked.month, picked.day));
    await _load();
  }

  Future<void> _pickTime() async {
    final settings = context.read<AppState>().settings;
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null || !mounted) {
      return;
    }
    if (picked.hour < settings.openHour || picked.hour >= settings.closeHour) {
      showAppMessage(
        context,
        'ဖွင့်ချိန် ${mmDigits(settings.openHour, 2)}:၀၀ ကနေ ${mmDigits(settings.closeHour, 2)}:၀၀ အထိ ရွေးပါ',
      );
      return;
    }
    setState(() => _time = TimeOfDay(hour: picked.hour, minute: 0));
  }

  TimeSlot? _matchingSlot() {
    for (final slot in _slots) {
      if (slot.startsAt.hour == _time.hour && slot.startsAt.minute == 0) {
        return slot;
      }
    }
    return null;
  }

  Future<void> _confirm() async {
    final slot = _matchingSlot();
    if (slot == null) {
      showAppMessage(context, 'ဒီအချိန်ကို ယူလို့ မရပါ');
      return;
    }
    final when = DateTime(_day.year, _day.month, _day.day, _time.hour);
    try {
      await context.read<AppState>().book(
        slotId: slot.id,
        children: _children,
        adults: _adults,
      );
      if (!mounted) {
        return;
      }
      showAppMessage(context, '${mmDate(when)} ${mmTime(when)} စာရင်း ယူပြီးပါပြီ');
    } catch (error) {
      if (mounted) {
        showAppMessage(context, error);
      }
    }
  }

  Future<void> _cancel(Booking booking) async {
    final ok = await confirmAction(
      context,
      title: 'စာရင်း ပယ်ဖျက်မလား',
      body:
          '${mmDateTime(booking.startsAt)} · ကလေး ${mmInt(booking.children)} · လူကြီး ${mmInt(booking.adults)} · ဦးရေ ${mmInt(booking.people)}',
      confirmLabel: 'ပယ်ဖျက်မယ်',
    );
    if (!ok || !mounted) {
      return;
    }
    try {
      await context.read<AppState>().cancel(booking.id);
    } catch (error) {
      if (mounted) {
        showAppMessage(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final upcoming = state.upcoming;
    final when = DateTime(_day.year, _day.month, _day.day, _time.hour);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(title: 'Booking', subtitle: 'အချိန်၊ ကလေးနဲ့ လူကြီးကို ရွေးပါ။'),
        if (upcoming != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _PaperTicket(booking: upcoming, onCancel: state.busy ? null : () => _cancel(upcoming)),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: AppCard(
            child: Column(
              children: [
                _ChoiceRow(
                  label: 'ရက်',
                  value: '${mmWeekday(_day)} · ${mmDate(_day)}',
                  onTap: _pickDay,
                ),
                const Divider(height: 1, color: AppColors.line),
                _ChoiceRow(
                  label: 'အချိန်',
                  value: mmTime(when),
                  onTap: _pickTime,
                ),
                const Divider(height: 1, color: AppColors.line),
                _StepperRow(
                  label: 'ကလေး',
                  value: _children,
                  onMinus: _children <= 0 ? null : () => setState(() => _children -= 1),
                  onPlus: () => setState(() => _children += 1),
                ),
                const Divider(height: 1, color: AppColors.line),
                _StepperRow(
                  label: 'လူကြီး',
                  value: _adults,
                  onMinus: _adults <= 0 ? null : () => setState(() => _adults -= 1),
                  onPlus: () => setState(() => _adults += 1),
                ),
                const Divider(height: 1, color: AppColors.line),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('ဦးရေ', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      Text(
                        mmInt(_people),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: FilledButton(
            onPressed: state.busy || upcoming != null || _people < 1 ? null : _confirm,
            child: Text(upcoming != null ? 'စာရင်း တစ်ခု ယူထားပြီးပါပြီ' : 'ယူမယ်'),
          ),
        ),
      ],
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Text(mmInt(value), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _PaperTicket extends StatelessWidget {
  const _PaperTicket({required this.booking, required this.onCancel});

  final Booking booking;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('HAPPY LA LA LAND', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.4)),
          const SizedBox(height: 4),
          const Text('ကြိုတင်စာရင်း', style: TextStyle(color: AppColors.muted)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: _DashedLine(),
          ),
          _line('ရက်', '${mmWeekday(booking.startsAt)} · ${mmDate(booking.startsAt)}'),
          _line('အချိန်', '${mmTime(booking.startsAt)} - ${mmTime(booking.endsAt)}'),
          _line('ကလေး', mmInt(booking.children)),
          _line('လူကြီး', mmInt(booking.adults)),
          _line('ဦးရေ', mmInt(booking.people)),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _DashedLine(),
          ),
          TextButton(onPressed: onCancel, child: const Text('ပယ်ဖျက်မယ်')),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dash = 6.0;
        final count = (constraints.maxWidth / (dash * 2)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (index) => const SizedBox(width: dash, height: 1, child: ColoredBox(color: AppColors.line)),
          ),
        );
      },
    );
  }
}
