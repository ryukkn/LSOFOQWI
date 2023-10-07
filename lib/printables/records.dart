import 'package:bupolangui/functions/functions.dart';
import 'package:bupolangui/models/report.dart';
import 'package:bupolangui/models/session.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

double printscale = 0.9;


pw.TableRow sheetHeader(){
  List<String> labels = ["NAME OF STUDENT", "WORKSTATION NO.", "SYSTEM UNIT","MONITOR", "KEYBOARD","MOUSE","AVR/UPS","WIFI DONGLE","REMARKS"];
  List<pw.Widget> rowWidgets = [ ];

  List<double> columnWidths = [double.infinity, 120, 60, 60, 60, 60, 60,60,120];
  int i = 0;
  for (var label in labels) {
    rowWidgets.add(
      pw.Flexible(
        child: pw.SizedBox(
          width: columnWidths[i],
          height: 30.0*printscale,
          child:  pw.Center(child: pw.Text(label, style:  pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 7.5*printscale,
                                fontWeight: pw.FontWeight.bold,
                            ))),)
      )
    );
    i+=1;
  }

  return pw.TableRow(children: rowWidgets);

}

pw.Widget convertStatus(String status){
  switch(status){
    case "NF":
      return pw.Text("X", style:  pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 7.5*printscale,
                                fontWeight:  pw.FontWeight.bold,
                            ));
    case "M":
      return pw.Text("M", style:  pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 7.5*printscale,
                                fontWeight:  pw.FontWeight.bold,
                            ));
    case "N/A":
      return pw.Text("N/A", style:  pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 7.5*printscale,
                                fontWeight:  pw.FontWeight.bold,
                            ));
    case "F":
      return  pw.Icon(const pw.IconData(0xe5ca), size: 12.0*printscale);
    default:
    return pw.Text(status, style:  pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 7.5*printscale,
                                fontWeight:  pw.FontWeight.bold,
                            ));

  }
}

pw.TableRow sheetRow(List<Session> sessions, int index){

  List<dynamic>? sessionInfos;
  if(sessions.length >= index){
    var session = sessions[index-1];
    sessionInfos = [session.student, session.device,session.systemUnit!, session.monitor!,
      session.keyboard!, session.mouse!, session.avrups!, session.wifidongle, session.remarks!
    ];
  }else{
    sessionInfos = ["","","","","","","","",""];
  }
  List<pw.Widget> rowWidgets = [ ];

  List<double> columnWidths = [double.infinity, 120, 60, 60, 60, 60, 60,60,120];
  int i = 0;
  for (var sessionInfo in sessionInfos) {
    rowWidgets.add(
      pw.Flexible(
        child: pw.SizedBox(
          width: columnWidths[i],
          height: 25.0*printscale,
          child:  (i==0) ? pw.Row(children: [
            pw.SizedBox(
              width: 15.0,
              height: double.infinity,
              child: pw.DecoratedBox(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 1.0)),),
              child: pw.Center(child: pw.Text(index.toString(),
                style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 7.5*printscale,
                            )
              ))
            )),
            pw.SizedBox(width: 10.0),
           convertStatus(sessionInfo)
          ]):  pw.Center(child:convertStatus(sessionInfo)),)
      )
    );
    i+=1;
  }

  return pw.TableRow(children: rowWidgets);

}



buildPrintableReport(List<Session> sessions, Report report, image,startIndex) => pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal:30.0*printscale, vertical: 15.0*printscale),
                  child: pw.Column(children: [
                    pw.Row(children: [
                      pw.Image(
                        image, width: 60*printscale, height: 60*printscale
                      ),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.SizedBox(width: 1.0*printscale , height: 60*printscale, child: pw.DecoratedBox(decoration: const pw.BoxDecoration(color: PdfColor(0, 0, 0,1)))),
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                        pw.SizedBox(height: 5.0*printscale),
                         pw.SizedBox(
                          width: 158*printscale,
                          child: pw.DecoratedBox(decoration: const pw.BoxDecoration(color: PdfColor(1,1,1,1)),
                          child: pw.Padding(padding: pw.EdgeInsets.only(left: 5.0*printscale),
                            child: pw.Text("BICOL UNIVERSITY", style: pw.TextStyle(color: const PdfColor(0,0,0,1), fontSize: 16*printscale,
                              fontWeight: pw.FontWeight.bold
                            ))
                          )
                        )),
                        pw.SizedBox(
                          width: 158*printscale,
                          child: pw.DecoratedBox(decoration: const pw.BoxDecoration(color: PdfColor(0,0,0,1)),
                          child: pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 5.0),
                            child: pw.Text("POLANGUI", 
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(color: const PdfColor(1,1,1,1),
                                    fontSize: 15.0*printscale, letterSpacing: 1.2, fontWeight: pw.FontWeight.bold
                            ))
                          )
                        )),
                         pw.SizedBox(
                          width: 165*printscale,
                          child: pw.DecoratedBox(decoration: const pw.BoxDecoration(color: PdfColor(1,1,1,1)),
                          child: pw.Padding(padding: const pw.EdgeInsets.only(left: 5.0),
                            child: pw.Text("COMPUTER STUDIES DEPARTMENT", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 9.0*printscale,
                                fontWeight: pw.FontWeight.bold,
                            ))
                          )
                        )),
                      ])
                    ]),
                    pw.SizedBox(height: 10.0*printscale,),
                     pw.Row(children: [
                      pw.Text("COMPUTER LABORATORY MONITORING SHEET", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold,
                            )),
                      pw.Spacer(),
                       pw.Text("COURSE CODE and SECTION: ", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.SizedBox(
                        width: 130*printscale,
                        child: pw.DecoratedBox(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5*printscale))),
                          child: pw.Text("${parseAcronym(report.course)} ${report.yearblock}",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                        )),
                      pw.SizedBox(width: 120.0*printscale)
                    ]),
                    pw.SizedBox(height: 3.0*printscale),
                     pw.Row(children: [
                       pw.Text("COMPUTER LABORATORY NO. ", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.SizedBox(
                        width: 70*printscale,
                        child: pw.DecoratedBox(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5*printscale))),
                          child: pw.Text( parseAcronym(report.laboratory),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                        )),
                      pw.Spacer(),
                       pw.Text("FACULTY IN-CHARGE: ", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.SizedBox(
                        width: 166*printscale,
                        child: pw.DecoratedBox(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5*printscale))),
                          child: pw.Text(report.faculty,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                        )),
                      pw.SizedBox(width: 120.0*printscale)
                    ]),
                    pw.SizedBox(height: 3.0*printscale),
                     pw.Row(children: [
                       pw.Text("DATE:", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.SizedBox(
                        width: 100*printscale,
                        child: pw.DecoratedBox(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5*printscale))),
                          child: pw.Text(parseDate(report.timeIn),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                        )),
                      pw.SizedBox(width: 5.0*printscale),
                       pw.Text("TIME:", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.SizedBox(
                        width: 60*printscale,
                        child: pw.DecoratedBox(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5*printscale))),
                          child: pw.Text(parseTime(report.timeIn),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                        )),
                      pw.SizedBox(width: 120.0*printscale)
                    ]),
                    pw.SizedBox(height: 15*printscale),
                     pw.Row(children: [
                       pw.Text("INSTRUCTIONS: ", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.Text("Indicate the status of your assigned workstation using the code below: ", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                    ]),
                    pw.SizedBox(height: 3.0*printscale),
                     pw.Row(children: [
                      pw.SizedBox(width: 30*printscale),
                      pw.Icon(const pw.IconData(0xe5ca), size: 16.0*printscale),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.Text(" - functional", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                      pw.SizedBox(width: 50*printscale),
                        pw.Text("X", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.Text(" - not functional", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                      pw.SizedBox(width: 50*printscale),
                        pw.Text("M", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.Text(" - missing", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                      pw.SizedBox(width: 50*printscale),
                        pw.Text("N/A", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                                fontWeight: pw.FontWeight.bold
                            )),
                      pw.SizedBox(width: 5.0*printscale),
                      pw.Text(" - not applicable", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                    ]),
                    pw.SizedBox(height: 5.0*printscale),
                     pw.Row(children: [
                      pw.SizedBox(width: 20.0*printscale),
                       pw.Text("For missing and non-functional components, please inform your faculty in-charge immediately.", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                    ]),
                    pw.SizedBox(height: 3.0*printscale),
                     pw.Row(children: [
                      pw.SizedBox(width: 20.0*printscale),
                       pw.Text("Submit this form to the laboratory technician at the end of each class.", style: pw.TextStyle(color: const PdfColor(0,0,0,1),
                                fontSize: 10.0*printscale,
                            )),
                    ]),
                    pw.SizedBox(height: 1.0*printscale),
                    pw.Table(
                      border:pw.TableBorder.all(width: 1.0),
                      children: [
                        sheetHeader(),
                        sheetRow(sessions, startIndex + 1),
                        sheetRow(sessions, startIndex + 2),
                        sheetRow(sessions, startIndex + 3),
                        sheetRow(sessions, startIndex + 4),
                        sheetRow(sessions, startIndex + 5),
                        sheetRow(sessions, startIndex + 6),
                        sheetRow(sessions, startIndex + 7),
                        sheetRow(sessions, startIndex + 8),
                        sheetRow(sessions, startIndex + 9),
                        sheetRow(sessions, startIndex + 10),
                        sheetRow(sessions, startIndex + 11),
                        sheetRow(sessions, startIndex + 12),
                        sheetRow(sessions, startIndex + 13),
                        sheetRow(sessions, startIndex + 14),
                        sheetRow(sessions, startIndex + 15),
                    ])

                  ]),
                ); // Center