import 'package:get/get.dart';
import 'package:ipuc/app/routes/app_routes.dart';
import 'package:ipuc/app/views/home_view.dart';
import 'package:ipuc/app/views/loading_view.dart';
import 'package:ipuc/app/views/screen_view.dart';

class AppPages {
  static const initial = AppRoutes.initial;

  static final pages = [
    GetPage(
      name: AppRoutes.initial,
      page: () => HomeView(),
    ),
    GetPage(
      name: AppRoutes.preview,
      page: () => ScreenView(),
    ),
    GetPage(
      name: AppRoutes.loading,
      page: () => const LoadingView(),
    ),
    // añade más páginas aquí
  ];
}
