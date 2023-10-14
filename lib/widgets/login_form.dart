import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {required this.initialValue,
      required this.hint,
      required this.isPasswordField,
      required this.onChnaged,
      required this.validator,
      super.key});

  final String? initialValue;
  final String hint;
  final bool isPasswordField;
  final void Function(String?) onChnaged;
  final String? Function(String?)? validator;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.initialValue,
      cursorColor: Colors.grey.shade900,
      cursorWidth: 0.5,
      onChanged: widget.onChnaged,
      validator: widget.validator,
      obscureText: widget.isPasswordField ? _obscureText : false,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(
                width: 1, color: Colors.grey.shade300), // Outline color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(
                color: Colors.grey.shade300), // Focused outline color
          ),
          suffixIcon: widget.isPasswordField
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText =
                          !_obscureText; // Toggle password visibility
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[200], // Background color
          hintText: widget.hint,
          contentPadding: const EdgeInsets.all(17),
          hintStyle: TextStyle(
              fontSize: 13, color: Colors.grey.shade500) // Placeholder text
          ),
      style: const TextStyle(color: Colors.black), // Text color
    );
  }
}
