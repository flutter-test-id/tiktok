import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/models/video.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  String tag = 'UploadVideoController';

  Future<MediaInfo?> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality);
    return compressedVideo;
  }

  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('videos').child(id);
    MediaInfo? media = await _compressVideo(videoPath);
    print('$tag media file is $media  ${media?.file} ${media?.file?.path}');
    if (media == null || media.file == null) {
      Get.snackbar('Upload Error ', 'Compressed media is null');
      return '';
    }

    UploadTask uploadTask = ref.putFile(File(media.file!.path))
      ..snapshotEvents.listen((event) {
        print(
            '$tag Uploading video to storage ... ${event.bytesTransferred / media.filesize!}');
        videoUploadNotifier.value = (
          -1,
          'Uploading video ${((event.bytesTransferred / media.filesize!) * 100).toStringAsFixed(2)}%'
        );
      });

    TaskSnapshot snap = await uploadTask;
    videoUploadNotifier.value = (-1, 'Please wait...');
    String downloadUrl = await snap.ref.getDownloadURL();
    print('$tag downloadUrl --> $downloadUrl');
    return downloadUrl;
  }

  _getThumbnail(String videoPath) async {
    print('$tag _getThumbnail --> $videoPath');
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    print('$tag _getThumbnail --> $thumbnail');
    return thumbnail;
  }

  _uploadImageToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('thumbnails').child(id);
    File? media = await _getThumbnail(videoPath);
    print('$tag thumnail file ---> ${media}');
    if (media == null) return;
    UploadTask uploadTask = ref.putFile(media)
      ..snapshotEvents.listen((event) {
        print('$tag Uploading video to storage ... ${event.bytesTransferred}');
        videoUploadNotifier.value = (
          -1,
          'Uploading thumbnail ${(event.bytesTransferred / media.lengthSync()).toStringAsFixed(2)}%'
        );
      });
    TaskSnapshot snap = await uploadTask;
    videoUploadNotifier.value = (-1, 'Please wait...');
    String downloadUrl = await snap.ref.getDownloadURL();
    print('$tag _uploadImageToStorage --> $downloadUrl');
    return downloadUrl;
  }

  //upload video
  uploadVideo(String songName, String caption, String videoPath) async {
    try {
      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(uid).get();
      print(
          '$tag user doc is $uid ${userDoc.data()} ${userDoc.data().runtimeType}');
      if (userDoc.data() == null) {
        Get.snackbar('Doc Missing', 'User Doc not found');
        return;
      }

      //get id
      var allDocs = await firestore.collection('videos').get();
      if (allDocs.docs.isEmpty) {
        Get.snackbar('Collection Missing', 'Video collection not found');
      }

      int len = allDocs.docs.length;
      String videoUrl = await _uploadVideoToStorage('Video $len', videoPath);
      if (videoUrl.isEmpty) return;
      print('$tag uploaded video --- > ${videoUrl}');
      String thumbnail = await _uploadImageToStorage('Video $len', videoPath);
      print('$tag thumbnail ---> $thumbnail');
      videoUploadNotifier.value = (-1, 'Creating doc...');
      await Future.delayed(Duration(seconds: 2));
      Video video = Video(
          username: (userDoc.data()! as Map<String, dynamic>)['name'] ?? '',
          uid: uid,
          id: 'Video $len',
          likes: [],
          commentCount: 0,
          shareCount: 0,
          songname: songName,
          caption: caption,
          videoUrl: videoUrl,
          // videoUrl:
          //     'https://firebasestorage.googleapis.com/v0/b/tiktok-48c2f.appspot.com/o/videos%2FVideo%200?alt=media&token=7a5f2730-3a57-47b7-96b9-47c367c80230',
          thumbnail: thumbnail,
          // thumbnail:
          //     'https://firebasestorage.googleapis.com/v0/b/tiktok-48c2f.appspot.com/o/thumbnails%2FVideo%200?alt=media&token=1ede67bf-4872-4ea7-ada7-5fc577e6d35c',
          profilePhoto:
              (userDoc.data()! as Map<String, dynamic>)['profilePic'] ?? '');
      print('$tag video item ${video.toJson()}');
      await firestore
          .collection('videos')
          .doc('Video $len')
          .set(video.toJson());
      videoUploadNotifier.value = (-1, 'Uploaded successfully!🥂');
      await Future.delayed(Duration(seconds: 1));
      videoUploadNotifier.value = (0, '');
      Get.back();
    } catch (e) {
      Get.snackbar("Error uploading video", e.toString());
      videoUploadNotifier.value = (0, '');
    }
  }

  ValueNotifier<(double, String)> videoUploadNotifier = ValueNotifier((0, ''));
  @override
  void onReady() {
    super.onReady();
    VideoCompress.compressProgress$.subscribe((event) {
      videoUploadNotifier.value = (event.round() == 100 ? 0 : event, '');
      print(' --------- media file UploadVideoController =>  ${event}');
      // Get.closeCurrentSnackbar();
      // Get.showSnackbar(GetSnackBar(
      //   title: 'Compress progress',
      //   message: '${event.toStringAsFixed(2)} compressed.',
      // ));
    });
  }
}
