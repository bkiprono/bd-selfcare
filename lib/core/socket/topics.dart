enum SocketIoTopics {
  paymentsSearch,
  invoiceSearch,
  mpesaTransactionResponse,
}

extension SocketIoTopicsExtension on SocketIoTopics {
  String get value {
    switch (this) {
      case SocketIoTopics.paymentsSearch:
        return 'paymentsSearch';
      case SocketIoTopics.invoiceSearch:
        return 'invoiceSearch';
      case SocketIoTopics.mpesaTransactionResponse:
        return 'mpesaTransactionResponse';
    }
  }
}
