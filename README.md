# CamMonitor — App Android para cámaras JOOAN/cam720.

App Flutter para ver tus 4 cámaras IP simultáneamente vía RTSP.

## Cámaras preconfiguradas
- CAM-01 ENTRADA → rtsp://admin:123456@192.168.68.114:554/live/ch00_0
- CAM-02 SALON   → rtsp://admin:123456@192.168.68.117:554/live/ch00_0
- CAM-03 GARAJE  → rtsp://admin:123456@192.168.68.100:554/live/ch00_0
- CAM-04 JARDIN  → rtsp://admin:123456@192.168.68.112:554/live/ch00_0

⚠️ Cambia "123456" por tu contraseña real antes de compilar,
   o cámbiala directamente en la app desde la pestaña "Configurar".

---

## CÓMO COMPILAR (Windows)

### 1. Instala Flutter
- Ve a: https://docs.flutter.dev/get-started/install/windows
- Descarga el ZIP, extráelo en C:\flutter
- Añade C:\flutter\bin al PATH del sistema

### 2. Instala Android Studio
- Descarga desde: https://developer.android.com/studio
- Durante la instalación, instala también el Android SDK
- Acepta las licencias: flutter doctor --android-licenses

### 3. Verifica que todo está listo
Abre una terminal (cmd) y ejecuta:
  flutter doctor
Debe mostrar ✓ en Flutter y ✓ en Android toolchain

### 4. Copia esta carpeta del proyecto
Coloca la carpeta "cammonitor" en cualquier lugar, por ejemplo:
  C:\proyectos\cammonitor

### 5. Instala dependencias
  cd C:\proyectos\cammonitor
  flutter pub get

### 6. Conecta tu Android por USB
- Activa "Opciones de desarrollador" en tu Android
  (Ajustes → Acerca del teléfono → toca 7 veces "Número de compilación")
- Activa "Depuración USB"
- Conecta el cable USB al PC
- Acepta la autorización en el móvil

### 7. Compila y genera el APK
  flutter build apk --release

El APK estará en:
  build\app\outputs\flutter-apk\app-release.apk

### 8. Instala el APK en tu Android
Copia el APK al móvil y ábrelo, o usa:
  flutter install

---

## Funcionalidades
- Vista en cuadrícula 2×2 de las 4 cámaras
- Vista en lista vertical
- Vista horizontal deslizable
- Pantalla completa al tocar cualquier cámara (gira a landscape)
- Pantalla siempre encendida mientras la app está abierta
- Edición de nombres y URLs desde la app
- Botón de reintentar si una cámara falla
- Indicador LIVE / conectando / sin señal por cámara

---

## Notas importantes
- La app usa flutter_vlc_player que reproduce RTSP nativamente
- Funciona en red local (192.168.68.x) sin configuración adicional
- Para acceso desde internet necesitas port forwarding en el router
- Contraseña por defecto configurada: 123456 (cámbiala si es diferente)
