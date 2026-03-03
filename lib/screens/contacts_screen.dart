import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';
import '../services/contacts_repository.dart';
import 'contact_form_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactsRepository _repo = ContactsRepository();
  List<Contact> _contacts = [];
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
      _contacts = items;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await _repo.save(_contacts);
  }

  String _getRoleLabel(ContactRole role) {
    switch (role) {
      case ContactRole.primary:
        return 'Основной контакт';
      case ContactRole.secondary:
        return 'Вторичный контакт';
      case ContactRole.autoAdded:
        return 'Автоматически добавлен';
    }
  }

  Color _getRoleColor(ContactRole role) {
    switch (role) {
      case ContactRole.primary:
        return AppTheme.emergencyRed;
      case ContactRole.secondary:
        return AppTheme.statusInfo;
      case ContactRole.autoAdded:
        return AppTheme.textSecondary;
    }
  }

  String _formatLastAlerted(DateTime? dateTime) {
    if (dateTime == null) return 'Никогда';
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${_pluralize(difference.inDays, 'день', 'дня', 'дней')} назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${_pluralize(difference.inHours, 'час', 'часа', 'часов')} назад';
    } else {
      return 'Только что';
    }
  }

  String _pluralize(int count, String one, String few, String many) {
    if (count % 10 == 1 && count % 100 != 11) return one;
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return few;
    }
    return many;
  }

  void _handleAddContact() {
    _openCreate();
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(builder: (_) => const ContactFormScreen()),
    );
    if (created == null) return;
    setState(() {
      _contacts = [created, ..._contacts];
    });
    await _persist();
  }

  Future<void> _openEdit(Contact contact) async {
    final edited = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(builder: (_) => ContactFormScreen(initial: contact)),
    );
    if (edited == null) return;
    setState(() {
      _contacts = _contacts.map((c) => c.id == edited.id ? edited : c).toList();
    });
    await _persist();
  }

  Future<void> _delete(Contact contact) async {
    if (contact.role == ContactRole.autoAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Автоматический контакт нельзя удалить')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить контакт?'),
        content: Text('Контакт "${contact.name}" будет удалён.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusError),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    setState(() {
      _contacts = _contacts.where((c) => c.id != contact.id).toList();
    });
    await _persist();
  }

  String _buildTestMessage(Contact contact) {
    final now = DateTime.now();
    final ts =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return 'ResQ TEST: проверка контакта.\nКонтакт: ${contact.name}\nВремя: $ts';
  }

  Future<void> _testContact(Contact contact) async {
    if (contact.phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('У контакта нет номера телефона')),
      );
      return;
    }

    final uri = Uri(
      scheme: 'sms',
      path: contact.phone.trim(),
      queryParameters: <String, String>{
        'body': _buildTestMessage(contact),
      },
    );

    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть SMS приложение')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя сеть доверия'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? _buildEmptyState()
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Add contact button
          ElevatedButton.icon(
            onPressed: _handleAddContact,
            icon: const Icon(Icons.add),
            label: const Text('Добавить контакт для экстренных случаев'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          // Contacts list
          ..._contacts.map((contact) => _buildContactCard(contact)),
        ],
      ),
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
              Icons.contacts_outlined,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Добавьте хотя бы одного человека,\nкоторому вы доверяете',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleAddContact,
              icon: const Icon(Icons.add),
              label: const Text('Добавить контакт'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    final canDelete = contact.role != ContactRole.autoAdded;

    Widget card = Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            contact.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          if (contact.role == ContactRole.primary) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: AppTheme.statusSuccess,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(contact.role).withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getRoleLabel(contact.role),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getRoleColor(contact.role),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  contact.phone,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            if (contact.email != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    contact.email!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  contact.receivesSOS ? Icons.notifications_active : Icons.notifications_off,
                  size: 18,
                  color: contact.receivesSOS ? AppTheme.statusSuccess : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  contact.receivesSOS ? 'Получает SOS' : 'SOS отключён',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (contact.lastAlerted != null) ...[
              const SizedBox(height: 12),
              Text(
                'Последний раз оповещён: ${_formatLastAlerted(contact.lastAlerted)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton.icon(
                  onPressed: contact.role == ContactRole.autoAdded ? null : () => _openEdit(contact),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _testContact(contact);
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Проверить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!canDelete) return card;
    return Dismissible(
      key: ValueKey('contact_${contact.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.statusError.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: AppTheme.statusError),
      ),
      confirmDismiss: (_) async {
        await _delete(contact);
        return false; // deletion already handled
      },
      child: card,
    );
  }
}