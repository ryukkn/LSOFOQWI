importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");
const firebaseConfig = {
    apiKey: "AIzaSyA0FHvo6DtQ13GNbz_Ik9GBRPTOsWwc0cY",
    authDomain: "comlabmanagement.firebaseapp.com",
    projectId: "comlabmanagement",
    storageBucket: "comlabmanagement.appspot.com",
    messagingSenderId: "184030789221",
    appId: "1:184030789221:web:87d6f3ec1330cad350108c",
    measurementId: "G-QBEDVY4RVZ"
  };
  firebase.initializeApp(firebaseConfig);
//   const messaging = firebase.messaging();

//   // Optional:
//   messaging.onBackgroundMessage((m) => {
//     console.log("onBackgroundMessage", m);
//   });
  
//   messaging.onMessage(function(payload) {
//     const notificationTitle = payload.notification.title;
//     const notificationOptions = {
//         body: payload.notification.body, 
//         icon: payload.notification.icon,        
//     };
//     // console.log(notificationTitle,notificationOptions)

//     if (!("Notification" in window)) {
//         console.log("This browser does not support system notifications.");
//     } else if (Notification.permission === "granted") {
//         // If it's okay let's create a notification
//         var notification = new Notification(notificationTitle,notificationOptions);
//         notification.onclick = function(event) {
//             event.preventDefault();
//             window.open(payload.notification.click_action , '_blank');
//             notification.close();
//         }
//     }
// });