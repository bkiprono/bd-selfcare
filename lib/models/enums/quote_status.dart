enum QuoteStatus {
  draft('DRAFT'),
  sent('SENT'),
  accepted('ACCEPTED'),
  rejected('REJECTED');

  final String value;
  const QuoteStatus(this.value);

  static QuoteStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return QuoteStatus.draft;
      case 'SENT':
        return QuoteStatus.sent;
      case 'ACCEPTED':
        return QuoteStatus.accepted;
      case 'REJECTED':
        return QuoteStatus.rejected;
      default:
        return QuoteStatus.draft;
    }
  }
}
