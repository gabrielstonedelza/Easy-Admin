import 'dart:convert';
import 'package:easy_admin/widget/loadingui.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;

import 'constants.dart';


class SearchAgentsOrOwner extends StatefulWidget {
  const SearchAgentsOrOwner({Key? key}) : super(key: key);

  @override
  State<SearchAgentsOrOwner> createState() => _SearchAgentsOrOwnerState();
}

class _SearchAgentsOrOwnerState extends State<SearchAgentsOrOwner> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _searchFilter;
  FocusNode searchFocusNode = FocusNode();
  late List searchedUsers = [];
  late List users = [];
  bool isSearching = false;
  bool hasData = false;
  var items;
  late String uToken = "";
  final storage = GetStorage();

  Future<void>fetchAgentOrOwner(String searchItem)async{
    final url = "https://fnetagents.xyz/search_agent_or_owner?search=$searchItem";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      users = json.decode(jsonData);
      setState(() {
        isSearching = false;
        hasData = true;
      });
    }
    else{
      if (kDebugMode) {
        print(response.body);
        setState(() {
          hasData = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    _searchFilter = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _searchFilter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Find agent or owner"),
          backgroundColor: secondaryColor,
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 10,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          focusNode: searchFocusNode,
                          controller: _searchFilter,
                          cursorColor: secondaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: buildInputDecoration("Eg.username,name,phone number,company"),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please field cannot be empty";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20,),

                        isSearching  ? const LoadingUi() :
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RawMaterialButton(
                            fillColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                            ),
                            onPressed: (){
                              setState(() {
                                isSearching = true;
                              });
                              FocusScopeNode currentFocus = FocusScope.of(context);

                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              if (!_formKey.currentState!.validate()) {
                                return;
                              } else {
                                fetchAgentOrOwner(_searchFilter.text);
                              }
                            },child: const Text("Search",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              hasData?  Expanded(
                flex: 3,
                child: ListView.builder(
                    itemCount: users != null ? users.length : 0,
                    itemBuilder: (context,i){
                      items = users[i];
                      return Column(
                        children: [
                          const SizedBox(height: 20,),
                          GestureDetector(
                            onTap: () {
                              // Get.to(()=> DetailCustomerRedeemedPoints(phone:customers[i]['phone']));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0,right: 8),
                              child: Card(
                                color: secondaryColor,
                                elevation: 12,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                // shadowColor: Colors.pink,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(bottom: 15.0),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top:10.0),
                                            child: Text("Name: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top:10.0),
                                            child: Text(items['full_name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Phone: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                            Text(items['phone_number'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                          ],
                                        ),
                                        const SizedBox(height:5),
                                        Row(
                                          children: [
                                            const Text("Location: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                            Text(items['location'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                          ],
                                        ),
                                        const SizedBox(height:5),
                                        Row(
                                          children: [
                                            const Text("Digital Add: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                            Text(items['digital_address'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                          ],
                                        ),
                                        const SizedBox(height:5),
                                        Row(
                                          children: [
                                            const Text("Email: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                            Text(items['email'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text("Company: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                            Text(items['company_name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                          ],
                                        ),
                                        const SizedBox(height:15),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }
                ),
              ) : Container()
            ],
          ),
        )
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
