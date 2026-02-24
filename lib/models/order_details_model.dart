class OrderDetailsModel {
  OrderData? orderData;

  OrderDetailsModel({this.orderData});

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      orderData: json['order'] != null ? OrderData.fromJson(json['order']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': orderData?.toJson(),
    };
  }
}

class OrderData {
  int? id;
  String? name;
  String? email;
  String? createdAt;
  String? financialStatus;
  String? fulfillmentStatus;
  String? currency;
  String? currentTotalPrice;
  Customer? customer;
  List<LineItem>? lineItems;
  List<ShippingLine>? shippingLine;
  final List<Fulfillment>? fulfillments;
  Address? shippingAddress;
  Address? billingAddress;

  OrderData({
    this.id,
    this.name,
    this.email,
    this.createdAt,
    this.currency,
    this.currentTotalPrice,
    this.fulfillments,
    this.financialStatus,
    this.fulfillmentStatus,
    this.customer,
    this.lineItems,
    this.shippingLine,
    this.shippingAddress,
    this.billingAddress,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      fulfillments: json['fulfillments'] != null
          ? List<Fulfillment>.from(
          json['fulfillments'].map((x) => Fulfillment.fromJson(x)))
          : [],
      financialStatus: json['financial_status'],
      fulfillmentStatus: json['fulfillment_status'],
      createdAt: json['created_at'],
      currency: json['currency'],
      currentTotalPrice: json['current_total_price'],
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      lineItems: json['line_items'] != null
          ? List<LineItem>.from(json['line_items'].map((x) => LineItem.fromJson(x)))
          : [],

      shippingLine: json['shipping_lines'] != null
          ? List<ShippingLine>.from(json['shipping_lines'].map((x) => ShippingLine.fromJson(x)))
          : [],
      shippingAddress: json['shipping_address'] != null ? Address.fromJson(json['shipping_address']) : null,
      billingAddress: json['billing_address'] != null ? Address.fromJson(json['billing_address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt,
      'financial_status': financialStatus,
      'currency': currency,
      'fulfillment_status': fulfillmentStatus,
      'current_total_price': currentTotalPrice,
      'customer': customer?.toJson(),
      'fulfillments': fulfillments?.map((x) => x.toJson()).toList(),
      'line_items': lineItems?.map((x) => x.toJson()).toList(),
      'shipping_lines': shippingLine?.map((x) => x.toJson()).toList(),
      'shipping_address': shippingAddress?.toJson(),
      'billing_address': billingAddress?.toJson(),
    };
  }
}

class Customer {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  DefaultAddress? defaultAddress;

  Customer({this.id, this.firstName, this.lastName, this.email, this.phone, this.defaultAddress});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      defaultAddress: json['default_address'] != null ? DefaultAddress.fromJson(json['default_address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'default_address': defaultAddress?.toJson(),
    };
  }
}

class DefaultAddress {
  String? firstName;
  String? lastName;
  String? address1;
  String? address2;
  String? city;
  String? province;
  String? country;
  String? zip;
  String? phone;
  String? company;

  DefaultAddress({
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.province,
    this.country,
    this.zip,
    this.phone,
    this.company,
  });

  factory DefaultAddress.fromJson(Map<String, dynamic> json) {
    return DefaultAddress(
      firstName: json['first_name'],
      lastName: json['last_name'],
      address1: json['address1'],
      address2: json['address2'],
      city: json['city'],
      province: json['province'],
      country: json['country'],
      zip: json['zip'],
      phone: json['phone'],
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'address1': address1,
      'address2': address2,
      'city': city,
      'province': province,
      'country': country,
      'zip': zip,
      'phone': phone,
      'company': company,
    };
  }
}

class LineItem {
  int? id;
  String? name;
  int? quantity;
  String? price;
  String? variantTitle;
  int? productId;
  String? imageUrl;
  LineItem({this.id, this.name, this.quantity, this.price, this.variantTitle, this.productId,this.imageUrl});

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'],
      variantTitle: json['variant_title'],
      productId: json['product_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'variant_title': variantTitle,
      'product_id': productId,
    };
  }
}

class Address {
  String? firstName;
  String? lastName;
  String? address1;
  String? address2;
  String? city;
  String? province;
  String? country;
  String? zip;
  String? phone;
  String? company;

  Address({
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.province,
    this.country,
    this.zip,
    this.phone,
    this.company,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      firstName: json['first_name'],
      lastName: json['last_name'],
      address1: json['address1'],
      address2: json['address2'],
      city: json['city'],
      province: json['province'],
      country: json['country'],
      zip: json['zip'],
      phone: json['phone'],
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'address1': address1,
      'address2': address2,
      'city': city,
      'province': province,
      'country': country,
      'zip': zip,
      'phone': phone,
      'company': company,
    };
  }
}
class ShippingLine {
  final int id;
  final String title;
  final String price;
  final String discountedPrice;
  final List<TaxLine> taxLines;
  final String source;
  final String code;
  final String? phone;
  final String? deliveryCategory;
  final String? carrierIdentifier;
  final List<DiscountAllocation> discountAllocations;
  final PriceSet priceSet;
  final PriceSet discountedPriceSet;
  final bool custom;
  final bool isRemoved;
  final String shippingRateHandle;

  ShippingLine({
    required this.id,
    required this.title,
    required this.price,
    required this.discountedPrice,
    required this.taxLines,
    required this.source,
    required this.code,
    this.phone,
    this.deliveryCategory,
    this.carrierIdentifier,
    required this.discountAllocations,
    required this.priceSet,
    required this.discountedPriceSet,
    required this.custom,
    required this.isRemoved,
    required this.shippingRateHandle,
  });

  factory ShippingLine.fromJson(Map<String, dynamic> json) => ShippingLine(
    id: json['id'],
    title: json['title'],
    price: json['price'],
    discountedPrice: json['discounted_price'],
    taxLines: (json['tax_lines'] as List)
        .map((e) => TaxLine.fromJson(e))
        .toList(),
    source: json['source'],
    code: json['code'],
    phone: json['phone'],
    deliveryCategory: json['delivery_category'],
    carrierIdentifier: json['carrier_identifier'],
    discountAllocations: (json['discount_allocations'] as List)
        .map((e) => DiscountAllocation.fromJson(e))
        .toList(),
    priceSet: PriceSet.fromJson(json['price_set']),
    discountedPriceSet: PriceSet.fromJson(json['discounted_price_set']),
    custom: json['custom'] ?? false,        // 🔥 FIX
    isRemoved: json['is_removed'],
    shippingRateHandle: json['shipping_rate_handle']??''
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'discounted_price': discountedPrice,
    'tax_lines': taxLines.map((e) => e.toJson()).toList(),
    'source': source,
    'code': code,
    'phone': phone,
    'delivery_category': deliveryCategory,
    'carrier_identifier': carrierIdentifier,
    'discount_allocations': discountAllocations.map((e) => e.toJson()).toList(),
    'price_set': priceSet.toJson(),
    'discounted_price_set': discountedPriceSet.toJson(),
    'custom': custom,
    'is_removed': isRemoved,
    'shipping_rate_handle': shippingRateHandle,
  };
}

class TaxLine {
  final String title;
  final String price;
  final double rate;

  TaxLine({required this.title, required this.price, required this.rate});

  factory TaxLine.fromJson(Map<String, dynamic> json) => TaxLine(
    title: json['title'],
    price: json['price'],
    rate: json['rate'].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'price': price,
    'rate': rate,
  };
}

class DiscountAllocation {
  final String amount;
  final int discountApplicationIndex;

  DiscountAllocation({required this.amount, required this.discountApplicationIndex});

  factory DiscountAllocation.fromJson(Map<String, dynamic> json) => DiscountAllocation(
    amount: json['amount'],
    discountApplicationIndex: json['discount_application_index'],
  );

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'discount_application_index': discountApplicationIndex,
  };
}

class PriceSet {
  final Money shopMoney;
  final Money presentmentMoney;

  PriceSet({required this.shopMoney, required this.presentmentMoney});

  factory PriceSet.fromJson(Map<String, dynamic> json) => PriceSet(
    shopMoney: Money.fromJson(json['shop_money']),
    presentmentMoney: Money.fromJson(json['presentment_money']),
  );

  Map<String, dynamic> toJson() => {
    'shop_money': shopMoney.toJson(),
    'presentment_money': presentmentMoney.toJson(),
  };
}

class Money {
  final String amount;
  final String currencyCode;

  Money({required this.amount, required this.currencyCode});

  factory Money.fromJson(Map<String, dynamic> json) => Money(
    amount: json['amount'],
    currencyCode: json['currency_code'],
  );

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency_code': currencyCode,
  };
}
class Fulfillment {
  final int? id;
  final String? status;
  final String? trackingCompany;
  final String? trackingNumber;
  final String? trackingUrl;

  Fulfillment({
    this.id,
    this.status,
    this.trackingCompany,
    this.trackingNumber,
    this.trackingUrl,
  });

  factory Fulfillment.fromJson(Map<String, dynamic> json) {
    return Fulfillment(
      id: json['id'],
      status: json['status'],
      trackingCompany: json['tracking_company'],
      trackingNumber: json['tracking_number'],
      trackingUrl: json['tracking_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'tracking_company': trackingCompany,
      'tracking_number': trackingNumber,
      'tracking_url': trackingUrl,
    };
  }
}