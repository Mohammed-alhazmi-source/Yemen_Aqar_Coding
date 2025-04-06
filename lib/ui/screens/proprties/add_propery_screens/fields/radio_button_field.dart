import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class CustomRadioField extends CustomField {
  @override
  String type = 'radiobutton';
  String? selectedRadioValue;
  @override
  String? backValue() {
    return selectedRadioValue;
  }

  @override
  void init() {
    id = data['id'];
    String? value;
    if (data['value'] != null) {
      value = data['value'].toString();
    }
    selectedRadioValue = value ?? (data['type_values'] as List).first;
    super.init();
  }

  @override
  Widget render(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48.rw(context),
              height: 48.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                height: 24,
                width: 24,
                child: FittedBox(
                  child: UiUtils.imageType(
                    data['image'],
                    color: Constant.adaptThemeColorSvg
                        ? context.color.tertiaryColor
                        : null,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10.rw(context),
            ),
            CustomText(
              data['name'],
              fontWeight: FontWeight.w500,
              fontSize: context.font.large,
              color: context.color.textColorDark,
            ),
            if (data['is_required'] == 1) ...[
              const SizedBox(width: 5),
              CustomText('*', color: context.color.error),
            ],
          ],
        ),
        SizedBox(
          height: 14.rh(context),
        ),
        Wrap(
          children: List.generate(data['type_values']?.length ?? 0, (index) {
            return Padding(
              padding: EdgeInsetsDirectional.only(
                start: index == 0 ? 0 : 4,
                end: 4,
                bottom: 4,
                top: 4,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  selectedRadioValue = data['type_values'][index];
                  update(() {});
                  // selectedRadio.value = widget.radioValues?[index];
                  // AbstractField.fieldsData.addAll(
                  //     {widget.parameters['id']: widget.radioValues?[index]});
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.color.borderColor,
                      width: 1.5,
                    ),
                    color: selectedRadioValue == data['type_values']?[index]
                        ? context.color.tertiaryColor.withValues(alpha: 0.1)
                        : context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    child: CustomText(
                      data['type_values'][index],
                      color: selectedRadioValue == data['type_values'][index]
                          ? context.color.tertiaryColor
                          : context.color.textLightColor,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
