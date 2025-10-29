// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundTestScreen extends StatefulWidget {
  const SoundTestScreen({super.key});

  @override
  State<SoundTestScreen> createState() => _SoundTestScreenState();
}

class _SoundTestScreenState extends State<SoundTestScreen> {
  final _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playIncomeSound() async {
    try {
      debugPrint('Attempting to play income sound...');
      await _audioPlayer.play(AssetSource('sounds/money-income.mp3'));
      debugPrint('Income sound played successfully');
    } catch (e) {
      debugPrint('Error playing income sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: _playIncomeSound,
          child: const Text('Test Sound'),
        ),
      ),
    );
  }
}