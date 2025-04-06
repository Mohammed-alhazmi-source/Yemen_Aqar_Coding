class AgentVerificationFormFieldsModel {
  AgentVerificationFormFieldsModel({
    required this.id,
    required this.name,
    required this.fieldType,
    required this.formFieldsValues,
  });

  factory AgentVerificationFormFieldsModel.fromJson(Map<String, dynamic> json) {
    return AgentVerificationFormFieldsModel(
      id: json['id'],
      name: json['name'],
      fieldType: json['field_type'],
      formFieldsValues: List<FormFieldValue>.from(
          json['form_fields_values'].map((x) => FormFieldValue.fromJson(x))),
    );
  }
  final int id;
  final String name;
  final String fieldType;
  final List<FormFieldValue> formFieldsValues;
}

class FormFieldValue {
  FormFieldValue({
    required this.id,
    required this.verifyCustomerFormId,
    required this.value,
  });

  factory FormFieldValue.fromJson(Map<String, dynamic> json) {
    return FormFieldValue(
      id: json['id'],
      verifyCustomerFormId: json['verify_customer_form_id'],
      value: json['value'],
    );
  }
  final int id;
  final int verifyCustomerFormId;
  final String value;
}
