import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import 'delete_screen.dart';
import 'form_screen.dart';


class InventoryScreen extends StatelessWidget {
  final ItemController controller = Get.find();

  InventoryScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: Column(
        children: [
          Obx(() {
            if (!controller.online.value) {
              return Container(
                width: double.infinity,
                color: Colors.redAccent,
                child: TextButton(
                  onPressed: () async {
                    try {
                      await controller.goOnline();
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Could not go back online: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text(
                    'Go Back Online',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(
                  () {
                final items = controller.items;

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items in inventory.'),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SizedBox(
                      height: 100,
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          'Expiration: ${item.expirationDate}',
                          style: TextStyle(
                            color: item.timeUntilExpires() == 0
                                ? Colors.red
                                : item.timeUntilExpires() == 1
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemFormScreen(
                                      itemId: item.id,
                                      name: item.name,
                                      quantity: item.quantity,
                                      cost: item.cost,
                                      supplier: item.supplier,
                                      expirationDate: item.expirationDate,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DeletePage(itemId: item.id),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}