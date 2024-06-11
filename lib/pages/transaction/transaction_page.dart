import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jamugo/api/transaction/transaction.dart';
import 'package:jamugo/api/payment/payment.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionPage extends StatefulWidget {
  final int orderId;

  const TransactionPage({super.key, required this.orderId});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late Future<TransactionResponse> transactionFuture;
  String selectedPaymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    transactionFuture = TransactionApi.getTransactionByOrderId(widget.orderId);
  }

  String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    final format = DateFormat('dd MMMM yyyy HH:mm');
    return format.format(dateTime);
  }

  void _showToast(String message, {Color backgroundColor = Colors.red}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
    );
  }

  Future<void> _updatePaymentMethod(int orderId, String paymentMethod) async {
    try {
      final response =
          await TransactionApi.updatePaymentMethod(orderId, paymentMethod);
      if (response.isSuccess) {
        _showToast('Payment method updated successfully',
            backgroundColor: Colors.green);
        setState(() {
          transactionFuture = TransactionApi.getTransactionByOrderId(orderId);
        });
      } else {
        _showToast('Failed to update payment method: ${response.message}');
      }
    } catch (error) {
      _showToast('Failed to update payment method: $error');
    }
  }

  Future<void> _initiatePayment(int orderId) async {
    try {
      final response = await PaymentApi.initiatePayment(orderId);
      if (response.isSuccess) {
        final url = response.redirectUrl!;
        if (await canLaunch(url)) {
          await launch(url, forceSafariVC: false, forceWebView: false);
        } else {
          _showToast('Could not launch payment URL');
        }
      } else {
        _showToast('Failed to initiate payment: ${response.message}');
      }
    } catch (error) {
      _showToast('Failed to initiate payment: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<TransactionResponse>(
        future: transactionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          } else if (snapshot.hasError) {
            _showToast('Error: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.transactions.isEmpty) {
            _showToast('Transaction details not found',
                backgroundColor: Colors.orange);
            return const Center(
              child: Text('Transaction details not found'),
            );
          } else {
            final transaction = snapshot.data!.transactions[0];
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Transaction ID: ${transaction.pkid}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Order ID: ${transaction.orderPkid}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Payment Status: ${transaction.paymentStatus}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Transaction Date: ${_formatDate(transaction.transactionDate)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  DropdownButton<String>(
                    value: selectedPaymentMethod,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentMethod = newValue!;
                      });
                      _updatePaymentMethod(widget.orderId, newValue!);
                    },
                    items: <String>[
                      'Cash',
                      'Transfer',
                      'QRIS',
                      'GoPay',
                      'OVO',
                      'Dana',
                      'LinkAja',
                      'ShopeePay'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _initiatePayment(widget.orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
