import 'env.dart';

class DevEnvironment implements Env {
  @override
  String get baseUrl => "https://api.dev.konekte.com";

  @override
  bool get isDebugMode => true;

  @override
  String get appName => "Konekte (Recette)";
}
