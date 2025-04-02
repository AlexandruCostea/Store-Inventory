import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';


class ItemFormScreen extends StatelessWidget {
  final ItemController controller = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();

  final int? itemId;

  ItemFormScreen({
    super.key,
    this.itemId,
    String? name,
    int? quantity,
    int? cost,
    String? supplier,
    String? expirationDate,
  }) {

    nameController.text = name ?? '';
    quantityController.text = quantity?.toString() ?? '';
    costController.text = cost?.toString() ?? '';
    supplierController.text = supplier ?? '';
    expirationDateController.text = expirationDate ?? '';
  }


  @override
  Widget build(BuildContext context) {
    final isUpdating = itemId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdating ? 'Update Item' : 'Create Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Name", nameController),
            _buildTextField("Quantity", quantityController, isNumeric: true),
            _buildTextField("Cost", costController, isNumeric: true),
            _buildTextField("Supplier", supplierController),
            _buildTextField("Expiration Date (YYYY-MM-DD)", expirationDateController),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  try {
                    controller.validateItem(
                      name: nameController.text,
                      quantity: quantityController.text,
                      cost: costController.text,
                      supplier: supplierController.text,
                      expirationDate: expirationDateController.text,
                    );

                    if (isUpdating) {
                      controller.updateItem(
                        itemId!,
                        nameController.text,
                        int.parse(quantityController.text),
                        int.parse(costController.text),
                        supplierController.text,
                        expirationDateController.text,
                      );
                    } else {
                      controller.addItem(
                        nameController.text,
                        int.parse(quantityController.text),
                        int.parse(costController.text),
                        supplierController.text,
                        expirationDateController.text,
                      );
                    }
                    Get.back();
                  } catch (e) {
                    Get.snackbar('Error', e.toString(),
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
                icon: Icon(isUpdating ? Icons.save : Icons.add),
                label: Text(isUpdating ? 'Update' : 'Create'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }


  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}