import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Column {
    property string title

    anchors {
        left: parent.left
        right: parent.right
    }

    Row {
        id: headerText
        padding: units.gu(1.5)
        anchors {
            left: parent.left
            right: parent.right
        }
        Label {
            text: title
            textSize: Label.Large
            width: parent.width - closeIcon.width - units.gu(3)
        }
        Icon {
            id: closeIcon
            name: "close"
            height: units.gu(3)
            width: height
        }
    }

    SeparationLine {}
}
