import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../authenticatebyphone.dart';


class LoginController extends GetxController {
  final client = http.Client();
  final storage = GetStorage();
  bool isLoggingIn = false;
  bool isUser = false;
  late List allAdmin = [];
  late List adminUsernames = [];
  late List adminEmails = [];
  late int oTP = 0;
  late String myToken = "";

  String errorMessage = "";
  bool isLoading = false;



  Future<void> getAllAdmin() async {
    try {
      isLoading = true;
      const completedRides = "https://fnetagents.xyz/get_de_admin/";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allAdmin.assignAll(jsonData);
        for (var i in allAdmin) {
          adminUsernames.add(i['username']);
        }
        update();
      }
    } catch (e) {
      Get.snackbar("Sorry",
          "something happened or please check your internet connection");
    } finally {
      isLoading = false;
    }
  }

  Future<void> loginUser(String username, String password) async {
    const loginUrl = "https://fnetagents.xyz/auth/token/login/";
    final myLink = Uri.parse(loginUrl);
    http.Response response = await client.post(myLink,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"username": username, "password": password});

    if (response.statusCode == 200) {
      final resBody = response.body;
      var jsonData = jsonDecode(resBody);
      var userToken = jsonData['auth_token'];

      storage.write("token", userToken);
      storage.write("agent_code", username);
      isLoggingIn = false;
      isUser = true;

      if (adminUsernames.contains(username)) {
        Get.offAll(() => const AuthenticateByPhone());
      } else {
        Get.snackbar(
            "Sorry 😢", "You are not an owner or you entered invalid details",
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        isLoggingIn = false;
        isUser = false;
        storage.remove("token");
        storage.remove("agent_code");
      }
    } else {
      Get.snackbar("Sorry 😢", "invalid details",
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      isLoggingIn = false;
      isUser = false;
      storage.remove("token");
      storage.remove("agent_code");
    }
  }

}
