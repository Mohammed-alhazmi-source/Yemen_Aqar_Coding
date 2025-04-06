import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/agent_verification_form.dart';
import 'package:flutter/material.dart';

class DocumentPickerWidget extends StatefulWidget {
  const DocumentPickerWidget({
    required this.onDocumentSelected,
    required this.fieldId,
    this.initialDocument,
    super.key,
  });

  final Function(AgentDocuments?) onDocumentSelected;
  final AgentDocuments? initialDocument;
  final int fieldId;

  @override
  State<DocumentPickerWidget> createState() => _DocumentPickerWidgetState();
}

class _DocumentPickerWidgetState extends State<DocumentPickerWidget> {
  AgentDocuments? selectedDocument;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    selectedDocument = widget.initialDocument;
  }

  @override
  void didUpdateWidget(DocumentPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDocument != widget.initialDocument) {
      selectedDocument = widget.initialDocument;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPickerUI(),
        if (selectedDocument?.isExisting ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: DownloadableDocuments(url: selectedDocument!.name),
          ),
      ],
    );
  }

  Widget _buildPickerUI() {
    return Row(
      children: [
        _buildUploadButton(),
        const SizedBox(width: 15),
        Expanded(
          child: _buildFileInfo(),
        ),
        if (selectedDocument != null) _buildRemoveButton(),
      ],
    );
  }

  Widget _buildUploadButton() {
    return DottedBorder(
      borderType: BorderType.RRect,
      color: context.color.textLightColor,
      radius: const Radius.circular(20),
      child: SizedBox(
        width: 60,
        height: 60,
        child: _isSelecting
            ? const Center(child: CircularProgressIndicator())
            : IconButton(
                onPressed: _pickDocument,
                icon: const Icon(Icons.upload),
              ),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          'UploadDocs'.translate(context),
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 4),
        CustomText(
          _getFileStatusText(),
          color: context.color.textLightColor,
          fontSize: 12,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return IconButton(
      icon: Icon(
        Icons.close,
        color: context.color.textLightColor,
      ),
      onPressed: () {},
    );
  }

  String _getFileStatusText() {
    if (selectedDocument == null) {
      return 'noFileSelected'.translate(context);
    }
    if (selectedDocument!.isExisting) {
      return 'existingDocument'.translate(context);
    }
    return '1 file selected';
  }

  Future<void> _pickDocument() async {
    if (_isSelecting) return;

    try {
      setState(() => _isSelecting = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (!mounted) return;

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final newDocument = AgentDocuments(
          name: file.name,
          file: file.path,
        );

        setState(() {
          selectedDocument = newDocument;
        });
        widget.onDocumentSelected(newDocument);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: CustomText('${'defaultErrorMsg'.translate(context)}: $e')),
      );
    } finally {
      setState(() => _isSelecting = false);
    }
  }
}
