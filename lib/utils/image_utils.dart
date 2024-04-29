// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:image_cropper/image_cropper.dart';
// import 'package:wechat_assets_picker/wechat_assets_picker.dart';
// import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import 'loading_utils.dart';
import 'toast_utils.dart';

enum ImageFormat { png, jpg, gif, webp, svg }

enum PathFormat {
  icons,
  images,
}

enum ImagePickType {
  common,
  image,
  video,
}

// var imagePickType = {
//   ImagePickType.common: RequestType.common,
//   ImagePickType.image: RequestType.image,
//   ImagePickType.video: RequestType.video,
// };

class ImageUtils {
  static Widget getAssets(
    String assetName, {
    Key? key,
    double? width,
    double? height,
    bool? isCustom = false,
    PathFormat pathFormat = PathFormat.icons,
    ImageFormat format = ImageFormat.png,
    BoxFit fit = BoxFit.contain,
    Color? color,
    void Function()? click,
  }) {
    return GestureDetector(
      onTap: click != null
          ? () {
              click.call();
            }
          : null,
      child: format == ImageFormat.svg
          ? SvgPicture.asset(
              key: key,
              isCustom!
                  ? assetName
                  : 'assets/${pathFormat.name}/$assetName.${format.name}',
              width: width,
              height: height,
              colorFilter: color != null
                  ? ColorFilter.mode(
                      color,
                      BlendMode.srcIn,
                    )
                  : null,
              fit: fit,
            )
          : Image.asset(
              isCustom!
                  ? assetName
                  : 'assets/${pathFormat.name}/$assetName.${format.name}',
              key: key,
              width: width,
              height: height,
              fit: fit,
              color: color,
            ),
    );
  }

  /// 图片压缩 File -> File
  static Future<Object?> imageCompressAndGetFile(
      {File? file, String? path}) async {
    if (file!.lengthSync() < 200 * 1024) {
      return file;
    }
    var quality = 100;
    if (file.lengthSync() > 6 * 1024 * 1024) {
      quality = 50;
    } else if (file.lengthSync() > 4 * 1024 * 1024) {
      quality = 60;
    } else if (file.lengthSync() > 2 * 1024 * 1024) {
      quality = 70;
    } else if (file.lengthSync() > 1 * 1024 * 1024) {
      quality = 80;
    } else if (file.lengthSync() > 0.5 * 1024 * 1024) {
      quality = 90;
    } else if (file.lengthSync() > 0.25 * 1024 * 1024) {
      quality = 100;
    }
    var dir = await path_provider.getTemporaryDirectory();
    var targetPath =
        "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      path ?? targetPath,
      minWidth: 600,
      quality: quality,
      rotate: 0,
    );
    return result;
  }

  /// 从相册取图片/视频
  // static Future getGallery(
  //   BuildContext context, {
  //   int? count = 1,
  //   ImagePickType type = ImagePickType.common,
  //   List<AssetEntity>? selectedAssets,
  //   Color? themeColor,
  // }) async {
  //   final List<AssetEntity>? result = await AssetPicker.pickAssets(
  //     context,
  //     pickerConfig: AssetPickerConfig(
  //       textDelegate: assetPickerTextDelegateFromLocale(
  //         const Locale('zh', 'CN'),
  //       ),
  //       selectedAssets: selectedAssets ?? [],
  //       requestType: imagePickType[type]!,
  //       maxAssets: count!,
  //       themeColor: themeColor,
  //       specialPickerType: count == 1 ? SpecialPickerType.noPreview : null,
  //     ),
  //   );
  //   if (result != null) {
  //     var assets = List<AssetEntity>.from(result);
  //     List<File> fileList = [];
  //     for (var element in assets) {
  //       File? file = await element.file;
  //       fileList.add(file!);
  //     }
  //     return [fileList, assets];
  //   }
  // }

  // /// 从相机取图片/视频
  // ///
  // /// maxTime 单位：s
  // static Future getCamera(
  //   BuildContext context, {
  //   int? count = 1,
  //   ImagePickType type = ImagePickType.common,
  //   List<AssetEntity>? selectedAssets,
  //   int? maxTime,
  //   bool? isSave = false,
  // }) async {
  //   File? fileToBeHandle;
  //   final AssetEntity? result = await CameraPicker.pickFromCamera(
  //     context,
  //     pickerConfig: CameraPickerConfig(
  //       enableRecording: true,
  //       enableTapRecording: true,
  //       textDelegate: cameraPickerTextDelegateFromLocale(
  //         const Locale('zh', 'CN'),
  //       ),
  //       maximumRecordingDuration: Duration(seconds: maxTime ?? 15),
  //       onEntitySaving: !isSave!
  //           ? (context, viewType, file) {
  //               fileToBeHandle = file;
  //               Navigator.of(context)
  //                 ..pop()
  //                 ..pop();
  //             }
  //           : null,
  //     ),
  //   );
  //   if (result != null) {
  //     fileToBeHandle = await result.file;
  //   }
  //   return fileToBeHandle;
  // }

  /// 裁剪图片
  static Future cropImage(String path, CropAspectRatio? aspectRatio,
      List<CropAspectRatioPreset>? aspectRatioPresets) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: 100,
      aspectRatio: aspectRatio ?? const CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: aspectRatioPresets ??
          [
            CropAspectRatioPreset.square,
          ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪图片',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: '裁剪图片',
          doneButtonTitle: "完成",
          cancelButtonTitle: "取消",
          aspectRatioLockEnabled: true,
          rotateButtonsHidden: true,
          resetButtonHidden: true,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );
    return croppedFile;
  }

  /*
  * 保存UI图片
  */
  static void saveUiImage(GlobalKey key) async {
    LoadingUtils.loading();
    ByteData? sourceByteData = await _capturePngToByteData(key);
    Uint8List sourceBytes = sourceByteData!.buffer.asUint8List();
    final result = await ImageGallerySaver.saveImage(
      sourceBytes,
      quality: 100,
    ); //这个是核心的保存图片的插件
    if (result['isSuccess']) {
      ToastUtils.toast(msg: "保存成功");
    } else {
      ToastUtils.toast(msg: "保存失败");
    }
    LoadingUtils.dismiss();
  }

  static Future<ByteData?> _capturePngToByteData(GlobalKey key) async {
    try {
      RenderRepaintBoundary? boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      double dpr =
          ui.PlatformDispatcher.instance.implicitView!.devicePixelRatio;
      // 获取当前设备的像素比
      ui.Image image = await boundary!.toImage(pixelRatio: dpr);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData;
    } catch (e) {
      // print(e);
    }
    return null;
  }

  /// ImageProvider转ui.Image 实际使用
  ///
  /// ui.Image image = await ImageUtils.loadImageByProvider(
  ///       CachedNetworkImageProvider(imgUrl));
  static Future<ui.Image> loadImageByProvider(
    ImageProvider provider, {
    ImageConfiguration config = ImageConfiguration.empty,
  }) async {
    Completer<ui.Image> completer = Completer<ui.Image>(); //完成的回调
    ImageStreamListener? listener;
    ImageStream stream = provider.resolve(config); //获取图片流
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      //监听
      final ui.Image image = frame.image;
      completer.complete(image); //完成
      stream.removeListener(listener!); //移除监听
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }
}
