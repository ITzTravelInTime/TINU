//
//  ToDo.swift
//  TINU
//
//  Created by Pietro Caruso on 17/12/2019.
//  Copyright © 2019 Pietro Caruso. All rights reserved.
//

/*TODO:

-EFIPM SF Symbols icons for volumes

-continue with ui revision

-debug and test all of the features

-remove partitions unmount hardcode (detect the partitions to unmount)

-menu items text from json

-credits view controller text from json (probably requires a custom json)

-contacts view controller text from json (probably requires a cutom json)

-thank you messange in the final screen (if successful)

-credits button in the final screen (if successful)

-"Star this project on github" button in the final screen (if successful)

-Maybe opening a terminal window and using it for the "createinstallmedia" process is the better way to avoid the SIP on issues, investigate

-Test if the SIP on issues are a thing on big sur and monterey

-Make UI Sketches for the multiple installer creation process

-Links should not be hardcoded

-EFIFolderReplacementManager should be part of CreationVariablesManager

*/

/*TODO but with less priority:
-EFI PM memory leak
-copyright string localization
-right to left languages ui support
-installation unsupported apps (lion and mountain lion) mark instead of hiding
-divide language files in folders one for each language rather than re-naming them according to the language to use

-reimplement efi partition mounter's back end using codable classes (Work in progress)

-download installer app window resizable
-installer app download background dark in dark mode

-write translation guidelines and how to translate to a new language

-fix crash recovery mode sudo manager
-fix volumes detection in recovery

-it's better to no longer mention directly hackintosh and hackintoshing in the tool, since it can be couse of possible problems maybe?

-show license just once as a dialog-ish window on the first usage of the app, maybe it's better just to have a disclamener rather than the license, since that is related to the distribution of the app

-optimize efi partition mounter for menu usage (not a lot of priority)

-show all mounted volumes in the drive detection but don't make them usable if they can't be used, and show a no go sign like with installer apps

-send notitifcation if the tinu version is not up to date (use a json file containing the reference link and the reference information to get)

-initial screen more like a home menu with more features ready to use + help section in this new home screen (which in cludes con tact us and help info and faqs)

-dynamic contact us window using the text assets or a json file (maybe the second option is the better one)

-take the user to contact us in case of problems

-global error screen for the installer creation/installation

*/
