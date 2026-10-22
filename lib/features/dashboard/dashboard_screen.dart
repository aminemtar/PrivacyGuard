import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/privacy_guard_app.dart';
import '../detection/camera_detection_screen.dart';
import '../protection/privacy_overlay.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _enabledKey = 'privacy_guard_enabled';
  bool _enabled = false;
  bool _demoProtection = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = preferences.getBool(_enabledKey) ?? false;
      _loading = false;
    });
  }

  Future<void> _setEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, value);
    if (!mounted) return;
    setState(() {
      _enabled = value;
      if (!value) _demoProtection = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrivacyOverlay(
      protect: _demoProtection,
      message: 'Privacy shield preview',
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 26),
                    _buildHeroCard(),
                    const SizedBox(height: 18),
                    _buildStatusCard(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('Protection tools'),
                    const SizedBox(height: 12),
                    _buildToolCard(
                      icon: Icons.visibility_rounded,
                      title: 'Shoulder-surfing detection',
                      subtitle: 'Analyze front-camera frames locally for a possible second viewer.',
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _openDetection,
                    ),
                    const SizedBox(height: 10),
                    _buildToolCard(
                      icon: Icons.layers_rounded,
                      title: 'Privacy shield preview',
                      subtitle: 'Test how sensitive content can be covered inside the app.',
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => setState(() => _demoProtection = !_demoProtection),
                    ),
                    const SizedBox(height: 10),
                    _buildToolCard(
                      icon: Icons.tune_rounded,
                      title: 'Sensitivity & permissions',
                      subtitle: 'Review the camera and on-device processing limits.',
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showPermissionInfo,
                    ),
                    const SizedBox(height: 22),
                    _buildPrivacyNote(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [PrivacyGuardApp.blue, PrivacyGuardApp.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.shield_moon_rounded, color: Colors.white, size: 27),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Guard',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 2),
              Text('Your screen. Your privacy.', style: TextStyle(color: Colors.white60)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'About Privacy Guard',
          onPressed: _showPermissionInfo,
          icon: const Icon(Icons.info_outline_rounded),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4F9C), Color(0xFF17345F), Color(0xFF10223A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Smart privacy\nprotection',
                  style: TextStyle(fontSize: 27, height: 1.12, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.security_rounded, size: 34, color: PrivacyGuardApp.cyan),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Detect a possible nearby viewer and conceal content in supported screens.',
            style: TextStyle(height: 1.45, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loading ? null : () => _setEnabled(!_enabled),
                  icon: Icon(_enabled ? Icons.pause_rounded : Icons.shield_rounded),
                  label: Text(_loading ? 'Loading…' : _enabled ? 'Disable guard' : 'Enable guard'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF123568),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _enabled ? 'Protection enabled' : 'Protection is off';
    final description = _enabled
        ? 'Open live detection to start the front camera.'
        : 'Enable the guard when you want to configure protection.';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (_enabled ? PrivacyGuardApp.cyan : Colors.white24).withValues(alpha: .13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _enabled ? Icons.shield_rounded : Icons.shield_outlined,
                color: _enabled ? PrivacyGuardApp.cyan : Colors.white60,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.white60, height: 1.35)),
                ],
              ),
            ),
            Switch(value: _enabled, onChanged: _setEnabled),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: PrivacyGuardApp.blue.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: PrivacyGuardApp.cyan),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white60, height: 1.35, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10223A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: PrivacyGuardApp.cyan, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Camera frames are analyzed on-device and are not saved or uploaded. Face detection is only a signal and cannot prove someone is reading your screen.',
              style: TextStyle(color: Colors.white70, height: 1.45, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetection() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CameraDetectionScreen()),
    );
  }

  void _showDetectionStatus() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF10223A),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shoulder-surfing detection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 12),
            Text(
              'The next phase connects the front camera to on-device face detection. Multiple faces can trigger a privacy warning, but they do not prove that another person is looking at the screen.',
              style: TextStyle(height: 1.5, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'Privacy Guard',
      applicationVersion: '0.1.0 MVP',
      applicationLegalese: 'Privacy first. Camera frames are intended to remain on device.',
      children: const [
        SizedBox(height: 12),
        Text(
          'Cross-app overlays are platform-dependent. iOS apps cannot generally cover other apps, and Android may require special user-granted permissions.',
        ),
      ],
    );
  }
}
