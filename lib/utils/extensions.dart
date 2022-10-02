import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocabhub/constants/const.dart';

extension StringExtension on String {
  String? capitalize() {
    return toBeginningOfSentenceCase(this);
  }

  String initals() {
    /// Returns the first letter of each word in the string.
    return this.split(' ').map((e) => e.capitalize()!.substring(0, 1)).join();
  }
}

extension DateHelper on DateTime {
  String formatDate() {
    final now = DateTime.now();
    final differenceInDays = getDifferenceInDaysWithNow();

    if (isSameDate(now)) {
      return 'Today';
    } else if (differenceInDays == 1) {
      return 'Yesterday';
    } else {
      final formatter = DateFormat(dateFormatter);
      return formatter.format(this);
    }
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}

extension ContainerBorderRadius on double {
  BorderRadiusGeometry get allRadius => BorderRadius.circular(this);

  BorderRadiusGeometry get topLeftRadius =>
      BorderRadius.only(topLeft: Radius.circular(this));

  BorderRadiusGeometry get topRightRadius =>
      BorderRadius.only(topRight: Radius.circular(this));

  BorderRadiusGeometry get bottomLeftRadius =>
      BorderRadius.only(bottomLeft: Radius.circular(this));

  BorderRadiusGeometry get bottomRightRadius =>
      BorderRadius.only(bottomRight: Radius.circular(this));

  BorderRadiusGeometry get verticalRadius => BorderRadius.vertical(
      top: Radius.circular(this), bottom: Radius.circular(this));

  BorderRadiusGeometry get horizontalRadius => BorderRadius.horizontal(
      left: Radius.circular(this), right: Radius.circular(this));

  BorderRadiusGeometry get topRadius =>
      BorderRadius.vertical(top: Radius.circular(this));

  BorderRadiusGeometry get bottomRadius =>
      BorderRadius.vertical(bottom: Radius.circular(this));

  BorderRadiusGeometry get leftRadius =>
      BorderRadius.horizontal(left: Radius.circular(this));

  BorderRadiusGeometry get rightRadius =>
      BorderRadius.horizontal(right: Radius.circular(this));

  BorderRadiusGeometry get topLeftBottomRightRadius => BorderRadius.only(
      topLeft: Radius.circular(this), bottomRight: Radius.circular(this));

  BorderRadiusGeometry get topRightBottomLeftRadius => BorderRadius.only(
      topRight: Radius.circular(this), bottomLeft: Radius.circular(this));
}

extension ContainerPadding on double {
  EdgeInsetsGeometry get allPadding => EdgeInsets.all(this);

  EdgeInsetsGeometry get topPadding => EdgeInsets.only(top: this);

  EdgeInsetsGeometry get bottomPadding => EdgeInsets.only(bottom: this);

  EdgeInsetsGeometry get leftPadding => EdgeInsets.only(left: this);

  EdgeInsetsGeometry get rightPadding => EdgeInsets.only(right: this);

  EdgeInsetsGeometry get verticalPadding =>
      EdgeInsets.symmetric(vertical: this);

  EdgeInsetsGeometry get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: this);
}

extension RoundedShape on double {
  ShapeBorder get rounded =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(this));

  ShapeBorder get roundedTop => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(this), topRight: Radius.circular(this)));

  ShapeBorder get roundedBottom => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(this),
          bottomRight: Radius.circular(this)));

  ShapeBorder get roundedLeft => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(this), bottomLeft: Radius.circular(this)));

  ShapeBorder get roundedRight => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(this), bottomRight: Radius.circular(this)));

  ShapeBorder get roundedTopLeft => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(this)));

  ShapeBorder get roundedTopRight => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topRight: Radius.circular(this)));

  ShapeBorder get roundedBottomLeft => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(this)));

  ShapeBorder get roundedBottomRight => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(this)));

  ShapeBorder get roundedTopBottom => RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(this), bottom: Radius.circular(this)));

  ShapeBorder get roundedLeftRight => RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
          left: Radius.circular(this), right: Radius.circular(this)));

  ShapeBorder get roundedTopLeftBottomRight => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(this), bottomRight: Radius.circular(this)));

  ShapeBorder get roundedTopRightBottomLeft => RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(this), bottomLeft: Radius.circular(this)));
}

extension SizedBoxSpacer on double {
  SizedBox vSpacer() => SizedBox(height: this);

  SizedBox hSpacer() => SizedBox(width: this);

}
