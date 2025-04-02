import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../domain/store_item.dart';
import 'package:store_inventory/repository/local_db_repository.dart';
import '../repository/remote_repository.dart';


class ItemController extends GetxController {
  final String? serverUrl;
  late final String? httpUrl;
  late final String? wsUrl;

  final LocalDBRepository localDbRepo;
  RemoteRepository? remoteServerRepo;
  WebSocketChannel? webSocketChannel;

  var online = false.obs;
  var items = <StoreItem>[].obs;


  ItemController({required this.localDbRepo, this.serverUrl}) {
    if (serverUrl != null) {
      httpUrl = 'http://$serverUrl/api';
      wsUrl = 'ws://$serverUrl';
      remoteServerRepo = RemoteRepository(httpUrl!);
    }
  }


  @override
  void onInit() async {
    super.onInit();
    await goOnline();
  }


  Future<void> goOnline() async {
    try {
      await _connectToServer();
    } catch (e) {
      // print('Error connecting to server: $e');
    }
    loadItems();
  }

  Future<void> _connectToServer() async {
    if (serverUrl == null) {
      return;
    }

    try {
      final response = await http.get(Uri.parse(httpUrl!));
      online.value = response.statusCode == 200;

      if (online.value) {
        webSocketChannel = WebSocketChannel.connect(Uri.parse('$wsUrl'));

        webSocketChannel?.stream.listen(
              (message) {
            loadItems();
          },
          onError: (error) {
            online.value = false;
          },
          onDone: () {
            online.value = false;
          },
        );

        await _syncLocalChanges();
        await _updateLocalItems();
      }
    } catch (e) {
      online.value = false;
      throw Exception('Error connecting to server: $e');
    }
  }


  Future<void> _syncLocalChanges() async {
    try {
      List<List<Map<String, dynamic>>>? logs = await localDbRepo.getSynchronizationLogs();
      if (logs == null) return;

      for (final row in logs[0]) {
        final item = StoreItem(
          name: row['name'],
          quantity: row['quantity'],
          cost: row['cost'],
          supplier: row['supplier'],
          expirationDate: row['expiration_date'],
        );
        await remoteServerRepo!.addItem(item);
      }

      for (final row in logs[1]) {
        final item = StoreItem(
          providedId: row['item_id'],
          name: row['name'],
          quantity: row['quantity'],
          cost: row['cost'],
          supplier: row['supplier'],
          expirationDate: row['expiration_date'],
        );
        await remoteServerRepo!.updateItem(item);
      }

      for (final row in logs[2]) {
        await remoteServerRepo!.removeItem(row['item_id']);
      }


      await localDbRepo.clearSynchronizationLogs();
    } catch (e) {
      // print('Error fetching synchronization logs: $e');
    }
  }


  Future<void> _updateLocalItems() async {
    try {
      final fetchedItems = await remoteServerRepo!.getItems();
      await localDbRepo.syncWithRemote(fetchedItems);
    } catch (e) {
      // print('Error updating local items: $e');
    }
  }

  void loadItems() async {
    try {
      if (online.value && remoteServerRepo != null) {
        final fetchedItems = await remoteServerRepo!.getItems();
        items.assignAll(fetchedItems);
      } else {
        final fetchedItems = await localDbRepo.getItems();
        items.assignAll(fetchedItems);
      }
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }


  void addItem(String name, int quantity, int cost, String supplier, String expirationDate) async {
    final item = StoreItem(
      name: name,
      quantity: quantity,
      cost: cost,
      supplier: supplier,
      expirationDate: expirationDate,
    );

    try {
      if (online.value) {
        await remoteServerRepo!.addItem(item);
        await localDbRepo.addItem(item, log: false);
      } else {
        final addedItem = await localDbRepo.addItem(item);
        items.add(addedItem);
      }
    } catch (e) {
      throw Exception('Error adding item: $e');
    }
  }


  void removeItem(int id) async {
    try {
      if (online.value) {
        await remoteServerRepo!.removeItem(id);
        await localDbRepo.removeItem(id, log: false);
      } else {
        await localDbRepo.removeItem(id);
        items.removeWhere((item) => item.id == id);
      }
    } catch (e) {
      throw Exception('Error removing item: $e');
    }
  }


  void updateItem(int id, String name, int quantity, int cost, String supplier, String expirationDate) async {
    final item = StoreItem(
      providedId: id,
      name: name,
      quantity: quantity,
      cost: cost,
      supplier: supplier,
      expirationDate: expirationDate,
    );

    try {
      if (online.value) {
        await remoteServerRepo!.updateItem(item);
        await localDbRepo.updateItem(item, log: false);
      } else {
        final updatedItem = await localDbRepo.updateItem(item);
        final index = items.indexWhere((item) => item.id == id);
        if (index != -1) {
          items[index] = updatedItem;
        }
      }
    } catch (e) {
      throw Exception('Error updating item: $e');
    }
  }


  StoreItem? searchItem(int id) {
    return items.firstWhereOrNull((item) => item.id == id);
  }


  @override
  void onClose() {
    webSocketChannel?.sink.close();
    super.onClose();
  }


  void validateItem({
    required String name,
    required String quantity,
    required String cost,
    required String supplier,
    required String expirationDate,
  }) {
    if (name.isEmpty || quantity.isEmpty || cost.isEmpty || supplier.isEmpty || expirationDate.isEmpty) {
      throw ArgumentError("All fields must be filled out");
    }

    final nameRegExp = RegExp(r'^[a-zA-Z ,.-]+$');
    if (!nameRegExp.hasMatch(name)) {
      throw ArgumentError("Name can contain only letters, spaces, dots, commas, and hyphens");
    }

    if (!nameRegExp.hasMatch(supplier)) {
      throw ArgumentError("Supplier can contain only letters, spaces, dots, commas, and hyphens");
    }

    final quantityInt = int.tryParse(quantity);
    final costInt = int.tryParse(cost);

    if (quantityInt == null || costInt == null) {
      throw ArgumentError("Quantity and cost must be numbers");
    }

    if (quantityInt < 0 || costInt < 0) {
      throw ArgumentError("Quantity and cost must be positive numbers");
    }

    if (expirationDate.length != 10 || expirationDate[4] != '-' || expirationDate[7] != '-') {
      throw ArgumentError("Expiration date must be in the format YYYY-MM-DD");
    }

    final year = int.tryParse(expirationDate.substring(0, 4));
    final month = int.tryParse(expirationDate.substring(5, 7));
    final day = int.tryParse(expirationDate.substring(8, 10));

    if (year == null || month == null || day == null) {
      throw ArgumentError("Expiration date must be in the format YYYY-MM-DD");
    }

    if (month < 1 || month > 12) {
      throw ArgumentError("Month must be between 1 and 12");
    }

    if (day < 1 || day > 31) {
      throw ArgumentError("Day must be between 1 and 31");
    }

    if (month == 2 && day > 29) {
      throw ArgumentError("February can have at most 29 days");
    }
    if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
      throw ArgumentError("This month can have at most 30 days");
    }
  }
}