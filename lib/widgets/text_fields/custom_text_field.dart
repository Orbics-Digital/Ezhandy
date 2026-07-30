import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezhandy_user/utils/app_colors.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  void Function()? onPrefixTap;
  void Function()? onTap;
  String? prefxicon;
  TextInputType? keyboardType;
  double? prefixRIghtPadding, sufixRIghtPadding, prefixLeftPadding;
  Widget? sufixImage, prefixImage;
  int? lines;
  double? borderRadius;
  bool readOnly, divider, label;
  // FocusNode? myFocusNode;
  EdgeInsetsGeometry? contentPadding;
  final String hint;
  final double? fontSize, width;
  final bool? obscureText;
  final Color? prefixIconColor, hintColor, fillColor, borderColor, fontColor;
  TextEditingController? controller;
  String? Function(String?)? validator;
  void Function(String)? onchange;
  bool? suffix_divider;
  final void Function()? onclickSufix;
  List<TextInputFormatter>? inputFormatters;
  FocusNode? focusNode;
  CustomTextField({
    Key? key,
    this.onPrefixTap,
    this.prefxicon,
    this.borderRadius,
    this.prefixRIghtPadding,
    this.sufixRIghtPadding,
    this.borderColor,
    this.fontColor,
    this.prefixImage,
    this.fillColor,
    this.prefixLeftPadding,
    this.lines,
    this.obscureText = false,
    this.hintColor,
    required this.hint,
    this.fontSize,
    this.width,
    this.prefixIconColor,
    // this.myFocusNode,
    this.contentPadding,
    this.onclickSufix,
    this.controller,
    this.validator,
    this.onchange,
    this.onTap,
    this.keyboardType,
    this.sufixImage,
    this.readOnly = false,
    this.divider = true,
    this.suffix_divider = false,
    this.label = true,
    this.inputFormatters,
    this.focusNode,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool get _isMultiline => (widget.lines ?? 1) > 1;

  bool get _hasPrefix =>
      widget.prefixImage != null || widget.prefxicon != null;

  /// Multiline + prefix: icon is laid out outside InputDecoration so it can
  /// top-align. Flutter's prefixIcon is always vertically centered.
  bool get _useExternalPrefix => _isMultiline && _hasPrefix;

  Widget? _buildInlinePrefixIcon() {
    if (_useExternalPrefix) return null;

    if (widget.prefixImage != null) return widget.prefixImage;

    if (widget.prefxicon == null) return null;

    return GestureDetector(
      onTap: widget.onPrefixTap,
      child: Container(
        width: 30.w,
        height: 25,
        margin: EdgeInsets.only(left: 15.w, right: 5.w),
        padding: EdgeInsets.only(
          right: widget.prefixRIghtPadding ?? 5.w,
          left: widget.prefixLeftPadding ?? 0,
        ),
        decoration: widget.divider == true
            ? const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.white)),
              )
            : null,
        child: Image.asset(
          widget.prefxicon!,
          color: widget.prefixIconColor ?? AppColors.orange,
          scale: 3,
        ),
      ),
    );
  }

  Widget _buildExternalPrefixIcon() {
    if (widget.prefixImage != null) {
      return widget.prefixImage!;
    }

    return GestureDetector(
      onTap: widget.onPrefixTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 22.w,
        height: 22.w,
        child: Image.asset(
          widget.prefxicon!,
          color: widget.prefixIconColor ?? AppColors.orange,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  InputDecoration _buildDecoration({required bool includePrefix}) {
    return InputDecoration(
      filled: !_useExternalPrefix,
      fillColor: widget.fillColor ?? AppColors.white,
      enabledBorder: _useExternalPrefix
          ? InputBorder.none
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.r),
              borderSide: BorderSide(
                  color: widget.borderColor ?? AppColors.greyBorder),
            ),
      focusedBorder: _useExternalPrefix
          ? InputBorder.none
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.r),
              borderSide:
                  BorderSide(color: widget.borderColor ?? AppColors.orange),
            ),
      focusedErrorBorder: _useExternalPrefix
          ? InputBorder.none
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.r),
              borderSide:
                  BorderSide(color: widget.borderColor ?? AppColors.red),
            ),
      errorBorder: _useExternalPrefix
          ? InputBorder.none
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.r),
              borderSide:
                  BorderSide(color: widget.borderColor ?? AppColors.red),
            ),
      contentPadding: widget.contentPadding ??
          (_useExternalPrefix
              ? EdgeInsets.fromLTRB(42.w, 10.h, 15.w, 10.h)
              : (!_hasPrefix
                  ? EdgeInsets.only(
                      top: 15.sp,
                      left: 15.sp,
                      bottom: 15.sp,
                      right: 15.sp,
                    )
                  : null)),
      label: widget.label ? Text(widget.hint) : null,
      labelStyle: TextStyle(
          color: widget.hintColor ?? AppColors.black, fontSize: 15),
      border: InputBorder.none,
      isDense: true,
      alignLabelWithHint: _isMultiline,
      hintStyle: TextStyle(
          color: widget.hintColor ?? AppColors.black, fontSize: 15),
      hintText: !widget.label ? widget.hint : null,
      errorStyle: const TextStyle(
          overflow: TextOverflow.visible, color: AppColors.red),
      errorMaxLines: 3,
      prefixIcon: includePrefix ? _buildInlinePrefixIcon() : null,
      prefixIconConstraints: const BoxConstraints(),
      suffixIcon: widget.sufixImage != null
          ? GestureDetector(
              onTap: widget.onclickSufix,
              child: Container(
                  height: 15,
                  margin: const EdgeInsets.only(
                      top: 5, bottom: 5, right: 10, left: 5),
                  decoration: widget.suffix_divider == true
                      ? BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: AppColors.black.withOpacity(0.5))))
                      : null,
                  child: widget.sufixImage),
            )
          : null,
    );
  }

  Widget _buildTextFormField({required bool includePrefix}) {
    return TextFormField(
      focusNode: widget.focusNode,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      onChanged: widget.onchange,
      validator: widget.validator,
      controller: widget.controller,
      obscureText: widget.obscureText!,
      minLines: widget.lines ?? 1,
      maxLines: widget.lines ?? 1,
      textAlignVertical:
          _isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
      cursorColor: AppColors.orange,
      inputFormatters: widget.inputFormatters,
      style: TextStyle(
          fontSize: widget.fontSize ?? 14.sp,
          color: widget.fontColor ?? AppColors.black,
          height: 1.3),
      decoration: _buildDecoration(includePrefix: includePrefix),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_useExternalPrefix) {
      return Container(
        decoration: BoxDecoration(
          color: widget.fillColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.r),
          border: Border.all(
            color: widget.borderColor ?? AppColors.greyBorder,
          ),
        ),
        child: Stack(
          children: [
            _buildTextFormField(includePrefix: false),
            Positioned(
              top: 10.h,
              left: 12.w,
              child: _buildExternalPrefixIcon(),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.r),
      ),
      child: _buildTextFormField(includePrefix: true),
    );
  }
}
