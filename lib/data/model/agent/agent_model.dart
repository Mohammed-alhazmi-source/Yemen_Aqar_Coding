import 'package:ebroker/utils/admob/native_ad_manager.dart';

class AgentModel implements NativeAdWidgetContainer {
  const AgentModel({
    required this.id,
    required this.name,
    required this.profile,
    required this.email,
    required this.projectsCount,
    required this.propertyCount,
    required this.mobile,
    required this.isVerified,
    required this.isAdmin,
  });

  AgentModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] ?? '',
        profile = json['profile']?.toString() ?? '',
        email = json['email']?.toString() ?? '',
        mobile = json['mobile']?.toString() ?? '',
        projectsCount = json['projects_count'] ?? 0,
        propertyCount = json['property_count'] ?? 0,
        isVerified = json['is_verified'] ?? false,
        isAdmin = json['is_admin'] ?? false;

  final int id;
  final String name;
  final String profile;
  final String email;
  final int projectsCount;
  final int propertyCount;
  final String mobile;
  final bool isVerified;
  final bool isAdmin;

  AgentModel copywith({
    int? id,
    String? name,
    String? profile,
    String? email,
    int? projectsCount,
    int? propertyCount,
    String? mobile,
    bool? isVerified,
    bool? isAdmin,
  }) =>
      AgentModel(
        id: id ?? this.id,
        name: name ?? this.name,
        profile: profile ?? this.profile,
        email: email ?? this.email,
        projectsCount: projectsCount ?? this.projectsCount,
        propertyCount: propertyCount ?? this.propertyCount,
        mobile: mobile ?? this.mobile,
        isVerified: isVerified ?? this.isVerified,
        isAdmin: isAdmin ?? this.isAdmin,
      );
}
