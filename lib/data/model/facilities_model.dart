class FacilitiesModel {
  final int? id;
  final String? name;
  final String? typeOfParameter;
  final List<String>? typeValues;
  final String? image;
  final int? isRequired;

  const FacilitiesModel({
    this.id,
    this.name,
    this.typeOfParameter,
    this.typeValues,
    this.image,
    this.isRequired,
  });

  FacilitiesModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        typeOfParameter = json['type_of_parameter'],
        typeValues = json['type_values'] != null
            ? List<String>.from(json['type_values'])
            : null,
        image = json['image'],
        isRequired = json['is_required'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type_of_parameter': typeOfParameter,
        'type_values': typeValues,
        'image': image,
        'is_required': isRequired,
      };
}
