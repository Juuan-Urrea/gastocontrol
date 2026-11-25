# GastoControl

Aplicación web de finanzas personales en pesos colombianos. Permite registrar gastos, comparar el consumo del mes con un presupuesto y llevar el saldo de una cuenta personal.

## Uso

1. Regístrate con correo y contraseña. Configura el ingreso mensual de referencia y el límite de gasto.
2. Desde **Inicio → Ver presupuesto y depositar dinero**, registra las entradas de dinero. El saldo corresponde a los depósitos acumulados menos los gastos de todo el historial. El ingreso mensual del perfil es una referencia que puedes editar. Para reflejar un ingreso recibido, regístralo como depósito.
3. Registra gastos con su fecha, categoría y medio de pago. Puedes editarlos o eliminarlos desde el detalle.
4. Abre **Estadísticas** para consultar el total y la distribución por categoría del mes actual según el calendario local. En **Presupuesto** verás el límite mensual y el disponible o exceso. En Perfil puedes cambiar el límite.
5. Concede permiso de notificaciones al iniciar sesión para recibir mensajes push en un navegador compatible.

## Arquitectura y tecnologías

Flutter y Dart forman la interfaz. GetX inyecta los servicios mediante `lib/bindings/app_binding.dart`. El controlador en `lib/controllers/` escucha los cambios de Firebase, calcula los totales y coordina la navegación. Las pantallas en `lib/screens/` muestran el estado con widgets reactivos. Los modelos de datos están en `lib/models/` y los servicios en `lib/services/`.

Firebase Authentication gestiona las sesiones. Cloud Firestore almacena el perfil en `usuarios/{uid}`, los gastos en la subcolección `gastos` y las notificaciones en `notificaciones`. Cada depósito incrementa de manera atómica el campo `deposited` del perfil. Los perfiles anteriores parten de cero depósitos. SharedPreferences recuerda el último correo y la preferencia de alertas. Firebase Cloud Messaging recibe notificaciones remotas.

## Ejecutar en web

Descomprime el ZIP y abre una terminal en la carpeta que contiene `pubspec.yaml`. Utiliza Flutter 3.29.3 con el soporte web habilitado y Chrome instalado. En Windows también puedes elegir Edge cambiando el dispositivo a `edge`.

```sh
flutter pub get
flutter run -d chrome
```

Para compilar la entrega, ejecuta `flutter build web --release`. Sirve el contenido de `build/web/` por HTTPS. Para FlutLab, importa el ZIP como proyecto Flutter, selecciona una versión compatible del SDK y ejecuta el destino Web.

## Configuración de Firebase

La configuración web incluida apunta a `gastocontrol-eaac4`. Para usar otro proyecto, registra una aplicación web en su consola Firebase y actualiza las opciones en `lib/firebase/firebase_options.dart` y en `web/firebase-messaging-sw.js` con los valores del mismo proyecto.

- Habilita el proveedor de correo y contraseña en Authentication y autoriza el dominio de la aplicación.
- Crea la base de datos de Cloud Firestore y publica las reglas de `firebase/firestore.rules`. Restringen cada perfil y sus subcolecciones al usuario autenticado correspondiente.
- En Cloud Messaging configura las credenciales push web y copia la clave pública VAPID en `firebase_options.dart`. Abre la app mediante HTTPS o localhost y concede el permiso de notificaciones. Para una prueba remota, utiliza la opción de mensaje de prueba de Firebase con el token del navegador.

## Comprobación funcional

Con una cuenta de prueba, configura un límite de $100.000, deposita $50.000 y registra un gasto de $10.000 del mes pasado y otro de $15.000 del mes actual. El saldo de cuenta debe mostrar $25.000, el disponible del presupuesto $85.000 y Estadísticas $15.000. Recarga la página y verifica que las cifras persistan. Si eliminas el gasto del mes pasado, el saldo sube a $35.000 y el disponible mensual continúa en $85.000.

