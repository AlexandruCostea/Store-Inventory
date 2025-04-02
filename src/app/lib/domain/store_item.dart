class StoreItem {

  final int id;
  String name;
  int quantity;
  int cost;
  String supplier;
  String expirationDate;


  StoreItem({
    providedId = -1,
    required this.name,
    required this.quantity,
    required this.cost,
    required this.supplier,
    required this.expirationDate,
  }) : id = providedId;


  int timeUntilExpires() {
    final currentDate = DateTime.now();
    final parsedExpirationDate = DateTime.tryParse(expirationDate);
    if (parsedExpirationDate == null) {
      throw FormatException('Invalid expiration date format: $expirationDate');
    }
    final daysUntilExpiration =
        parsedExpirationDate.difference(currentDate).inDays;

    if (daysUntilExpiration > 21) {
      return 2;
    } else if (daysUntilExpiration >= 1) {
      return 1;
    } else {
      return 0;
    }
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StoreItem) return false;

    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;


  static fromJson(json) {
    return StoreItem(
      providedId: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      cost: json['cost'],
      supplier: json['supplier'],
      expirationDate: json['expiration_date'],
    );
  }


  Object? toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'cost': cost,
      'supplier': supplier,
      'expiration_date': expirationDate,
    };
  }
}