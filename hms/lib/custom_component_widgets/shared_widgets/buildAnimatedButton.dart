import 'package:flutter/material.dart';

Icon _getIconForLabel(String label) {
  switch (label) {
    case 'Daily Report':
      return const Icon(Icons.calendar_today, color: Colors.white);
    case 'Daily Sales Report':
      return const Icon(Icons.bar_chart, color: Colors.white);
    case 'Sales Report':
      return const Icon(Icons.wallet, color: Colors.white);
    case 'Purchase Report':
      return const Icon(Icons.shopping_bag, color: Colors.white);
    case 'Users List':
      return const Icon(Icons.people, color: Colors.white);
    case 'Sales & Purchase Report':
      return const Icon(Icons.receipt_long, color: Colors.white);
    case 'Customer & Supplier Ledger Report':
      return const Icon(Icons.account_balance_wallet, color: Colors.white);
    case 'Stock List':
      return const Icon(Icons.inventory, color: Colors.white);
    case 'Purchase':
      return Icon(Icons.shopping_bag, color: Colors.white);
    case 'Account Book':
      return Icon(Icons.book, color: Colors.white);
    case 'Supplier Ledger':
      return Icon(Icons.business, color: Colors.white);
    case 'Customer Ledger':
      return Icon(Icons.person, color: Colors.white);
    case 'Supplier Master':
      return Icon(Icons.local_shipping, color: Colors.white);
    case 'Customer Master':
      return Icon(Icons.people_alt, color: Colors.white);
    case 'Item Master':
      return Icon(Icons.inventory_2, color: Colors.white);
    case 'Group Account Head':
      return Icon(Icons.account_tree, color: Colors.white);
    case 'Account Head':
      return Icon(Icons.account_balance, color: Colors.white);
    default:
      return const Icon(Icons.description, color: Colors.white);
  }
}

Widget buildAnimatedButton(
  BuildContext context,
  String label,
  VoidCallback onPressed,
) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          _getIconForLabel(label),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
