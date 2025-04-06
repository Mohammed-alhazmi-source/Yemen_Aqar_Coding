class AgentVerificationFormValueModel {
  AgentVerificationFormValueModel({
    this.id,
    this.userId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.user,
    this.verifyCustomerValues,
  });

  AgentVerificationFormValueModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['verify_customer_values'] != null) {
      verifyCustomerValues = <VerifyCustomerValues>[];
      json['verify_customer_values'].forEach((v) {
        verifyCustomerValues!.add(VerifyCustomerValues.fromJson(v));
      });
    }
  }
  int? id;
  int? userId;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  User? user;
  List<VerifyCustomerValues>? verifyCustomerValues;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (verifyCustomerValues != null) {
      data['verify_customer_values'] =
          verifyCustomerValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  User({
    this.id,
    this.name,
    this.profile,
    this.propertyCount,
    this.projectsCount,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profile = json['profile'];
    propertyCount = json['property_count'];
    projectsCount = json['projects_count'];
  }
  int? id;
  String? name;
  String? profile;
  int? propertyCount;
  int? projectsCount;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profile'] = profile;
    data['property_count'] = propertyCount;
    data['projects_count'] = projectsCount;
    return data;
  }
}

class VerifyCustomerValues {
  VerifyCustomerValues({
    this.id,
    this.verifyCustomerId,
    this.verifyCustomerFormId,
    this.value,
    this.verifyForm,
  });

  VerifyCustomerValues.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    verifyCustomerId = json['verify_customer_id'];
    verifyCustomerFormId = json['verify_customer_form_id'];
    value = json['value'];
    verifyForm = json['verify_form'] != null
        ? VerifyForm.fromJson(json['verify_form'])
        : null;
  }
  int? id;
  int? verifyCustomerId;
  int? verifyCustomerFormId;
  dynamic value;
  VerifyForm? verifyForm;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['verify_customer_id'] = verifyCustomerId;
    data['verify_customer_form_id'] = verifyCustomerFormId;
    data['value'] = value;
    if (verifyForm != null) {
      data['verify_form'] = verifyForm!.toJson();
    }
    return data;
  }
}

class VerifyForm {
  VerifyForm({this.id, this.name, this.fieldType, this.formFieldsValues});

  VerifyForm.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fieldType = json['field_type'];
    if (json['form_fields_values'] != null) {
      formFieldsValues = <FormFieldsValues>[];
      json['form_fields_values'].forEach((v) {
        formFieldsValues!.add(FormFieldsValues.fromJson(v));
      });
    }
  }
  int? id;
  String? name;
  String? fieldType;
  List<FormFieldsValues>? formFieldsValues;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['field_type'] = fieldType;
    if (formFieldsValues != null) {
      data['form_fields_values'] =
          formFieldsValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FormFieldsValues {
  FormFieldsValues({this.id, this.verifyCustomerFormId, this.value});

  FormFieldsValues.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    verifyCustomerFormId = json['verify_customer_form_id'];
    value = json['value'];
  }
  int? id;
  int? verifyCustomerFormId;
  String? value;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['verify_customer_form_id'] = verifyCustomerFormId;
    data['value'] = value;
    return data;
  }
}
