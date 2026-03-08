import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/services/sensors/device_sensor_service.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_feedback_page.dart';
import 'package:kaarya/features/interviews/presentation/state/take_interview_state.dart';
import 'package:kaarya/features/interviews/presentation/view_model/take_interview_view_model.dart';

class TakeInterviewScreen extends ConsumerStatefulWidget {
  final String interviewId;
  final InterviewEntity? interview;

  const TakeInterviewScreen({
    super.key,
    required this.interviewId,
    this.interview,
  });

  @override
  ConsumerState<TakeInterviewScreen> createState() =>
      _TakeInterviewScreenState();
}

class _TakeInterviewScreenState extends ConsumerState<TakeInterviewScreen>
    with WidgetsBindingObserver {
  final ScrollController _transcriptScrollController = ScrollController();
  final SustainedThresholdMonitor _motionMonitor = SustainedThresholdMonitor(
    warningThreshold: 1.85,
    clearThreshold: 1.05,
    sustainDuration: const Duration(seconds: 2),
    cooldown: const Duration(seconds: 9),
  );

  StreamSubscription<double>? _gyroscopeSubscription;
  StreamSubscription<double>? _lightSubscription;
  double? _latestLux;
  double _smoothedRotation = 0;
  bool _isDeviceUnsteady = false;
  bool _isLowLight = false;
  DateTime? _lowLightStartedAt;
  DateTime? _lastLowLightWarningAt;
  late final DeviceSensorService _sensorService;
  late final StateController<bool> _interviewSensorActiveController;
  TakeInterviewPhase _currentPhase = TakeInterviewPhase.idle;
  bool _isTearingDown = false;
  bool _hasLightSensor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sensorService = ref.read(deviceSensorServiceProvider);
    _interviewSensorActiveController = ref.read(
      interviewSensorActiveProvider.notifier,
    );
    _interviewSensorActiveController.state = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(takeInterviewViewModelProvider.notifier);
      vm.reset();
      if (widget.interview != null) {
        vm.loadInterview(widget.interviewId);
      } else {
        vm.loadInterview(widget.interviewId);
      }
    });
    _startSensorMonitoring();
  }

  @override
  void dispose() {
    _isTearingDown = true;
    WidgetsBinding.instance.removeObserver(this);
    _gyroscopeSubscription?.cancel();
    _lightSubscription?.cancel();
    _interviewSensorActiveController.state = false;
    _transcriptScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _lightSubscription?.cancel();
      _lightSubscription = null;
    } else if (state == AppLifecycleState.resumed) {
      _startLightMonitoringIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(takeInterviewViewModelProvider);
    _currentPhase = state.phase;

    ref.listen(takeInterviewViewModelProvider, (prev, next) {
      if (prev?.phase != TakeInterviewPhase.completed &&
          next.phase == TakeInterviewPhase.completed &&
          next.sessionId != null) {
        AppRoutes.pushReplacement(
          context,
          InterviewFeedbackPage(
            sessionId: next.sessionId!,
            interviewId: widget.interviewId,
          ),
        );
      }
      if (prev?.transcript.length != next.transcript.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_transcriptScrollController.hasClients) {
            _transcriptScrollController.animateTo(
              _transcriptScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return PopScope(
      canPop:
          state.phase == TakeInterviewPhase.idle ||
          state.phase == TakeInterviewPhase.ready ||
          state.phase == TakeInterviewPhase.error ||
          state.phase == TakeInterviewPhase.loading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            state.interview?.title ?? 'Interview',
            style: const TextStyle(fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft),
            onPressed: () {
              if (state.phase == TakeInterviewPhase.active ||
                  state.phase == TakeInterviewPhase.connecting) {
                _showExitConfirmation(context);
              } else {
                AppRoutes.pop(context);
              }
            },
          ),
        ),
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(TakeInterviewState state) {
    if (state.phase == TakeInterviewPhase.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Column(
      children: [
        _buildStatusBar(state),
        if (_isDeviceUnsteady || _isLowLight || _latestLux != null)
          _buildEnvironmentStrip(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildAvatarSection(state),
                const SizedBox(height: 16),
                _buildControlBar(state),
                const SizedBox(height: 16),
                _buildTranscriptSection(state),
                const SizedBox(height: 16),
                if (state.error != null) _buildErrorBanner(state.error!),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(TakeInterviewState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        border: Border(bottom: BorderSide(color: const Color(0xFFE7EEF7))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    state.interview?.title ?? 'Interview',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D6FAE),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 6),
                _statusBadge(
                  'AI',
                  const Color(0xFF0D6FAE).withValues(alpha: 0.1),
                  const Color(0xFF0D6FAE),
                ),
                if (state.totalQuestions > 0) ...[
                  const SizedBox(width: 6),
                  _statusBadge(
                    '${state.askedQuestionCount}/${state.totalQuestions} Q',
                    const Color(0xFF0D6FAE).withValues(alpha: 0.1),
                    const Color(0xFF0D6FAE),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD8E4F1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  _formatElapsed(state.elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _callStatusBadge(state.phase),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(TakeInterviewState state) {
    return Row(
      children: [
        Expanded(
          child: _buildAvatarCard(
            isAI: true,
            label: 'AI Interviewer',
            sublabel: 'Kaarya AI Interviewer',
            isActive: state.activeSpeaker == 'assistant',
            isSpeaking: state.isSpeaking,
            state: state,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAvatarCard(
            isAI: false,
            label: 'You',
            sublabel: 'Candidate',
            isActive: state.activeSpeaker == 'user',
            isSpeaking: state.activeSpeaker == 'user',
            state: state,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCard({
    required bool isAI,
    required String label,
    required String sublabel,
    required bool isActive,
    required bool isSpeaking,
    required TakeInterviewState state,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF34D399) : const Color(0xFFD9E5F2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              color: isAI ? const Color(0xFF0C6DAF) : const Color(0xFFDBE6F2),
              child: isAI
                  ? Image.asset(
                      'assets/images/ai_interviewer.webp',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    )
                  : Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF9EB9D3),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 3,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sublabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isSpeaking ? 'Speaking...' : 'Listening...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAI ? LucideIcons.volume2 : LucideIcons.mic,
                      size: 14,
                      color: Colors.white,
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

  Widget _buildControlBar(TakeInterviewState state) {
    return Column(
      children: [
        if (state.phase == TakeInterviewPhase.ready ||
            state.phase == TakeInterviewPhase.idle)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _onStartInterview,
              icon: Icon(LucideIcons.mic, size: 18),
              label: const Text('Start Interview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6FAE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else if (state.phase == TakeInterviewPhase.connecting ||
            state.phase == TakeInterviewPhase.finishing)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              label: Text(
                state.phase == TakeInterviewPhase.connecting
                    ? 'Connecting...'
                    : 'Finishing...',
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else if (state.phase == TakeInterviewPhase.active)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(takeInterviewViewModelProvider.notifier)
                    .endInterview();
              },
              icon: Icon(LucideIcons.phoneOff, size: 18),
              label: const Text('End Interview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          state.phase == TakeInterviewPhase.active
              ? _buildInterviewHint()
              : 'Use a quiet environment, stable device, and clear audio for better AI evaluation.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildEnvironmentStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _sensorChip(
            icon: LucideIcons.rotate3d,
            label: _isDeviceUnsteady
                ? 'Motion high ${_smoothedRotation.toStringAsFixed(2)}'
                : 'Motion ${_smoothedRotation.toStringAsFixed(2)}',
            background: _isDeviceUnsteady
                ? const Color(0xFFFFF4E5)
                : const Color(0xFFF3F8FD),
            foreground: _isDeviceUnsteady
                ? const Color(0xFFB45309)
                : AppColors.primary,
          ),
          if (_latestLux != null)
            _sensorChip(
              icon: LucideIcons.sunMedium,
              label: _lightingLabel(_latestLux!),
              background: _isLowLight
                  ? const Color(0xFFFFF7E7)
                  : const Color(0xFFF4FBF7),
              foreground: _isLowLight
                  ? const Color(0xFFD97706)
                  : const Color(0xFF15803D),
            ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection(TakeInterviewState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.messageSquareText,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Live Transcript',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Real-time',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (state.partialMessage != null || state.transcript.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: state.partialMessage != null
                      ? const Color(0xFF0D6FAE).withValues(alpha: 0.4)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.partialMessage != null)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 5, right: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D6FAE),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      state.partialMessage ?? state.transcript.last.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: state.partialMessage != null
                            ? AppColors.textDark
                            : AppColors.textDark,
                        fontStyle: state.partialMessage != null
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: state.transcript.isNotEmpty
                ? ListView.builder(
                    controller: _transcriptScrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.transcript.length,
                    itemBuilder: (context, index) {
                      final msg = state.transcript[index];
                      return _buildTranscriptBubble(msg);
                    },
                  )
                : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Transcript will appear here in real time after the call starts.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptBubble(TranscriptMessage msg) {
    Color bgColor;
    Color borderColor;
    String roleLabel;

    switch (msg.role) {
      case 'assistant':
        bgColor = const Color(0xFFEDF7FF);
        borderColor = const Color(0xFFD7ECFF);
        roleLabel = 'AI';
        break;
      case 'system':
        bgColor = const Color(0xFFFFF7F2);
        borderColor = const Color(0xFFFFE0B2);
        roleLabel = 'System';
        break;
      default:
        bgColor = const Color(0xFFF8F9FB);
        borderColor = const Color(0xFFE6E9EF);
        roleLabel = 'You';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                roleLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _formatTime(msg.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            msg.content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(fontSize: 13, color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _callStatusBadge(TakeInterviewPhase phase) {
    Color bg;
    String label;

    switch (phase) {
      case TakeInterviewPhase.active:
        bg = const Color(0xFF10B981);
        label = 'In Call';
        break;
      case TakeInterviewPhase.connecting:
        bg = const Color(0xFFF59E0B);
        label = 'Connecting';
        break;
      case TakeInterviewPhase.finishing:
        bg = const Color(0xFFF43F5E);
        label = 'Finishing';
        break;
      default:
        bg = const Color(0xFF94A3B8);
        label = 'Ready';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sensorChip({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  String _buildInterviewHint() {
    if (_isLowLight && _isDeviceUnsteady) {
      return 'Low light and high device movement detected. Move to a brighter place and keep the phone steady.';
    }
    if (_isLowLight) {
      return 'Low light detected. Move to a brighter area for better interview visibility.';
    }
    if (_isDeviceUnsteady) {
      return 'Keep your device steady for more reliable interview audio and video.';
    }
    return 'Interview is live. Your transcript and evaluation are being recorded.';
  }

  void _startSensorMonitoring() {
    _gyroscopeSubscription = _sensorService.gyroscopeMagnitudeStream().listen((
      magnitude,
    ) {
      if (_isTearingDown || !mounted) return;
      if (_currentPhase != TakeInterviewPhase.active &&
          _currentPhase != TakeInterviewPhase.connecting) {
        return;
      }

      _smoothedRotation = (_smoothedRotation * 0.8) + (magnitude * 0.2);
      final didTrigger = _motionMonitor.addSample(_smoothedRotation);
      final shouldBeUnsteady = _motionMonitor.isActive;

      if (!mounted) return;
      if (_isDeviceUnsteady != shouldBeUnsteady) {
        setState(() => _isDeviceUnsteady = shouldBeUnsteady);
      } else {
        setState(() {});
      }

      if (didTrigger) {
        SnackbarUtils.showWarning(
          context,
          'Keep your device steady for a better interview experience.',
        );
      }
    });

    _startLightMonitoringIfNeeded();
  }

  void _startLightMonitoringIfNeeded() {
    if (_isTearingDown || !mounted || _lightSubscription != null) return;

    if (_hasLightSensor) {
      _lightSubscription = _sensorService.lightLevelStream().listen(
        _handleLightReading,
      );
      return;
    }

    _sensorService.hasLightSensor().then((hasSensor) {
      if (!mounted ||
          _isTearingDown ||
          !hasSensor ||
          _lightSubscription != null) {
        return;
      }
      _hasLightSensor = true;
      _lightSubscription = _sensorService.lightLevelStream().listen(
        _handleLightReading,
      );
    });
  }

  void _handleLightReading(double lux) {
    if (_isTearingDown || !mounted) return;
    if (_currentPhase != TakeInterviewPhase.active &&
        _currentPhase != TakeInterviewPhase.connecting) {
      return;
    }

    _latestLux = lux;
    final now = DateTime.now();
    bool didTrigger = false;
    bool shouldBeLowLight = _isLowLight;

    if (lux < 60) {
      _lowLightStartedAt ??= now;
      final sustained =
          now.difference(_lowLightStartedAt!) >= const Duration(seconds: 4);
      if (sustained) {
        shouldBeLowLight = true;
        final isCoolingDown =
            _lastLowLightWarningAt != null &&
            now.difference(_lastLowLightWarningAt!) <
                const Duration(seconds: 10);
        if (!isCoolingDown) {
          _lastLowLightWarningAt = now;
          didTrigger = true;
        }
      }
    } else if (lux > 90) {
      _lowLightStartedAt = null;
      shouldBeLowLight = false;
    }

    if (!mounted) return;
    setState(() {
      _isLowLight = shouldBeLowLight;
    });

    if (didTrigger) {
      SnackbarUtils.showWarning(
        context,
        'Low light detected. Move to a brighter area for better interview visibility.',
      );
    }
  }

  String _lightingLabel(double lux) {
    final score = _lightingScore(lux);
    final label = _lightingDescription(lux);
    return 'Lighting $score% • $label';
  }

  int _lightingScore(double lux) {
    if (lux <= 0) return 0;
    final score = (lux / 2).clamp(0, 100);
    return score.round();
  }

  String _lightingDescription(double lux) {
    if (lux < 20) return 'Dark room';
    if (lux < 60) return 'Dim room';
    if (lux < 140) return 'Normal room light';
    return 'Bright room';
  }

  Future<void> _onStartInterview() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required for the interview.',
            ),
          ),
        );
      }
      return;
    }

    ref.read(takeInterviewViewModelProvider.notifier).startSession();
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Interview?'),
        content: const Text(
          'Your interview is still in progress. If you leave now, the session will be abandoned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(takeInterviewViewModelProvider.notifier).reset();
              AppRoutes.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  String _formatElapsed(int seconds) {
    final safeSeconds = seconds.clamp(0, 99999);
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  String _formatTime(DateTime timestamp) {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
