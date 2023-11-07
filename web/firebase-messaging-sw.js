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
  const messaging = firebase.messaging();

  // Optional:
  messaging.onBackgroundMessage((m) => {
    console.log("onBackgroundMessage", m);
  });