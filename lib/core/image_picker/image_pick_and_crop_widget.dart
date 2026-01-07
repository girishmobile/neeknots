import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonImagePicker {
  static Future<String?> pickImage(
    BuildContext context,
    ThemeProvider hemeProvider,
  ) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        message: commonText(
          text:
              "Choose an option below to upload your image from camera or gallery.",
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        title: commonText(
          text: "Upload Your Image",
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: commonText(
            text: "Cancel",
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined),
                commonText(fontWeight: FontWeight.w600, text: 'Camera'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined),
                commonText(fontWeight: FontWeight.w600, text: 'Gallery'),
              ],
            ),
          ),
        ],
      ),
    );

    if (source == null) return null;

    /// Ask platform-specific permissions
    bool permissionGranted = false;

    if (Platform.isAndroid) {
      final cameraStatus = await Permission.camera.request();
      final storageStatus = await Permission.storage
          .request(); // use `storage` for general storage access
      if (cameraStatus.isGranted || storageStatus.isGranted) {
        permissionGranted = true;
      } else if (cameraStatus.isPermanentlyDenied ||
          storageStatus.isPermanentlyDenied) {
        // Open settings dialog
        await _showPermissionDialog(isPermanent: true);
        return null;
      } else {
        // Show retry dialog
        await _showPermissionDialog();
        return null;
      }
    } else if (Platform.isIOS) {
      final cameraStatus = await Permission.camera.request();
      final photosStatus = await Permission.photos.request();

      if (cameraStatus.isGranted || photosStatus.isGranted) {
        permissionGranted = true;
      }
      // Request them if not already asked
      final newCamera = await Permission.camera.request();
      final newPhotos = await Permission.photos.request();
      if (newCamera.isGranted || newPhotos.isGranted) {
        permissionGranted = true;
      }
      // If permanently denied → open settings
      if (newCamera.isPermanentlyDenied || newPhotos.isPermanentlyDenied) {
        //  await openAppSettings();
        permissionGranted = true;
      }
    }

    if (!permissionGranted) {
      debugPrint("Permissions not granted");
      return null;
    }

    final pickedFile = await ImagePicker().pickImage(
      imageQuality: 70, // reduce size/quality
      maxWidth: 1080,
      source: source,
    );

    if (pickedFile == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,

      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: colorLogo,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.blue,

          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    return croppedFile?.path;
  }

  //openImageDialog(context, onImageSelected);
}

Future<void> _showPermissionDialog({bool isPermanent = false}) async {
  return showDialog(
    context: navigatorKey.currentContext!,
    builder: (ctx) {
      return CupertinoAlertDialog(
        title: commonText(
          text: "Permission Required",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        content: commonText(
          text: isPermanent
              ? "You have permanently denied permission. Please enable it from settings to continue."
              : "This feature requires permission. Please allow it to continue.",
        ),
        actions: [
          if (!isPermanent)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Retry by calling the function again
              },
              child: const Text("Retry"),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      );
    },
  );
}
