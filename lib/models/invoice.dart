// invoice.dart

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;

  // Additional properties
  final String location;
  final double netTotalAmount;
  final double vatTotalAmount;
  final double grossTotalAmount;
  final String paymentStatus;
  final DateTime paymentDueDate;
  final String paymentMethod;
  final String paymentType;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
    required this.location,
    required this.netTotalAmount,
    required this.vatTotalAmount,
    required this.grossTotalAmount,
    required this.paymentStatus,
    required this.paymentDueDate,
    required this.paymentMethod,
    required this.paymentType,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });
}

class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final double vat;
  final double unitPrice;

  // Additional fields
  final double netAmount;
  final double vatAmount;
  final double grossAmount;

  const InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
    required this.netAmount,
    required this.vatAmount,
    required this.grossAmount,
  });
}

class Supplier {
  final String name;
  final String address;
  final String paymentInfo;
  final String postalCode;
  final String city;
  final String nip;

  const Supplier({
    required this.name,
    required this.address,
    required this.paymentInfo,
    required this.postalCode,
    required this.city,
    required this.nip,
  });
}

class Customer {
  final String name;
  final String address;
  final String postalCode;
  final String city;
  final String nip;

  const Customer({
    required this.name,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.nip,
  });
}
