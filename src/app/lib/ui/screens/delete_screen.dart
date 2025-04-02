import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../domain/store_item.dart';


class DeletePage extends StatelessWidget {
  final int itemId;

  const DeletePage({super.key, required this.itemId});


  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ItemController>();
    final StoreItem? item = controller.searchItem(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Delete Item"),
        ),
        body: const Center(
          child: Text("Item not found"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldRow("Name", item.name),
            const SizedBox(height: 8),
            _buildFieldRow("Quantity", item.quantity.toString()),
            const SizedBox(height: 8),
            _buildFieldRow("Cost", "\$${item.cost}"),
            const SizedBox(height: 8),
            _buildFieldRow("Supplier", item.supplier),
            const SizedBox(height: 8),
            _buildFieldRow("Expiration Date", item.expirationDate),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  try {
                    controller.removeItem(itemId);
                    Get.back();
                  } catch (e) {
                    Get.snackbar('Error', e.toString(),
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text("Confirm Delete"),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFieldRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
}