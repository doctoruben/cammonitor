class CameraModel {
  String name;
  String url;
  bool enabled;

  CameraModel({
    required this.name,
    required this.url,
    this.enabled = true,
  });

  factory CameraModel.fromJson(Map<String, dynamic> json) => CameraModel(
        name: json['name'] ?? 'Cámara',
        url: json['url'] ?? '',
        enabled: json['enabled'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'enabled': enabled,
      };

  CameraModel copyWith({String? name, String? url, bool? enabled}) => CameraModel(
        name: name ?? this.name,
        url: url ?? this.url,
        enabled: enabled ?? this.enabled,
      );
}
