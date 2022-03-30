# Copyright:
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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

- credits view controller text from json (probably requires a reimplementation)

- contacts view controller text from json (probably requires a reimplementation)

- "Star this project on github" button in the final screen (if successful)

- Make UI Sketches for the multiple installer creation process

- Lion/mountain lion installer creation (WIP)

- always display cd/dvd drives as unusable in the drive select screen 

- concurrent multithreaded installer app scanning.

- use appropriate sfsymbols with custom colors for drive ok/not ok badge

- check for rosetta on apple silicon and force the older installer creations to use rosetta, if necessary prompt users to install rosetta.

- Downloads with top bar like efi partition mounter

# TO DO but with less priority:

- dmg/iso to usb drive for compete with rufus.

- Installer to dmg creation (check free space on the computer first, use hdiutil, modifiy the requirements screen for this, avoid the drive select screen)

- right to left languages ui support 

- divide language files in folders one for each language rather than re-naming them according to the language to use

- write translation guidelines and how to translate to a new language

- it might be better to no longer mention directly hackintosh and hackintoshing in the tool, since it can be couse of possible problems (maybe?)

- help section in the home screen (which includes tutorials, faqs and something to create a new issue)

- take the user to contact us in case of problems

