importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyANBo0R4-CsuA9FqQpupqP1s61I_6gKCjI",
  appId: "1:340500256654:web:e13140d716b1b1423ff6df",
  messagingSenderId: "340500256654",
  projectId: "sageosf-cf0dc",
  authDomain: "sageosf-cf0dc.firebaseapp.com",
  storageBucket: "sageosf-cf0dc.firebasestorage.app",
  measurementId: "G-6Q2CC1KQ1V"
});

const messaging = firebase.messaging();
