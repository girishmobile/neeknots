import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/feature/auth/app_lock_services.dart';
import 'package:neeknots/feature/auth/app_lock_storage.dart';

class BioMetricView extends StatefulWidget {
  const BioMetricView({super.key});

  @override
  State<BioMetricView> createState() => _BioMetricViewState();
}

class _BioMetricViewState extends State<BioMetricView> {
  final _storage = AppLockStorage();
  final _biometric = AppLockServices();
  bool _enabled = false;
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    if (Platform.isAndroid) {
      _showBiometric = await _biometric.isAvailable();
      if (_showBiometric) {
        _enabled = await _storage.isEnabled();
      }
    } else {
      _showBiometric = true;
      _enabled = await _storage.isEnabled();
      setState(() {});
    }
    setState(() {});
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final authenticated = await _biometric.authenticate();
      if (!authenticated) return;
      await _storage.enable();
    } else {
      await _storage.disable();
    }
    setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBiometric) {
      return const SizedBox.shrink();
    }
    return Row(
      spacing: 8,
      children: [
        Icon(Icons.lock_outline),
        Text("Face ID or Biometric Lock"),
        Spacer(),
        Switch(
          value: _enabled,
          onChanged: _toggle,


          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeThumbColor:colorMenu,
        ),
      ],
    );
  }
}
