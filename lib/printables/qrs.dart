

import 'package:bupolangui/models/device.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;


buildPrintableQR(List<Device> devices) => pw.Center(child: pw.Column(
  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
  children:[
  pw.Padding(padding:const pw.EdgeInsets.symmetric(horizontal:110.0), child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
        pw.Column(children: [
          (devices.isEmpty) ? pw.SizedBox(width:0) : pw.BarcodeWidget(
            data: devices[0].QR!,
            barcode: pw.Barcode.qrCode(),
            width: 120,
            height: 120,
            ),
          pw.SizedBox(height:15.0,),
          (devices.isEmpty) ? pw.SizedBox(width:0) : pw.Text(devices[0].name , style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
          ]),
          pw.Column(children: [
          (devices.length < 2) ? pw.SizedBox(width:0) : pw.BarcodeWidget(
            data: devices[1].QR!,
            barcode: pw.Barcode.qrCode(),
            width: 120,
            height: 120,),
          pw.SizedBox(height:15.0,),
           (devices.length < 2) ? pw.SizedBox(width:0) : pw.Text(devices[1].name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
          ]),
      
      ])),
      pw.Padding(padding:const pw.EdgeInsets.symmetric(horizontal:110.0), child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
        pw.Column(children: [
          (devices.length < 3) ? pw.SizedBox(width:0) : pw.BarcodeWidget(
            data: devices[2].QR!,
            barcode: pw.Barcode.qrCode(),
            width: 120,
            height: 120,
            ),
          pw.SizedBox(height:15.0,),
           (devices.length < 3) ? pw.SizedBox(width:0) : pw.Text(devices[2].name , style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
          ]),
          pw.Column(children: [
          (devices.length < 4) ? pw.SizedBox(width:0) : pw.BarcodeWidget(
            data: devices[3].QR!,
            barcode: pw.Barcode.qrCode(),
            width: 120,
            height: 120,),
          pw.SizedBox(height:15.0,),
           (devices.length < 4) ? pw.SizedBox(width:0) :pw.Text(devices[3].name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
          ]),
      
      ])),
      pw.Padding(padding:const pw.EdgeInsets.symmetric(horizontal:110.0), child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
        pw.Column(children: [
          (devices.length < 5) ? pw.SizedBox(width:0) : pw.BarcodeWidget(
            data: devices[4].QR!,
            barcode: pw.Barcode.qrCode(),
            width: 120,
            height: 120,
            ),
          pw.SizedBox(height:15.0,),
          (devices.length < 5) ? pw.SizedBox(width:0) : pw.Text(devices[4].name , style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
          ]),
          pw.Column(children: [
          (devices.length < 6) ? pw.SizedBox(width:0) : pw.BarcodeWidget(
            data: devices[5].QR!,
            barcode: pw.Barcode.qrCode(),
            width: 120,
            height: 120,),
          pw.SizedBox(height:15.0,),
          (devices.length < 6) ? pw.SizedBox(width:0) :  pw.Text(devices[5].name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
          ]),
      
      ]))
]));