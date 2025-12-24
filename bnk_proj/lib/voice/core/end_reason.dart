enum EndReason {
  completed,
  canceled,
  timeout,
  error;
  static EndReason from(String value) {
    return EndReason.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => EndReason.error,
    );
  }
}
