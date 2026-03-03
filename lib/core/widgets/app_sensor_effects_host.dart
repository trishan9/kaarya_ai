import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/theme_mode_controller.dart';
import 'package:kaarya/core/services/sensors/device_sensor_service.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/navigation_provider.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/features/auth/presentation/pages/login_page.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AppSensorEffectsHost extends ConsumerStatefulWidget {
  const AppSensorEffectsHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppSensorEffectsHost> createState() =>
      _AppSensorEffectsHostState();
}

class _AppSensorEffectsHostState extends ConsumerState<AppSensorEffectsHost>
    with WidgetsBindingObserver {
  final ShakeDetector _shakeDetector = ShakeDetector();
  StreamSubscription<UserAccelerometerEvent>? _shakeSubscription;
  StreamSubscription<double>? _lightSubscription;
  StreamSubscription<bool>? _proximitySubscription;

  Timer? _proximityHoldTimer;
  DateTime? _lastLogoutDialogAt;
  bool _shortcutOpening = false;
  bool _logoutDialogVisible = false;
  bool _isProximityNear = false;
  DateTime? _lastFarAt;
  bool _hasLightSensor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startGlobalSensors();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shakeSubscription?.cancel();
    _lightSubscription?.cancel();
    _proximitySubscription?.cancel();
    _proximityHoldTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _proximityHoldTimer?.cancel();
      _lightSubscription?.cancel();
      _lightSubscription = null;
    } else if (state == AppLifecycleState.resumed) {
      _startLightSensorIfNeeded();
    }
  }

  void _startGlobalSensors() {
    final sensorService = ref.read(deviceSensorServiceProvider);

    _shakeSubscription = sensorService.shakeEventStream().listen((event) {
      if (_shakeDetector.addSample(event)) {
        _handleShakeShortcut();
      }
    });

    _startLightSensorIfNeeded();

    sensorService.hasProximitySensor().then((hasSensor) {
      if (!mounted || !hasSensor) return;
      _proximitySubscription = sensorService.proximityStateStream().listen(
        _handleProximityChange,
      );
    });
  }

  void _startLightSensorIfNeeded() {
    if (!Platform.isAndroid || _lightSubscription != null) return;

    final sensorService = ref.read(deviceSensorServiceProvider);
    if (_hasLightSensor) {
      _lightSubscription = sensorService.lightLevelStream().listen((lux) {
        ref.read(themeModeControllerProvider.notifier).applyAmbientLux(lux);
      });
      return;
    }

    sensorService.hasLightSensor().then((hasSensor) {
      if (!mounted || !hasSensor || _lightSubscription != null) return;
      _hasLightSensor = true;
      _lightSubscription = sensorService.lightLevelStream().listen((lux) {
        ref.read(themeModeControllerProvider.notifier).applyAmbientLux(lux);
      });
    });
  }

  Future<void> _handleShakeShortcut() async {
    if (!mounted || _shortcutOpening) return;
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    if (ref.read(interviewSensorActiveProvider)) return;

    final session = ref.read(userSessionServiceProvider);
    if (!session.isLoggedIn()) return;
    final role = session.getCurrentUserRole()?.trim().toLowerCase();
    if (role == 'recruiter' || role == 'college') return;
    final currentDestination = ref.read(bottomNavProvider);
    final pushedPage = ref.read(pushedPageProvider);
    final isOnOverview =
        currentDestination == AppDestination.overview && pushedPage == null;
    if (!isOnOverview) return;
    if (AppRoutes.navigatorKey.currentState == null) return;

    _shortcutOpening = true;
    SnackbarUtils.showInfo(context, 'Opening AI Interview Hub.');
    ref.read(pushedPageProvider.notifier).state = null;
    ref.read(bottomNavProvider.notifier).state = AppDestination.interviewHub;
    AppRoutes.popToFirstGlobal();
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _shortcutOpening = false;
    });
  }

  void _handleProximityChange(bool isNear) {
    final session = ref.read(userSessionServiceProvider);
    if (!session.isLoggedIn() || !mounted) return;

    _isProximityNear = isNear;
    if (!isNear) {
      _lastFarAt = DateTime.now();
      _proximityHoldTimer?.cancel();
      return;
    }

    final now = DateTime.now();
    final isCoolingDown =
        _lastLogoutDialogAt != null &&
        now.difference(_lastLogoutDialogAt!) < const Duration(seconds: 30);
    if (isCoolingDown || _logoutDialogVisible) return;

    _proximityHoldTimer?.cancel();
    _proximityHoldTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (!_isProximityNear) return;
      final farJustHappened =
          _lastFarAt != null &&
          DateTime.now().difference(_lastFarAt!) <
              const Duration(milliseconds: 600);
      if (farJustHappened) return;
      _showLogoutDialog();
    });
  }

  Future<void> _showLogoutDialog() async {
    if (_logoutDialogVisible || !mounted) return;
    final navigatorContext = AppRoutes.navigatorKey.currentContext;
    if (navigatorContext == null) return;
    _logoutDialogVisible = true;

    final shouldLogout = await showDialog<bool>(
      context: navigatorContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout from Kaarya?'),
        content: const Text(
          'The proximity sensor has been covered for 5 seconds. Do you want to sign out now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    _logoutDialogVisible = false;
    _proximityHoldTimer?.cancel();

    if (shouldLogout != true || !mounted) return;
    _lastLogoutDialogAt = DateTime.now();

    await ref.read(authViewModelProvider.notifier).logoutUser();
    ref.read(dashboardViewModelProvider.notifier).resetState();
    ref.read(collegeDashboardViewModelProvider.notifier).resetState();

    if (!mounted) return;
    await AppRoutes.pushAndRemoveUntilGlobal(const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
