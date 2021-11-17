import 'package:new_version/new_version.dart';

class AppStrings {
  static String updateTitle = 'Actualització Disponible';

  static String updateButtonText = 'Actualitzar';

  static String dismissButtonText = 'Potser després';

  static String closeAppText = '¿Esteu segur que voleu tancar la aplicacio?';

  static String copy = 'Còpia';

  static String copied = 'Copiat';

  static String noResults = 'Sense resultats';

  static String results = 'Resultat de la cerca';

  static String noMoreResults =
      'No s\'han trobat més ocurrències. Voleu continuar cercant des del principi?';

  static String validPageNumber = 'Introduïu un número de pàgina vàlid.';

  static String noNetwork = 'Sense xarxa';

  static String checkNetwork =
      'Comproveu la vostra connexió a Internet i torneu-ho a provar.';

  static String somethingWrong =
      'Alguna cosa surt malament, si us plau intenta de nou';

  static String welcomeText = 'Benvinguts a CSIntranet';

  static String updateText(VersionStatus status) {
    return 'Ara podeu actualitzar aquesta aplicació de la ${status.localVersion} a la ${status.storeVersion}';
  }
}
