import 'dart:ffi';

typedef SetWindowLongC = Int32 Function(
    IntPtr hWnd, Int32 nIndex, Int32 dwNewLong);
typedef SetWindowLongDart = int Function(int hWnd, int nIndex, int dwNewLong);

typedef ShowWindowC = Int32 Function(IntPtr hWnd, Int32 nCmdShow);
typedef ShowWindowDart = int Function(int hWnd, int nCmdShow);

typedef GetForegroundWindowC = IntPtr Function();
typedef GetForegroundWindowDart = int Function();

final user32 = DynamicLibrary.open('user32.dll');

final setWindowLong =
    user32.lookupFunction<SetWindowLongC, SetWindowLongDart>('SetWindowLongW');
final showWindow =
    user32.lookupFunction<ShowWindowC, ShowWindowDart>('ShowWindow');
final getForegroundWindow =
    user32.lookupFunction<GetForegroundWindowC, GetForegroundWindowDart>(
        'GetForegroundWindow');

const gwlStyle = -16;
const wsCaption = 0x00C00000;
const wsThickFrame = 0x00040000;
const swMaximize = 3;
const swRestore = 9;

bool isFullScreen = false;

void toggleFullScreen() {
  final hWnd = getForegroundWindow();
  if (isFullScreen) {
    int styles = setWindowLong(hWnd, gwlStyle, 0);
    setWindowLong(hWnd, gwlStyle, styles | (wsCaption | wsThickFrame));
    showWindow(hWnd, swRestore);
    isFullScreen = false;
  } else {
    int styles = setWindowLong(hWnd, gwlStyle, wsCaption | wsThickFrame);
    setWindowLong(hWnd, gwlStyle, styles & ~(wsCaption | wsThickFrame));
    showWindow(hWnd, swMaximize);
    isFullScreen = true;
  }
}

// Definición de la función nativa
typedef PostQuitMessageC = Void Function(Int32 exitCode);
typedef PostQuitMessageDart = void Function(int exitCode);

void closeWindow() {
  // Cargando la biblioteca de usuario de Windows
  final user32 = DynamicLibrary.open('user32.dll');

  // Obteniendo un puntero a la función 'PostQuitMessage'
  final PostQuitMessageDart postQuitMessage = user32
      .lookupFunction<PostQuitMessageC, PostQuitMessageDart>('PostQuitMessage');

  // Llamando a la función con código de salida 0
  postQuitMessage(0);
}
