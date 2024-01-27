import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:violence_detector/application/sos/sos_cubit.dart';
import 'package:violence_detector/core/ui/theme/palette.dart';

class IntentionModal extends StatefulWidget {
  const IntentionModal({super.key});

  @override
  State<IntentionModal> createState() => _IntentionModalState();
}

class _IntentionModalState extends State<IntentionModal> {
  double _progress = 100;
  int seconds = 10;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_progress > 0) {
        setState(() {
          seconds--;
          _progress -= 10;
        });
      } else {
        context.read<SosCubit>().sendSOS(true);
        context.pop();
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          const Text(
            'Отменить помощь',
            style: TextStyle(
              color: Palette.neutral600,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Palette.neutral100),
          const SizedBox(height: 10),
          Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 62,
                  width: 62,
                  child: CircularProgressIndicator(
                    value: _progress / 100,
                    strokeWidth: 5,
                    color: Palette.primary500,
                    backgroundColor: Colors.white10,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    seconds.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Palette.primary700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Вы уверены, что в безопасности?',
            style: TextStyle(
              color: Palette.neutral500,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Palette.neutral100),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.read<SosCubit>().sendSOS(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.primary100,
                    ),
                    child: const Text('Да'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
