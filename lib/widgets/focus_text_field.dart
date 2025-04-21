import 'dart:async';
import 'package:flutter/material.dart';

class FocusTextField extends StatefulWidget {
  final void Function()? onFocus;
  final void Function()? onBlur;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? initialValue;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onDebouncedChanged;
  final Duration debounceDuration;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final bool readOnly;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;

  const FocusTextField({
    super.key,
    this.onFocus,
    this.onBlur,
    this.focusNode,
    this.controller,
    this.initialValue,
    this.decoration,
    this.onChanged,
    this.onDebouncedChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.readOnly = false,
    this.onFieldSubmitted,
    this.onEditingComplete,
  });

  @override
  _FocusTextFieldState createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<FocusTextField> {
  late FocusNode _internalFocusNode;
  bool _isExternalFocusNode = false;

  TextEditingController? _internalController;
  bool get _isExternalController => widget.controller != null;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _isExternalFocusNode = widget.focusNode != null;
    _internalFocusNode = widget.focusNode ?? FocusNode();

    if (!_isExternalController) {
      _internalController = TextEditingController(text: widget.initialValue);
    }

    _internalFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant FocusTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update focus node if it changed
    if (oldWidget.focusNode != widget.focusNode && !_isExternalFocusNode) {
      _internalFocusNode.removeListener(_handleFocusChange);
      _internalFocusNode.dispose();
      _internalFocusNode = widget.focusNode ?? FocusNode();
      _internalFocusNode.addListener(_handleFocusChange);
      _isExternalFocusNode = widget.focusNode != null;
    }

    // Update controller if needed
    if (!_isExternalController && widget.initialValue != oldWidget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _internalController?.text = widget.initialValue ?? '';
      });
    }
  }
  void _handleFocusChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_internalFocusNode.hasFocus) {
        widget.onFocus?.call();
      } else {
        debugPrint("[FocusTextField] Blur triggered");
        widget.onBlur?.call();
      }
    });
  }

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);

    // ⏱ Debounce first
    if (widget.onDebouncedChanged != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration, () {
        widget.onDebouncedChanged?.call(value);
      });
    }

    // ✅ Defer form validation to after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final form = Form.of(context);
      form.validate();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _internalFocusNode.removeListener(_handleFocusChange);

    if (!_isExternalFocusNode) {
      _internalFocusNode.dispose();
    }

    if (!_isExternalController) {
      _internalController?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveController = widget.controller ?? _internalController;

    return TextFormField(
      focusNode: _internalFocusNode,
      controller: effectiveController,
      decoration: widget.decoration,
      onChanged: _onTextChanged,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      style: widget.style,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      onFieldSubmitted: widget.onFieldSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );
  }
}
