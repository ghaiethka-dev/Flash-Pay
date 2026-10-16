// =============================================================================
//  lib/views/auth/widgets/fp_auth_field.dart
//  FlashPay — حقل إدخال موحّد لشاشات الدخول/التسجيل/الاستعادة
//  • نفس التصميم الحالي (عنوان فوق الحقل + أيقونة بلون التطبيق)
//  • التحقق عند مغادرة الحقل، ثم مباشرة أثناء الكتابة ليختفي الخطأ فور إصلاحه
//  • رسالة الخطأ تحت الحقل نفسه (حتى سطرين) + حد أحمر واضح
//  • ✅ إذا وُجد FPAuthThemeExt في الثيم (FPAuthTheme) تُؤخذ منه الألوان الذهبية تلقائياً
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flashpay/core/constants.dart';
import 'package:flashpay/views/auth/widgets/fp_auth_style.dart';

Color fpErrorColor(bool isDark) =>
    isDark ? const Color(0xFFFF8A80) : const Color(0xFFD32F2F);

InputDecoration fpAuthDecoration(
    BuildContext context, {
      required String hint,
      IconData? icon,
      Widget? prefix,
      Color? accent,
      Color? fill,
      double radius = 12.0,
    }) {
  final theme = Theme.of(context);
  final bool isDark = theme.brightness == Brightness.dark;
  final FPAuthThemeExt? ext = theme.extension<FPAuthThemeExt>();
  final Color primary =
      accent ?? ext?.accent ?? AppColors.primaryGradient.colors.first;
  final Color err = fpErrorColor(isDark);
  final Color borderColor = ext?.border ?? theme.dividerColor;

  OutlineInputBorder border(Color c, [double w = 1.0]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: c, width: w),
  );

  return InputDecoration(
    filled: true,
    fillColor: fill ??
        ext?.fill ??
        (isDark ? theme.scaffoldBackgroundColor : Colors.white),
    hintText: hint,
    hintStyle: TextStyle(
      color: ext?.hint ?? (isDark ? Colors.white38 : Colors.grey.shade400),
      fontSize: 13,
    ),
    counterText: '',
    suffixIcon: icon != null ? Icon(icon, color: primary) : null,
    prefixIcon: prefix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    errorMaxLines: 3,
    errorStyle: TextStyle(
      color: err,
      fontSize: 12,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
    border: border(borderColor),
    enabledBorder: border(borderColor),
    disabledBorder: border(borderColor.withOpacity(0.5)),
    focusedBorder: border(primary, 1.5),
    errorBorder: border(err, 1.5),
    focusedErrorBorder: border(err, 2.0),
  );
}

class FPAuthField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final GlobalKey<FormFieldState<String>>? fieldKey;

  final bool isPassword;
  final bool isObscured; // يُستخدم فقط مع onTogglePassword الخارجي
  final VoidCallback? onTogglePassword;

  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  // تخصيص الشكل (افتراضيًا: شكل شاشات الدخول)
  final Color? accent;
  final Color? fill;
  final double radius;

  const FPAuthField({
    Key? key,
    required this.label,
    required this.hint,
    this.icon,
    required this.controller,
    this.validator,
    this.focusNode,
    this.fieldKey,
    this.isPassword = false,
    this.isObscured = true,
    this.onTogglePassword,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.accent,
    this.fill,
    this.radius = 12.0,
  }) : super(key: key);

  @override
  State<FPAuthField> createState() => _FPAuthFieldState();
}

class _FPAuthFieldState extends State<FPAuthField> {
  late final GlobalKey<FormFieldState<String>> _key;
  late final FocusNode _focus;
  late final bool _ownsFocus;

  bool _hadFocus = false;
  bool _touched = false; // بعد أول مغادرة للحقل يبدأ التحقق المباشر
  bool _internalHidden = true;

  @override
  void initState() {
    super.initState();
    _key = widget.fieldKey ?? GlobalKey<FormFieldState<String>>();
    _ownsFocus = widget.focusNode == null;
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      _hadFocus = true;
      return;
    }
    if (_hadFocus && mounted) {
      _key.currentState?.validate();
      if (!_touched) setState(() => _touched = true);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    if (_ownsFocus) _focus.dispose();
    super.dispose();
  }

  bool get _hidden =>
      widget.onTogglePassword != null ? widget.isObscured : _internalHidden;

  void _toggle() {
    if (widget.onTogglePassword != null) {
      widget.onTogglePassword!();
    } else {
      setState(() => _internalHidden = !_internalHidden);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final FPAuthThemeExt? ext = Theme.of(context).extension<FPAuthThemeExt>();
    final bool isEmail = widget.keyboardType == TextInputType.emailAddress;

    final Widget? eye = widget.isPassword
        ? IconButton(
      tooltip: _hidden ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
      icon: Icon(
        _hidden ? Icons.visibility_off : Icons.visibility,
        color: ext?.hint ?? (isDark ? Colors.white54 : Colors.grey),
      ),
      onPressed: _toggle,
    )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ext?.label ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: widget.label,
          child: TextFormField(
            key: _key,
            controller: widget.controller,
            focusNode: _focus,
            enabled: widget.enabled,
            obscureText: widget.isPassword && _hidden,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            autofillHints: widget.autofillHints,
            autocorrect: !(widget.isPassword || isEmail),
            enableSuggestions: !(widget.isPassword || isEmail),
            validator: widget.validator,
            autovalidateMode: _touched
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            onChanged: (value) {
              // الخطأ الظاهر (مثلًا بعد الضغط على الزر) يختفي فور إصلاحه
              final st = _key.currentState;
              if (st != null && st.hasError) st.validate();
              widget.onChanged?.call(value);
            },
            onFieldSubmitted: widget.onSubmitted,
            style: TextStyle(
                color: ext?.text ?? (isDark ? Colors.white : Colors.black87)),
            decoration: fpAuthDecoration(
              context,
              hint: widget.hint,
              icon: widget.icon,
              prefix: eye,
              accent: widget.accent,
              fill: widget.fill,
              radius: widget.radius,
            ),
          ),
        ),
      ],
    );
  }
}

class FPAuthDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final GlobalKey<FormFieldState<T>>? fieldKey;
  final Color? accent;
  final Color? fill;
  final double radius;

  const FPAuthDropdown({
    Key? key,
    required this.label,
    required this.hint,
    this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.fieldKey,
    this.accent,
    this.fill,
    this.radius = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final FPAuthThemeExt? ext = theme.extension<FPAuthThemeExt>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ext?.label ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          child: DropdownButtonFormField<T>(
            key: fieldKey,
            value: value,
            isExpanded: true,
            dropdownColor: theme.cardColor,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: fpAuthDecoration(context,
                hint: hint,
                icon: icon,
                accent: accent,
                fill: fill,
                radius: radius),
            icon: Icon(Icons.arrow_drop_down,
                color: accent ??
                    ext?.accent ??
                    (isDark ? Colors.white54 : Colors.grey)),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}