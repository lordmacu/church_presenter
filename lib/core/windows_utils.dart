import 'dart:ffi';
import 'package:ffi/ffi.dart';

typedef SetWindowLongC = Int32 Function(
    IntPtr hWnd, Int32 nIndex, Int32 dwNewLong);
typedef SetWindowLongDart = int Function(int hWnd, int nIndex, int dwNewLong);

typedef ShowWindowC = Int32 Function(IntPtr hWnd, Int32 nCmdShow);
typedef ShowWindowDart = int Function(int hWnd, int nCmdShow);

typedef GetForegroundWindowC = IntPtr Function();
typedef GetForegroundWindowDart = int Function();

final user32 = DynamicLibrary.open('user32.dll');

final SetWindowLong =
    user32.lookupFunction<SetWindowLongC, SetWindowLongDart>('SetWindowLongW');
final ShowWindow =
    user32.lookupFunction<ShowWindowC, ShowWindowDart>('ShowWindow');
final GetForegroundWindow =
    user32.lookupFunction<GetForegroundWindowC, GetForegroundWindowDart>(
        'GetForegroundWindow');

const GWL_STYLE = -16;
const WS_CAPTION = 0x00C00000;
const WS_THICKFRAME = 0x00040000;
const SW_MAXIMIZE = 3;
const SW_RESTORE = 9;

bool isFullScreen = false;

void toggleFullScreen() {
  final hWnd = GetForegroundWindow();
  if (isFullScreen) {
    int styles = SetWindowLong(hWnd, GWL_STYLE, 0);
    SetWindowLong(hWnd, GWL_STYLE, styles | (WS_CAPTION | WS_THICKFRAME));
    ShowWindow(hWnd, SW_RESTORE);
    isFullScreen = false;
  } else {
    int styles = SetWindowLong(hWnd, GWL_STYLE, WS_CAPTION | WS_THICKFRAME);
    SetWindowLong(hWnd, GWL_STYLE, styles & ~(WS_CAPTION | WS_THICKFRAME));
    ShowWindow(hWnd, SW_MAXIMIZE);
    isFullScreen = true;
  }
}
