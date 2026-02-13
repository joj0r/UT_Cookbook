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

LomiriShape {
    id: cookbooksPage
    anchors.fill: parent
    property var categories
    property int selectedIndex: -1
    property bool hasAccount: accountModel.accountList.length > 0 || serverModel.count > 0
    signal refresh
    signal openCategory(string category)

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

        LomiriListView {
            id: categoriesModelView
            model: categories

            anchors {
                fill: parent
                topMargin: units.gu(0.5)
                bottomMargin: units.gu(3)
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
}
