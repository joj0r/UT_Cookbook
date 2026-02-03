# Nextcloud Cookbook app for the Ubuntu Touch

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/cookbook.stene)

Sync your recipes from your [Nextlcoud server]("https://nextcloud.com/") with [Cookbook app]("https://apps.nextcloud.com/apps/cookbook") installed to your Ubuntu Touch device.

Currently a work in progress, expect some bugs and lacking features.

Known bugs:
- Image does not get downloaded during import from URL. Gets downloaded at next sync.
- Category page dissappears on desktop if changing from three column layout to one column layout and then back to three column layout

Currently implemented features:
- Browse recipes by category
- View, edit, create and delete recipe
- Import recipe from URL

Features not yet implemented:
- View and edit tools and nutrition
- Edit keywords and category
- Browse recipes by keywords
- Search for recipes
- Export recipe to JSON

## Developing

Install [clickable](https://clickable-ut.dev/en/latest/).
If you are using NixOs, you can use the included `shell.nix` as a starting point, but you will also need docker anabled.

```bash
# Build and run the app to run on your desktop:
clickable desktop

#To get dark mode:
clickable desktop --dark-mode

# To build and install the app to your Ubuntu Touch device:
clickable #Assuming device connected through cable or ssh configured
```

When testing on your desktop (if you do not have the Lomiri Account Manager) you can add your own `qml/secrets.js` file from the template: [qml/testAccount.js](qml/testAccount.js) with url and credentials.
Then you must set the `showTestAccount` to true:
```qml
    property bool showTestAccount: true
```
And click the `Use test account` button that will appear under settings to activate.

I have experienced the device freezing and rebooting after running `clickable`, this seems to happen if an account is added to the app. To avoid this you can go to `System Settings` -> `Accounts` -> `[yourAccount]` and remove the access to this account for this app before running `clickable`.

## Contributing
Contributions are welcome, first and foremost in the following:
**AI contributions are NOT welcome**

### Translating

Translations are welcome, and must be done manually in the `.po` text files. A description of how this is done can be found on the [UBPorts docs](https://docs.ubports.com/en/latest/contribute/translations.html#po-ts-file-editor)

### Logo and placeholder image

Currently this projects uses the standard Nextcloud Cookbook app icon, but ideally it should have a redesigned icon to be more in sync with Ubuntu Touch.
Requirements:
- Must follow the design philosophy and tips for [Ubuntu Touch App icon design](https://docs.ubports.com/en/latest/humanguide/design-concepts/app-icon-design.html)
- Must clearly show what this app is about
- Preferably use the Nextcloud blue color, but this is not required
- Must have the size of 256x256 pixels

In addition I would lika an accompanying placeholder image/icon for recipes that have no image. This image does not need to be the same/look like the logo, but should rather illustrate a recipe/meal. It also should:
- Be not to flashy
- Preferably grayish with no colors
- Be square (the image will be places in a Lomiri shape, so the corners will be cropped)

### Testing and feedback

If you try out this app, and experience any bugs, errors or other, please add an issue here.
The same goes if you have any feature requests for features not mentioned in the "Features not yet implemented"

## License

Copyright (C) 2025  Jonas Stene

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3, as published by the
Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY
QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.
