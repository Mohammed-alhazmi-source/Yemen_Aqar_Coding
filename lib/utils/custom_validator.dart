import 'package:flutter/material.dart';

class CustomValidator<T> extends FormField<T> {
  CustomValidator({
    required FormFieldValidator<T> super.validator,
    required Widget Function(FormFieldState<T> state) builder,
    super.key,
    super.initialValue,
  }) : super(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<T> state) {
            return builder(state);
          },
        );
}
