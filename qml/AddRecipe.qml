import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Rectangle {
    id: dialog
    signal createRecipe
    signal importRecipe(string url)
    signal close()
    color: theme.palette.normal.background
    height: units.gu(20)
    anchors {
      bottom: parent.bottom
    }

    LomiriShape {
        height: units.gu(2)
        width: units.gu(3.5)
        color: theme.palette.normal.foreground
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: close()
        }
        Icon {
            name: "dropdown-menu"
            color: theme.palette.normal.baseText
            anchors {
                fill: parent
                rightMargin: units.gu(0.75)
                leftMargin: units.gu(0.75)
            }
        }
    }

    LomiriShape {
        anchors {
            fill: parent
            topMargin: units.gu(2.5)
            bottomMargin: units.gu(3.5)
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }
        color: theme.palette.normal.foreground
        LomiriShape {
            anchors {
                fill: parent
                topMargin: units.gu(0.125)
                bottomMargin: units.gu(0.125)
                leftMargin: units.gu(0.125)
                rightMargin: units.gu(0.125)
            }
            color: theme.palette.normal.background
            Column {
                spacing: units.gu(2)
                anchors.fill: parent
                padding: units.gu(2)

                Button {
                    width: parent.width - units.gu(4)
                    anchors {}
                    onClicked: {
                        createRecipe();
                        close();
                    }
                    Row {
                        spacing: units.gu(1)
                        padding: units.gu(1)
                        anchors {
                            verticalCenter: parent.verticalCenter
                            horizontalCenter: parent.horizontalCenter
                        }
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
                            text: i18n.tr("Create recipe")
                            width: contentWidth
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
                Row {
                    spacing: units.gu(1)
                    width: parent.width - units.gu(4)
                    TextField {
                        id: nameInput
                        width: parent.width - importRectangle.width - units.gu(2)
                        height: units.gu(4)
                        placeholderText: i18n.tr('Download recipe from URL')

                        Keys.onReturnPressed: {
                            addTask(nameInput.text);
                            nameInput.text = "";
                        }
                        Keys.onEscapePressed: {
                            nameInput.text = "";
                        }
                    }
                    Rectangle {
                        id: importRectangle
                        height: units.gu(3)
                        width: height
                        color: theme.palette.normal.background
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        Icon {
                            name: "import"
                            anchors {
                                fill: parent
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                importRecipe(nameInput.text);
                                nameInput.text = "";
                            }
                        }
                    }
                }
            }
        }
    }
}
