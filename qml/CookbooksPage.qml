/*
 * Copyright (C) 2025  Jonas Stene
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * Cookbook is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Lomiri.Components.Popups 1.3

import "database.js" as DB
import "server.js" as Server

Page {
    id: cookbooksPage
    anchors.fill: parent
    property var categories
    property bool loading
    property bool startupSync
    property int selectedIndex: -1
    property Component bottomEdgeComp
    property bool hasAccount: accountModel.accountList.length > 0 || serverModel.count > 0
    signal refresh
    signal openCategory(string category)
    signal openSettings
    signal openAbout

    header: PageHeader {
        id: header
        title: i18n.tr('Cookbooks')

        ActionBar {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            actions: [
                Action {
                    iconName: "settings"
                    text: i18n.tr("Settings")
                    onTriggered: openSettings()
                },
                Action {
                    iconName: "info"
                    text: i18n.tr("About")
                    onTriggered: openAbout()
                }
            ]
        }
        extension: LoadingBar {
            id: loadingBar
            loading: cookbooksPage.startupSync
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: -units.gu(0.1)
            }
        }
    }
    Loader {
        id: noRecipeLoader
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        sourceComponent: {
            if (!cookbooksPage.hasAccount)
                return noRecipeComp;
            return modelView;
        }
    }

    Component {
        id: noRecipeComp
        Column {
            padding: units.gu(2)
            topPadding: units.gu(8)
            spacing: units.gu(2)
            width: parent.width
            Label {
                text: i18n.tr("No recipes here..")
                color: theme.palette.disabled.baseText
                textSize: Label.Large
                width: parent.width - units.gu(4)
                horizontalAlignment: Label.AlignHCenter
            }
            Label {
                text: i18n.tr("Head over to settings and add a Nextcloud account")
                color: theme.palette.disabled.baseText
                width: parent.width - units.gu(4)
                wrapMode: Text.WordWrap
                horizontalAlignment: Label.AlignHCenter
            }
        }
    }

    Component {
        id: modelView
        LomiriListView {
            id: categoriesModelView
            model: categories

            anchors {
                fill: parent
                bottomMargin: units.gu(3)
            }

            onMovementEnded: console.log(categoriesModelView.verticalOvershoot)

            pullToRefresh {
                enabled: true
                onRefresh: refresh()
                refreshing: loading
            }

            delegate: ListItem {
                id: listItem
                width: categoriesModelView.width
                height: units.gu(8)
                divider.visible: false

                Rectangle {
                    anchors.fill: parent
                    color: theme.palette.normal.background
                    LomiriShape {
                        anchors {
                            fill: parent
                            topMargin: units.gu(0.5)
                            bottomMargin: units.gu(0.5)
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
                            LomiriShape {
                                anchors.fill: parent
                                color: theme.palette.normal.selection
                                visible: selectedIndex == index
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    openCategory(modelData.recipeCategory);
                                    selectedIndex = index;
                                }
                            }
                            Icon {
                                id: categoryIcon
                                name: "stock_ebook"
                                height: units.gu(3)
                                width: height
                                anchors {
                                    left: parent.left
                                    leftMargin: units.gu(2)
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                            Label {
                                text: modelData.recipeCategory ? modelData.recipeCategory : i18n.tr("Uncategorized")
                                textSize: Label.Large
                                anchors {
                                    left: categoryIcon.right
                                    leftMargin: units.gu(1.5)
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                            Label {
                                id: itemCount
                                text: modelData.count
                                textSize: Label.Large
                                anchors {
                                    right: parent.right
                                    leftMargin: units.gu(1)
                                    rightMargin: units.gu(2)
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: bottomEdgeLoader
        width: parent.width
        anchors {
            bottom: parent.bottom
        }
        sourceComponent: {
            if (!cookbooksPage.hasAccount)
                return undefined;
            return cookbooksPage.bottomEdgeComp;
        }
    }
}
