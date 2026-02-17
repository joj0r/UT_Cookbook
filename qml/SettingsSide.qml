import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import QtQuick.LocalStorage 2.7

import Lomiri.OnlineAccounts 2.0
import Lomiri.OnlineAccounts.Client 0.1

Rectangle {
    id: settingsSide
    property bool showTestAccount

    property var settingsUI

    signal addAccount
    signal useTest
    signal purgeDatabase
    signal openAccountInfo

    anchors.fill: parent
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: settingsSide.parent.sourceComponent = undefined
    }

    LomiriBorder {
        width: parent.width * 0.8
        height: mainSettingsColumn.height + units.gu(2)
        anchors {
            right: parent.right
            top: parent.top
        }
        Flickable {
            anchors.fill: parent
            contentHeight: mainSettingsColumn.height

            Column {
                id: mainSettingsColumn
                spacing: units.gu(1.5)
                padding: units.gu(2)
                anchors {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                }
                Row {
                    spacing: units.gu(1)
                    Icon {
                        name: "account"
                        height: units.gu(3)
                        width: height
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Label {
                        text: i18n.tr("Account")
                        textSize: Label.Large
                    }
                }
                Loader {
                    id: accountLoader
                    sourceComponent: accountModel.accountList.length > 0 ? currentAccountComp : addAccountComp
                    // sourceComponent: serverModel.count > 0 ? currentAccountComp : addAccountComp
                    width: parent.width
                }
                Component {
                    id: addAccountComp
                    Row {

                        Button {
                            text: i18n.tr("Add Nextcloud account")
                            width: parent.width - units.gu(4)
                            onClicked: settingsSide.addAccount()
                        }
                    }
                }
                Component {
                    id: currentAccountComp
                    Column {
                        spacing: units.gu(1)
                        Row {
                            id: setupRectangle
                            spacing: units.gu(1)

                            LomiriShape {
                                id: accountImage
                                width: units.gu(6)
                                height: width
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                }
                                source: Image {
                                    source: accountModel.accountList[0].service.iconSource
                                }
                            }
                            Label {
                                text: accountModel.accountList[0].displayName
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                            Icon {
                                name: "info"
                                height: units.gu(2)
                                width: height
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: openAccountInfo()
                                }
                            }
                        }
                    }
                }
                Loader {
                    id: testAccountLoader
                    sourceComponent: settingsSide.showTestAccount ? testAccountComp : undefined
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }
                Component {
                    id: testAccountComp
                    Column {
                        padding: 0
                        spacing: units.gu(2)
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        Rectangle {
                            height: units.gu(0.125)
                            color: theme.palette.normal.foreground
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                        }
                        Row {
                            id: testAccount
                            spacing: units.gu(2)
                            leftPadding: units.gu(2)

                            Button {
                                text: i18n.tr("Use test account")
                                onClicked: settingsSide.useTest()
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    height: units.gu(0.125)
                    color: theme.palette.normal.foreground
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }
                Row {
                    spacing: units.gu(1)
                    Icon {
                        name: "view-fullscreen"
                        height: units.gu(3)
                        width: height
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Label {
                        text: i18n.tr("Recipe page UI")
                        textSize: Label.Large
                    }
                }
                Row {
                    width: parent.width
                    Label {
                        text: i18n.tr("Large text size")
                        width: parent.width - textSwitch.width - units.gu(4)
                    }
                    Switch {
                        id: textSwitch
                        checked: settingsUI.labelSize === 4
                        onClicked: {
                            if (settingsUI.labelSize === 3)
                                settingsUI.labelSize = 4;
                            else
                                settingsUI.labelSize = 3;
                        }
                    }
                }
                Rectangle {
                    height: units.gu(0.125)
                    color: theme.palette.normal.foreground
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }
                Row {
                    spacing: units.gu(1)
                    Icon {
                        name: "mail-mark-important"
                        height: units.gu(3)
                        width: height
                        color: theme.palette.normal.negative
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Label {
                        text: i18n.tr("Danger zone")
                        textSize: Label.Large
                    }
                }
                Button {
                    text: i18n.tr("Purge recipe database")
                    color: theme.palette.normal.negative
                    onClicked: purgeDatabase()
                }
            }
        }
    }
}
