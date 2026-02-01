import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Pickers 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Column {
    id: listRoot
    property var model
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

    LomiriListView {
        id: listView
        model: listRoot.model
        width: parent.width
        height: contentItem.childrenRect.height
        flickableDirection: Flickable.AutoFlickIfNeeded
        ViewItems.onDragUpdated: {
            if (event.status == ListItemDrag.Moving) {
                // inform dragging that move is not performed
                event.accept = false;
            } else if (event.status == ListItemDrag.Dropped) {
                moveItem(event.from, event.to)
                listRoot.refresh()
            }
        }
        ViewItems.dragMode: true
        anchors {
            left: parent.left
            right: parent.right
        }
        delegate: ListItem {
            id: delegateItem
            property bool recalcError: modelData.value === undefined
            width: parent.width
            height: ingredientText.height + units.gu(1)
            color: theme.palette.normal.background
            divider.visible: false
            Row {
                spacing: units.gu(1)
                topPadding: units.gu(1)
                bottomPadding: units.gu(1)
                width: parent.width
                Icon {
                    id: deleteIcon
                    name: "delete"
                    height: units.gu(2)
                    width: height
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            listRoot.deleteItem(index);
                            listRoot.refresh();
                        }
                    }
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                TextArea {
                    id: ingredientText
                    text: modelData
                    width: parent.width - deleteIcon.width - units.gu(1)
                    autoSize: true
                    // Keys.onReleased: editItem(index, text)
                    onTextChanged: editItem(index, text)
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
    Row {
        spacing: units.gu(1)
        topPadding: units.gu(1)
        width: parent.width
        layoutDirection: Qt.RightToLeft
        Button {
            onClicked: {
                listRoot.addItem('');
                listRoot.refresh();
            }
            Row {
                spacing: units.gu(1)
                padding: units.gu(1)
                Icon {
                    height: units.gu(2)
                    width: height
                    color: theme.palette.normal.baseText
                    name: "list-add"
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    text: i18n.tr("Add")
                    width: contentWidth
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
