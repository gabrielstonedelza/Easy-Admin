
import 'dart:convert';
import 'package:get/get.dart';
import 'package:easy_admin/dashboard.dart';
import 'package:easy_admin/widget/loadingui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../sendsms.dart';



class AddMeeting extends StatefulWidget {
  const AddMeeting({Key? key}) : super(key: key);

  @override
  State<AddMeeting> createState() => _AddMeetingState();
}

class _AddMeetingState extends State<AddMeeting> {

  final storage = GetStorage();
  late String uToken = "";
  late DateTime _dateTime;
  TimeOfDay _timeOfDay = const TimeOfDay(hour: 8, minute: 30);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController messageController;
  late final TextEditingController dateOfMeetingController;
  late final TextEditingController timeOfMeetingController;
  FocusNode titleFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();
  FocusNode dateOfMeetingFocusNode = FocusNode();
  FocusNode timeOfMeetingFocusNode = FocusNode();

  bool isPosting = false;
  bool isLoading = true;
  late List owners = [];
  late List ownersNumbers = [];
  final SendSmsController sendSms = SendSmsController();

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }
  addMeeting() async {
    const bidUrl = "https://fnetagents.xyz/admin_set_up_meeting/";
    final myLink = Uri.parse(bidUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "title": titleController.text.trim(),
      "message": messageController.text.trim(),
      "date_of_meeting": dateOfMeetingController.text.trim(),
      "time_of_meeting": timeOfMeetingController.text.trim(),
    });
    if (response.statusCode == 201) {
      for(var i in ownersNumbers){
        String telnum = i;
        telnum = telnum.replaceFirst("0", '+233');
        sendSms.sendMySms(telnum, "EasyAgent","Hello folks,hope you are all doing well.There is going to be a meeting on the ${dateOfMeetingController.text.trim} at ${timeOfMeetingController.text.trim()},this meeting is going to be online and links will be sent you via sms,thank you.");
      }
      Get.snackbar("Success", "Meeting was created",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);
      Get.offAll(() => const Dashboard());
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }
  fetchOwners() async {
    const url = "https://fnetagents.xyz/get_all_supervisors/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      owners = json.decode(jsonData);
      for(var i in owners){
        if(!ownersNumbers.contains(i['phone_number'])){
          ownersNumbers.add(i['phone_number']);
        }
      }
      print(ownersNumbers);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    titleController = TextEditingController();
    messageController = TextEditingController();
    dateOfMeetingController = TextEditingController();
    timeOfMeetingController = TextEditingController();
    fetchOwners();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    messageController.dispose();
    dateOfMeetingController.dispose();
    timeOfMeetingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("Add new meeting"),
      ),
      body:isLoading
          ? const LoadingUi()
          : ListView(
        children: [
          const SizedBox(height: 60,),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: titleController,
                      focusNode: titleFocusNode,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Title"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter title";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: messageController,
                      focusNode: messageFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorColor: secondaryColor,
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Agenda"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter agenda";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: dateOfMeetingController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.event,color: secondaryColor,),
                            onPressed: (){
                              showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2080)
                              ).then((value) {
                                setState(() {
                                  _dateTime = value!;
                                  dateOfMeetingController.text = _dateTime.toString().split("00").first;
                                });
                              });
                            },
                          ),
                          labelText: "click on icon to pick meeting date",
                          labelStyle: const TextStyle(color: secondaryColor),

                          focusColor: secondaryColor,
                          fillColor: secondaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please pick a start date";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: timeOfMeetingController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time,color: secondaryColor,),
                            onPressed: (){
                              showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value) {
                                setState(() {
                                  _timeOfDay = value!;
                                  timeOfMeetingController.text = _timeOfDay.format(context).toString();
                                });
                              });
                            },
                          ),
                          labelText: "Click on icon to pick up time for meeting",
                          labelStyle: const TextStyle(color: secondaryColor),

                          focusColor: secondaryColor,
                          fillColor: secondaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please pick a time";
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  isPosting  ? const LoadingUi() :
                  NeoPopTiltedButton(
                    isFloating: true,
                    onTapUp: () {
                      _startPosting();
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        addMeeting();
                      }
                    },
                    decoration: const NeoPopTiltedButtonDecoration(
                      color: secondaryColor,
                      plunkColor: Color.fromRGBO(255, 235, 52, 1),
                      shadowColor: Color.fromRGBO(36, 36, 36, 1),
                      showShimmer: true,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 70.0,
                        vertical: 15,
                      ),
                      child: Text('Save',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelStyle: const TextStyle(color: secondaryColor),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(12)),
    );
  }
}
