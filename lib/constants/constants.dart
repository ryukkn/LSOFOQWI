



import 'package:bupolangui/models/student.dart';
import 'package:bupolangui/pages/faculty_portal.dart';
import 'package:bupolangui/pages/landing.dart';
import 'package:bupolangui/pages/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_html/flutter_html.dart';

dashboardHeader(double scaleFactor,String title) => Column(children: [
    Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60 *scaleFactor,
                width: 500.0 * scaleFactor,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                     boxShadow: [
                      BoxShadow(
                        offset: Offset(1,3),
                        spreadRadius: 2,
                        blurRadius: 2,
                        color: Colors.black54
                      )
                    ],
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), bottomRight: Radius.circular(20)),
                    color: Color.fromARGB(239, 7, 67, 90)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right_rounded, size: 32.0, color: Colors.white),
                          const SizedBox(width: 20.0),
                          Text(title,
                            style: TextStyle(
                              fontSize: 24 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2 ,
                              color: Colors.white
                            ),),
                        ],
                      )
                      ),
                  ),
                  ),  
                ),
                 Padding(
                   padding: const EdgeInsets.only(left: 20.0),
                   child: SizedBox(
                      width: 150.0 * scaleFactor,
                      height: 150.0 * scaleFactor,
                      child: Image.asset('assets/images/bupolanguiseal.png',
                        isAntiAlias: true,
                      )
                    ),
                 ),
                 Expanded(child: SizedBox(
                   height: 130.0 * scaleFactor,
                   child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,                      
                        child: Text("",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 20 *scaleFactor,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                   ),
                 )
                 )
            ],
          ),
],);


appBar(double scaleFactor,title, context,currentTab, back, account, {bool autoleading = false})=>AppBar(
              title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,letterSpacing: 1.5, fontSize: 20 * scaleFactor),),
              centerTitle: true,
              actions: [
                SizedBox(
                  width: 80.0*scaleFactor,
                  child: InkWell(
                    onTap: ()=>{
                      showDialog(context:context, builder:(context)=>
                        SimpleDialog(
                          alignment: Alignment.bottomCenter,
                          backgroundColor: Colors.transparent,
                          children:[
                             SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
                                ),
                                child: const Text("PROFILE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:()async{
                                   var accountUpdate =  await Navigator.push(
                                      context,
                                    PageRouteBuilder(
                                        pageBuilder: (context , anim1, anim2) =>
                                            ViewProfile(account: account)));
                                   if(accountUpdate!=null){
                                    account.fullname = accountUpdate.fullname;
                                    account.contact =accountUpdate.contact;
                                    if(account is Student){
                                      account.block = accountUpdate.block;
                                    }
                                   } 
                                }),
                            ),
                            const SizedBox(height: 20,),
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
                                ),
                                child: const Text("LOGOUT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:() async{
                                   SharedPreferences prefs =  await SharedPreferences.getInstance();
                                    await prefs.remove('ID');
                                    await prefs.remove('Type');
                                    try{
                                      final GoogleSignIn googleSignIn = GoogleSignIn(
                                        scopes: [
                                          'email',
                                          'https://www.googleapis.com/auth/contacts.readonly',
                                        ],
                                      );
                                      await googleSignIn.disconnect();
                                    }catch(e){
                                      print("Google SignIn failed");
                                    }
                                   Navigator.pushReplacement(
                                      context,
                                    PageRouteBuilder(
                                        pageBuilder: (context , anim1, anim2) =>
                                            const LandingPage()));
                                }),
                            ),
                          ]
                        )
                      )
                    },
                    child: const Icon(Icons.menu),
                  ),
                )
              ],
              automaticallyImplyLeading: autoleading,
              leading: (currentTab == 0) ? null : SizedBox(
                  width: 80.0*scaleFactor,
                  child: InkWell(
                    onTap: (){
                      back();
                    },
                    child: Icon(Icons.arrow_back, color:  (currentTab == 0) ? Colors.grey: Colors.white,),
                  ),
                )
            );


bottomNavigation (double scaleFactor, context,faculty, active)=> Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: 90*scaleFactor,
              child: Padding(
                padding: EdgeInsets.symmetric( horizontal: 10.0*scaleFactor ,vertical: 8.0),
                child: DecoratedBox(decoration: BoxDecoration(color: Colors.black87,
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                  boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, -2), // changes position of shadow
                          )
                        ]
                ),
                child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    SizedBox(
                      width: 60*scaleFactor,
                      height: double.infinity,
                      child: TextButton(child: Icon(Icons.home,color:  (active==1) ? Colors.blue : Colors.white, size: 40*scaleFactor,), onPressed: ()=>{
                          Navigator.pushReplacement(
                            context,
                          PageRouteBuilder(
                              pageBuilder: (context , anim1, anim2) =>
                                  FacultyHome(faculty: faculty,)))
                      },),
                    ),
                    SizedBox(
                      width: 60*scaleFactor,
                      height: double.infinity,
                      child: TextButton(child: Icon(Icons.calendar_month,color:  (active==2) ? Colors.blue :Colors.white, size: 40*scaleFactor,), onPressed: ()=>{
                         Navigator.pushReplacement(
                            context,
                          PageRouteBuilder(
                              pageBuilder: (context , anim1, anim2) =>
                                  FacultyScheduling(faculty: faculty,)))
                      },),
                    ),
                    SizedBox(
                      width: 60*scaleFactor,
                      height: double.infinity,
                      child: TextButton(child: Icon(Icons.edit_note,color: (active==3) ? Colors.blue : Colors.white, size: 40*scaleFactor,), onPressed: ()=>{
                           Navigator.pushReplacement(
                            context,
                          PageRouteBuilder(
                              pageBuilder: (context , anim1, anim2) =>
                                  FacultyManageCourse(faculty: faculty,)))
                      },),
                    ),
                    SizedBox(
                      width: 60*scaleFactor,
                      height: double.infinity,
                      child: TextButton(child: Icon(Icons.qr_code_scanner,color: (active==4) ? Colors.blue : Colors.white, size: 40*scaleFactor,), onPressed: ()=>{
                        Navigator.pushReplacement(
                            context,
                          PageRouteBuilder(
                              pageBuilder: (context , anim1, anim2) =>
                                  TimeIn(faculty: faculty,)))
                      },),
                    ),
                  ]),
                ),
              )
              ),
          );


simpleTitleHeader(double scaleFactor, String mainText, String subText)=> Column(children: [
    SizedBox(
            width: double.infinity,
            height: 25*scaleFactor,
            child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
          ),
          SizedBox(
          width: double.infinity,
          height: 90*scaleFactor,
          child: DecoratedBox(decoration: const BoxDecoration(color: Color.fromARGB(255, 200, 238, 255)),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                TextSpan(text: "$mainText\n", style: TextStyle(height: 2.5,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                TextSpan(text: "$subText\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black)),
              ])),
            ),
          ),
        ),
          SizedBox(
            width: double.infinity,
            height: 20*scaleFactor,
            child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
          ),
],);

infoHeader(double scaleFactor, String mainText, String subText)=> Column(children: [
    SizedBox(
            width: double.infinity,
            height: 25*scaleFactor,
            child: const DecoratedBox(decoration: BoxDecoration(color: Color.fromARGB(255, 17, 77, 112),
            )),
          ),
          SizedBox(
          width: double.infinity,
          height: 90*scaleFactor,
          child: DecoratedBox(decoration: const BoxDecoration(color: Color.fromARGB(255, 247, 232, 222),
          ),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                TextSpan(text: "$mainText\n", style: TextStyle(height: 2.5,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                TextSpan(text: "$subText\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 16*scaleFactor, color: Colors.black)),
              ])),
            ),
          ),
        ),
          SizedBox(
            width: double.infinity,
            height: 20*scaleFactor,
            child:  const DecoratedBox(decoration: BoxDecoration(color:  Color.fromARGB(255, 17, 77, 112),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2.0,
                  spreadRadius: 2.0
                )
              ]
            )),
          ),
],);


Widget termsAndCondition = Html(
  data: """<h2><strong>Terms and Conditions</strong></h2>

            <p>Welcome to CSD Comlab Monitoring!</p>

            <p>These terms and conditions outline the rules and regulations for the use of https://csdcomlabmonitoring.website's Website, located at https://csdcomlabmonitoring.website.</p>

            <p>By accessing this website we assume you accept these terms and conditions. Do not continue to use CSD Comlab Monitoring if you do not agree to take all of the terms and conditions stated on this page.</p>

            <p>The following terminology applies to these Terms and Conditions, Privacy Statement and Disclaimer Notice and all Agreements: "Client", "You" and "Your" refers to you, the person log on this website and compliant to the Company's terms and conditions. "The Company", "Ourselves", "We", "Our" and "Us", refers to our Company. "Party", "Parties", or "Us", refers to both the Client and ourselves. All terms refer to the offer, acceptance and consideration of payment necessary to undertake the process of our assistance to the Client in the most appropriate manner for the express purpose of meeting the Client's needs in respect of provision of the Company's stated services, in accordance with and subject to, prevailing law of ph. Any use of the above terminology or other words in the singular, plural, capitalization and/or he/she or they, are taken as interchangeable and therefore as referring to same.</p>

            <h3><strong>Cookies</strong></h3>

            <p>We employ the use of cookies. By accessing CSD Comlab Monitoring, you agreed to use cookies in agreement with the https://csdcomlabmonitoring.website's Privacy Policy. </p>

            <p>Most interactive websites use cookies to let us retrieve the user's details for each visit. Cookies are used by our website to enable the functionality of certain areas to make it easier for people visiting our website. Some of our affiliate/advertising partners may also use cookies.</p>

            <h3><strong>License</strong></h3>

            <p>Unless otherwise stated, https://csdcomlabmonitoring.website and/or its licensors own the intellectual property rights for all material on CSD Comlab Monitoring. All intellectual property rights are reserved. You may access this from CSD Comlab Monitoring for your own personal use subjected to restrictions set in these terms and conditions.</p>

            <p>You must not:</p>
            <ul>
                <li>Republish material from CSD Comlab Monitoring</li>
                <li>Sell, rent or sub-license material from CSD Comlab Monitoring</li>
                <li>Reproduce, duplicate or copy material from CSD Comlab Monitoring</li>
                <li>Redistribute content from CSD Comlab Monitoring</li>
            </ul>

            <p>This Agreement shall begin on the date hereof. Our Terms and Conditions were created with the help of the <a href="https://www.termsandconditionsgenerator.com/">Free Terms and Conditions Generator</a>.</p>

            <p>Parts of this website offer an opportunity for users to post and exchange opinions and information in certain areas of the website. https://csdcomlabmonitoring.website does not filter, edit, publish or review Comments prior to their presence on the website. Comments do not reflect the views and opinions of https://csdcomlabmonitoring.website,its agents and/or affiliates. Comments reflect the views and opinions of the person who post their views and opinions. To the extent permitted by applicable laws, https://csdcomlabmonitoring.website shall not be liable for the Comments or for any liability, damages or expenses caused and/or suffered as a result of any use of and/or posting of and/or appearance of the Comments on this website.</p>

            <p>https://csdcomlabmonitoring.website reserves the right to monitor all Comments and to remove any Comments which can be considered inappropriate, offensive or causes breach of these Terms and Conditions.</p>

            <p>You warrant and represent that:</p>

            <ul>
                <li>You are entitled to post the Comments on our website and have all necessary licenses and consents to do so;</li>
                <li>The Comments do not invade any intellectual property right, including without limitation copyright, patent or trademark of any third party;</li>
                <li>The Comments do not contain any defamatory, libelous, offensive, indecent or otherwise unlawful material which is an invasion of privacy</li>
                <li>The Comments will not be used to solicit or promote business or custom or present commercial activities or unlawful activity.</li>
            </ul>

            <p>You hereby grant https://csdcomlabmonitoring.website a non-exclusive license to use, reproduce, edit and authorize others to use, reproduce and edit any of your Comments in any and all forms, formats or media.</p>

            <h3><strong>Hyperlinking to our Content</strong></h3>

            <p>The following organizations may link to our Website without prior written approval:</p>

            <ul>
                <li>Government agencies;</li>
                <li>Search engines;</li>
                <li>News organizations;</li>
                <li>Online directory distributors may link to our Website in the same manner as they hyperlink to the Websites of other listed businesses; and</li>
                <li>System wide Accredited Businesses except soliciting non-profit organizations, charity shopping malls, and charity fundraising groups which may not hyperlink to our Web site.</li>
            </ul>

            <p>These organizations may link to our home page, to publications or to other Website information so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement or approval of the linking party and its products and/or services; and (c) fits within the context of the linking party's site.</p>

            <p>We may consider and approve other link requests from the following types of organizations:</p>

            <ul>
                <li>commonly-known consumer and/or business information sources;</li>
                <li>dot.com community sites;</li>
                <li>associations or other groups representing charities;</li>
                <li>online directory distributors;</li>
                <li>internet portals;</li>
                <li>accounting, law and consulting firms; and</li>
                <li>educational institutions and trade associations.</li>
            </ul>

            <p>We will approve link requests from these organizations if we decide that: (a) the link would not make us look unfavorably to ourselves or to our accredited businesses; (b) the organization does not have any negative records with us; (c) the benefit to us from the visibility of the hyperlink compensates the absence of https://csdcomlabmonitoring.website; and (d) the link is in the context of general resource information.</p>

            <p>These organizations may link to our home page so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement or approval of the linking party and its products or services; and (c) fits within the context of the linking party's site.</p>

            <p>If you are one of the organizations listed in paragraph 2 above and are interested in linking to our website, you must inform us by sending an e-mail to https://csdcomlabmonitoring.website. Please include your name, your organization name, contact information as well as the URL of your site, a list of any URLs from which you intend to link to our Website, and a list of the URLs on our site to which you would like to link. Wait 2-3 weeks for a response.</p>

            <p>Approved organizations may hyperlink to our Website as follows:</p>

            <ul>
                <li>By use of our corporate name; or</li>
                <li>By use of the uniform resource locator being linked to; or</li>
                <li>By use of any other description of our Website being linked to that makes sense within the context and format of content on the linking party's site.</li>
            </ul>

            <p>No use of https://csdcomlabmonitoring.website's logo or other artwork will be allowed for linking absent a trademark license agreement.</p>

            <h3><strong>iFrames</strong></h3>

            <p>Without prior approval and written permission, you may not create frames around our Webpages that alter in any way the visual presentation or appearance of our Website.</p>

            <h3><strong>Content Liability</strong></h3>

            <p>We shall not be hold responsible for any content that appears on your Website. You agree to protect and defend us against all claims that is rising on your Website. No link(s) should appear on any Website that may be interpreted as libelous, obscene or criminal, or which infringes, otherwise violates, or advocates the infringement or other violation of, any third party rights.</p>

            <h3><strong>Reservation of Rights</strong></h3>

            <p>We reserve the right to request that you remove all links or any particular link to our Website. You approve to immediately remove all links to our Website upon request. We also reserve the right to amen these terms and conditions and it's linking policy at any time. By continuously linking to our Website, you agree to be bound to and follow these linking terms and conditions.</p>

            <h3><strong>Removal of links from our website</strong></h3>

            <p>If you find any link on our Website that is offensive for any reason, you are free to contact and inform us any moment. We will consider requests to remove links but we are not obligated to or so or to respond to you directly.</p>

            <p>We do not ensure that the information on this website is correct, we do not warrant its completeness or accuracy; nor do we promise to ensure that the website remains available or that the material on the website is kept up to date.</p>

            <h3><strong>Disclaimer</strong></h3>

            <p>To the maximum extent permitted by applicable law, we exclude all representations, warranties and conditions relating to our website and the use of this website. Nothing in this disclaimer will:</p>

            <ul>
                <li>limit or exclude our or your liability for death or personal injury;</li>
                <li>limit or exclude our or your liability for fraud or fraudulent misrepresentation;</li>
                <li>limit any of our or your liabilities in any way that is not permitted under applicable law; or</li>
                <li>exclude any of our or your liabilities that may not be excluded under applicable law.</li>
            </ul>

            <p>The limitations and prohibitions of liability set in this Section and elsewhere in this disclaimer: (a) are subject to the preceding paragraph; and (b) govern all liabilities arising under the disclaimer, including liabilities arising in contract, in tort and for breach of statutory duty.</p>

<p>As long as the website and the information and services on the website are provided free of charge, we will not be liable for any loss or damage of any nature.</p>
"""
  
);