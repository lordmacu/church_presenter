import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/routes/app_routes.dart';
import 'package:ipuc/app/views/home_view.dart';
import 'package:ipuc/app/views/loading_view.dart';
import 'package:ipuc/app/views/screen_view.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;

  static final pages = [
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => HomeView(),
    ),
    GetPage(
      name: AppRoutes.PREVIEW,
      page: () => ScreenView(),
    ),
    GetPage(
      name: AppRoutes.LOADING,
      page: () => LoadingView(),
    ),
    // añade más páginas aquí
  ];
}
