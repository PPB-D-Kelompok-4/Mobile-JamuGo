import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamugo/api/transaction/transaction.dart';
import 'package:jamugo/api/payment/payment.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionPage extends StatefulWidget {
  final int orderId;
  final String orderPriceTotal;

  const TransactionPage(
      {super.key, required this.orderId, required this.orderPriceTotal});

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
        final Uri url = response.redirectUrl!;
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
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
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Order ID: ${widget.orderId}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.orderPriceTotal,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: <String>[
                      'Cash',
                      'Transfer',
                      'QRIS',
                      'GoPay',
                      'OVO',
                      'Dana',
                      'LinkAja',
                      'ShopeePay'
                    ].length,
                    itemBuilder: (context, index) {
                      final paymentMethod = <String>[
                        'Cash',
                        'Transfer',
                        'QRIS',
                        'GoPay',
                        'OVO',
                        'Dana',
                        'LinkAja',
                        'ShopeePay'
                      ][index];
                      return Card(
                        child: ListTile(
                          title: Text(paymentMethod),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: selectedPaymentMethod == paymentMethod
                              ? Colors.green
                              : Colors.white,
                          onTap: () {
                            setState(() {
                              selectedPaymentMethod = paymentMethod;
                            });
                            _updatePaymentMethod(widget.orderId, paymentMethod);
                          },
                        ),
                      );
                    },
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
