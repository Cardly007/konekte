import 'env.dart';

class ProdEnvironment implements Env {
  @override
  String get baseUrl => "https://api.konekte.com";

  @override
  bool get isDebugMode => false;

  @override
  String get appName => "Konekte";
}
