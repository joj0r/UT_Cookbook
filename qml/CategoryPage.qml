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
import Lomiri.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "database.js" as DB
import "server.js" as Server

Page {
    id: categoryPage
    anchors.fill: parent
    property string category
    property var recipes
    property bool loading
    property bool startupSync
    property int selectedIndex

    property Component cookbooksSide
    property Component settingsSide
    property Component aboutSide
    property Component bottomEdgeComp
    property Component logsSide

    signal select(int index)
    signal refresh
    signal openRecipe(int id)
    signal deleteRecipe(var recipe)

    header: PageHeader {
        id: header
        title: category
        subtitle: i18n.tr("Category")
        z: 10
        leadingActionBar.actions: [
            Action {
                iconName: "navigation-menu"
                text: "Category menu"
                onTriggered: {
                    if (leftSideLoader.sourceComponent === cookbooksSide) {
                        leftSideLoader.sourceComponent = undefined;
                    } else {
                        leftSideLoader.sourceComponent = cookbooksSide;
                    }
                }
            }
        ]
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
                    onTriggered: {
                        if (leftSideLoader.sourceComponent === settingsSide) {
                            leftSideLoader.sourceComponent = undefined;
                        } else {
                            leftSideLoader.sourceComponent = settingsSide;
                        }
                    }
                },
                Action {
                    iconName: "info"
                    text: i18n.tr("About")
                    onTriggered: {
                        if (leftSideLoader.sourceComponent === aboutSide) {
                            leftSideLoader.sourceComponent = undefined;
                        } else {
                            leftSideLoader.sourceComponent = aboutSide;
                        }
                    }
                },
                Action {
                    iconName: "document-preview"
                    text: i18n.tr("See logs")
                    onTriggered: {
                        if (leftSideLoader.sourceComponent === logsSide) {
                            leftSideLoader.sourceComponent = undefined;
                        } else {
                            leftSideLoader.sourceComponent = logsSide;
                        }
                    }
                }
            ]
        }
        extension: LoadingBar {
            id: loadingBar
            loading: categoryPage.startupSync
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: -units.gu(0.1)
            }
        }
    }

    Loader {
        id: leftSideLoader
        z: 9
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    LomiriListView {
        id: categoryListView
        model: recipes
        interactive: leftSideLoader.sourceComponent ? false : true

        pullToRefresh {
            enabled: true
            onRefresh: refresh()
            refreshing: loading
        }

        anchors {
            top: header.bottom
            topMargin: units.gu(0.5)
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: units.gu(3)
        }

        delegate: ListItem {
            id: listItem
            width: parent.width
            height: units.gu(12)
            divider.visible: false
            color: theme.palette.normal.background

            Rectangle {
                color: theme.palette.normal.background
                anchors {
                    fill: parent
                }
                LomiriBorder {
                    anchors.fill: parent
                    child: LomiriShape {
                        anchors.fill: parent
                        LomiriShape {
                            anchors.fill: parent
                            color: theme.palette.normal.selection
                            visible: selectedIndex == index
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                openRecipe(modelData.id);
                                select(index);
                            }
                        }

                        LomiriShape {
                            id: recipeImage
                            width: units.gu(10)
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                left: parent.left
                            }
                            source: Image {
                                source: modelData.localImagePlaceholderUrl ? modelData.localImagePlaceholderUrl : "../assets/placeholderImage.svg"
                            }
                        }
                        Label {
                            anchors {
                                left: recipeImage.right
                                right: parent.right
                                top: parent.top
                                topMargin: units.gu(2)
                                leftMargin: units.gu(2)
                                rightMargin: units.gu(2)
                            }
                            textSize: Label.Large
                            width: parent.width
                            wrapMode: Text.WordWrap
                            verticalAlignment: Label.AlignVCenter
                            text: modelData.name
                        }
                    }
                }
            }

            leadingActions: ListItemActions {
                delegate: Rectangle {
                    width: units.gu(10)
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
                            color: theme.palette.normal.background
                            anchors {
                                fill: parent
                                topMargin: units.gu(0.125)
                                bottomMargin: units.gu(0.125)
                                leftMargin: units.gu(0.125)
                                rightMargin: units.gu(0.125)
                            }
                            Icon {
                                name: "delete"
                                width: units.gu(3)
                                height: width
                                color: "red"
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: {
                            deleteRecipe(modelData);
                        }
                    }
                ]
            }
        }
    }

    Loader {
        id: bottomEdgeLoader
        width: parent.width
        anchors {
            bottom: parent.bottom
        }
        sourceComponent: leftSideLoader.sourceComponent ? undefined : categoryPage.bottomEdgeComp
    }
}
