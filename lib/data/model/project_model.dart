class ProjectModel {
  ProjectModel({
    this.id,
    this.slugId,
    this.categoryId,
    this.title,
    this.description,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.metaImage,
    this.image,
    this.videoLink,
    this.location,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.addedBy,
    this.customer,
    this.gallaryImages,
    this.documents,
    this.plans,
    this.category,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] ?? 0,
      slugId: map['slug_id'] ?? '',
      categoryId: map['category_id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      metaTitle: map['meta_title'] ?? '',
      metaDescription: map['meta_description'] ?? '',
      metaKeywords: map['meta_keywords'] ?? '',
      metaImage: map['meta_image'] ?? '',
      image: map['image'] ?? '',
      videoLink: map['video_link'] ?? '',
      location: map['location'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? 0,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      addedBy: map['added_by'] ?? 0,
      customer: Customer.fromMap(map['customer'] ?? {}),
      gallaryImages: (map['gallary_images'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map<Document>(Document.fromMap)
          .toList(),
      documents: (map['documents'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map<Document>(Document.fromMap)
          .toList(),
      plans: (map['plans'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map<Plan>(Plan.fromMap)
          .toList(),
      category: ProjectCategory.fromMap(map['category'] ?? {}),
    );
  }
  int? id;
  String? slugId;
  int? categoryId;
  String? title;
  String? description;
  String? metaTitle;
  String? metaDescription;
  String? metaKeywords;
  String? metaImage;
  String? image;
  String? videoLink;
  String? location;
  String? latitude;
  String? longitude;
  String? city;
  String? state;
  String? country;
  String? type;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? addedBy;
  Customer? customer;
  List<Document>? gallaryImages;
  List<Document>? documents;
  List<Plan>? plans;
  ProjectCategory? category;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug_id': slugId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      'meta_image': metaImage,
      'image': image,
      'video_link': videoLink,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'type': type,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'added_by': addedBy,
      'customer': customer?.toMap(),
      'gallary_images': gallaryImages?.map((e) => e.toMap()).toList(),
      'documents': documents?.map((x) => x.toMap()).toList(),
      'plans': plans?.map((x) => x.toMap()).toList(),
      'category': category?.toMap(),
    };
  }

  @override
  String toString() {
    return 'ProjectModel(id: $id, slugId: $slugId, categoryId: $categoryId, title: $title, description: $description, metaTitle: $metaTitle, metaDescription: $metaDescription, metaKeywords: $metaKeywords, metaImage: $metaImage, image: $image, videoLink: $videoLink, location: $location, latitude: $latitude, longitude: $longitude, city: $city, state: $state, country: $country, type: $type, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, addedBy: $addedBy, customer: $customer, gallaryImages: $gallaryImages, documents: $documents, plans: $plans, category: $category)';
  }
}

class Customer {
  Customer({
    this.id,
    this.name,
    this.profile,
    this.email,
    this.mobile,
    this.customertotalpost,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      profile: map['profile'],
      email: map['email'],
      mobile: map['mobile'],
      customertotalpost: map['customertotalpost'],
    );
  }
  int? id;
  String? name;
  String? profile;
  String? email;
  String? mobile;
  int? customertotalpost;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profile': profile,
      'email': email,
      'mobile': mobile,
      'customertotalpost': customertotalpost,
    };
  }
}

class Document {
  Document({
    this.id,
    this.name,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.projectId,
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      projectId: map['project_id'],
    );
  }
  int? id;
  String? name;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? projectId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'project_id': projectId,
    };
  }
}

class Plan {
  Plan({
    this.id,
    this.title,
    this.document,
    this.createdAt,
    this.updatedAt,
    this.projectId,
  });

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'],
      title: map['title'],
      document: map['document'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      projectId: map['project_id'],
    );
  }
  int? id;
  String? title;
  String? document;
  String? createdAt;
  String? updatedAt;
  int? projectId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'document': document,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'project_id': projectId,
    };
  }
}

class ProjectCategory {
  ProjectCategory({
    this.id,
    this.category,
    this.image,
  });

  factory ProjectCategory.fromMap(Map<String, dynamic> map) {
    return ProjectCategory(
      id: map['id'],
      category: map['category'],
      image: map['image'],
    );
  }
  final int? id;
  final String? category;
  final String? image;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'image': image,
    };
  }
}
