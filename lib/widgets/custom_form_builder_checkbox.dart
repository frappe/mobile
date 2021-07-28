// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/widgets/custom_check_box.dart';

// class CustomFormBuilderCheckbox extends StatefulWidget {
//   final String attribute;
//   final List<FormFieldValidator> validators;
//   final bool initialValue;
//   final bool readOnly;
//   final InputDecoration decoration;
//   final ValueChanged onChanged;
//   final ValueTransformer valueTransformer;
//   final bool leadingInput;

//   final Widget label;

//   final Color activeColor;
//   final Color checkColor;
//   final MaterialTapTargetSize materialTapTargetSize;
//   final bool tristate;
//   final FormFieldSetter onSaved;
//   final EdgeInsets contentPadding;
//   final Color focusColor;
//   final Color hoverColor;
//   final FocusNode focusNode;
//   final bool autoFocus;
//   final MouseCursor mouseCursor;
//   final VisualDensity visualDensity;

//   CustomFormBuilderCheckbox({
//     Key key,
//     @required this.attribute,
//     @required this.label,
//     this.initialValue,
//     this.validators = const [],
//     this.readOnly = false,
//     this.decoration = const InputDecoration(),
//     this.onChanged,
//     this.valueTransformer,
//     this.leadingInput = false,
//     this.activeColor,
//     this.checkColor,
//     this.materialTapTargetSize,
//     this.tristate = false,
//     this.onSaved,
//     this.contentPadding = const EdgeInsets.all(0.0),
//     this.focusColor,
//     this.hoverColor,
//     this.focusNode,
//     this.autoFocus = false,
//     this.mouseCursor,
//     this.visualDensity,
//   }) : super(key: key);

//   @override
//   _CustomFormBuilderCheckboxState createState() =>
//       _CustomFormBuilderCheckboxState();
// }

// class _CustomFormBuilderCheckboxState extends State<CustomFormBuilderCheckbox> {
//   bool _readOnly = false;
//   final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
//   FormBuilderState _formState;
//   bool _initialValue;

//   @override
//   void initState() {
//     _formState = FormBuilder.of(context);
//     _initialValue = widget.initialValue ??
//         ((_formState?.initialValue?.containsKey(widget.attribute) ?? false)
//             ? _formState.initialValue[widget.attribute]
//             : null);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   Widget _checkbox(FormFieldState<dynamic> field) {
//     return SizedBox(
//       width: 24.0,
//       height: 24,
//       child: CustomCheckbox(
//         value: (field.value == null && !widget.tristate) ? false : field.value,
//         activeColor: widget.activeColor,
//         checkColor: widget.checkColor,
//         tristate: widget.tristate,
//         onChanged: _readOnly
//             ? null
//             : (bool value) {
//                 FocusScope.of(context).requestFocus(FocusNode());
//                 field.didChange(value);
//                 widget.onChanged?.call(value);
//               },
//         focusColor: widget.focusColor,
//         hoverColor: widget.hoverColor,
//         focusNode: widget.focusNode,
//         autofocus: widget.autoFocus,
//         mouseCursor: widget.mouseCursor,
//         visualDensity: VisualDensity(horizontal: 0, vertical: -4),
//       ),
//     );
//   }

//   Widget _leading(FormFieldState<dynamic> field) {
//     if (widget.leadingInput) return _checkbox(field);
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TODO

//     return FormField(
//       key: _fieldKey,
//       enabled: !_readOnly,
//       initialValue: _initialValue,
//       onSaved: (val) {
//         var transformed;
//         if (widget.valueTransformer != null) {
//           transformed = widget.valueTransformer(val);
//         } else {}
//         widget.onSaved?.call(transformed ?? val);
//       },
//       builder: (FormFieldState<dynamic> field) {
//         return InputDecorator(
//           decoration: widget.decoration.copyWith(
//             enabled: !_readOnly,
//             errorText: field.errorText,
//           ),
//           child: Container(
//             child: GestureDetector(
//               onTap: _readOnly
//                   ? null
//                   : () {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       final newValue = !(field.value ?? false);
//                       field.didChange(newValue);
//                       widget.onChanged?.call(newValue);
//                     },
//               child: Row(children: [
//                 _leading(field),
//                 SizedBox(
//                   width: 8,
//                 ),
//                 widget.label,
//               ]),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }



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
              decoration: state.decoration(),
              child: CheckboxListTile(
                dense: true,
                isThreeLine: false,
                title: label,
                subtitle: subtitle,
                value: (state.value == null && !tristate) ? false : state.value,
                onChanged: state.enabled
                    ? (val) {
                        state.requestFocus();
                        state.didChange(val);
                      }
                    : null,
                checkColor: checkColor,
                activeColor: activeColor,
                secondary: secondary,
                controlAffinity: controlAffinity,
                autofocus: autofocus,
                tristate: tristate,
                contentPadding: contentPadding,
                selected: selected,
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
