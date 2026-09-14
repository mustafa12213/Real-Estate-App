class DeveloperModel {
  final int id;
  final String name;
  final String? imageUrl;

  DeveloperModel({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory DeveloperModel.fromJson(Map<String, dynamic> json) {
    return DeveloperModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['name_en'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

class CompoundModel {
  final int id;
  final String compoundName;
  final String? imageUrl;

  CompoundModel({
    required this.id,
    required this.compoundName,
    this.imageUrl,
  });

  factory CompoundModel.fromJson(Map<String, dynamic> json) {
    return CompoundModel(
      id: json['id'] ?? 0,
      compoundName: json['compound_name'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

class UptownTypeModel {
  final int id;
  final String name;

  UptownTypeModel({
    required this.id,
    required this.name,
  });

  factory UptownTypeModel.fromJson(Map<String, dynamic> json) {
    return UptownTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['name_en'] ?? '',
    );
  }
}

class UnitImageModel {
  final int id;
  final String imageUrl;

  UnitImageModel({
    required this.id,
    required this.imageUrl,
  });

  factory UnitImageModel.fromJson(Map<String, dynamic> json) {
    return UnitImageModel(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class UnitModel {
  final int id;
  final String name;
  final String? description;
  final double space;
  final int? bed;
  final int? bathroom;
  final String? stratPrice;
  final String? installmentPrice;
  final int? installmentYears;
  final String? installmentPlan;
  final String type;
  final String status;
  final String? deliveryDate;
  final String? googleMap;
  final double? longitude;
  final double? latitude;
  final DeveloperModel? developer;
  final CompoundModel? compound;
  final UptownTypeModel? uptownType;
  final List<UnitImageModel> unitImages;

  UnitModel({
    required this.id,
    required this.name,
    this.description,
    required this.space,
    this.bed,
    this.bathroom,
    this.stratPrice,
    this.installmentPrice,
    this.installmentYears,
    this.installmentPlan,
    required this.type,
    required this.status,
    this.deliveryDate,
    this.googleMap,
    this.longitude,
    this.latitude,
    this.developer,
    this.compound,
    this.uptownType,
    this.unitImages = const [],
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['name_en'] ?? '',
      description: json['description'] ?? json['description_en'],
      space: (json['space'] ?? 0).toDouble(),
      bed: json['bed'],
      bathroom: json['bathroom'],
      stratPrice: json['strat_price'],
      installmentPrice: json['installment_price'],
      installmentYears: json['installment_years'],
      installmentPlan: json['installment_plan'],
      type: json['type'] ?? 'buy',
      status: json['status'] ?? 'available',
      deliveryDate: json['delivery_date'],
      googleMap: json['google_map'],
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      developer: json['developer'] != null
          ? DeveloperModel.fromJson(json['developer'])
          : null,
      compound: json['compound'] != null
          ? CompoundModel.fromJson(json['compound'])
          : null,
      uptownType: json['uptown_type'] != null
          ? UptownTypeModel.fromJson(json['uptown_type'])
          : null,
      unitImages: (json['unitimages'] as List<dynamic>?)
              ?.map((e) => UnitImageModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  String get formattedPrice {
    final price = int.tryParse(stratPrice ?? '0') ?? 0;
    if (type == 'buy') {
      if (price >= 1000000) {
        return 'EGP \$${(price / 1000000).toStringAsFixed(1)}M';
      }
      return 'EGP \$$price';
    }
    return 'EGP \$${price.toString()}/yr';
  }

  String get displayType {
    if (type == 'buy') return 'For Sale';
    if (type == 'rent') return 'For Rent';
    return type.toUpperCase();
  }
}

class UnitsResponse {
  final List<UnitModel> units;

  UnitsResponse({required this.units});

  factory UnitsResponse.fromJson(Map<String, dynamic> json) {
    final unitsList = json['units'] as List<dynamic>? ?? [];
    return UnitsResponse(
      units: unitsList.map((e) => UnitModel.fromJson(e)).toList(),
    );
  }
}
