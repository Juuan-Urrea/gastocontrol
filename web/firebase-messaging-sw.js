// Service worker de Firebase Cloud Messaging (notificaciones push en WEB).
// Debe llamarse EXACTAMENTE firebase-messaging-sw.js y estar en la carpeta web/ (raiz del sitio).
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBzExHpw576PqI_PuDpFKERl9kG9KY5rmA",
  authDomain: "gastocontrol-eaac4.firebaseapp.com",
  projectId: "gastocontrol-eaac4",
  storageBucket: "gastocontrol-eaac4.firebasestorage.app",
  messagingSenderId: "942983192460",
  appId: "1:942983192460:web:4e101bbe1aa1a2d2d780a9",
});

const messaging = firebase.messaging();

// Push recibido con la pestana cerrada o en segundo plano.
messaging.onBackgroundMessage((payload) => {
  const n = payload.notification || {};
  self.registration.showNotification(n.title || 'GastoControl', { body: n.body || '' });
});
