import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:location/location.dart' as loc;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as paths;
import 'package:permission_handler/permission_handler.dart' as ph;

class Utils {
  static final ImagePicker picker = ImagePicker();
  static final loc.Location location = loc.Location();

  static String normalizeString(String text) {
    return text
        .trim() // remove leading/trailing spaces
        .toLowerCase() // case-insensitive
        .replaceAll(RegExp(r'\s+'), ' '); // collapse multiple spaces
  }

  static void printFullJson(dynamic data) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    printLongData(jsonString);
  }

  static void printLongData(String text) {
    const int chunkSize = 800; // safe size for logcat
    for (int i = 0; i < text.length; i += chunkSize) {
      debugPrint(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }

  // Collect the devicwe id

  static Future<Map<String, dynamic>> collectDeviceData() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Map<String, dynamic> data = {"appVersion": packageInfo.version};

    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      data.addAll({
        "sdkVersion": webInfo.userAgent,
        "deviceName": webInfo.browserName.name,
        "productName": webInfo.platform,
        "phoneModel": webInfo.vendor,
        "maid": "",
      });
      return data;
    }
    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await deviceInfo.androidInfo;
      data.addAll({
        "sdkVersion": "${android.version.sdkInt}",
        "deviceName": android.device,
        "productName": android.product,
        "phoneModel": android.model,
        "maid": android.id,
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo ios = await deviceInfo.iosInfo;
      data.addAll({
        "sdkVersion": ios.systemVersion,
        "deviceName": ios.name,
        "productName": ios.model,
        "phoneModel": ios.utsname.machine,
        "maid": ios.identifierForVendor,
      });
    }
    return data;
  }

  static Future<bool> checkLocationAndGpsPermission(BuildContext context) async {
    // Check location permission status
    loc.PermissionStatus permissionStatus = await location.hasPermission();

    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted && permissionStatus != loc.PermissionStatus.grantedLimited) {
        if (context.mounted) {
          CutsomAlertDialogues.showPermissionSettingsDialog(context, permissionName: "Location");
        }
        // throw Exception("Location permission denied.");
        return false;
      }
    }

    if (permissionStatus == loc.PermissionStatus.deniedForever || permissionStatus != loc.PermissionStatus.granted) {
      debugPrint('Location permission permanently denied.');
      if (context.mounted) {
        CutsomAlertDialogues.showPermissionSettingsDialog(context, permissionName: "Location");
      }
      // throw Exception("Location permission permanently denied.");
      return false;
    }

    // Check if location services (GPS) are enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        // throw Exception("Location services are disabled.");
        CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
        return false;
      }
    }

    return true;
  }

  static Future<bool> checkLocationGPS() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  // capture current location
  static Future<loc.LocationData?> getCurrentLocation() async {
    try {
      loc.LocationData position = await location.getLocation();
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  static Future<bool> requestCameraPermission(BuildContext context) async {
    //  Check current status first
    ph.PermissionStatus status = await ph.Permission.camera.status;

    //  If denied, request permission
    if (status.isDenied) {
      status = await ph.Permission.camera.request();
    }

    // Handle permanently denied
    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;

      CutsomAlertDialogues.showPermissionSettingsDialog(context, permissionName: "Camera");
      return false;
    }

    //Handle denied
    if (!status.isGranted) {
      return false;
    }

    // Permission granted
    return true;
  }

  static Future<bool> requestGalleryPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        // REQUEST PHOTOS PERMISSION ANDROID 13--
        final storagePermission = await ph.Permission.storage.request();
        if (!storagePermission.isGranted) {
          return false;
        }
      }
    }

    // iOS still needs permission
    if (Platform.isIOS) {
      final status = await ph.Permission.photos.request();
      if (status.isPermanentlyDenied) {
        if (!context.mounted) return false;
        CutsomAlertDialogues.showPermissionSettingsDialog(context, permissionName: "Gallery");
        return false;
      }

      if (!status.isGranted && !status.isLimited) {
        return false;
      }
    }

    return true; // permission granted
  }

  static Future<XFile?> pickFromCamera({
    required BuildContext context,
    int imgQuality = 85,
    double imgWidth = 1280,
    double imgHeight = 1280,
  }) async {
    final result = await requestCameraPermission(context);
    if (result) {
      return await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imgQuality,
        maxWidth: imgWidth,
        maxHeight: imgHeight,
      );
    }
    return null;
  }

  static Future<XFile?> pickFromGallery({
    required BuildContext context,
    int imgQuality = 85,
    double imgWidth = 1280,
    double imgHeight = 1280,
  }) async {
    final result = await requestGalleryPermission(context);
    if (result) {
      return await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imgQuality,
        maxWidth: imgWidth,
        maxHeight: imgHeight,
      );
    }
    return null;
  }

  static Future<List<XFile>?> pickMultipleImages({required BuildContext context, int limit = 50}) async {
    final hasPermission = await requestGalleryPermission(context);
    if (!hasPermission) return null;
    try {
      return await picker.pickMultiImage(limit: 50);
    } catch (e) {
      throw Exception(e);
    }
  }

  // Add meta data at image like watermark method
  // static Future<File?> addMetadataToImage({
  //   required File imagePath,
  //   required DateTime timestamp,
  //   required String imageName,
  //   required String comment,
  //   String source = "",
  // }) async {
  //   try {
  //     final originalImage = img.decodeImage(await imagePath.readAsBytes());
  //     if (originalImage == null) return imagePath;

  //     loc.LocationData? locationData = await getCurrentLocation();
  //     // Prepare text to draw
  //     final text = source != "gallery"
  //         ? 'Info- \n'
  //               'Lat: ${locationData!.latitude?.toStringAsFixed(5)}\n'
  //               'Lng: ${locationData.longitude?.toStringAsFixed(5)}\n'
  //               'Acc: ${locationData.accuracy?.toStringAsFixed(1)}m\n'
  //               'Date: ${DateFormat("dd-MM-yyyy HH:mm a").format(timestamp)}'
  //               '${comment.isNotEmpty ? "\nComment: $comment" : ""}'
  //         : 'Date: ${DateFormat("dd-MM-yyyy HH:mm a").format(timestamp)}\n'
  //               '${comment.isNotEmpty ? "\nComment: $comment" : ""}';

  //     final font = img.arial48;
  //     final textLines = text.split('\n');
  //     final lineHeight = font.lineHeight;
  //     final totalTextHeight = lineHeight * textLines.length;

  //     const leftPadding = 20;
  //     const bottomPadding = 10;
  //     final yStart = originalImage.height - totalTextHeight - bottomPadding;

  //     final textColor = img.ColorRgb8(255, 255, 255);
  //     int maxLineWidth = 0;
  //     for (final line in textLines) {
  //       int currentLineWidth = 0;
  //       // Iterate through the character code units in the line
  //       for (final codeUnit in line.codeUnits) {
  //         // Get the glyph/character information from the font
  //         final ch = font.characters[codeUnit];
  //         if (ch != null) {
  //           // Add the advance distance for the character
  //           currentLineWidth += ch.xAdvance;
  //         }
  //       }
  //       // Keep track of the longest line
  //       if (currentLineWidth > maxLineWidth) {
  //         maxLineWidth = currentLineWidth;
  //       }
  //     }

  //     // Add padding around text
  //     const paddingX = 10;
  //     const paddingY = 6;

  //     // Draw semi-transparent black rectangle behind text
  //     final rectX = leftPadding - paddingX;
  //     final rectY = yStart - paddingY;
  //     // final rectWidth = maxLineWidth + (paddingX * 2);
  //     final rectWidth = maxLineWidth + (paddingX);
  //     final rectHeight = totalTextHeight + (paddingY);

  //     final watermarkColor = img.ColorRgba8(0, 0, 0, 25); // black  opacity
  //     // final watermarkColor = img.ColorRgba8(0, 0, 0, 200); // black  opacity

  //     img.fillRect(
  //       originalImage,
  //       x1: rectX,
  //       y1: rectY,
  //       x2: (rectX + rectWidth).toInt(),
  //       y2: rectY + rectHeight,
  //       color: watermarkColor,
  //     );

  //     // Draw the white text on top of the background
  //     img.drawString(originalImage, text, font: font, x: leftPadding, y: yStart, color: textColor);

  //     // Build path
  //     final appDir = await getApplicationDocumentsDirectory();

  //     // final safeTitle = imageName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'); // Avoid invalid characters
  //     final safeTitle = _cleanFileName(imageName);
  //     final datePath = DateFormat("dd-MM-yyyy").format(timestamp); // Avoid slashes in folder names
  //     final folderPath = paths.join(appDir.path, safeTitle, datePath);

  //     //  Create directories if they don't exist
  //     final folder = Directory(folderPath);
  //     if (!await folder.exists()) {
  //       await folder.create(recursive: true);
  //     }
  //     // final formattedTime = DateFormat('yyyyMMdd_ hh_mm_ss_SSS_a').format(timestamp);
  //     final formattedTime =
  //         DateFormat('yyyyMMdd_').format(timestamp) +
  //         (timestamp.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
  //     final fileName = '${imageName}_$formattedTime.jpg';

  //     final newPath = paths.join(folderPath, fileName);

  //     // Save image
  //     final newImageFile = File(newPath)..writeAsBytesSync(img.encodeJpg(originalImage));

  //     return newImageFile;
  //   } catch (e) {
  //     String errorMsg = e.toString().split(":").last;
  //     throw Exception(errorMsg);
  //   }
  // }

  // Add meta data at image like watermark method using canvas
  static Future<File?> addMetadataWithCanvas({
    required File imageFile,
    required DateTime timestamp,
    required String imageName,
    required String comment,
    String source = "",
    String buildingName = "",
    String wingName = "",
    loc.LocationData? locationData,
    String? additionalPathInfo,
  }) async {
    try {
      // Load the image
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;

      // Create a recorder and canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw the original image
      canvas.drawImage(originalImage, Offset.zero, Paint());

      // Prepare text
      final text = source != "gallery"
          ? 'Info- \n'
                'Lat: ${locationData!.latitude?.toStringAsFixed(5)}\n'
                'Lng: ${locationData.longitude?.toStringAsFixed(5)}\n'
                'Acc: ${locationData.accuracy?.toStringAsFixed(1)}m\n'
                'Date: ${DateFormat("dd-MM-yyyy HH:mm a").format(timestamp)}'
                '${buildingName.isNotEmpty ? "\nBuilding Name: $buildingName" : ""}'
                '${wingName.isNotEmpty ? "\nWing Name: $wingName" : ""}'
                '${comment.isNotEmpty ? "\nComment: $comment" : ""}'
          : 'Date: ${DateFormat("dd-MM-yyyy HH:mm a").format(timestamp)}'
                '${buildingName.isNotEmpty ? "\nBuilding Name: $buildingName" : ""}'
                '${wingName.isNotEmpty ? "\nWing Name: $wingName" : ""}'
                '${comment.isNotEmpty ? "\nComment: $comment" : ""}';

      // Create text style
      final textStyle = ui.TextStyle(color: const ui.Color(0xFFFFFFFF), fontSize: 40);

      final paragraphStyle = ui.ParagraphStyle(textAlign: TextAlign.left);
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(text);

      final paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: originalImage.width.toDouble() - 40));

      // Draw semi-transparent rectangle behind text

      const paddingX = 20.0; // space from image left
      const paddingY = 10.0; // vertical padding inside rectangle
      const horizontalPadding = 10.0; // extra padding around text horizontally

      final rectHeight = paragraph.height + paddingY * 2;
      final rect = ui.Rect.fromLTWH(
        paddingX - horizontalPadding, // start slightly left of text
        // originalImage.height - rectHeight - 10, // y-position
        originalImage.height - paragraph.height - paddingY - 10,
        paragraph.width + horizontalPadding * 2, // width matches text + padding
        rectHeight, // height with vertical padding
      );

      final rectPaint = Paint()..color = const ui.Color.fromARGB(30, 0, 0, 0);
      canvas.drawRect(rect, rectPaint);

      // Draw text
      canvas.drawParagraph(paragraph, Offset(paddingX, originalImage.height - paragraph.height - paddingY - 10));

      // Finish drawing and convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(originalImage.width, originalImage.height);
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      if (pngBytes == null) {
        throw Exception("Failed to convert canvas to image bytes.");
      }

      // Save to file
      final appDir = await getApplicationDocumentsDirectory();
      final safeTitle = imageName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final datePath = DateFormat("dd-MM-yyyy").format(timestamp);
      final folderPath = paths.join(appDir.path, safeTitle, datePath);

      final folder = Directory(folderPath);
      if (!await folder.exists()) await folder.create(recursive: true);

      final formattedTime =
          DateFormat('yyyyMMdd_').format(timestamp) +
          (timestamp.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
      final fileName = additionalPathInfo != null && additionalPathInfo != ""
          ? '${imageName}_${formattedTime}_$additionalPathInfo.png'
          : '${imageName}_$formattedTime.png';
      final newPath = paths.join(folderPath, fileName);

      final file = File(newPath);
      await file.writeAsBytes(pngBytes.buffer.asUint8List());

      return file;
    } catch (e) {
      // Catch and rethrow a clean error
      String errorMsg = e.toString().split(":").last.trim();
      throw Exception("Error adding metadata: $errorMsg");
    }
  }

  // static String _cleanFileName(String path) {
  //   final name = paths.basenameWithoutExtension(path);

  //   return name.replaceAll(RegExp(r'(\.(jpe?g|png))+$', caseSensitive: false), '');
  // }

  static Future<File> compressIfNeeded(
    File file, {
    int maxSizeKB = 400,
    int maxWidth = 1280,
    int maxHeight = 1280,
  }) async {
    int quality = 90;
    Uint8List? result;

    while (file.lengthSync() > maxSizeKB * 1024 && quality >= 30) {
      result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) break;

      file = await file.writeAsBytes(result, flush: true);
      quality -= 10;
    }

    return file;
  }

  // try parse the date
  static DateTime? tryParseDate(String date) {
    if (date.trim().isEmpty) return null;

    // If it's an ISO DateTime → use native parser
    // Example: 2025-12-01 12:00:00.000 OR 2025-12-01T12:00:00Z
    try {
      return DateTime.parse(date);
    } catch (_) {}

    final List<DateFormat> formats = [
      // Date + Time (IMPORTANT for your error)
      DateFormat("dd-MMM-yyyy'T'HH:mm:ss"),
      DateFormat("d-MMM-yyyy'T'HH:mm:ss"),
      DateFormat("dd-MMM-yyyy HH:mm:ss"),
      DateFormat("d-MMM-yyyy HH:mm:ss"),

      // handle this way date "09-May-2001"
      DateFormat("dd-MMM-yyyy"),
      DateFormat("d-MMM-yyyy"),
      // Numeric dates
      DateFormat("dd-MM-yyyy"),
      DateFormat("d-MM-yyyy"),
      DateFormat("dd-M-yyyy"),
      DateFormat("yyyy-MM-dd"),
      DateFormat("MM-dd-yyyy"),
      DateFormat("M-d-yyyy"),

      // Slash formats
      DateFormat("dd/MM/yyyy"),
      DateFormat("d/MM/yyyy"),
      DateFormat("MM/dd/yyyy"),
      DateFormat("M/d/yyyy"),

      // Month names
      DateFormat("dd MMM yyyy"),
      DateFormat("d MMM yyyy"),
      DateFormat("dd MMMM yyyy"),
      DateFormat("d MMMM yyyy"),

      // With commas
      DateFormat("MMM d, yyyy"),
      DateFormat("MMMM d, yyyy"),
      DateFormat("dd MMM, yyyy"),
    ];

    for (final f in formats) {
      try {
        final parsed = f.parse(date);
        // Normalize to midnight
        return DateTime(parsed.year, parsed.month, parsed.day);
      } catch (_) {}
    }

    return null;
    // throw FormatException("Unable to parse date: '$date'");
  }

  // Pick pdf from device
  static Future<File?> pickedPdf() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        throw Exception("No PDF selected");
      }

      final File file = File(result.files.single.path!);
      debugPrint('Selected PDF: ${file.path}');
      return file;
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      throw Exception(erMsg);
    }
  }

  // print huge data
  static void printFull(Object? data) {
    const int chunkSize = 1000; // you can increase this
    final str = data.toString();
    for (var i = 0; i < str.length; i += chunkSize) {
      debugPrint(str.substring(i, i + chunkSize > str.length ? str.length : i + chunkSize));
    }
  }

  static Future<File> addInfoFile({
    required File file,
    required String projectId,
    required String imageTitle,
    String? additionalPathInfo,
  }) async {
    final dir = file.parent.path;
    final ext = paths.extension(file.path);

    final timestamp = DateTime.now();
    final formattedTime =
        DateFormat('yyyyMMdd_').format(timestamp) +
        (timestamp.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');

    final newFileName = additionalPathInfo != null && additionalPathInfo != ""
        ? '${projectId}_${imageTitle}_${formattedTime}_$additionalPathInfo$ext'
        : '${projectId}_${imageTitle}_$formattedTime$ext';

    final newPath = paths.join(dir, newFileName);

    // Rename replaces the original file
    return await file.rename(newPath);
  }
}
