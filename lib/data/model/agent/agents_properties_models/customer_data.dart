import 'package:ebroker/utils/admob/native_ad_manager.dart';

class CustomerData implements NativeAdWidgetContainer {
  const CustomerData({
    required this.id,
    required this.slugId,
    required this.name,
    required this.profile,
    required this.mobile,
    required this.email,
    required this.address,
    required this.city,
    required this.country,
    required this.state,
    required this.facebookId,
    required this.twitterId,
    required this.youtubeId,
    required this.instagramId,
    required this.aboutMe,
    required this.projectCount,
    required this.propertyCount,
    required this.isVerified,
  });

  CustomerData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        slugId = json['slug_id']?.toString() ?? '',
        name = json['name']?.toString() ?? '',
        profile = json['profile']?.toString() ?? '',
        mobile = json['mobile']?.toString() ?? '',
        email = json['email']?.toString() ?? '',
        address = json['address'] as String? ?? '',
        city = json['city'] as String? ?? '',
        country = json['country'] as String? ?? '',
        state = json['state'] as String? ?? '',
        facebookId = json['facebook_id'] as String? ?? '',
        twitterId = json['twitter_id'] as String? ?? '',
        youtubeId = json['youtube_id'] as String? ?? '',
        instagramId = json['instagram_id'] as String? ?? '',
        aboutMe = json['about_me'] as String? ?? '',
        projectCount = json['projects_count'] as int,
        propertyCount = json['property_count'] as int,
        isVerified = json['is_verify'] as bool;

  final int id;
  final String slugId;
  final String name;
  final String profile;
  final String mobile;
  final String email;
  final String? address;
  final String? city;
  final String? country;
  final String? state;
  final String? facebookId;
  final String? twitterId;
  final String? youtubeId;
  final String? instagramId;
  final String? aboutMe;
  final int? projectCount;
  final int? propertyCount;
  final bool? isVerified;
}
