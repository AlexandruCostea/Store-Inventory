import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/store_item.dart';


class RemoteRepository {
  final String serverURL;

  RemoteRepository(this.serverURL);


  void _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
    }
  }


  Future<List<StoreItem>> getItems() async {
    try {
      final response = await http.get(Uri.parse('$serverURL/items'));
      _handleResponse(response);

      final List<dynamic> data = jsonDecode(response.body);

      return List.generate(data.length, (i) {
        return StoreItem.fromJson(data[i]);
      });
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }


  Future<StoreItem> addItem(StoreItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$serverURL/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
      _handleResponse(response);

      final Map<String, dynamic> data = jsonDecode(response.body);
      return StoreItem.fromJson(data);
    } catch (e) {
      throw Exception('Error adding item: $e');
    }
  }


  Future<void> removeItem(int id) async {
    try {
      final response = await http.delete(Uri.parse('$serverURL/items/$id'));
      _handleResponse(response);
    } catch (e) {
      throw Exception('Error removing item: $e');
    }
  }


  Future<StoreItem> updateItem(StoreItem item) async {
    try {
      final response = await http.put(
        Uri.parse('$serverURL/items/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
      _handleResponse(response);

      final Map<String, dynamic> data = jsonDecode(response.body);
      return StoreItem.fromJson(data);
    } catch (e) {
      throw Exception('Error updating item: $e');
    }
  }


  Future<StoreItem?> searchItem(int id) async {
    try {
      final response = await http.get(Uri.parse('$serverURL/items/$id'));
      if (response.statusCode == 404) {
        return null;
      }
      _handleResponse(response);

      final Map<String, dynamic> data = jsonDecode(response.body);
      return StoreItem.fromJson(data);
    } catch (e) {
      throw Exception('Error searching for item: $e');
    }
  }
}
