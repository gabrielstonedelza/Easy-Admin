import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../controller/agentcontroller.dart';
import '../widget/loadingui.dart';



class MyUsers extends StatefulWidget {
  const MyUsers({Key? key}) : super(key: key);

  @override
  State<MyUsers> createState() => _MyUsersState();
}

class _MyUsersState extends State<MyUsers> {
  final AgentController controller = Get.find();
  late String uToken = "";
  late String agentCode = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyAgents = [];
  late List allBlockedUsers = [];
  bool isPosting = false;
  late Timer _timer;

  Future<void> getAllMyUsers() async {
    const completedRides = "https://fnetagents.xyz/get_all_agents/";
    var link = Uri.parse(completedRides);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allMyAgents.assignAll(jsonData);
      setState(() {
        isLoading = false;
      });
    }
    else{
    }
  }

  Future<void>fetchBlockedAgents()async{
    const url = "https://fnetagents.xyz/get_all_blocked/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBlockedUsers = json.decode(jsonData);
      if (kDebugMode) {
        print(allBlockedUsers);
      }
      setState(() {
        isLoading = false;
        allBlockedUsers = allBlockedUsers;
      });
    }

  }
  addToBlockedList(String userId,String email,String username,String phone,String fullName,String owner,String aCode) async {
    final depositUrl = "https://fnetagents.xyz/update_blocked/$userId/";
    final myLink = Uri.parse(depositUrl);
    final res = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "user_blocked": "True",
      "email": email,
      "username": username,
      "phone_number": phone,
      "full_name": fullName,
      "owner": owner,
      "agent_unique_code": aCode,
    });
    if (res.statusCode == 201) {
      setState(() {
        isLoading = false;
      });
      getAllMyUsers();
      Get.snackbar("Please wait", "blocking agent",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);
    }
    else{
      if (kDebugMode) {
        // print(res.body);
      }
    }
  }

  removeFromBlockedList(String userId,String email,String username,String phone,String fullName,String owner,String aCode) async {
    final depositUrl = "https://fnetagents.xyz/update_blocked/$userId/";
    final myLink = Uri.parse(depositUrl);
    final res = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "user_blocked": "False",
      "email": email,
      "username": username,
      "phone_number": phone,
      "full_name": fullName,
      "owner": owner,
      "agent_unique_code": aCode,
    });
    if (res.statusCode == 201) {
      setState(() {
        isLoading = false;
      });
      getAllMyUsers();
      Get.snackbar("Please wait", "unblocking agent",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);
    }
    else{
      if (kDebugMode) {
        // print(res.body);
      }
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
    if (storage.read("agent_code") != null) {
      setState(() {
        agentCode = storage.read("agent_code");
      });
    }
    controller.getAllMyAgents(uToken,agentCode);
    getAllMyUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Agents"),
        backgroundColor: secondaryColor,
      ),
      body:isLoading
          ? const LoadingUi() : ListView.builder(
          itemCount: allMyAgents != null ? allMyAgents.length : 0,
          itemBuilder: (context, i) {
            items = allMyAgents[i];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(

                title: buildRow("Name: ", "full_name"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Username : ", "username"),
                    buildRow("Phone : ", "phone_number"),
                    buildRow("Email : ", "email"),
                    // const Padding(
                    //   padding: EdgeInsets.only(left: 8.0,bottom: 8,top: 8),
                    //   child: Text("Tap for more",style: TextStyle(fontWeight: FontWeight.bold,color: snackBackground),),
                    // )
                  ],
                ),
                trailing: items['user_blocked'] ? IconButton(
                    onPressed: () {
                      Get.snackbar("Please wait...", "removing user from  block lists",
                          colorText: defaultWhite,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 5),
                          backgroundColor: snackBackground);
                      removeFromBlockedList(allMyAgents[i]['id'].toString(),allMyAgents[i]['email'],allMyAgents[i]['username'],allMyAgents[i]['phone_number'],allMyAgents[i]['full_name'],allMyAgents[i]['owner'],allMyAgents[i]['agent_unique_code'],);
                    },
                    icon:Image.asset("assets/images/blocked.png",width:100,height:100)
                ) : IconButton(
                    onPressed: () {
                      Get.snackbar("Please wait...", "adding user to block lists",
                          colorText: defaultWhite,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 5),
                          backgroundColor: snackBackground);
                      addToBlockedList(allMyAgents[i]['id'].toString(),allMyAgents[i]['email'],allMyAgents[i]['username'],allMyAgents[i]['phone_number'],allMyAgents[i]['full_name'],allMyAgents[i]['owner'],allMyAgents[i]['agent_unique_code']);
                    },
                    icon:Image.asset("assets/images/block.png",width:100,height:100)
                ),
              ),
            );
          })

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
