import 'dart:async';
import 'dart:convert';

import 'package:easy_admin/controller/profilecontroller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../../constants.dart';
import '../../controller/agentcontroller.dart';


class MyOwners extends StatefulWidget {
  const MyOwners({Key? key}) : super(key: key);

  @override
  State<MyOwners> createState() => _MyOwnersState();
}

class _MyOwnersState extends State<MyOwners> {
  final AgentController controller = Get.find();
  final ProfileController profileController = Get.find();
  late String uToken = "";
  late String agentCode = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyAgents = [];
  late List allBlockedUsers = [];
  bool isPosting = false;
  late Timer _timer;

  Future<void> getAllMyAgents() async {
    try {
      isLoading = true;
      const completedRides = "https://fnetagents.xyz/get_all_my_agents/admin/";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $uToken"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allMyAgents.assignAll(jsonData);
        setState(() {
          isLoading = false;
        });
      }
      else{
        print(response.body);
      }
    } catch (e) {
      Get.snackbar("Sorry","something happened or please check your internet connection");
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

  approveOwner(String userId,String email,String username,String phone,String fullName,String owner,String aCode) async {
    final depositUrl = "https://fnetagents.xyz/approve_user/$userId/";
    final myLink = Uri.parse(depositUrl);
    final res = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "user_approved": "True",
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
      getAllMyAgents();
      Get.snackbar("Success", "agent is added to block lists",
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
      getAllMyAgents();
      Get.snackbar("Success", "agent is added to block lists",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);
    }
    else{
      if (kDebugMode) {
        print(res.body);
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
      getAllMyAgents();
      Get.snackbar("Success", "agent is removed from block lists",
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
    if (kDebugMode) {
      print(agentCode);
    }
    controller.getAllMyAgents(uToken,profileController.adminUniqueCode);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      controller.getAllMyAgents(uToken,profileController.adminUniqueCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Owners"),
        backgroundColor: secondaryColor,
      ),
      body: GetBuilder<AgentController>(builder: (controller){
        return ListView.builder(
            itemCount: controller.allMyAgents != null ? controller.allMyAgents.length : 0,
            itemBuilder: (context, i) {
              items = controller.allMyAgents[i];
              return controller.allMyAgents[i]['agent_unique_code'] == profileController.adminUniqueCode ? Container() : Card(
                color: secondaryColor,
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: (){
                    !controller.allMyAgents[i]['user_approved'] ? Get.snackbar("Please wait", "approving owner",
                        colorText: defaultWhite,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: snackBackground,
                        duration: const Duration(seconds: 5)) : Container();
                   approveOwner(controller.allMyAgents[i]['id'].toString(),controller.allMyAgents[i]['email'],controller.allMyAgents[i]['username'],controller.allMyAgents[i]['phone_number'],controller.allMyAgents[i]['full_name'],controller.allMyAgents[i]['owner'],controller.allMyAgents[i]['agent_unique_code']);
                  },
                  title: buildRow("Name: ", "full_name"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildRow("Username : ", "username"),
                      buildRow("Phone : ", "phone_number"),
                      buildRow("Email : ", "email"),
                      buildRow("Company : ", "company_name"),
                      buildRow("Company No : ", "company_number"),
                      buildRow("Location : ", "location"),
                     items['agent_code'] == "" ? Container() :  buildRow("Agent Code : ", "agent_code"),
                      !controller.allMyAgents[i]['user_approved'] ?
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0,bottom: 8,top: 8),
                        child: Text("Owner is not approved yet,tap to approve",style: TextStyle(fontWeight: FontWeight.bold,color: snackBackground),),
                      ) : Row(
                        children: [
                          Lottie.asset("assets/images/41755-approved.json",width: 50,height: 50),
                          const Text("Owner Approved",style: TextStyle(fontWeight: FontWeight.bold,color: snackBackground))
                        ],
                      ),
                    ],
                  ),
                  trailing: items['user_blocked'] ? IconButton(
                      onPressed: () {
                        Get.snackbar("Please wait...", "unblocking owner",
                            colorText: defaultWhite,
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 5),
                            backgroundColor: snackBackground);
                        removeFromBlockedList(controller.allMyAgents[i]['id'].toString(),controller.allMyAgents[i]['email'],controller.allMyAgents[i]['username'],controller.allMyAgents[i]['phone_number'],controller.allMyAgents[i]['full_name'],controller.allMyAgents[i]['owner'],controller.allMyAgents[i]['agent_unique_code'],);
                      },
                      icon:Image.asset("assets/images/blocked.png",width:100,height:100)
                  ) :
                  IconButton(
                      onPressed: () {
                        Get.snackbar("Please wait...", "blocking owner",
                            colorText: defaultWhite,
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 5),
                            backgroundColor: snackBackground);
                        addToBlockedList(controller.allMyAgents[i]['id'].toString(),controller.allMyAgents[i]['email'],controller.allMyAgents[i]['username'],controller.allMyAgents[i]['phone_number'],controller.allMyAgents[i]['full_name'],controller.allMyAgents[i]['owner'],controller.allMyAgents[i]['agent_unique_code']);
                      },
                      icon:Image.asset("assets/images/block.png",width:100,height:100)
                  ),
                ),
              );
            });
      },),

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
          Expanded(
            child: Text(
              items[subtitle],
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
