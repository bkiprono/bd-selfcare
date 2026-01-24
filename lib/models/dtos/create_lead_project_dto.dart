import 'package:bdoneapp/models/enums/lead_source.dart';
import 'package:bdoneapp/models/enums/project_type.dart';

/// DTO for creating a lead project (quote request)
/// Matches the TypeScript CreateLeadProject interface
class CreateLeadProjectDto {
  final String title;
  final String description;
  final String? leadId;
  final String? clientId;
  final String? duration;
  final LeadSourceEnum source;
  final ProjectTypeEnum projectType;
  final String? productId;
  final String? serviceId;
  final List<String>? features;

  CreateLeadProjectDto({
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
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'title': title,
      'description': description,
      'source': source.value,
      'projectType': projectType.value,
    };

    // Add optional fields only if they have values
    if (duration != null && duration!.isNotEmpty) {
      json['duration'] = duration;
    }
    if (leadId != null && leadId!.isNotEmpty) {
      json['leadId'] = leadId;
    }
    if (clientId != null && clientId!.isNotEmpty) {
      json['clientId'] = clientId;
    }
    if (productId != null && productId!.isNotEmpty) {
      json['productId'] = productId;
    }
    if (serviceId != null && serviceId!.isNotEmpty) {
      json['serviceId'] = serviceId;
    }
    if (features != null) {
      json['features'] = features;
    }

    return json;
  }
}
