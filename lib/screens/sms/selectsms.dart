import 'package:easy_admin/constants.dart';
import 'package:easy_admin/screens/sms/sendagentsms.dart';
import 'package:easy_admin/screens/sms/sendcustomersms.dart';
import 'package:easy_admin/screens/sms/sendownersms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SelectSms extends StatelessWidget {
  const SelectSms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Select to send sms"),
            backgroundColor: secondaryColor),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => const SendOwnersSms());
                },
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/smartphone.png",
                      width: 70,
                      height: 70,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("Owners",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const SendAgentsSms());
                },
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/smartphone.png",
                      width: 70,
                      height: 70,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("Agents",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const SendCustomersSms());
                },
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/smartphone.png",
                      width: 70,
                      height: 70,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("Customers",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ])
          ],
        ));
  }
}
