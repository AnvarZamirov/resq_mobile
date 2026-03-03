import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/checkin.dart';
import '../models/emergency.dart';
import '../services/timeline_repository.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  TimelineFilter _currentFilter = TimelineFilter.all;

  final TimelineRepository _repo = TimelineRepository();
  List<dynamic> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.load();
    if (!mounted) return;
    setState(() {
      _events = items;
      _loading = false;
    });
  }

  List<dynamic> get _filteredEvents {
    switch (_currentFilter) {
      case TimelineFilter.all:
        return _events;
      case TimelineFilter.emergencies:
        return _events.whereType<Emergency>().toList();
      case TimelineFilter.checkins:
        return _events.whereType<CheckIn>().toList();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Сегодня, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Вчера, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал безопасности'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCheckIn,
        backgroundColor: AppTheme.emergencyRed,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildFilterChip('Все', TimelineFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('Только SOS', TimelineFilter.emergencies),
                const SizedBox(width: 8),
                _buildFilterChip('Чек-ины', TimelineFilter.checkins),
              ],
            ),
          ),
          // Timeline
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      if (event is Emergency) {
                        return _buildEmergencyCard(event);
                      } else if (event is CheckIn) {
                        return _buildCheckInCard(event);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCheckIn() async {
    final controller = TextEditingController();
    final durationController = TextEditingController(text: '30');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый чек-ин'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Сообщение',
                hintText: 'Например, “Иду домой”',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Длительность (мин)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Создать'),
          ),
        ],
      ),
    );

    if (ok != true) {
      controller.dispose();
      durationController.dispose();
      return;
    }

    final msg = controller.text.trim().isEmpty ? 'Check-in' : controller.text.trim();
    final dur = int.tryParse(durationController.text.trim()) ?? 30;

    controller.dispose();
    durationController.dispose();

    final checkIn = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      message: msg,
      durationMinutes: dur,
      status: CheckInStatus.active,
      notifiedContactIds: const [],
    );

    await _repo.addCheckIn(checkIn);
    await _load();
  }

  Widget _buildFilterChip(String label, TimelineFilter filter) {
    final isSelected = _currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
      },
      selectedColor: AppTheme.emergencyRed.withOpacity(0.2),
      checkmarkColor: AppTheme.emergencyRed,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Нет событий',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ваши чек-ины и экстренные события\nпоявятся здесь',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard(CheckIn checkIn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.statusSuccess,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDateTime(checkIn.timestamp),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.statusSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Чек-ин',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.statusSuccess,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (checkIn.message != null) ...[
              const SizedBox(height: 8),
              Text(
                '"${checkIn.message}"',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (checkIn.durationMinutes != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Таймер на ${checkIn.durationMinutes} мин',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
            if (checkIn.endedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check, size: 16, color: AppTheme.statusSuccess),
                  const SizedBox(width: 4),
                  Text(
                    'Завершено вручную',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.statusSuccess,
                        ),
                  ),
                ],
              ),
            ],
            if (checkIn.notifiedContactIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Уведомлены: ${checkIn.notifiedContactIds.length} контактов',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(Emergency emergency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to After Action Report
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AfterActionReportScreen(emergency: emergency),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.emergencyRed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDateTime(emergency.activatedAt),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emergencyRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.emergencyRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'SOS активирован (3x нажатие)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.mic, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${emergency.audioDurationSeconds ?? 0}с аудио записано',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Уведомлены службы',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppTheme.statusSuccess),
                  const SizedBox(width: 4),
                  Text(
                    'Решено за ${emergency.responseTime?.inMinutes ?? 0} мин',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.statusSuccess,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum TimelineFilter {
  all,
  emergencies,
  checkins,
}

// After Action Report Screen
class AfterActionReportScreen extends StatelessWidget {
  final Emergency emergency;

  const AfterActionReportScreen({
    super.key,
    required this.emergency,
  });

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'N/A';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчёт о действиях'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency #${emergency.id} – Решено',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildReportItem(
                    context,
                    'Активировано',
                    '${emergency.activatedAt.day}.${emergency.activatedAt.month}.${emergency.activatedAt.year}, ${emergency.activatedAt.hour}:${emergency.activatedAt.minute.toString().padLeft(2, '0')}',
                    Icons.access_time,
                  ),
                  const Divider(),
                  _buildReportItem(
                    context,
                    'Время реакции',
                    _formatDuration(emergency.responseTime),
                    Icons.timer,
                  ),
                  const Divider(),
                  _buildReportItem(
                    context,
                    'Контакты достигнуты',
                    '${emergency.contactsReached}/${emergency.totalContacts}',
                    Icons.people,
                  ),
                  const Divider(),
                  _buildReportItem(
                    context,
                    'Аудио записано',
                    '${emergency.audioDurationSeconds ?? 0} сек',
                    Icons.mic,
                  ),
                  const Divider(),
                  _buildReportItem(
                    context,
                    'Точность локации',
                    '${emergency.locationAccuracy?.toStringAsFixed(1) ?? 'N/A'} м',
                    Icons.location_on,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Действия',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            icon: Icons.save,
            label: 'Сохранить в журнал безопасности',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            context,
            icon: Icons.share,
            label: 'Поделиться с психологом',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            context,
            icon: Icons.description,
            label: 'Экспортировать для полиции',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            context,
            icon: Icons.settings,
            label: 'Настроить поведение в будущем',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.statusInfo),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

