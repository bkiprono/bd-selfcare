import 'package:equatable/equatable.dart';
import 'package:bdcomputing/models/common/client.dart';

class LeadProject extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? leadId;
  final String? clientId;
  final String? duration;
  final String source;
  final String projectType;
  final String? productId;
  final String? serviceId;
  final List<String>? features;
  final String? projectId;
  final Client? client;
  final DateTime createdAt;
  final String createdBy;

  const LeadProject({
    required this.id,
    required this.title,
    required this.description,
    this.leadId,
    this.clientId,
    this.duration,
    required this.source,
    required this.projectType,
    this.productId,
    this.serviceId,
    this.features,
    this.projectId,
    this.client,
    required this.createdAt,
    required this.createdBy,
  });

  factory LeadProject.fromJson(Map<String, dynamic> json) {
    return LeadProject(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      leadId: json['leadId'],
      clientId: json['clientId'],
      duration: json['duration'],
      source: json['source'] ?? '',
      projectType: json['projectType'] ?? '',
      productId: json['productId'],
      serviceId: json['serviceId'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : null,
      projectId: json['projectId'],
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'leadId': leadId,
      'clientId': clientId,
      'duration': duration,
      'source': source,
      'projectType': projectType,
      'productId': productId,
      'serviceId': serviceId,
      'features': features,
      'projectId': projectId,
      'client': client?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  bool get hasQuote => projectId != null;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        leadId,
        clientId,
        duration,
        source,
        projectType,
        productId,
        serviceId,
        features,
        projectId,
        client,
        createdAt,
        createdBy,
      ];
}
