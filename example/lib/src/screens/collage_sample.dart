library image_collage_widget;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_collage_widget/image_collage_widget.dart';
import 'package:image_collage_widget/utils/CollageType.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

/// A CollageWidget.
class CollageSample extends StatefulWidget {
  final CollageType collageType;

  CollageSample(this.collageType);

  @override
  State<StatefulWidget> createState() {
    return _CollageSample();
  }
}

class _CollageSample extends State<CollageSample> {
  var globalKey = GlobalKey(debugLabel: "screenShotKey");
  ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Text(
            "Collage maker",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                _captureImage();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text("Share",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ),
              ),
            )
          ]),
      body: Screenshot(
        key: globalKey,
        controller: _screenshotController,

        /// @param withImage:- If withImage = true, It will load image from given {filePath (default = "Camera")}
        /// @param collageType:- CollageType.CenterBig

        child: Center(
          child: ImageCollageWidget(
            collageType: widget.collageType,
            withImage: true,
          ),
        ),
      ),
    );
  }

  /// call this method to share file
  _shareScreenShot(String imgpath) async {
    final Email email = Email(
      attachmentPath: imgpath,
    );

    await FlutterEmailSender.send(email);
  }

  _captureImage() async {
    var directory;

    if (Platform.isIOS) {
      /// For iOS platform
      directory = (await getApplicationDocumentsDirectory()).path;
    } else {
      /// For android platform
      directory = (await getTemporaryDirectory()).path;
    }
    String fileName = DateTime.now().toIso8601String();
    String path = '$directory/$fileName.png';
    debugPrint("saved screenshot path: " + path);
    _screenshotController.capture(path: path).then((File image) {
      ///Capture Done`
      debugPrint("saved screenshot path1: " + image.path);

      _shareScreenShot(image.path);
    }).catchError((onError) {
      debugPrint(onError);
    });
  }
}
