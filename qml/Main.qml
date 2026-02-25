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

import QtQuick.LocalStorage 2.7

import Lomiri.OnlineAccounts 2.0
import Lomiri.OnlineAccounts.Client 0.1

import "database.js" as DB
import "server.js" as Server
// Enable this if you need a test-account on desktop
// import "secret.js" as Testing

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'cookbook.stene'
    automaticOrientation: true

    // Enable this if you need a test-account on desktop
    property bool showTestAccount: false

    property var categories
    property var logs
    property string selectedCategory: "All recipes"
    property var categoryRecipes

    property var selectedRecipe: -1

    property bool loading: false
    property bool startupSync: false

    Settings {
        id: settings
        property real labelSize: 3
    }

    function setCategory(category) {
        DB.getCategoryRecipesMeta(category).then(recipes => {
            categoryRecipes = recipes;
        });
    }

    function purge() {
        DB.purgeDatabase();
        categories = [];
    }

    function update() {
        const account = serverModel.get(0);
        DB.checkForUpdates(account.serverUrl, account.auth).then(response => {
            DB.getCategories().then(cat => {
                categories = cat;
            });
        }).then(() => {
            setCategory(selectedCategory);
        }).then(() => {
            loading = false;
            startupSync = false;
        }).catch(error => {
            loading = false;
            startupSync = false;
            PopupUtils.open(infoPopover, root, {
                'heading': i18n.tr('Error syncing recipes'),
                'body': error
            });
        });
    }

    function importRecipeUrl(recipeUrl) {
        return new Promise((resolve, reject) => {
            const account = serverModel.get(0);
            const importMessage = "Importing recipe: ";
            Server.importRecipe(account.serverUrl, account.auth, {
                "url": recipeUrl
            }).then(response => {
                // Hackishly setting the modified date in the past
                // to trigger a download of the image on next sync.
                // Doing like this because image is not ready for
                // download right after import to server.
                const now = new Date("2026-01-01T00:00:00");
                response.dateModified = now;
                return response;
            }).then(response => {
                // Update meta to skip update on refresh
                DB.addRecipeMeta(response);
                DB.addRecipe(response);
                setCategory(selectedCategory);

                PopupUtils.open(infoPopover, root, {
                    'heading': i18n.tr('Status'),
                    // TRANSLATORS: %1 is the recipe name
                    'body': i18n.tr("Recipe '%1' successfully imported").arg(response.name)
                });
                DB.addLogEntry("server", "OK", importMessage + `'${response.name}' - OK`);
                resolve(response);
            }).catch(error => {
                PopupUtils.open(infoPopover, root, {
                    'heading': i18n.tr('Error'),
                    'body': error
                });
                DB.addLogEntry("server", "ERROR", importMessage + `'${recipeUrl}' - Failed: ${error}`);
                reject();
            });
        });
    }

    function createRecipe(recipe) {
        return new Promise((resolve, reject) => {
            const account = serverModel.get(0);
            const createMessage = "Creating recipe: ";
            Server.createRecipe(account.serverUrl, account.auth, recipe).then(response => {
                PopupUtils.open(infoPopover, root, {
                    'heading': i18n.tr('Status'),
                    // TRANSLATORS: %1 is the recipe name
                    'body': i18n.tr('Recipe %1 successfully saved').arg(recipe.name)
                });
                const now = new Date();
                const isoNow = now.toISOString();
                const formatNow = isoNow.split(".")[0] + "+00:00";
                recipe.dateModified = formatNow;
                recipe.id = response;
                // Update meta to skip update on refresh
                DB.addRecipeMeta(recipe);
                DB.addRecipe(recipe);
                setCategory(selectedCategory);
                DB.addLogEntry("server", "OK", createMessage + `'${recipe.name}' - OK`);
                resolve();
            }).catch(error => {
                PopupUtils.open(infoPopover, root, {
                    'heading': i18n.tr('Error'),
                    'body': error
                });
                DB.addLogEntry("server", "ERROR", createMessage + `'${recipe.name}' - Failed: ${error}`);
                reject();
            });
        });
    }

    function saveRecipe(recipe) {
        return new Promise((resolve, reject) => {
            const account = serverModel.get(0);
            const saveMessage = "Saving recipe: ";
            Server.updateRecipe(account.serverUrl, account.auth, recipe.id, recipe).then(response => {
                PopupUtils.open(infoPopover, root, {
                    'heading': i18n.tr('Status'),
                    // TRANSLATORS: %1 is the recipe name
                    'body': i18n.tr("Recipe '%1' successfully saved").arg(recipe.name)
                });
                const now = new Date();
                const isoNow = now.toISOString();
                const formatNow = isoNow.split(".")[0] + "+00:00";
                recipe.dateModified = formatNow;
                // Update meta to skip update on refresh
                DB.updateRecipeMeta(recipe);
                DB.updateRecipe(recipe);
                DB.addLogEntry("server", "OK", saveMessage + `'${recipe.name}' - OK`);
                resolve();
            }).catch(error => {
                PopupUtils.open(infoPopover, root, {
                    'heading': i18n.tr('Error'),
                    'body': error
                });
                DB.addLogEntry("server", "ERROR", saveMessage + `'${recipe.name}' - Failed: ${error}`);
                reject();
            });
        });
    }

    function deleteRecipe(id) {
        return new Promise((resolve, reject) => {
            const account = serverModel.get(0);
            const deleteMessage = "Deleting recipe: ";
            const recipe = DB.getRecipe(id).then(recipe => {
                Server.deleteRecipe(account.serverUrl, account.auth, id).then(response => {
                    PopupUtils.open(infoPopover, root, {
                        'heading': i18n.tr('Status'),
                        // TRANSLATORS: %1 is the recipe name
                        'body': i18n.tr("Recipe '%1' successfully deleted").arg(response.name)
                    });
                    DB.removeRecipe(id);
                    DB.removeRecipeMeta(id);
                    setCategory(selectedCategory);
                    pageLayout.removePages(recipePageComponent); // remove recipePage
                    DB.addLogEntry("server", "OK", deleteMessage + `'${recipe.name}' - OK`);
                    resolve();
                // Update categoryPage and cookbooksPage
                }).catch(error => {
                    PopupUtils.open(infoPopover, root, {
                        'heading': i18n.tr('Error'),
                        'body': error
                    });
                    DB.addLogEntry("server", "ERROR", deleteMessage + `'${recipe.name}' - Failed: ${error}`);
                    reject();
                });
            });
        });
    }

    function startSync() {
        startupSync = true;
        DB.initializeDB();
        update();
    }

    onSelectedCategoryChanged: setCategory(selectedCategory)

    Component.onCompleted: {
        if (accountModel.accountList.length > 0)
            startSync();
    }

    property string category: ""

    width: units.gu(45)
    height: units.gu(75)

    ListModel {
        id: serverModel
    }

    AccountModel {
        id: accountModel
        applicationId: "cookbook.stene_cookbook"
        onAccessReply: {
            reply.account.authenticate({});
        }
        onReadyChanged: {
            if (accountModel.accountList.length > 0)
                accountModel.accountList[0].authenticate({});
        }
    }

    Connections {
        id: accountConnection
        target: accountModel.accountList[0]
        onAuthenticationReply: {
            var reply = authenticationData;
            serverModel.clear();
            serverModel.append({
                "auth": Qt.btoa(reply.Username + ':' + reply.Password),
                "serverUrl": accountConnection.target.settings.host
            });
            startSync();
        }
    }

    AdaptivePageLayout {
        id: pageLayout
        anchors.fill: parent
        primaryPage: categoryPage

        layouts: [
            PageColumnsLayout {
                when: width > units.gu(80) && width < units.gu(140)
                PageColumn {
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(60)
                    preferredWidth: units.gu(40)
                }
                PageColumn {
                    fillWidth: true
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(100)
                    preferredWidth: units.gu(40)
                }
            },
            PageColumnsLayout {
                when: width > units.gu(140)
                PageColumn {
                    minimumWidth: units.gu(60)
                    maximumWidth: units.gu(80)
                    preferredWidth: units.gu(40)
                }
                PageColumn {
                    fillWidth: true
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(100)
                    preferredWidth: units.gu(40)
                }
            }
        ]

        Component {
            id: cookbooksSideComp
            CookbooksSide {
                id: cookbooksSide
                categories: root.categories
                selectedCategory: root.selectedCategory
                onOpenCategory: category => {
                    root.selectedCategory = category ? category : i18n.tr("Uncategorized");
                    root.selectedRecipe = -1;
                }
            }
        }

        CategoryPage {
            id: categoryPage
            category: root.selectedCategory
            recipes: root.categoryRecipes
            selectedIndex: root.selectedRecipe
            loading: root.loading
            startupSync: root.startupSync
            cookbooksSide: cookbooksSideComp
            settingsSide: settingsSideComp
            aboutSide: aboutSideComp
            logsSide: logsSideComp
            bottomEdgeComp: bottomEdgeComponent
            onSelect: index => root.selectedRecipe = index
            onRefresh: {
                root.loading = true;
                root.update();
            }
            onOpenRecipe: id => {
                DB.getRecipe(id).then(recipe => {
                    pageLayout.addPageToNextColumn(categoryPage, recipePageComponent, {
                        "id": parseInt(id),
                        "recipe": recipe
                    });
                });
            }
            onDeleteRecipe: recipe => {
                PopupUtils.open(deleteRecipeDialogFromCategoryPage, root, {
                    "object": {
                        "recipe": recipe,
                        "page": root
                    }
                });
            }
        }

        Component {
            id: recipePageComponent
            RecipePage {
                id: recipePage
                labelSize: settings.labelSize
                headingSubtitle: i18n.tr('Viewing Recipe')
                onBack: {
                    pageLayout.removePages(recipePage);
                    root.selectedRecipe = -1;
                }
                onEditRecipe: recipe => {
                    var incubator = pageLayout.addPageToCurrentColumn(recipePage, editRecipePageComponent, {
                        "id": parseInt(id),
                        "recipe": recipe,
                        "prevPage": recipePage
                    });
                    if (incubator && incubator.status == Component.Loading) {
                        incubator.onStatusChanged = function (status) {
                            if (status == Component.Ready) {
                                // connect page's destruction to decrement model
                                incubator.object.Component.destruction.connect(function () {
                                    DB.getRecipe(recipe.id).then(recipe => {
                                        recipePage.recipe = recipe;
                                    }).catch(() => pageLayout.removePages(recipePage));
                                });
                            }
                        };
                    }
                }
            }
        }
        Component {
            id: editRecipePageComponent
            EditRecipePage {
                id: editRecipePage
                loading: false
                headingSubtitle: i18n.tr('Editing Recipe')
                onDeleteRecipe: recipe => {
                    PopupUtils.open(deleteRecipeDialog, root, {
                        "object": {
                            "recipe": recipe,
                            "page": editRecipePage
                        }
                    });
                }
                onCancelEdit: recipe => {
                    PopupUtils.open(cancelEditDialog, root, {
                        "object": editRecipePage
                    });
                }
                onSaveRecipe: (recipe, recipePage) => {
                    loading = true;
                    root.saveRecipe(recipe).then(() => {
                        loading = false;
                        pageLayout.removePages(editRecipePage);
                    }).catch(() => loading = false);
                }
            }
        }
        Component {
            id: createRecipePageComponent
            EditRecipePage {
                id: createRecipePage
                loading: false
                headingSubtitle: i18n.tr('Creating new Recipe')
                onDeleteRecipe: recipe => {
                    PopupUtils.open(cancelEditDialog, root, {
                        "object": createRecipePage
                    });
                }
                onCancelEdit: recipe => {
                    PopupUtils.open(cancelEditDialog, root, {
                        "object": createRecipePage
                    });
                }
                onSaveRecipe: (recipe, recipePage) => {
                    loading = true;
                    root.createRecipe(recipe).then(() => {
                        loading = false;
                        pageLayout.removePages(createRecipePage);
                    }).catch(() => loading = false);
                }
            }
        }
        Component {
            id: cancelEditDialog

            OKCancelDialog {
                okButtonText: i18n.tr("Abort")
                title: i18n.tr("Abort editing")
                text: i18n.tr('Are you sure you want to abort editing, and discard all changes?')
                onDoAction: page => pageLayout.removePages(page)
            }
        }
        Component {
            id: deleteRecipeDialog

            OKCancelDialog {
                okButtonText: i18n.tr("Delete")
                title: i18n.tr("Delete recipe")
                // TRANSLATORS: %1 is the recipe name
                text: i18n.tr('Are you sure you want to delete recipe %1?').arg(object.recipe.name)
                onDoAction: {
                    const prevPage = object.page;
                    const pLayout = pageLayout;
                    prevPage.loading = true;
                    // Set loading bar active during deletion
                    deleteRecipe(object.recipe.id).then(() => {
                        pLayout.removePages(prevPage);
                        prevPage.loading = false;
                    });
                }
            }
        }
        Component {
            id: deleteRecipeDialogFromCategoryPage

            OKCancelDialog {
                signal action
                okButtonText: i18n.tr("Delete")
                title: i18n.tr("Delete recipe")
                // TRANSLATORS: %1 is the recipe name
                text: i18n.tr('Are you sure you want to delete recipe %1?').arg(object.recipe.name)
                onDoAction: {
                    const prevPage = object.page;
                    const pLayout = pageLayout;
                    prevPage.startupSync = true;
                    // Set loading bar active during deletion
                    deleteRecipe(object.recipe.id).then(() => {
                        prevPage.startupSync = false;
                    });
                }
            }
        }
        Component {
            id: accountInfoComp

            OKDialog {
                okButtonText: i18n.tr("Ok")
                title: i18n.tr("Accounts")
                text: i18n.tr('To change account, you have to disable this account from the Lomiri System Settings.\n\nThen you can restart this app, and add a new account here.')
            }
        }
        Component {
            id: purgeDatabaseComp

            OKCancelDialog {
                okButtonText: i18n.tr("Purge")
                title: i18n.tr("Purge recipe database")
                text: i18n.tr('Are you sure you want to purge the local recipe database?\n\nThis will drop all the tables of the local database, but will have no effect on the upstream server.')
                onDoAction: {
                    purge();
                }
            }
        }
        Component {
            id: infoPopover
            Popover {
                property string heading
                property string body
                Column {
                    spacing: units.gu(1)
                    padding: units.gu(1)
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    Label {
                        text: heading
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        text: body
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Component {
            id: aboutSideComp
            AboutSide {}
        }

        Component {
            id: logsSideComp
            LogsSide {
                logs: root.logs
                startupSync: root.startupSync
                onUpdateLogs: DB.getLogs().then(logs => root.logs = logs)
            }
        }

        Component {
            id: settingsSideComp
            SettingsSide {
                id: settingsSide
                settingsUI: settings
                onAddAccount: {
                    accountModel.requestAccess(accountModel.applicationId + "_nextcloud", {});
                }
                onOpenAccountInfo: {
                    PopupUtils.open(accountInfoComp, root);
                }
                showTestAccount: root.showTestAccount
                onUseTest: {
                    serverModel.clear();
                    serverModel.append({
                        "auth": Qt.btoa(Testing.account.username + ":" + Testing.account.password),
                        "serverUrl": Testing.account.serverUrl
                    });
                    startSync();
                }
                onPurgeDatabase: {
                    PopupUtils.open(purgeDatabaseComp, root);
                }
            }
        }
    }
    Component {
        id: addRecipeDialog
        AddRecipe {
            width: parent.width
            onCreateRecipe: () => pageLayout.addPageToNextColumn(bottomEdge.parent.parent, createRecipePageComponent, {
                    "recipe": DB.getEmptyRecipe(),
                    "id": "",
                    "prevPage": bottomEdge.parent.parent
                })
            onImportRecipe: url => {
                root.startupSync = true;
                bottomEdge.collapse();
                importRecipeUrl(url).then(recipe => {
                    root.startupSync = false;
                    pageLayout.addPageToNextColumn(bottomEdge.parent.parent, recipePageComponent, {
                        "recipe": recipe,
                        "id": recipe.id,
                        "prevPage": bottomEdge.parent.parent
                    });
                }).catch(() => root.startupSync = false);
            }
            onClose: {
                bottomEdge.collapse();
            }
        }
    }
    Component {
        id: bottomEdgeComponent
        BottomEdge {
            id: bottomEdge
            height: Qt.inputMethod.keyboardRectangle.height + units.gu(20)
            width: parent.width
            anchors {
                topMargin: units.gu(5)
            }
            hint.text: i18n.tr("Create new recipe")
            contentComponent: addRecipeDialog
        }
    }
}
