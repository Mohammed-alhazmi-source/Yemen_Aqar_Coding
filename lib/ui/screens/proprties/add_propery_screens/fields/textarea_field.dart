import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/ui/screens/widgets/custom_text_form_field.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/cupertino.dart';

class CustomTextAreaField extends CustomField {
  @override
  String type = 'textarea';
  TextEditingController? controller;

  @override
  void init() {
    id = data['id'];

    var initialValue = '';
    if (data['value'] != null && data['value'] != 'null') {
      initialValue = "${data['value']}";
    }
    controller = TextEditingController(text: initialValue);
    super.init();
  }

  @override
  String? backValue() {
    return controller?.text;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget render(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
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
          CustomTextFormField(
            hintText: 'Write something...',
            minLine: 4,
            maxLine: 100,
            validator: CustomTextFieldValidator.maxFifty,
            controller: controller,
            onChange: (value) {},
          ),
        ],
      ),
    );
  }
}
