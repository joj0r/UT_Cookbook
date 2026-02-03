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
    id: logsPage
    property var logs
    property bool startupSync
    signal updateLogs

    anchors.fill: parent

    Component.onCompleted: updateLogs()

    onStartupSyncChanged: {
      if (startupSync === false)
        stopTimer.start()
    }

    Timer {
      id: stopTimer
      interval: 500;
      triggeredOnStart: true
      onTriggered: logsPage.updateLogs()
    }

    Timer {
      interval: 500;
      running: logsPage.startupSync;
      repeat: true;
      onTriggered: logsPage.updateLogs()
    }

    function getStatusColor(status) {
        switch (status) {
        case "OK":
            return "green";
        case "ERROR":
            return "red";
        case "WARNING":
            return "yellow";
        default:
            return "white";
        }
    }

    header: PageHeader {
        id: header
        title: i18n.tr("Logs")
        extension: LoadingBar {
            id: loadingBar
            loading: logsPage.startupSync
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: -units.gu(0.1)
            }
        }
    }

    LomiriListView {
        id: logView
        model: logs

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
            height: logColumn.height
            divider.visible: false
            color: theme.palette.normal.background

            Column {
                id: logColumn
                padding: units.gu(0.5)
                Row {
                    spacing: units.gu(1)
                    Label {
                        color: getStatusColor(modelData.status)
                        wrapMode: Text.WordWrap
                        verticalAlignment: Label.AlignVCenter
                        text: `[ ${modelData.status} ]`
                    }
                    Label {
                        wrapMode: Text.WordWrap
                        verticalAlignment: Label.AlignVCenter
                        color: theme.palette.disabled.baseText
                        text: new Date(modelData.timeStamp).toISOString().split(".")[0]
                    }
                }
                Row {
                    Label {
                        wrapMode: Text.WordWrap
                        width: listItem.width - units.gu(2)
                        verticalAlignment: Label.AlignVCenter
                        text: modelData.message
                    }
                }
            }

        }
    }
}
