import 'dart:async';
import 'dart:convert';

import 'package:easy_admin/join_screen.dart';
import 'package:easy_admin/screens/aboutpage.dart';
import 'package:easy_admin/screens/agents/addnewagent.dart';
import 'package:easy_admin/screens/agents/myowners.dart';
import 'package:easy_admin/screens/allusers.dart';
import 'package:easy_admin/screens/chats/allmyagents.dart';
import 'package:easy_admin/screens/chats/groupchat.dart';
import 'package:easy_admin/screens/chats/ownersgroupchat.dart';
import 'package:easy_admin/screens/makepayment.dart';
import 'package:easy_admin/screens/meetings/allmeetings.dart';
import 'package:easy_admin/screens/sms/selectsms.dart';
import 'package:easy_admin/searchagentorowner.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

import 'authenticatebyphone.dart';

import 'authphones.dart';
import 'complains.dart';
import 'constants.dart';
import 'controller/authphonecontroller.dart';
import 'controller/localnotificationmanager.dart';
import 'controller/notificationcontroller.dart';
import 'controller/profilecontroller.dart';
import 'controller/trialmonthlypayment.dart';
import 'login.dart';
import 'package:badges/badges.dart' as badges;

import 'notifications.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  NotificationController notificationsController = Get.find();
  final ProfileController profileController = Get.find();
  final storage = GetStorage();
  late String uToken = "";
  late String agentCode = "";
  late Timer _timer;
  bool isLoading = true;

  final _advancedDrawerController = AdvancedDrawerController();
  SmsQuery query = SmsQuery();
  late List mySmss = [];
  int lastSmsCount = 0;
  late List allNotifications = [];

  late List yourNotifications = [];

  late List notRead = [];

  late List triggered = [];

  late List unreadNotifications = [];

  late List triggeredNotifications = [];

  late List notifications = [];

  late List allNots = [];
  bool phoneNotAuthenticated = false;
  final AuthPhoneController authController = Get.find();
  final TrialAndMonthlyPaymentController tpController = Get.find();

  bool isAuthenticated = false;
  bool isAuthenticatedAlready = false;


  Future<void> getAllTriggeredNotifications() async {
    const url = "https://fnetagents.xyz/get_triggered_notifications/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      triggeredNotifications = json.decode(jsonData);
      triggered.assignAll(triggeredNotifications);
    }
  }

  Future<void> getAllUnReadNotifications() async {
    const url = "https://fnetagents.xyz/get_my_unread_notifications/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      yourNotifications = json.decode(jsonData);
      notRead.assignAll(yourNotifications);
    }
  }

  Future<void> getAllNotifications() async {
    const url = "https://fnetagents.xyz/get_my_notifications/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allNotifications = json.decode(jsonData);
      allNots.assignAll(allNotifications);
    }
  }

  unTriggerNotifications(int id) async {
    final requestUrl = "https://fnetagents.xyz/un_trigger_notification/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "notification_trigger": "Not Triggered",
      "read": "Read",
    });
    if (response.statusCode == 200) {}
  }

  updateReadNotification(int id) async {
    const requestUrl = "https://fnetagents.xyz/read_notification/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
    });
    if (response.statusCode == 200) {}
  }


  @override
  void initState() {
    super.initState();

    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    if (storage.read("phoneAuthenticated") != null) {
      setState(() {
        phoneNotAuthenticated = true;
      });
    }
    if (storage.read("agent_code") != null) {
      setState(() {
        agentCode = storage.read("agent_code");
      });
    }

    tpController.fetchFreeTrial(uToken);
    tpController.fetchAccountBalance(uToken);
    tpController.fetchMonthlyPayment(uToken);

    notificationsController.getAllNotifications(uToken);
    notificationsController.getAllUnReadNotifications(uToken);
    profileController.getUserDetails(uToken);
    profileController.getUserProfile(uToken);
    getAllTriggeredNotifications();

    _timer = Timer.periodic(const Duration(seconds: 12), (timer) {
      getAllTriggeredNotifications();
      getAllUnReadNotifications();
      // tpController.fetchFreeTrial(uToken);
      // tpController.fetchAccountBalance(uToken);
      // tpController.fetchMonthlyPayment(uToken);
      for (var i in triggered) {
        NotificationService().showNotifications(title:i['notification_title'], body:i['notification_message']);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      for (var e in triggered) {
        unTriggerNotifications(e["id"]);
      }
    });

  }

  logoutUser() async {
    storage.remove("token");
    storage.remove("agent_code");
    storage.remove("phoneAuthenticated");
    Get.offAll(() => const LoginView());
    const logoutUrl = "https://www.fnetagents.xyz/auth/token/logout";
    final myLink = Uri.parse(logoutUrl);
    http.Response response = await http.post(myLink, headers: {
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });

    if (response.statusCode == 200) {
      Get.snackbar("Success", "You were logged out",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);
      storage.remove("token");
      storage.remove("agent_code");
      Get.offAll(() => const LoginView());
    }
  }

  @override
  void dispose(){
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return  AdvancedDrawer(
        backdropColor: snackBackground,
        controller: _advancedDrawerController,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        animateChildDecoration: true,
        rtlOpening: false,
        // openScale: 1.0,
        disabledGestures: false,
        childDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        drawer: SafeArea(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 140.0,
                  height: 140.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/forapp.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                const Center(
                  child: Text(
                    "Version: 1.1.1",
                    style: TextStyle(
                        fontSize: 20,
                        color: defaultWhite,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(
                  color: secondaryColor,
                ),
                ListTile(
                  onTap: () {
                    Get.to(() => const AboutPage());
                  },
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                ),
                ListTile(
                  onTap: () {
                    Get.defaultDialog(
                        buttonColor: primaryColor,
                        title: "Confirm Logout",
                        middleText: "Are you sure you want to logout?",
                        confirm: RawMaterialButton(
                            shape: const StadiumBorder(),
                            fillColor: secondaryColor,
                            onPressed: () {
                              logoutUser();
                              Get.back();
                            },
                            child: const Text(
                              "Yes",
                              style: TextStyle(color: Colors.white),
                            )),
                        cancel: RawMaterialButton(
                            shape: const StadiumBorder(),
                            fillColor: secondaryColor,
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            )));
                  },
                  leading: const Icon(Icons.logout_sharp),
                  title: const Text('Logout'),
                ),
                const Spacer(),
                Container(
                  width: 140.0,
                  height: 140.0,
                  margin: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 14.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/png.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Column(
                    children: [
                      const Text(
                          'App created by Havens Software Development'),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child: const Text(
                            '+233597565022'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: _handleMenuButtonPressed,
              icon: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advancedDrawerController,
                builder: (_, value, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      value.visible ? Icons.clear : Icons.menu,
                      key: ValueKey<bool>(value.visible),
                    ),
                  );
                },
              ),
            ),
            title: GetBuilder<ProfileController>(builder:(controller){
              return Text(controller.adminUniqueCode,
                  style: const TextStyle(fontWeight: FontWeight.bold));
            }),
            backgroundColor: secondaryColor,
            actions: [
              // IconButton(onPressed: () {  }, icon: const Icon(Icons.notifications),)
              Padding(
                padding: const EdgeInsets.only(right: 23.0),
                child: Row(
                  children: [
                    GetBuilder<NotificationController>(
                        builder: (controller) {
                          return badges.Badge(
                            position:
                            badges.BadgePosition.topEnd(top: -10, end: -12),
                            showBadge: true,
                            badgeContent: Text(
                                controller.notificationsUnread.length
                                    .toString(),
                                style: const TextStyle(color: defaultWhite)),
                            badgeAnimation:
                            const badges.BadgeAnimation.rotation(
                              animationDuration: Duration(seconds: 1),
                              colorChangeAnimationDuration:
                              Duration(seconds: 1),
                              loopAnimation: false,
                              curve: Curves.fastOutSlowIn,
                              colorChangeAnimationCurve: Curves.easeInCubic,
                            ),
                            child: GestureDetector(
                                onTap: () {
                                  Get.to(() => const Notifications());
                                },
                                child: const Icon(Icons.notifications)),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
          body:  ListView(
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/sms.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Send Sms"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const SelectSms());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/group.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("My Owners"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const MyOwners());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/groupchat.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Chat"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const OwnersGroupChat());

                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/team1.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("All Agents"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const MyUsers());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/coworking.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Create Meeting"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const Meetings());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/sad.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Complains"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const Complains());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/live-stream.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Start Live Stream"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => JoinScreen());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/two-factor-authentication.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Delete auth"),
                          const Text("Phones"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const AuthPhones());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/recruitment.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Search"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const SearchAgentsOrOwner());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
    );

  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}