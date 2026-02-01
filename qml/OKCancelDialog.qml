import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Dialog {
    id: dialog
    property var okButtonText
    property var object
    signal doAction(var object)

    Button {
        text: okButtonText
        color: theme.palette.normal.negative
        onClicked: {
            doAction(object);
            PopupUtils.close(dialog);
        }
    }

    Button {
        text: i18n.tr("Cancel")
        onClicked: {
          PopupUtils.close(dialog)
        }
    }
}
