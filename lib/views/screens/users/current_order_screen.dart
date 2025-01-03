import 'package:flutter/material.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';

class CurrentOrderScreen extends StatefulWidget {
  const CurrentOrderScreen({super.key});

  @override
  State<CurrentOrderScreen> createState() => _CurrentOrderScreenState();
}

class _CurrentOrderScreenState extends State<CurrentOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "SSS Retail"),
      body: Center(
        child: Text('Current Order Screen'),
      ),
    );
  }
}
