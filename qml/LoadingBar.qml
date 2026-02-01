import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Lomiri.Components.Popups 1.3

Item {
    property bool loading
    height: units.gu(0.5)
    Loader {
        id: progressBarLoader
        sourceComponent: parent.loading ? progressBarComponent : undefined
        anchors {
          right: parent.right
          left: parent.left
        }
    }

    Component {
        id: progressBarComponent
        ProgressBar {
            indeterminate: true
        }
    }
}
