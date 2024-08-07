import 'dart:io';

import 'package:celebrare/controller/image_mask_controller.dart';
import 'package:celebrare/utils/colors.dart';
import 'package:celebrare/widgets/use_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:widget_mask/widget_mask.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();
  File? image;

  Future<void> _selectImage(BuildContext context) async {
    final mask = Provider.of<ImageMaskController>(context, listen: false);
    final XFile? im = await picker.pickImage(source: ImageSource.gallery);
    if (im == null) {
      return Future.error('No image selected');
    }

    final CroppedFile? croppedImg =
        await ImageCropper().cropImage(sourcePath: im.path, uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: primaryTextColor,
        toolbarWidgetColor: Colors.white,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
        ],
      ),
      IOSUiSettings(
        title: 'Crop Image',
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
        ],
      ),
      WebUiSettings(
        context: context,
      ),
    ]);

    if (croppedImg == null) {
      return Future.error('Image cropping cancelled');
    }

    showDialog(
      context: context,
      builder: (ctx) => UseImage(image: File(croppedImg.path)),
    ).whenComplete(() {
      if (mask.getImgNum != 5.toString()) {
        setState(() {
          image = File(croppedImg.path);
        });
      }
    });
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mask = Provider.of<ImageMaskController>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        shadowColor: Colors.black,
        backgroundColor: primaryBg,
        leading: IconButton(
          onPressed: _exitApp,
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Add Image / Icon',
          style: TextStyle(fontFamily: 'Olivetti', color: primaryTextColor),
        ),
        centerTitle: true,
      ),
      backgroundColor: primaryBg,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  children: [
                    const Text(
                      'Upload Image',
                      style: TextStyle(
                          fontFamily: 'Olivetti', color: primaryTextColor),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await _selectImage(context);
                        },
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(177, 25),
                            backgroundColor: secondaryColors,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3))),
                        child: const Text(
                          'Choose from Device',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              image != null
                  ? mask.getFinalNum == 0.toString()
                      ? Image.file(image!)
                      : WidgetMask(
                          blendMode: BlendMode.srcATop,
                          childSaveLayer: true,
                          mask: Image.file(
                            image!,
                            fit: BoxFit.cover,
                          ),
                          child: Image.asset(
                            'assets/user_image_frame_${mask.getFinalNum}.png',
                            width: 300,
                          ))
                  : const SizedBox(
                      height: 20,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
