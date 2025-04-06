import 'package:ebroker/data/model/agent/agents_properties_models/customer_data.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/project_data.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/properties_data.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';

class AgentsProperty implements NativeAdWidgetContainer {
  const AgentsProperty({
    required this.customerData,
    required this.propertiesData,
    required this.projectData,
  });

  AgentsProperty.fromJson(Map<String, dynamic> json)
      : projectData = (json['projects_data'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(ProjectData.fromJson)
            .toList(),
        propertiesData = (json['properties_data'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(PropertiesData.fromJson)
            .toList(),
        customerData = CustomerData.fromJson(
          json['customer_data'] as Map<String, dynamic>,
        );

  final List<ProjectData> projectData;
  final List<PropertiesData> propertiesData;
  final CustomerData customerData;

  AgentsProperty copyWith({
    List<ProjectData>? projectData,
    List<PropertiesData>? propertiesData,
    CustomerData? customerData,
  }) {
    return AgentsProperty(
      projectData: projectData ?? this.projectData,
      propertiesData: propertiesData ?? this.propertiesData,
      customerData: customerData ?? this.customerData,
    );
  }
}
