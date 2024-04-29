import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialUtils {
  final BuildContext context;

  TutorialUtils(this.context);

  static TutorialCoachMarkController? tutorialCoachMarkController;
  void showTutorial({
    bool? hideSkip,
    String? skipText,
    TextStyle? skipTextStyle,
    AlignmentGeometry? skipPosition,
    Color? bgColor,
    double? opacity,
    double? padding,
    List? keyList,
    double? radius,
    Function(TargetFocus)? clickTarget,
    Function(TargetFocus)? clickOverlay,
    Function(TargetFocus, TapDownDetails)? clickTargetWithTapPosition,
    Function()? onSkip,
    Function()? onFinish,
  }) {
    TutorialCoachMark(
      targets: _createTargets(
        keyList: keyList ?? [],
        radius: radius,
        skipPosition: skipPosition,
      ),
      colorShadow: bgColor ?? Colors.red,
      pulseEnable: false,
      skipWidget: Text(
        skipText ?? "跳过",
        style: skipTextStyle,
      ),
      hideSkip: hideSkip ?? false,
      paddingFocus: padding ?? 0,
      opacityShadow: opacity ?? 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        onFinish?.call();
      },
      onClickTarget: (target) {
        clickTarget?.call(target);
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        clickTargetWithTapPosition?.call(target, tapDetails);
      },
      onClickOverlay: (target) {
        clickOverlay?.call(target);
      },
      onSkip: () {
        onSkip?.call();
        return true;
      },
    ).show(context: context);
  }

  List<TargetFocus> _createTargets({
    List? keyList,
    double? radius,
    AlignmentGeometry? skipPosition,
  }) {
    List<TargetFocus> targets = [];

    for (var i in keyList!) {
      // int index = keyList.indexOf(i);
      var id = ValueKey(i['key']);
      GlobalKey key = i['key'];
      double? left = i['LTRB'][0];
      double? top = i['LTRB'][1];
      double? right = i['LTRB'][2];
      double? bottom = i['LTRB'][3];
      String? type = i["shape"];
      targets.add(
        TargetFocus(
          identify: id,
          keyTarget: key,
          shape:
              type == "Circle" ? ShapeLightFocus.Circle : ShapeLightFocus.RRect,
          alignSkip: skipPosition ?? Alignment.center,
          radius: radius,
          enableTargetTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                left: left,
                top: top,
                right: right,
                bottom: bottom,
              ),
              builder: (context, controller) {
                tutorialCoachMarkController = controller;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    i['widget'],
                  ],
                );
              },
            ),
          ],
        ),
      );
    }

    return targets;
  }
}
