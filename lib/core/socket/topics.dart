enum SocketIoTopics {
  customerReports,
  orderReports,
  customerSearch,
  paymentsSearch,
  invoiceSearch,
  productSearch,
  fuelOrderCalculation,
  productOrderCalculation,
}

extension SocketIoTopicsExtension on SocketIoTopics {
  String get value {
    switch (this) {
      case SocketIoTopics.customerReports:
        return 'customerReports';
      case SocketIoTopics.orderReports:
        return 'orderReports';
      case SocketIoTopics.customerSearch:
        return 'customerSearch';
      case SocketIoTopics.paymentsSearch:
        return 'paymentsSearch';
      case SocketIoTopics.invoiceSearch:
        return 'invoiceSearch';
      case SocketIoTopics.productSearch:
        return 'productSearch';
      case SocketIoTopics.fuelOrderCalculation:
        return 'fuelOrderCalculation';
      case SocketIoTopics.productOrderCalculation:
        return 'productOrderCalculation';
    }
  }
}
