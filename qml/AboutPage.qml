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
    id: aboutPage

    anchors.fill: parent

    header: PageHeader {
        id: header
        title: i18n.tr('About')
    }

    Flickable {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: mainColumn.height

        Column {
            id: mainColumn
            spacing: units.gu(1.5)
            padding: units.gu(2)
            anchors {
                top: parent.top
                right: parent.right
                left: parent.left
            }
            LomiriShape {
                id: logo
                height: units.gu(12)
                width: height
                source: Image {
                    source: "../assets/logo.svg"
                }
                anchors {
                    topMargin: units.gu(2)
                    horizontalCenter: parent.horizontalCenter
                }
            }
            Label {
                text: i18n.tr("Cookbook")
                wrapMode: Text.WordWrap
                textSize: Label.Large
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
            Label {
                text: "V 1.0.0"
                wrapMode: Text.WordWrap
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Label {
                text: `
              <p>Sync your recipes from your <a href=\"https://nextcloud.com/\">Nextcloud server</a> with <a href=\"https://apps.nextcloud.com/apps/cookbook\">Cookbook app</a> installed to your Ubuntu Touch device.</p>

              <p>Currently a work in progress, expect some bugs and lacking features.</p>

              <p>Currently implemented features:</p>
              <ul>
                <li>Browse recipes by category</li>
                <li>View, edit, create and delete recipe</li>
                <li>Import recipe from URL</li>
              </ul>

              <p>Features not yet implemented:</p>
              <ul>
                <li>View and edit tools and nutrition</li>
                <li>Edit keywords and category</li>
                <li>Browse recipes by keywords</li>
                <li>Search for recipes</li>
                <li>Export recipe to JSON</li>
              </ul>
              `
                wrapMode: Text.WordWrap
                onLinkActivated: Qt.openUrlExternally(link)
                linkColor: LomiriColors.orange
                width: parent.width - units.gu(8)
                anchors {
                    horizontalCenter: parent.horizontalCenter
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
            ListModel {
                id: linkModel
                ListElement {
                    title: "Donate"
                    link: "https://ubports.com/donate"
                }
                ListElement {
                    title: "Source code"
                    link: "https://github.com/joj0r/UT_Cookbook"
                }
                ListElement {
                    title: "Issues"
                    link: "https://github.com/joj0r/UT_Cookbook/issues"
                }
            }
            Repeater {
                model: linkModel
                Rectangle {
                    width: parent.width
                    height: sourceRow.height + units.gu(2)
                    color: theme.palette.normal.background
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally(link)
                    }
                    Row {
                        id: sourceRow
                        spacing: units.gu(1)
                        leftPadding: units.gu(2)
                        width: parent.width - units.gu(2)
                        Column {
                            width: parent.width - units.gu(5)
                            Label {
                                text: title
                                font.bold: true
                            }
                            Label {
                                text: link
                                textSize: Label.Small
                            }
                        }
                        Icon {
                            name: "go-next"
                            height: units.gu(3)
                            width: height
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
                            bottom: parent.bottom
                        }
                    }
                }
            }
        }
    }
}
