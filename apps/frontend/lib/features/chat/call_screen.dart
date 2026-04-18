import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'chat_service.dart' as svc;
import 'call_provider.dart';

class CallScreen extends ConsumerStatefulWidget {
  final int callId;
  final svc.BackendUser otherUser;
  final bool isVideo;
  final bool isIncoming;

  const CallScreen({
    super.key,
    required this.callId,
    required this.otherUser,
    this.isVideo = false,
    this.isIncoming = false,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  int _seconds = 0;
  Timer? _callTimer;
  bool _timerStarted = false;

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _endCall() async {
    await ref.read(callProvider.notifier).updateStatus(widget.callId, 'ended');
    if (mounted) {
      Navigator.pop(context, {
        'status': 'ended',
        'duration': _seconds,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callProvider);
    final activeCall = callState.activeCall;

    // Use current active call status, if ended in background, exit
    String statusStr = 'Connecting...';
    if (activeCall != null && activeCall['id'] == widget.callId) {
      statusStr = activeCall['status'] as String;
    } else if (callState.activeCall == null) {
      // It was ended remotely!
      statusStr = 'ended';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, {
            'status': 'ended',
            'duration': _seconds,
          });
        }
      });
    }

    if (statusStr == 'answered' && !_timerStarted) {
      _timerStarted = true;
      _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() { _seconds++; });
      });
    }

    final displayStatus = statusStr == 'answered' 
        ? _formattedTime 
        : (statusStr == 'ringing' ? 'Ringing...' : 'Ended');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top actions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Icon(Icons.lock, color: Colors.white54, size: 16),
                    const SizedBox(width: 48), 
                  ],
                ),
              ),

              // Profile and Status
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondary.withValues(alpha: 0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.otherUser.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayStatus,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              // Call Controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlBtn(Icons.mic_off, Colors.white24),
                        if (widget.isVideo)
                          _buildControlBtn(Icons.videocam_off, Colors.white24),
                        _buildControlBtn(Icons.volume_up, Colors.white24),
                        GestureDetector(
                          onTap: _endCall,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
