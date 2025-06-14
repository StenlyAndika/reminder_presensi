import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/permission_handler.dart';

class ScheduleSettingsPage extends StatefulWidget {
  const ScheduleSettingsPage({super.key});

  @override
  State<ScheduleSettingsPage> createState() => _ScheduleSettingsPageState();
}

class _ScheduleSettingsPageState extends State<ScheduleSettingsPage> {
  // Default times
  TimeOfDay monThuMorning = const TimeOfDay(hour: 7, minute: 26);
  TimeOfDay monThuNoon = const TimeOfDay(hour: 13, minute: 1);
  TimeOfDay monThuEvening = const TimeOfDay(hour: 16, minute: 16);

  TimeOfDay friMorning = const TimeOfDay(hour: 7, minute: 11);
  TimeOfDay friEvening = const TimeOfDay(hour: 11, minute: 46);

  @override
  void initState() {
    super.initState();
    PermissionHandler.checkAndRequestAlarmPermission(context);
    // 🟡 Load saved schedule or fallback to default
    monThuMorning = loadSchedule('monThuMorning', fallback: const TimeOfDay(hour: 7, minute: 26));
    monThuNoon = loadSchedule('monThuNoon', fallback: const TimeOfDay(hour: 13, minute: 1));
    monThuEvening = loadSchedule('monThuEvening', fallback: const TimeOfDay(hour: 16, minute: 16));
    friMorning = loadSchedule('friMorning', fallback: const TimeOfDay(hour: 7, minute: 11));
    friEvening = loadSchedule('friEvening', fallback: const TimeOfDay(hour: 11, minute: 46));
  }

  Future<void> pickTime(BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onPicked) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  String formatTime(TimeOfDay t) => t.format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Jadwal Absen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Senin - Kamis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildTimePicker("Absen Pagi", monThuMorning, (val) => setState(() => monThuMorning = val)),
            buildTimePicker("Absen Siang", monThuNoon, (val) => setState(() => monThuNoon = val)),
            buildTimePicker("Absen Sore", monThuEvening, (val) => setState(() => monThuEvening = val)),
            const SizedBox(height: 24),
            const Text("Jumat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildTimePicker("Absen Pagi", friMorning, (val) => setState(() => friMorning = val)),
            buildTimePicker("Absen Sore", friEvening, (val) => setState(() => friEvening = val)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                saveSchedule('monThuMorning', monThuMorning);
                saveSchedule('monThuNoon', monThuNoon);
                saveSchedule('monThuEvening', monThuEvening);
                saveSchedule('friMorning', friMorning);
                saveSchedule('friEvening', friEvening);

                scheduleCustomNotifications(
                  monThuPagi: monThuMorning,
                  monThuSiang: monThuNoon,
                  monThuSore: monThuEvening,
                  friPagi: friMorning,
                  friSore: friEvening,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jadwal berhasil disimpan & notifikasi dijadwalkan!')),
                );
              },
              child: const Text("Simpan Jadwal"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onTimePicked) {
    return ListTile(
      title: Text(label),
      trailing: Text(formatTime(time)),
      onTap: () => pickTime(context, time, onTimePicked),
    );
  }
}
