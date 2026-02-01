import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Dialog {
    id: dialog
    property var okButtonText

    Button {
        text: okButtonText
        onClicked: {
            PopupUtils.close(dialog);
        }
    }
}
