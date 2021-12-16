# Copyright:
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# TO DO:
- continue with ui revision

- remove partitions unmount hardcode (detect the partitions to unmount)

- menu items text from json

- credits view controller text from json (probably requires a custom json)

- contacts view controller text from json (probably requires a cutom json)

- "Star this project on github" button in the final screen (if successful)

- Make UI Sketches for the multiple installer creation process

- Lion/mountain lion installer creation (WIP)

- Installer to dmg creation (check free space on the computer first, use hdiutil, modifiy the requirements screen for this, avoid the drive select screen)

- Main menu overhaul (put an icon there to access the installer apps downloads)

- always display cd/dvd drives as unusable in the drive select screen 

- concurrent multithreaded installer app scanning.

# TO DO but with less priority:
- right to left languages ui support

- divide language files in folders one for each language rather than re-naming them according to the language to use

- write translation guidelines and how to translate to a new language

- it's better to no longer mention directly hackintosh and hackintoshing in the tool, since it can be couse of possible problems maybe?

- send notitifcation if the tinu version is not up to date (use a json file containing the reference link and the reference information to get) (WIP)

- initial screen more like a home menu with more features ready to use + help section in this new home screen (which includes con tact us and help info and faqs)

- dynamic contact us window using the text assets or a json file (maybe the second option is the better one)

- take the user to contact us in case of problems

