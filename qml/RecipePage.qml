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
import Lomiri.Components.Pickers 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "database.js" as DB
import "server.js" as Server

Page {
    id: recipePage
    property int id
    property var recipe
    property int yield: recipe.recipeYield
    property string headingSubtitle
    property var ingredients
    property bool recalculated: recipe.recipeYield != yield
    signal editRecipe(var recipe)
    signal refreshRecipe(var recipe)

    // Component.onCompleted: ingredients = updateAllIngredients(recipe.recipeIngredient, yield, yield)

    onRecipeChanged: ingredients = updateAllIngredients(recipe.recipeIngredient, yield, yield)

    function formatDuration(time) {
        const qtime = time.split(/\D+/);
        var duration = "";
        if (qtime[1] > 0)
            duration = duration.concat(qtime[1], " ", i18n.tr("h"), " ");
        if (qtime[2] > 0)
            duration = duration.concat(qtime[2], " ", i18n.tr("min"), " ");
        if (qtime[3] > 0)
            duration = duration.concat(qtime[3], " ", i18n.tr("s"));
        return duration;
    }

    function updateIngredient(ingredient, recipeYield, yield) {
        const ing = ingredient.split(/(^(?:\d+\s+\d+|\d+)(?:[,.\/]+\d+)?)/);

        if (ing.length === 3) {
            var value = (eval(ing[1].replace(/\s/, "+").replace(",", ".")) / recipeYield) * yield;
            // Value extracted
            return {
                value: Math.round(value * 100) / 100,
                ingredient: ing[2].trim(),
                updated: true
            };
        } else {
            // No value extracted
            return {
                value: undefined,
                ingredient: ing[0],
                updated: false
            };
        }
    }

    function updateAllIngredients(ingredients, recipeYield, yield) {
        return ingredients.map(ing => {
            return updateIngredient(ing, recipeYield, yield);
        });
    }

    function handleYieldChange(increase) {
        if (increase)
            yield = yield + 1;
        else
            yield = yield - 1;

        ingredients = updateAllIngredients(recipe.recipeIngredient, recipe.recipeYield, yield);
    }

    header: PageHeader {
        id: pageHeader
        title: recipe.name
        subtitle: headingSubtitle
        ActionBar {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            actions: [
                Action {
                    iconName: "edit"
                    text: i18n.tr("Edit")
                    onTriggered: editRecipe(recipe)
                }
            ]
        }
        extension: LoadingBar {
            id: loadingBar
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
    }

    Flickable {
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: units.gu(6)
        }
        contentHeight: recipeImage.height + mainLayout.height

        Image {
            id: recipeImage
            source: recipe.localImagePlaceholderUrl
            fillMode: Image.PreserveAspectCrop
            height: recipe.localImagePlaceholderUrl ? units.gu(30) : units.gu(0)
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }

        Column {
            id: mainLayout
            spacing: units.gu(1)
            anchors {
                top: recipeImage.bottom
                left: parent.left
                right: parent.right
                topMargin: units.gu(2)
                leftMargin: units.gu(2)
                rightMargin: units.gu(2)
            }
            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 500
                }
            }
            add: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 500
                }
            }

            Label {
                id: nameLabel
                text: recipe.name
                wrapMode: Text.WordWrap
                textSize: Label.XLarge
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Label {
                id: descriptionLabel
                text: recipe.description
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Flow {
                spacing: units.gu(0.5)
                width: parent.width
                Repeater {
                    model: recipe.keywords.split(",")
                    LomiriShape {
                        height: keywordLabel.height + units.gu(1)
                        width: keywordLabel.width + units.gu(1.5)
                        anchors {
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
                            Label {
                                id: keywordLabel
                                text: modelData
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
            Row {
                spacing: units.gu(1)
                Icon {
                    name: "clock"
                    height: units.gu(3)
                    width: height
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    text: i18n.tr("Cooking times")
                    font.bold: true
                    color: theme.palette.disabled.baseText
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
            Loader {
                sourceComponent: timeComponent
                property string label: i18n.tr("Preparation")
                property string time: recipe.prepTime
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Loader {
                sourceComponent: timeComponent
                property string label: i18n.tr("Cooking")
                property string time: recipe.cookTime
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Loader {
                sourceComponent: timeComponent
                property string label: i18n.tr("Total time")
                property string time: recipe.totalTime
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Rectangle {
                width: parent.width
                height: units.gu(4)
                color: theme.palette.normal.background
                Row {
                    spacing: units.gu(1)
                    anchors {
                        left: parent.left
                    }
                    Icon {
                        name: "view-list-symbolic"
                        height: units.gu(3)
                        width: height
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Label {
                        text: i18n.tr("Ingredients")
                        font.bold: true
                        color: theme.palette.disabled.baseText
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Row {
                    spacing: units.gu(1)
                    anchors {
                        right: parent.right
                    }
                    Icon {
                        name: "contact-group"
                        height: units.gu(3)
                        width: height
                        color: theme.palette.disabled.baseText
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Icon {
                        name: "view-collapse"
                        height: units.gu(3)
                        width: height
                        color: theme.palette.normal.baseText
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: handleYieldChange(false)
                        }
                    }
                    TextInput {
                        color: theme.palette.normal.baseText
                        text: recipePage.yield
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Icon {
                        name: "view-expand"
                        height: units.gu(3)
                        width: height
                        color: theme.palette.normal.baseText
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: handleYieldChange(true)
                        }
                    }
                }
            }
            Column {
                anchors {
                    right: parent.right
                    left: parent.left
                }
                Repeater {
                    model: ingredients
                    Rectangle {
                        property bool done: false
                        property string statusColor: done ? theme.palette.disabled.baseText : theme.palette.normal.baseText
                        property bool recalcError: modelData.value === undefined
                        width: parent.width
                        height: ingredientText.contentHeight + units.gu(1)
                        color: theme.palette.normal.background
                        MouseArea {
                            anchors.fill: parent
                            onClicked: done = !done
                        }
                        Component {
                            id: infoIconComponent
                            Icon {
                                name: "info"
                                height: units.gu(2)
                                width: height
                                color: statusColor
                                anchors {
                                    top: parent.top
                                }
                            }
                        }
                        Row {
                            spacing: units.gu(1)
                            topPadding: units.gu(1)
                            bottomPadding: units.gu(1)
                            width: parent.width
                            Icon {
                                id: checkBox
                                name: done ? "select" : "select-none"
                                height: units.gu(2)
                                width: height
                                color: statusColor
                                anchors {
                                    top: parent.top
                                }
                            }
                            Loader {
                                id: infoIconLoader
                                sourceComponent: recalculated & recalcError ? infoIconComponent : undefined
                                anchors {
                                    top: parent.top
                                }
                            }
                            Label {
                                id: ingredientValue
                                text: recalcError ? "" : modelData.value
                                wrapMode: Text.WordWrap
                                color: statusColor
                                font.weight: recalculated ? Font.Normal : Font.Light
                                anchors {
                                    top: parent.top
                                }
                            }
                            Label {
                                id: ingredientText
                                text: modelData.ingredient
                                width: parent.width - ingredientValue.width - infoIconLoader.width - checkBox.width - units.gu(1)
                                wrapMode: Text.WordWrap
                                color: statusColor
                                anchors {
                                    top: parent.top
                                }
                            }
                        }
                    }
                }
                Row {
                    spacing: units.gu(1)
                    visible: recalculated & ingredients.some(ing => ing.value === undefined)
                    width: parent.width
                    Icon {
                        id: infoSectionIcon
                        name: "info"
                        height: units.gu(2)
                        width: height
                        color: theme.palette.disabled.baseText
                        anchors {
                            top: parent.top
                        }
                    }
                    Label {
                        id: infoIngredientsText
                        text: i18n.tr("Marked ingredients could not be recalculated due to incorrect syntax.")
                        wrapMode: Text.WordWrap
                        width: parent.width - infoSectionIcon.width - units.gu(1)
                        color: theme.palette.disabled.baseText
                        font.weight: Font.Normal
                        anchors {
                            top: parent.top
                        }
                    }
                }
            }
            Row {
                spacing: units.gu(2)
                topPadding: units.gu(1)
                Icon {
                    name: "view-list-symbolic"
                    height: units.gu(3)
                    width: height
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    text: i18n.tr("Instructions")
                    font.bold: true
                    color: theme.palette.disabled.baseText
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
            Column {
                anchors {
                    right: parent.right
                    left: parent.left
                }
                Repeater {
                    model: recipe.recipeInstructions
                    Rectangle {
                        property bool done: false
                        property string statusColor: done ? theme.palette.disabled.baseText : theme.palette.normal.baseText
                        width: parent.width
                        height: instructionText.contentHeight + units.gu(1)
                        color: theme.palette.normal.background
                        MouseArea {
                            anchors.fill: parent
                            onClicked: done = !done
                        }
                        Row {
                            spacing: units.gu(1)
                            topPadding: units.gu(1)
                            bottomPadding: units.gu(1)
                            width: parent.width
                            Label {
                                text: (index + 1) + "."
                                width: units.gu(3)
                                color: statusColor
                                anchors {
                                    top: parent.top
                                }
                            }
                            Label {
                                id: instructionText
                                text: modelData
                                wrapMode: Text.WordWrap
                                width: parent.width - units.gu(4)
                                color: statusColor
                                anchors {
                                    top: parent.top
                                }
                            }
                        }
                    }
                }
            }
            Row {
                spacing: units.gu(2)
                topPadding: units.gu(1)
                Icon {
                    name: "info"
                    height: units.gu(3)
                    width: height
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    text: i18n.tr("Metadata")
                    font.bold: true
                    color: theme.palette.disabled.baseText
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
            Row {
                spacing: units.gu(1)
                height: units.gu(2)
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: units.gu(1)
                }
                Label {
                    text: i18n.tr("Date created")
                    width: units.gu(12)
                    color: theme.palette.disabled.baseText
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    text: new Date(recipe.dateCreated).toLocaleString(Locale.ShortFormat)
                    height: units.gu(2)
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
            Row {
                spacing: units.gu(1)
                height: units.gu(2)
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: units.gu(1)
                }
                Label {
                    text: i18n.tr("Date modified")
                    width: units.gu(12)
                    color: theme.palette.disabled.baseText
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    text: new Date(recipe.dateModified).toLocaleString(Locale.ShortFormat)
                    height: units.gu(2)
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Component {
        id: timeComponent
        Row {
            spacing: units.gu(1)
            height: units.gu(3)
            anchors {
                left: parent.left
                right: parent.right
                topMargin: units.gu(1)
            }
            Label {
                text: label
                width: units.gu(14)
                color: theme.palette.disabled.baseText
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
            Label {
                text: formatDuration(time)
                height: units.gu(2)
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
