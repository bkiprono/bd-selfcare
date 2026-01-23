import 'package:equatable/equatable.dart';
import 'package:bdcomputing/models/common/client.dart';
import 'package:bdcomputing/models/common/invoice.dart';

class Project extends Equatable {
  final String id;
  final String title;
  final String description;
  final String clientId;
  final String? startDate;
  final String? duration;
  final String? imageLink;
  final String? leadProjectId;
  final String projectType;
  final String? productId;
  final String? serviceId;
  final List<String> technologies;
  final String? projectLink;
  final List<String>? features;
  final String? githubUrl;
  final bool isPublic;
  final String status;
  final Client? client;
  final List<Invoice>? invoices;
  final DateTime createdAt;
  final String createdBy;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    this.startDate,
    this.duration,
    this.imageLink,
    this.leadProjectId,
    required this.projectType,
    this.productId,
    this.serviceId,
    required this.technologies,
    this.projectLink,
    this.features,
    this.githubUrl,
    required this.isPublic,
    required this.status,
    this.client,
    this.invoices,
    required this.createdAt,
    required this.createdBy,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      clientId: json['clientId'] ?? '',
      startDate: json['startDate'],
      duration: json['duration'],
      imageLink: json['imageLink'],
      leadProjectId: json['leadProjectId'],
      projectType: json['projectType'] ?? '',
      productId: json['productId'],
      serviceId: json['serviceId'],
      technologies: json['technologies'] != null
          ? List<String>.from(json['technologies'])
          : [],
      projectLink: json['projectLink'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : null,
      githubUrl: json['githubUrl'],
      isPublic: json['isPublic'] ?? false,
      status: json['status'] ?? '',
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      invoices: json['invoices'] != null
          ? (json['invoices'] as List)
              .map((invoice) => Invoice.fromJson(invoice))
              .toList()
          : null,
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
      'clientId': clientId,
      'startDate': startDate,
      'duration': duration,
      'imageLink': imageLink,
      'leadProjectId': leadProjectId,
      'projectType': projectType,
      'productId': productId,
      'serviceId': serviceId,
      'technologies': technologies,
      'projectLink': projectLink,
      'features': features,
      'githubUrl': githubUrl,
      'isPublic': isPublic,
      'status': status,
      'client': client?.toJson(),
      'invoices': invoices?.map((invoice) => invoice.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        clientId,
        startDate,
        duration,
        imageLink,
        leadProjectId,
        projectType,
        productId,
        serviceId,
        technologies,
        projectLink,
        features,
        githubUrl,
        isPublic,
        status,
        client,
        invoices,
        createdAt,
        createdBy,
      ];
}
