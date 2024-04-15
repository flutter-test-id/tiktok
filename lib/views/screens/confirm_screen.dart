import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tiktok/controller/upload_video_controller.dart';
import 'package:tiktok/views/widgets/text_inputfield.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class ConfirmScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  const ConfirmScreen(
      {super.key, required this.videoFile, required this.videoPath});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late VideoPlayerController controller;

  TextEditingController _songController = TextEditingController();
  TextEditingController _captionController = TextEditingController();

  UploadVideoController uploadVideoController =
      Get.put(UploadVideoController());

  @override
  void initState() {
    super.initState();
    setState(() {
      controller = VideoPlayerController.file(widget.videoFile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(true);
  }

  @override
  void dispose() {
    controller.dispose();

    VideoCompress.cancelCompression().then((value) {
      if (!VideoCompress.isCompressing) {
        Get.closeAllSnackbars();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.5,
              child: VideoPlayer(controller),
            ),
            const SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width - 20,
                    child: TextInputField(
                        controller: _songController,
                        icon: Icons.music_note,
                        labelText: "Song name",
                        isObsecure: false),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width - 20,
                    child: TextInputField(
                        controller: _captionController,
                        icon: Icons.closed_caption,
                        labelText: "Caption",
                        isObsecure: false),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ValueListenableBuilder<(double,String)>(
                      valueListenable:
                          Get.find<UploadVideoController>().videoUploadNotifier,
                      builder: (context, value, _) {
                        return ElevatedButton(
                            onPressed: value.$1 > 0
                                ? null
                                : () => uploadVideoController.uploadVideo(
                                    _songController.text,
                                    _captionController.text,
                                    widget.videoPath),
                            child: Text(
                              value.$1 == 0
                                  ? 'Share ! '
                                  : value.$2.isEmpty?
                                  'Compressing ${value.$1.toStringAsFixed(2)}%':
                                  
                                  value.$2,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ));
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
