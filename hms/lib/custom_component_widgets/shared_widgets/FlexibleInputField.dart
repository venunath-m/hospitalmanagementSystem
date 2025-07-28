import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class FlexibleInputField extends StatefulWidget {
  final FieldType fieldType;
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? customValidator;
  final bool isRequired;
  final void Function(String)? onChanged;

  const FlexibleInputField({
    Key? key,
    required this.fieldType,
    required this.controller,
    required this.label,
    this.hintText,
    this.customValidator,
    this.isRequired = false,
    this.onChanged,
  }) : super(key: key);

  @override
  State<FlexibleInputField> createState() => _FlexibleInputFieldState();
}

class _FlexibleInputFieldState extends State<FlexibleInputField> {
  bool _obscureText = true;
  PhoneNumber? _phoneNumber;

  @override
  void initState() {
    super.initState();
    if (widget.fieldType == FieldType.phone) {
      _phoneNumber = PhoneNumber(isoCode: 'IN');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Special case for phone
    if (widget.fieldType == FieldType.phone) {
      return InternationalPhoneNumberInput(
        onInputChanged: (number) {
          _phoneNumber = number;
          widget.onChanged?.call(number.phoneNumber ?? '');
        },
        textFieldController: widget.controller,
        initialValue: _phoneNumber,
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.DROPDOWN,
        ),
        autoValidateMode: AutovalidateMode.onUserInteraction,
        inputDecoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
        ),
        validator:
            widget.customValidator ??
            (v) {
              if (widget.isRequired && (v == null || v.trim().isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
      );
    }

    // Special case for date/datetime
    if (widget.fieldType == FieldType.date ||
        widget.fieldType == FieldType.datetime) {
      return TextFormField(
        controller: widget.controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? picked;
          if (widget.fieldType == FieldType.date) {
            picked = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
          } else {
            picked = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                picked = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  time.hour,
                  time.minute,
                );
              }
            }
          }
          if (picked != null) {
            widget.controller.text = DateFormat(
              'yyyy-MM-dd${widget.fieldType == FieldType.datetime ? ' HH:mm' : ''}',
            ).format(picked);
            widget.onChanged?.call(widget.controller.text);
          }
        },
        validator:
            widget.customValidator ??
            (v) {
              if (widget.isRequired && (v == null || v.trim().isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
      );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.fieldType == FieldType.password && _obscureText,
      maxLines: widget.fieldType == FieldType.multiline ? null : 1,
      keyboardType: _getKeyboardType(),
      inputFormatters: _getInputFormatters(),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        suffixIcon: widget.fieldType == FieldType.password
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() {
                  _obscureText = !_obscureText;
                }),
              )
            : null,
      ),
      validator: widget.customValidator ?? _defaultValidator,
      onChanged: widget.onChanged,
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.fieldType) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.number:
      case FieldType.currency:
      case FieldType.zipcode:
        return TextInputType.number;
      case FieldType.url:
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.fieldType == FieldType.number ||
        widget.fieldType == FieldType.currency ||
        widget.fieldType == FieldType.zipcode) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  String? _defaultValidator(String? value) {
    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
      return 'This field is required';
    }
    if (widget.fieldType == FieldType.email) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value ?? '')) {
        return 'Enter a valid email';
      }
    }
    if (widget.fieldType == FieldType.url) {
      final urlRegex = RegExp(r'^(http|https)://');
      if (!urlRegex.hasMatch(value ?? '')) {
        return 'Enter a valid URL';
      }
    }
    return null;
  }
}
