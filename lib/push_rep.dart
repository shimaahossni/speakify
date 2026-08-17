// push_rep.dart
import 'package:flutter/material.dart';

pushReplacement(BuildContext context, Widget view) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => view));
}