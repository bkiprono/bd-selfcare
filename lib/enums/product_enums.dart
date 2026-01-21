enum ProductAvailability {
  express,
  global,
  factoryOrder,
}

extension ProductAvailabilityX on ProductAvailability {
  String get value {
    switch (this) {
      case ProductAvailability.express:
        return 'express';
      case ProductAvailability.global:
        return 'global';
      case ProductAvailability.factoryOrder:
        return 'factory-order';
    }
  }

  String get label {
    switch (this) {
      case ProductAvailability.express:
        return 'Available for Express Orders';
      case ProductAvailability.global:
        return 'Available on Factory Orders';
      case ProductAvailability.factoryOrder:
        return 'Available on Order';
    }
  }

  static ProductAvailability fromString(String value) {
    switch (value.toLowerCase()) {
      case 'express':
        return ProductAvailability.express;
      case 'global':
        return ProductAvailability.global;
      case 'factory-order':
        return ProductAvailability.factoryOrder;
      default:
        return ProductAvailability.global; // safe fallback
    }
  }
}

enum ProductApprovalStatus {
  pending,
  approved,
  rejected,
}

extension ProductApprovalStatusX on ProductApprovalStatus {
  String get value {
    switch (this) {
      case ProductApprovalStatus.pending:
        return 'PENDING';
      case ProductApprovalStatus.approved:
        return 'APPROVED';
      case ProductApprovalStatus.rejected:
        return 'REJECTED';
    }
  }

  static ProductApprovalStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return ProductApprovalStatus.pending;
      case 'APPROVED':
        return ProductApprovalStatus.approved;
      case 'REJECTED':
        return ProductApprovalStatus.rejected;
      default:
        return ProductApprovalStatus.pending; // safe fallback
    }
  }
}