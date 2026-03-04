import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Pickers 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Column {
    id: listRoot
    property var model
    property bool dragMode
    signal deleteItem(int index)
    signal addItem(string name)
    signal editItem(int index, string name)
    signal moveItem(int from, int to)

    function refresh() {
        var tmp = model;
        model = null;
        model = tmp;
    }

    anchors {
        right: parent.right
        left: parent.left
    }

    Component {
        id: dragModeComp
        Icon {
            name: "ok"
            height: units.gu(3)
            width: height
            // color: theme.palette.normal.baseText
            anchors {
                verticalCenter: parent.verticalCenter
            }
            MouseArea {
                anchors.fill: parent
                onClicked: listRoot.dragMode = false
            }
        }
    }

    LomiriListView {
        id: listView
        model: listRoot.model
        width: parent.width
        height: contentItem.childrenRect.height
        spacing: units.gu(1)
        flickableDirection: Flickable.AutoFlickIfNeeded
        interactive: false
        ViewItems.onDragUpdated: {
            if (event.status == ListItemDrag.Moving) {
                // inform dragging that move is not performed
                event.accept = false;
            } else if (event.status == ListItemDrag.Dropped) {
                moveItem(event.from, event.to);
                listRoot.refresh();
            }
        }
        ViewItems.dragMode: listRoot.dragMode
        anchors {
            left: parent.left
            right: parent.right
        }
        delegate: ListItem {
            id: delegateItem
            property bool recalcError: modelData.value === undefined
            width: parent.width
            height: ingredientText.height
            color: theme.palette.normal.background
            divider.visible: false
            Row {
                spacing: units.gu(1)
                width: parent.width
                Loader {
                    id: dragModeLoader
                    sourceComponent: listRoot.dragMode ? dragModeComp : undefined
                    width: listRoot.dragMode ? units.gu(3) : 0
                }
                TextArea {
                    id: ingredientText
                    text: modelData
                    width: parent.width - dragModeLoader.width - (listRoot.dragMode ? units.gu(1) : 0)
                    autoSize: true
                    onTextChanged: editItem(index, text)
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        text: i18n.tr("Delete")
                        onTriggered: {
                            listRoot.deleteItem(index);
                            listRoot.refresh();
                        }
                    }
                ]
            }
            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "sort-listitem"
                        onTriggered: {
                            listRoot.dragMode = true;
                        }
                    }
                ]
            }
        }
        footer: Row {
            spacing: units.gu(1)
            topPadding: units.gu(1)
            width: parent.width
            TextArea {
                id: newIngredientText
                width: parent.width - newIngredientButton.width - units.gu(1)
                autoSize: true
            }
            Button {
              id: newIngredientButton
                text: i18n.tr("Add")
                width: units.gu(8)
                onClicked: {
                    listRoot.addItem(newIngredientText.text);
                    newIngredientText.text = "";
                    listRoot.refresh();
                    newIngredientText.forceActiveFocus()
                }
            }
        }
    }
}
