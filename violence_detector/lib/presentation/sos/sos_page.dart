import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:violence_detector/application/prediction/prediction_cubit.dart';
import 'package:violence_detector/application/sos/sos_cubit.dart';
import 'package:violence_detector/core/router/routes.dart';
import 'package:violence_detector/core/ui/theme/palette.dart';

import 'widgets/phone_call_button.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PredictionCubit, VideoUploadState>(
      listener: (context, state) {
        if (state is VideoUploadSuccess) {
          String message;
          Color backgroundColor;

          if (state.result['prediction'] == 'violent') {
            message = 'Violent Actions detected';
            backgroundColor = Colors.red;
          } else {
            message = 'Violent actions are not detected';
            backgroundColor = Colors.green;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: backgroundColor,
            ),
          );
        }
        if (state is VideoUploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => context.push(
                Routes.map.path,
                extra: {'cubit': context.read<SosCubit>()},
              ),
              icon: const Icon(
                Icons.map_outlined,
                size: 30,
                color: Palette.primary500,
              ),
            ),
            const SizedBox(width: 8.0),
          ],
        ),
        body: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Нажмите кнопку',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  height: 200,
                  width: 200,
                  decoration: const BoxDecoration(
                    color: Palette.primary500,
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Palette.primary500,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        context.read<SosCubit>().getReady();
                        context.push(
                          Routes.map.path,
                          extra: {
                            'cubit': context.read<SosCubit>(),
                            'isSending': true,
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(95),
                      child: const Center(
                        child: Text(
                          'SOS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Текущая кнопка отправит сообщение “SOS” доверенным людям и покажет ваше местоположение на карте',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Palette.neutral400,
                  ),
                ),
                const PhoneCallButton(),
                const SizedBox(height: 50),
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final _picker = ImagePicker();
            _picker.pickVideo(source: ImageSource.gallery).then((value) {
              if (value != null) {
                context.read<PredictionCubit>().getPrediction(
                      videoPath: value.path,
                    );
              }
            });
          },
          child: const Icon(Icons.upload),
        ),
      ),
    );
  }
}
