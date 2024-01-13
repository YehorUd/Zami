// Klasa reprezentująca fakturę
class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;

  final String location;  // Lokalizacja, do której przypisana jest faktura
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

// Klasa reprezentująca informacje o fakturze
class InvoiceInfo {
  final String description;  // Opis faktury
  final String number;       // Numer faktury
  final DateTime date;       // Data wystawienia faktury
  final DateTime dueDate;    // Termin płatności

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });
}

// Klasa reprezentująca pozycję na fakturze
class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final double vat;
  final double unitPrice;

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

// Klasa reprezentująca dostawcę
class Supplier {
  final String name;
  final String address;
  final String paymentInfo;  // Informacje dotyczące płatności
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

// Klasa reprezentująca klienta
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
