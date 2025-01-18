import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For date formatting

class PaymentMethodsCard extends StatelessWidget {
  const PaymentMethodsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current date
    DateTime now = DateTime.now();
    DateTime targetDate = now.day > 15 ? DateTime(now.year, now.month + 1, 1) : now;

    // Get the correct month and year
    String billingMonth = DateFormat('MMMM').format(targetDate); // e.g., January or February
    String billingYear = DateFormat('y').format(targetDate); // e.g., 2024
    String dueDate = "15th of $billingMonth, $billingYear"; // Example: "15th of February, 2024"

    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: const Text(
                'Monthly Billing',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Text("Month of:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                Text(billingMonth),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text("Due Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                Text(dueDate), // Dynamically calculated due date
              ],
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: const Text(
                'Payment Methods',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Payment Methods List (ALL FIELDS NOW SHOW)
            _buildPaymentItem(context, 'GCash / PayMaya', '0917 700 0710', 'Bascara Apartment'),
            _buildPaymentItem(context, 'Over-the-Counter', '0917 700 0710', 'M Lhuillier / Palawan / Cebuana', 'Bascara Apartment'),
            _buildPaymentItem(context, 'BDO', '5210 6988 8182 2136', 'Bascara Apartment'),
            _buildPaymentItem(context, 'China Bank', '5210 6988 8182 2136', 'Bascara Apartment'),
            _buildPaymentItem(context, 'BPI', '5210 6988 8182 2136', 'Bascara Apartment'),
            _buildPaymentItem(context, 'Land Bank', '5210 6988 8182 2136', 'Bascara Apartment'),
          ],
        ),
      ),
    );
  }

  /// Reusable Widget for Payment Methods with Copy Functionality
  static Widget _buildPaymentItem(BuildContext context, String title, String account, String holder, [String? extra]) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          // Account Number with Copy Function
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: account));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$title account number copied: $account"),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  account,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.copy, color: Colors.grey, size: 20),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // Holder (Ensured it always shows)
          Text(
            holder,
            style: const TextStyle(fontSize: 14),
          ),

          // Extra (If Available)
          if (extra != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(extra, style: const TextStyle(fontSize: 14)),
            ),
        ],
      ),
    );
  }
}
