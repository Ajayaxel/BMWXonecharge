import 'package:equatable/equatable.dart';

class ServiceBanner extends Equatable {
  final int id;
  final String bgImage;
  final String title;
  final String code;

  const ServiceBanner({
    required this.id,
    required this.bgImage,
    required this.title,
    required this.code,
  });

  factory ServiceBanner.fromJson(Map<String, dynamic> json) {
    return ServiceBanner(
      id: json['id'] ?? 0,
      bgImage: json['bg_image'] ?? '',
      title: json['title'] ?? '',
      code: json['code'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, bgImage, title, code];
}
