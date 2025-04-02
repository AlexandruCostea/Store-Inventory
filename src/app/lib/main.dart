import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:store_inventory/controller/controller.dart';
import 'package:store_inventory/repository/local_db_repository.dart';
import 'package:store_inventory/ui/screens/error_screen.dart';
import 'package:store_inventory/ui/screens/inventory_screen.dart';


void main() async {

  try {
    await dotenv.load(fileName: '.env');
    final serverUrl = dotenv.env['SERVER_URL'];
    WidgetsFlutterBinding.ensureInitialized();

    final repo = await LocalDBRepository.create();
    Get.put(ItemController(localDbRepo: repo, serverUrl: serverUrl));

    runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: InventoryScreen(),
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
    ));
  } catch (e) {
    runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ErrorScreen(),
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
    ));
  }
}