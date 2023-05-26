import 'dart:async';
import 'dart:convert';

import 'package:easy_admin/widget/loadingui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';


class AuthPhones extends StatefulWidget {
  const AuthPhones({Key? key}) : super(key: key);

  @override
  State<AuthPhones> createState() => _AuthPhonesState();
}

class _AuthPhonesState extends State<AuthPhones> {

  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allAuthPhones = [];
  bool isPosting = false;
  late Timer _timer;

  Future<void> getAllAuthPhones() async {
    const completedRides = "https://fnetagents.xyz/get_all_auth_phones/";
    var link = Uri.parse(completedRides);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allAuthPhones.assignAll(jsonData);
      setState(() {
        isLoading = false;
      });
    }
  }
  deleteRequest(String id) async {
    final url = "https://fnetagents.xyz/delete_auth_phone/$id";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 204) {
      // Get.offAll(() => const Dashboard());
    } else {

    }
  }


  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    getAllAuthPhones();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auth Phones"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allAuthPhones != null ? allAuthPhones.length : 0,
          itemBuilder: (context, i) {
            items = allAuthPhones[i];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: buildRow("User: ", "get_agent_username"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Phone : ", "phone_model"),
                  ],
                ),
                trailing: IconButton(
                    onPressed: () async{
                      Get.snackbar("Please wait...", "removing authenticated phone",
                          colorText: defaultWhite,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 5),
                          backgroundColor: snackBackground);
                      deleteRequest(allAuthPhones[i]['id'].toString());
                      await Future.delayed(const Duration(seconds: 3));
                      getAllAuthPhones();
                    },
                    icon:const Icon(Icons.close,size: 30,color: warning,)
                ),
              ),
            );
          }),

    );
  }

  Padding buildRow(String mainTitle, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            mainTitle,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            items[subtitle],
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
