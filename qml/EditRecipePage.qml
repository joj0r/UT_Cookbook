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
import Lomiri.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "database.js" as DB
import "server.js" as Server

Page {
    id: editRecipePage
    property int id
    property var recipe
    property var prevPage
    property string headingSubtitle
    property bool loading: false
    property int yield: recipe.recipeYield
    property bool recalculated: recipe.recipeYield != yield
    signal deleteRecipe(var recipe)
    signal cancelEdit(var recipe)
    signal saveRecipe(var recipe, var recipePage)

    function removeListItem(list, index) {
        if (index > -1)
            list.splice(index, 1);
    }

    function getTimeFromDuration(time, index) {
        // index is: 1 - h, 2 - m, 3 - s
        const t = time.split(/\D+/);
        return t[index];
    }

    function getDurationFromTime(val) {
        // values is a list of value
        return `PT${val[0]}H${val[1]}M${val[2]}S`;
    }

    function formatDuration(time) {
        const t = time.split(/\D+/);

        const formatString = [];
        if (t[1] > 0)
            formatString.push(`${t[1]} h`);
        if (t[2] > 0)
            formatString.push(`${t[2]} min`);
        if (t[3] > 0)
            formatString.push(`${t[3]} s`);

        return formatString.join(" ");
    }

    function getList(character, length) {
        var output = [];
        for (let i = 0; i < length; i++) {
            output.push(i + " " + character);
        }
        return output;
    }

    function handleYieldChange(increase) {
        if (increase)
            yield = yield + 1;
        else
            yield = yield - 1;
        recipe.recipeYield = yield;
    }

    header: PageHeader {
        id: pageHeader
        title: recipe.name ? recipe.name : headingSubtitle
        subtitle: recipe.name ? headingSubtitle : ""
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Cancel edit")
                onTriggered: cancelEdit(recipe)
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
                    iconName: "ok"
                    text: i18n.tr("Save")
                    onTriggered: {
                        saveRecipe(recipe, prevPage);
                    }
                },
                Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    onTriggered: deleteRecipe(recipe)
                }
            ]
        }
        extension: LoadingBar {
            id: loadingBar
            loading: editRecipePage.loading
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: -units.gu(0.1)
            }
        }
    }

    Component {
        id: overlay
        Rectangle {
            anchors.fill: parent
            opacity: 0.5
            color: theme.palette.normal.overlay
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons //to block right click and middle click
                hoverEnabled: true //to block hover events
                propagateComposedEvents: false
                onWheel: wheel.accepted = true //to block wheel events
            }
        }
    }

    Loader {
        z: 10
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        sourceComponent: loading ? overlay : undefined
        onItemChanged: {
            if (loading)
                item.forceActiveFocus();
        }
    }

    Flickable {
        height: parent.height - pageHeader.height - Qt.inputMethod.keyboardRectangle.height
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            topMargin: units.gu(2)
            bottomMargin: units.gu(2)
        }
        contentHeight: mainLayout.height + pageHeader.height

        Column {
            id: mainLayout
            spacing: units.gu(1)
            anchors {
                left: parent.left
                right: parent.right
                topMargin: units.gu(2)
                leftMargin: units.gu(2)
                rightMargin: units.gu(2)
            }

            Label {
                text: i18n.tr("Recipe name")
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            TextField {
                id: nameField
                text: recipe.name
                onTextChanged: () => recipe.name = nameField.text
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Label {
                text: i18n.tr("Description")
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            TextArea {
                id: descriptionField
                text: recipe.description
                onTextChanged: () => recipe.description = descriptionField.text
                anchors {
                    left: parent.left
                    right: parent.right
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
                property string name: "prepTime"
                property string time: recipe.prepTime
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Loader {
                sourceComponent: timeComponent
                property string label: i18n.tr("Cooking")
                property string name: "cookTime"
                property string time: recipe.cookTime
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Loader {
                sourceComponent: timeComponent
                property string label: i18n.tr("Total time")
                property string name: "totalTime"
                property string time: recipe.totalTime
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Rectangle {
                width: parent.width
                height: units.gu(3)
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
                        text: editRecipePage.yield
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
            EditableList {
                id: ingredientListView
                model: recipe.recipeIngredient
                onDeleteItem: index => {
                    removeListItem(recipe.recipeIngredient, index);
                }
                onAddItem: name => {
                    recipe.recipeIngredient.push(name);
                }
                onEditItem: (index, name) => {
                    recipe.recipeIngredient[index] = name;
                }
                onMoveItem: (from, to) => {
                    const item = recipe.recipeIngredient[from];
                    recipe.recipeIngredient.splice(from, 1);
                    recipe.recipeIngredient.splice(to, 0, item);
                }
            }
            Column {
                anchors {
                    right: parent.right
                    left: parent.left
                }
                Row {
                    spacing: units.gu(1)
                    // visible: recalculated & ingredients.some(ing => ing.value === undefined)
                    visible: false
                    topPadding: units.gu(1)
                    width: parent.width
                    Icon {
                        id: infoSectionIcon
                        name: "info"
                        height: units.gu(2)
                        width: height
                        color: theme.palette.disabled.baseText
                        anchors {
                            verticalCenter: parent.verticalCenter
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
                            verticalCenter: parent.verticalCenter
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
            EditableList {
                id: instructionListView
                model: recipe.recipeInstructions
                onDeleteItem: index => {
                    removeListItem(recipe.recipeInstructions, index);
                }
                onAddItem: name => {
                    recipe.recipeInstructions.push(name);
                }
                onEditItem: (index, name) => {
                    recipe.recipeInstructions[index] = name;
                }
                onMoveItem: (from, to) => {
                    const item = recipe.recipeInstructions[from];
                    recipe.recipeInstructions.splice(from, 1);
                    recipe.recipeInstructions.splice(to, 0, item);
                }
            }
        }
    }

    Component {
        id: timeComponent
        Row {
            spacing: units.gu(1)
            anchors {
                left: parent.left
                right: parent.right
                topMargin: units.gu(1)
            }
            Label {
                id: timeLabel
                text: label
                width: units.gu(14)
                color: theme.palette.disabled.baseText
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
            LomiriShape {
                color: theme.palette.disabled.baseText
                height: units.gu(3.75)
                width: units.gu(18)
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: PopupUtils.open(datePickerPopover, cookTimeLabel)
                }
                LomiriShape {
                    color: theme.palette.normal.background
                    height: parent.height - units.gu(0.25)
                    width: parent.width - units.gu(0.25)
                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }
                    Label {
                        id: cookTimeLabel
                        text: formatDuration(time)
                        height: units.gu(2)
                        anchors {
                            verticalCenter: parent.verticalCenter
                            horizontalCenter: parent.horizontalCenter
                        }
                        Component {
                            id: datePickerPopover
                            Popover {
                                Row {
                                    spacing: units.gu(1)
                                    padding: units.gu(2)
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    Picker {
                                        id: hourPicker
                                        model: getList(i18n.tr("h"), 24)
                                        circular: false
                                        selectedIndex: getTimeFromDuration(time, 1) || 0
                                        onSelectedIndexChanged: {
                                            recipe[name] = getDurationFromTime([hourPicker.selectedIndex, minutePicker.selectedIndex, secondPicker.selectedIndex]);
                                            time = getDurationFromTime([hourPicker.selectedIndex, minutePicker.selectedIndex, secondPicker.selectedIndex]);
                                        }
                                        delegate: PickerDelegate {
                                            Label {
                                                text: modelData
                                                anchors {
                                                    verticalCenter: parent.verticalCenter
                                                    horizontalCenter: parent.horizontalCenter
                                                }
                                            }
                                        }
                                    }
                                    Picker {
                                        id: minutePicker
                                        model: getList(i18n.tr("min"), 59)
                                        circular: false
                                        selectedIndex: getTimeFromDuration(time, 2) || 0
                                        onSelectedIndexChanged: {
                                            recipe[name] = getDurationFromTime([hourPicker.selectedIndex, minutePicker.selectedIndex, secondPicker.selectedIndex]);
                                            time = getDurationFromTime([hourPicker.selectedIndex, minutePicker.selectedIndex, secondPicker.selectedIndex]);
                                        }
                                        delegate: PickerDelegate {
                                            Label {
                                                text: modelData
                                                anchors {
                                                    verticalCenter: parent.verticalCenter
                                                    horizontalCenter: parent.horizontalCenter
                                                }
                                            }
                                        }
                                    }
                                    Picker {
                                        id: secondPicker
                                        model: getList(i18n.tr("s"), 59)
                                        circular: false
                                        selectedIndex: getTimeFromDuration(time, 3) || 0
                                        onSelectedIndexChanged: {
                                            recipe[name] = getDurationFromTime([hourPicker.selectedIndex, minutePicker.selectedIndex, secondPicker.selectedIndex]);
                                            time = getDurationFromTime([hourPicker.selectedIndex, minutePicker.selectedIndex, secondPicker.selectedIndex]);
                                        }
                                        delegate: PickerDelegate {
                                            Label {
                                                text: modelData
                                                anchors {
                                                    verticalCenter: parent.verticalCenter
                                                    horizontalCenter: parent.horizontalCenter
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
