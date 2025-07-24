class TransactionHistory {
  String? transactionId;
  int? userId;
  String? connectsPackagesId;
  String? currencyCode;
  num? amount;
  DateTime? createdDate;
  num? tid;
  num? discountedAmount;
  num? actualAmount;
  String? name;
  num? numberOfConnects;

  TransactionHistory({
    this.transactionId,
    this.userId,
    this.connectsPackagesId,
    this.currencyCode,
    this.amount,
    this.createdDate,
    this.tid,
    this.discountedAmount,
    this.actualAmount,
    this.name,
    this.numberOfConnects,
  });

  TransactionHistory.fromJson(Map<String, dynamic> json) {
    transactionId = json['transaction_id'];
    userId = json['user_id'];
    connectsPackagesId = json['connectsPackagesId'] == 1 ? "Silver" : "Gold";
    currencyCode = json['Currency_code'];
    amount = json['Amount'];
    createdDate = DateTime.parse(json['createdDate'] ?? DateTime.now().toString());
    tid = json['Tid'];
    discountedAmount = json['discountedAmount'];
    actualAmount = json['actualAmount'];
    name = json['name'];
    numberOfConnects = json['numberOfConnects'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transaction_id'] = transactionId;
    data['user_id'] = userId;
    data['connectsPackagesId'] = connectsPackagesId;
    data['Currency_code'] = currencyCode;
    data['Amount'] = amount;
    data['createdDate'] = createdDate;
    data['Tid'] = tid;
    data['discountedAmount'] = discountedAmount;
    data['actualAmount'] = actualAmount;
    data['name'] = name;
    data['numberOfConnects'] = numberOfConnects;
    return data;
  }

// Static method to parse a list of countries from JSON
  static List<TransactionHistory> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TransactionHistory.fromJson(json)).toList();
  }
}
