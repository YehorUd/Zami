import 'package:zami/models/customer.dart';
import 'package:zami/models/supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;

  // Additional properties
  final String location;
  final double totalAmount;
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
    required this.totalAmount,
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

  const InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
  });
}
