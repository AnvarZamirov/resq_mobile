import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Добро пожаловать в ResQ',
      subtitle: 'Безопасность упрощена',
      icon: Icons.security,
      description: 'Ваш личный помощник безопасности всегда с вами',
    ),
    OnboardingStep(
      title: 'Разрешения',
      subtitle: 'Для работы приложения нужны разрешения',
      icon: Icons.location_on,
      description: 'Разрешите доступ к геолокации для отправки точных координат в экстренных случаях',
      permissionType: PermissionType.location,
    ),
    OnboardingStep(
      title: 'Критические уведомления',
      subtitle: 'Обход режима "Не беспокоить"',
      icon: Icons.notifications_active,
      description: 'Разрешите критические уведомления, чтобы они работали даже в режиме "Не беспокоить"',
      permissionType: PermissionType.notifications,
    ),
    OnboardingStep(
      title: 'Добавьте контакт',
      subtitle: 'Кто ваш главный человек?',
      icon: Icons.person_add,
      description: 'Добавьте хотя бы одного человека, которому вы доверяете',
      permissionType: PermissionType.contacts,
      canSkip: true,
    ),
    OnboardingStep(
      title: 'Подключите устройство',
      subtitle: 'Нажмите кнопку ResQ сейчас',
      icon: Icons.bluetooth,
      description: 'Если у вас есть устройство ResQ, нажмите кнопку для подключения',
      permissionType: null,
      canSkip: true,
    ),
    OnboardingStep(
      title: 'Тестовый сигнал',
      subtitle: 'Попробуйте прямо сейчас',
      icon: Icons.notifications_active,
      description: 'Мы отправим тестовое уведомление вашему контакту. Это безопасно!',
      permissionType: null,
    ),
    OnboardingStep(
      title: 'Готово!',
      subtitle: 'Вы защищены',
      icon: Icons.check_circle,
      description: 'Теперь вы можете использовать ResQ для вашей безопасности',
      permissionType: null,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipStep() {
    if (_currentStep < _steps.length - 1) {
      _nextStep();
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  void _handlePermissionRequest(PermissionType? type) {
    // TODO: Implement actual permission requests
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Запрос разрешения: $type')),
    );
    _nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(
                  _steps.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < _steps.length - 1 ? 4 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppTheme.emergencyRed
                            : AppTheme.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildStep(_steps[index]);
                },
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_steps[_currentStep].canSkip)
                    TextButton(
                      onPressed: _skipStep,
                      child: const Text('Пропустить'),
                    ),
                  const Spacer(),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Назад'),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final step = _steps[_currentStep];
                      if (step.permissionType != null) {
                        _handlePermissionRequest(step.permissionType);
                      } else {
                        _nextStep();
                      }
                    },
                    child: Text(
                      _currentStep == _steps.length - 1 ? 'Начать' : 'Далее',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            step.icon,
            size: 80,
            color: AppTheme.emergencyRed,
          ),
          const SizedBox(height: 32),
          Text(
            step.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            step.subtitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;
  final PermissionType? permissionType;
  final bool canSkip;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    this.permissionType,
    this.canSkip = false,
  });
}

enum PermissionType {
  location,
  notifications,
  contacts,
  microphone,
}

