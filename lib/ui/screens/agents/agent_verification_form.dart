import 'package:dio/dio.dart';
import 'package:ebroker/data/cubits/agents/apply_agent_verification_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_agent_verification_form_fields.dart';
import 'package:ebroker/data/cubits/agents/fetch_agent_verification_form_values.dart';
import 'package:ebroker/data/model/agent/agent_verification_form_fields_model.dart';
import 'package:ebroker/data/model/agent/agent_verification_form_values_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class AgentVerificationForm extends StatefulWidget {
  const AgentVerificationForm({super.key, this.formValues});

  final AgentVerificationFormValueModel? formValues;

  @override
  State<AgentVerificationForm> createState() => _AgentVerificationFormState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FetchAgentVerificationFormValuesCubit(),
          ),
          BlocProvider(
            create: (context) => FetchAgentVerificationFormFieldsCubit(),
          ),
        ],
        child: AgentVerificationForm(
          formValues:
              arguments?['formValues'] as AgentVerificationFormValueModel?,
        ),
      ),
    );
  }
}

class _AgentVerificationFormState extends State<AgentVerificationForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formData = {};
  bool _isFormInitialized = false;
  final Map<int, AgentDocuments> _selectedDocuments = {};

  @override
  void initState() {
    super.initState();
    context
        .read<FetchAgentVerificationFormFieldsCubit>()
        .fetchAgentsVerificationForm(forceRefresh: true);
    context
        .read<FetchAgentVerificationFormValuesCubit>()
        .fetchAgentsVerificationFormValues(forceRefresh: true);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'agentVerificationForm'.translate(context),
      ),
      body: BlocProvider.value(
        value: context.read<FetchAgentVerificationFormValuesCubit>(),
        child: BlocBuilder<FetchAgentVerificationFormFieldsCubit,
            FetchAgentVerificationFormFieldsState>(
          builder: (context, fieldsState) {
            return BlocBuilder<FetchAgentVerificationFormValuesCubit,
                FetchAgentVerificationFormValuesState>(
              builder: (context, valuesState) {
                if (fieldsState is FetchAgentVerificationFormFieldsSuccess &&
                    valuesState is FetchAgentVerificationFormValuesSuccess) {
                  // Call _initializeFormData here, when both states are successful
                  if (!_isFormInitialized) {
                    _initializeFormData(valuesState.values.first);
                  }
                  return _buildForm(context, fieldsState, valuesState);
                } else if (fieldsState
                        is FetchAgentVerificationFormFieldsSuccess &&
                    valuesState is FetchAgentVerificationFormValuesFailure) {
                  // Handle the case where values failed to load
                  return _buildFormWithoutValues(context, fieldsState);
                } else if (fieldsState
                        is FetchAgentVerificationFormFieldsLoading ||
                    valuesState is FetchAgentVerificationFormValuesLoading) {
                  return Center(child: UiUtils.progress());
                } else if (fieldsState
                    is FetchAgentVerificationFormFieldsFailure) {
                  return const SomethingWentWrong();
                }
                return Container();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormWithoutValues(
    BuildContext context,
    FetchAgentVerificationFormFieldsSuccess fieldsState,
  ) {
    // Build the form with empty or default values
    return _buildForm(
      context,
      fieldsState,
      FetchAgentVerificationFormValuesSuccess(values: []),
    );
  }

  Widget _buildForm(
    BuildContext context,
    FetchAgentVerificationFormFieldsSuccess fieldsState,
    FetchAgentVerificationFormValuesSuccess valuesState,
  ) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...fieldsState.fields.map(_buildFormField),
              const SizedBox(height: 20),
              BlocConsumer<ApplyAgentVerificationCubit,
                  ApplyAgentVerificationState>(
                listener: (context, state) {
                  if (state is ApplyAgentVerificationSuccess) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      'verificationApplied'.translate(context),
                    );
                    context.read<FetchSystemSettingsCubit>().fetchSettings(
                          isAnonymous: false,
                          forceRefresh: true,
                        );
                    Navigator.pop(context);
                  } else if (state is ApplyAgentVerificationFailure) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      '${'failedTOApplyVerification'.translate(context)}: ${state.errorMessage}',
                    );
                  }
                },
                builder: (context, state) {
                  return UiUtils.buildButton(
                    context,
                    onPressed: _submitForm,
                    buttonTitle: state is ApplyAgentVerificationInProgress
                        ? ''
                        : 'submit'.translate(context),
                    prefixWidget: state is ApplyAgentVerificationInProgress
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.color.buttonColor,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(AgentVerificationFormFieldsModel field) {
    final fieldValue = _formData[field.name];

    switch (field.fieldType) {
      case 'text':
      case 'number':
        return _buildTextField(field, fieldValue);
      case 'radio':
        return _buildRadioGroup(field, fieldValue);
      case 'checkbox':
        return _buildCheckboxGroup(field, fieldValue);
      case 'dropdown':
        return _buildDropdown(field, fieldValue);
      case 'textarea':
        return _buildTextArea(field, fieldValue);
      case 'file':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(field.name),
            const SizedBox(
              height: 10,
            ),
            DocumentPickerWidget(
              fieldId: field.id,
              initialDocument: _selectedDocuments[field.id],
              onDocumentSelected: (document) {
                setState(() {
                  if (document != null) {
                    _selectedDocuments[field.id] = document;
                  } else {
                    _selectedDocuments.remove(field.id);
                  }
                });
              },
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildTextField(
    AgentVerificationFormFieldsModel field,
    String? fieldValue,
  ) {
    if (!_controllers.containsKey(field.name)) {
      _controllers[field.name] = TextEditingController(text: fieldValue);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(field.name),
        const SizedBox(height: 10),
        CustomTextFormField(
          hintText: '${'enter'.translate(context)} ${field.name}',
          controller: _controllers[field.name],
          action: TextInputAction.next,
          validator: CustomTextFieldValidator.nullCheck,
          onChange: (value) {
            _formData[field.name] = value;
          },
          keyboard: field.fieldType == 'number'
              ? TextInputType.number
              : TextInputType.text,
          formaters: field.fieldType == 'number'
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRadioGroup(
    AgentVerificationFormFieldsModel field,
    String? fieldValue,
  ) {
    return FormField<String>(
      initialValue: fieldValue,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${field.name} ${'isRequired'.translate(context)}';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(field.name),
            const SizedBox(height: 10),
            ...field.formFieldsValues.map(
              (option) => Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        state.hasError ? Colors.red : context.color.borderColor,
                    width: 1.5,
                  ),
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RadioListTile(
                  activeColor: context.color.tertiaryColor,
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: CustomText(option.value),
                  value: option.value,
                  groupValue: state.value,
                  onChanged: (value) {
                    state.didChange(value);

                    _formData[field.name] = value;
                  },
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 12),
                child: CustomText(
                  state.errorText!,
                  color: context.color.error,
                  fontSize: context.font.small,
                ),
              ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildCheckboxGroup(
    AgentVerificationFormFieldsModel field,
    dynamic fieldValue,
  ) {
    var initialValues = <String>[];
    if (fieldValue is String) {
      initialValues = fieldValue.split(',').map((e) => e.trim()).toList();
    } else if (fieldValue is List<String>) {
      initialValues = fieldValue;
    }

    return FormField<List<String>>(
      initialValue: initialValues,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${field.name} ${'isRequired'.translate(context)}';
        }
        return null;
      },
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(field.name),
            const SizedBox(height: 10),
            ...field.formFieldsValues.map(
              (option) => Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        state.hasError ? Colors.red : context.color.borderColor,
                    width: 1.5,
                  ),
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CheckboxListTile(
                  activeColor: context.color.tertiaryColor,
                  title: CustomText(option.value),
                  value: state.value!.contains(option.value),
                  onChanged: (bool? checked) {
                    final newValue = List<String>.from(state.value!);
                    if (checked!) {
                      newValue.add(option.value);
                    } else {
                      newValue.remove(option.value);
                    }
                    state.didChange(newValue);

                    // Convert the list to a comma-separated string
                    _formData[field.name] = newValue.join(',');
                  },
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 12),
                child: CustomText(
                  state.errorText!,
                  color: context.color.error,
                  fontSize: context.font.small,
                ),
              ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(
    AgentVerificationFormFieldsModel field,
    String? fieldValue,
  ) {
    return FormField<String>(
      initialValue: fieldValue,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${field.name} ${'isRequired'.translate(context)}';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(field.name),
            const SizedBox(height: 10),
            DropdownButtonHideUnderline(
              child: Container(
                width: context.screenWidth,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        state.hasError ? Colors.red : context.color.borderColor,
                    width: 1.5,
                  ),
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  menuWidth: context.screenWidth * 0.945,
                  borderRadius: BorderRadius.circular(10),
                  elevation: 1,
                  dropdownColor: context.color.secondaryColor,
                  isExpanded: true,
                  value: state.value,
                  hint: CustomText(
                      '${'select'.translate(context)} ${field.name}'),
                  items: List.generate(field.formFieldsValues.length, (index) {
                    return DropdownMenuItem<String>(
                      value: field.formFieldsValues[index].value,
                      child: CustomText(field.formFieldsValues[index].value),
                    );
                  }),
                  // field.formFieldsValues
                  //     .map(
                  //       (option) => DropdownMenuItem<String>(
                  //         value: option.value,
                  //         child: CustomText(option.value),
                  //       ),
                  //     )
                  //     .toList(),
                  onChanged: (value) {
                    state.didChange(value);

                    _formData[field.name] = value;
                  },
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 12),
                child: CustomText(
                  state.errorText!,
                  color: context.color.error,
                  fontSize: context.font.small,
                ),
              ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildTextArea(
    AgentVerificationFormFieldsModel field,
    String? fieldValue,
  ) {
    if (!_controllers.containsKey(field.name)) {
      _controllers[field.name] = TextEditingController(text: fieldValue);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(field.name),
        const SizedBox(height: 10),
        CustomTextFormField(
          hintText: '${'enter'.translate(context)} ${field.name}',
          controller: _controllers[field.name],
          action: TextInputAction.newline,
          validator: CustomTextFieldValidator.nullCheck,
          onChange: (value) {
            _formData[field.name] = value;
          },
          maxLine: 5,
          minLine: 3,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _initializeFormData(AgentVerificationFormValueModel values) {
    if (_isFormInitialized) return;

    try {
      final userFormValues = values;

      if (userFormValues.verifyCustomerValues != null) {
        for (final value in userFormValues.verifyCustomerValues!) {
          final fieldName = value.verifyForm?.name;
          final fieldValue = value.value;
          final fieldId = value.verifyForm?.id;
          final fieldType = value.verifyForm?.fieldType;

          if (fieldName == null || fieldType == null) continue;

          switch (fieldType) {
            case 'checkbox':
              _formData[fieldName] = _parseCheckboxValue(fieldValue);
            case 'file':
              if (fieldId != null && fieldValue != null) {
                _selectedDocuments[fieldId] = AgentDocuments(
                  id: fieldId,
                  name: fieldValue.toString(),
                  isExisting: true,
                );
              }
            case 'radio':
            case 'dropdown':
              _formData[fieldName] = fieldValue?.toString();
            default:
              _formData[fieldName] = fieldValue?.toString() ?? '';
              _controllers[fieldName] = TextEditingController(
                text: fieldValue?.toString() ?? '',
              );
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing form data: $e\n$stackTrace');
      // Handle error appropriately
    } finally {
      _isFormInitialized = true;
    }
  }

  List<String> _parseCheckboxValue(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) return value.split(',').map((e) => e.trim()).toList();
    return [];
  }

  Widget buildDocumentsPicker(
    BuildContext context,
    AgentVerificationFormFieldsModel field,
    String? fieldValue,
    AgentDocuments? selectedDocument,
    Function(AgentDocuments?) onDocumentSelected,
  ) {
    return Row(
      children: [
        DottedBorder(
          borderType: BorderType.RRect,
          color: context.color.textLightColor,
          radius: const Radius.circular(20),
          child: SizedBox(
            width: 60,
            height: 60,
            child: IconButton(
              onPressed: () => _pickDocument(context, onDocumentSelected),
              icon: const Icon(Icons.upload),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText('UploadDocs'.translate(context)),
              const SizedBox(height: 4),
              CustomText(
                selectedDocument != null
                    ? selectedDocument.name
                    : 'noFileSelected'.translate(context),
                color: context.color.textLightColor,
                fontSize: context.font.small,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (selectedDocument != null)
          IconButton(
            icon: Icon(Icons.close, color: context.color.textLightColor),
            onPressed: () => onDocumentSelected(null),
          ),
      ],
    );
  }

  Future<void> _pickDocument(
    BuildContext context,
    Function(AgentDocuments?) onDocumentSelected,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        onDocumentSelected(
          AgentDocuments(
            name: file.name,
            file: file.path,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: CustomText('${'defaultErrorMsg'.translate(context)}: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        final fetchFormFieldsState =
            context.read<FetchAgentVerificationFormFieldsCubit>().state;
        if (fetchFormFieldsState is FetchAgentVerificationFormFieldsSuccess) {
          final formFields = <Map<String, dynamic>>[];

          for (final field in fetchFormFieldsState.fields) {
            if (field.fieldType == 'file') {
              final documentField = prepareDocumentForFormField(
                field.id,
                _selectedDocuments[field.id],
              );
              if (documentField.isNotEmpty) {
                formFields.add(documentField);
              }
              if (documentField.isEmpty) {
                await HelperUtils.showSnackBarMessage(
                  context,
                  'Please select a document',
                );
                return;
              }
            } else if (field.fieldType == 'checkbox') {
            } else {
              final value = _formData[field.name];
              if (value != null) {
                formFields.add({
                  'id': field.id.toString(),
                  'value': value.toString(),
                });
              }
            }
          }

          final submissionData = {
            'form_fields': formFields,
          };

          await context.read<ApplyAgentVerificationCubit>().applyVerification(
                parameters: submissionData,
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText('unableToSubmitForm'.translate(context)),
            ),
          );
        }
      }
    } catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        '${'unableToSubmitForm'.translate(context)} $e',
      );
    }
  }
}

class AgentDocuments {
  AgentDocuments({
    required this.name,
    this.file,
    this.id,
    this.isExisting = false,
  });
  final String name;
  final String? file;
  final int? id;
  final bool isExisting;
}

class DocumentPickerWidget extends StatefulWidget {
  const DocumentPickerWidget({
    required this.onDocumentSelected,
    required this.fieldId,
    super.key,
    this.initialDocument,
  });
  final Function(AgentDocuments?) onDocumentSelected;
  final AgentDocuments? initialDocument;
  final int fieldId;

  @override
  DocumentPickerWidgetState createState() => DocumentPickerWidgetState();
}

class DocumentPickerWidgetState extends State<DocumentPickerWidget> {
  AgentDocuments? selectedDocument;

  @override
  void initState() {
    super.initState();
    selectedDocument = widget.initialDocument;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDocumentsPicker(context),
        if (selectedDocument != null)
          DownloadableDocuments(url: widget.initialDocument!.name),
      ],
    );
  }

  Widget buildDocumentsPicker(BuildContext context) {
    return Row(
      children: [
        DottedBorder(
          borderType: BorderType.RRect,
          color: context.color.textLightColor,
          radius: const Radius.circular(20),
          child: SizedBox(
            width: 60,
            height: 60,
            child: IconButton(
              onPressed: () => _pickDocument(context),
              icon: const Icon(Icons.upload),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText('UploadDocs'.translate(context)),
            const SizedBox(height: 4),
            CustomText(
              selectedDocument != null
                  ? (selectedDocument!.isExisting
                      ? 'Existing document'
                      : '1 file selected')
                  : 'No file selected',
              color: context.color.textLightColor,
              fontSize: context.font.small,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          selectedDocument = AgentDocuments(
            name: file.name,
            file: file.path,
          );
        });
        widget.onDocumentSelected(selectedDocument);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: CustomText('${'defaultErrorMsg'.translate(context)}: $e')),
      );
    }
  }
}

Map<String, dynamic> prepareDocumentForFormField(
  int fieldId,
  AgentDocuments? document,
) {
  if (document != null) {
    if (document.isExisting) {
      // For existing documents, we need to send the ID or name
      return {
        'id': fieldId.toString(),
        'value': document.name,
      };
    } else if (document.file != null) {
      // For new documents, send the file
      return {
        'id': fieldId.toString(),
        'value':
            MultipartFile.fromFileSync(document.file!, filename: document.name),
      };
    }
  }
  return {};
}
