import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import QtQuick.LocalStorage 2.7

import Lomiri.OnlineAccounts 2.0
import Lomiri.OnlineAccounts.Client 0.1

Page {
    id: settingsPage
    property bool startupSync
    signal addAccount
    signal useTest
    signal purgeDatabase
    signal openAccountInfo
    signal openLogs

    anchors.fill: parent

    header: PageHeader {
        id: settingsHeader
        title: i18n.tr('Settings')
        ActionBar {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            actions: [
                Action {
                    iconName: "document-preview"
                    text: i18n.tr("See logs")
                    onTriggered: openLogs()
                }
            ]
        }
        extension: LoadingBar {
            id: loadingBar
            loading: settingsPage.startupSync
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: -units.gu(0.1)
            }
        }
    }

    Flickable {
        anchors {
            top: settingsHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
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
                        onClicked: settingsPage.addAccount()
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

                Button {
                    text: i18n.tr("Use test account")
                    onClicked: settingsPage.useTest()
                    anchors {
                        verticalCenter: parent.verticalCenter
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
