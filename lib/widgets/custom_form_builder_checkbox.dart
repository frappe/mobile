// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/widgets/custom_check_box.dart';

/// Single Checkbox field
class CustomFormBuilderCheckbox extends FormBuilderField<bool> {
  /// The primary content of the CheckboxListTile.
  ///
  /// Typically a [Text] widget.
  final Widget label;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget subtitle;

  /// A widget to display on the opposite side of the tile from the checkbox.
  ///
  /// Typically an [Icon] widget.
  final Widget secondary;

  /// The color to use when this checkbox is checked.
  ///
  /// Defaults to accent color of the current [Theme].
  final Color activeColor;

  /// The color to use for the check icon when this checkbox is checked.
  ///
  /// Defaults to Color(0xFFFFFFFF).
  final Color checkColor;

  /// Where to place the control relative to its label.
  final ListTileControlAffinity controlAffinity;

  /// Defines insets surrounding the tile's contents.
  ///
  /// This value will surround the [Checkbox], [title], [subtitle], and [secondary]
  /// widgets in [CheckboxListTile].
  ///
  /// When the value is null, the `contentPadding` is `EdgeInsets.symmetric(horizontal: 16.0)`.
  final EdgeInsets contentPadding;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// If true the checkbox's [value] can be true, false, or null.
  ///
  /// Checkbox displays a dash when its value is null.
  ///
  /// When a tri-state checkbox ([tristate] is true) is tapped, its [onChanged]
  /// callback will be applied to true if the current value is false, to null if
  /// value is true, and to false if value is null (i.e. it cycles through false
  /// => true => null => false when tapped).
  ///
  /// If tristate is false (the default), [value] must not be null.
  final bool tristate;

  /// Whether to render icons and text in the [activeColor].
  ///
  /// No effort is made to automatically coordinate the [selected] state and the
  /// [value] state. To have the list tile appear selected when the checkbox is
  /// checked, pass the same value to both.
  ///
  /// Normally, this property is left to its default value, false.
  final bool selected;

  /// Creates a single Checkbox field
  CustomFormBuilderCheckbox({
    //From Super
    Key key,
    @required String name,
    FormFieldValidator<bool> validator,
    bool initialValue,
    InputDecoration decoration = const InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    ValueChanged onChanged,
    ValueTransformer<bool> valueTransformer,
    bool enabled = true,
    FormFieldSetter<bool> onSaved,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    VoidCallback onReset,
    FocusNode focusNode,
    this.activeColor,
    @required this.label,
    this.checkColor,
    this.subtitle,
    this.secondary,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.contentPadding = EdgeInsets.zero,
    this.autofocus = false,
    this.tristate = false,
    this.selected = false,
  }) : super(
          key: key,
          initialValue: initialValue,
          name: name,
          validator: validator,
          valueTransformer: valueTransformer,
          onChanged: onChanged,
          autovalidateMode: autovalidateMode,
          onSaved: onSaved,
          enabled: enabled,
          onReset: onReset,
          decoration: decoration,
          focusNode: focusNode,
          builder: (FormFieldState<bool> field) {
            final state = field as _CustomFormBuilderCheckboxState;

            return InputDecorator(
              decoration: state.decoration,
              child: GestureDetector(
                onTap: state.enabled
                    ? () {
                        final newValue = !(field.value ?? false);
                        state.requestFocus();
                        state.didChange(newValue);
                      }
                    : null,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Transform.scale(
                          scale: 0.8,
                          child: CustomCheckbox(
                            value: (state.value == null && !tristate)
                                ? false
                                : state.value,
                            onChanged: state.enabled
                                ? (val) {
                                    state.requestFocus();
                                    state.didChange(val);
                                  }
                                : null,
                            checkColor: checkColor,
                            activeColor: activeColor,
                            autofocus: autofocus,
                            tristate: tristate,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      label,
                    ],
                  ),
                ),
              ),
            );
          },
        );

  @override
  _CustomFormBuilderCheckboxState createState() =>
      _CustomFormBuilderCheckboxState();
}

class _CustomFormBuilderCheckboxState
    extends FormBuilderFieldState<CustomFormBuilderCheckbox, bool> {}
