{ pkgs ? import <nixpkgs> {}, }:

pkgs.mkShell {
  packages = [
    pkgs.clickable
    pkgs.android-tools
    pkgs.xhost
    pkgs.kdePackages.qtdeclarative
  ];

  CLICKABLE_SSH="10.0.0.25";
  QT_LOGGING_RULES="lomiri.deprecations.debug=true";

  shellHook = ''
    # Required for qmlls to find the correct type declarations (but does not work)
    export QMLLS_BUILD_DIRS=${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml/
    export QML_IMPORT_PATH=$PWD/src:${pkgs.lomiri.lomiri-ui-toolkit}/lib/qt-5.15.17/qml/
   '';
}
