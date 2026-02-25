import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Rectangle {
    id: sepLine
    height: units.gu(0.125)
    color: theme.palette.normal.base
    anchors {
        left: parent.left
        right: parent.right
    }
}
