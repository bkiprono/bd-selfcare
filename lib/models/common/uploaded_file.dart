import 'package:bdoneapp/models/common/file.dart';

class FileModel {
  final String id;
  final String name;
  final File file;
  final String url;
  final DateTime createdAt;
  final String createdBy;

  FileModel({
    required this.id,
    required this.name,
    required this.file,
    required this.url,
    required this.createdAt,
    required this.createdBy,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      file: File.fromJson(json['file'] ?? {}),
      url: json['url'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'file': file.toJson(),
      'url': url,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
