

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

loader(double scaleFactor)=>Column(
  children: [
    Expanded(
      child: Center(
        child: SpinKitFoldingCube(
          color: Colors.blue,
          size: 250 * scaleFactor,
          ),
      ),
    ),
      SizedBox(height: 90*scaleFactor,)
  ],
);