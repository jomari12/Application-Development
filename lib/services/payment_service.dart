import '../models/payment.dart';
import 'storage_service.dart';

class PaymentService {
  static List<Payment> getAllPayments() {
    final paymentsData = StorageService.getList('payments');
    return paymentsData.map((data) => Payment.fromMap(data)).toList();
  }

  static void savePayment(Payment payment) {
    final payments = getAllPayments();
    final existingIndex = payments.indexWhere((p) => p.id == payment.id);

    if (existingIndex != -1) {
      payments[existingIndex] = payment;
    } else {
      payments.add(payment);
    }

    final paymentsData = payments.map((p) => p.toMap()).toList();
    StorageService.setList('payments', paymentsData);
  }

  static String generatePaymentId() {
    return 'P${DateTime.now().millisecondsSinceEpoch}';
  }

  static List<Payment> getPaymentsByBookingId(String bookingId) {
    final allPayments = getAllPayments();
    return allPayments.where((payment) => payment.bookingId == bookingId).toList();
  }
}