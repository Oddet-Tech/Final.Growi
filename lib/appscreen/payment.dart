import 'package:flutter/material.dart';
import 'package:growi_project/appscreen/models.dart';

class PaymentPage extends StatefulWidget {
  final List<Models> cartItems;
  final int totalPrice;

  const PaymentPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  String _selectedPaymentMethod = "Card";

  // Card fields
  final TextEditingController cardName = TextEditingController();
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  final TextEditingController cvv = TextEditingController();

  // Mobile money
  final TextEditingController phone = TextEditingController();

  bool _processing = false;

  double get total => widget.totalPrice * 1.04; // tax included

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate payment API

    setState(() => _processing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Payment Successful"),
        content: const Text("Your order has been placed successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // return success to previous page
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...widget.cartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item.name)),
                      Text("R${item.price * 1.04}"),
                    ],
                  ),
                )),

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  "R${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Payment Method",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

        RadioListTile(
          value: "Card",
          groupValue: _selectedPaymentMethod,
          onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
          title: const Text("Credit / Debit Card"),
        ),

        RadioListTile(
          value: "Mobile",
          groupValue: _selectedPaymentMethod,
          onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
          title: const Text("Mobile Money"),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextFormField(
          controller: cardName,
          decoration: const InputDecoration(labelText: "Card Holder Name"),
          validator: (v) =>
              v!.isEmpty ? "Enter card holder name" : null,
        ),
        TextFormField(
          controller: cardNumber,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Card Number"),
          validator: (v) =>
              v!.length < 16 ? "Invalid card number" : null,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: expiry,
                decoration: const InputDecoration(labelText: "MM/YY"),
                validator: (v) =>
                    v!.isEmpty ? "Required" : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: cvv,
                obscureText: true,
                decoration: const InputDecoration(labelText: "CVV"),
                validator: (v) =>
                    v!.length < 3 ? "Invalid CVV" : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileMoneyForm() {
    return TextFormField(
      controller: phone,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: "Mobile Number",
        hintText: "+27...",
      ),
      validator: (v) =>
          v!.length < 10 ? "Enter valid number" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout Payment"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 20),
              _buildPaymentMethod(),
              const SizedBox(height: 10),

              if (_selectedPaymentMethod == "Card")
                _buildCardForm()
              else
                _buildMobileMoneyForm(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _processing ? null : _processPayment,
                  child: _processing
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text("Pay R${total.toStringAsFixed(2)}"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}