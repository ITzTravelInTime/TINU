# TINU
TINU, the open tool to create bootable macOS installers 

[TINU Is Not Unibe**t]

This software is intended to be used to create a bootable macOS installer for computers capable of running Apple's macOS, this app is basically a GUI for the createinstallmedia executable that could be found in any macOS installer app from Mavericks up to the latest versions.

Allows you to create easily a macOS install media without messing around with command line stuff and without using disk utility, and also detects and prevents the most common errors with the creation of bootable vanilla macOS installers. 

# For the latest Source code check out the delopment branch!

# Features:
- Fully open: You can see how this programs works and you can freely contribute to it! (See the `Repository rules` and the `Note that` sections of this file)
- Simple-to-use UI that allows you to easily start the bootable macOS installer creation process.
- Support for multiple languages (currently just italian, but more will be added with future updates once the system which allows it gets improoved)
- Can work with every macOS installer app that has the createinstallmedia executable inside its resources folder (including also beta and newly released installers).
- You can use any erasable volume that's large enought (see the `Requirements` section for size requirements).
- 100% clean: The bootable macOS installers created with this tool are completely vanilla, just as if you created them using the command line "createinstallmedia" method in the Terminal.
- Does not require any special preparations. Just open the program, make sure you have a USB drive plugged in and have a macOS installer app on your disk.
- No need to use Disk Utility first. TINU can format your drive or partition for you, if it's necessary.
- Integrated EFI partition mounter tool.
- Works using the latest versions of macOS and will also support newer Mac installers out of the box without requiring an update.
- Automatic Clover and OpenCore EFI folder installer.

 (To suggest a new feature please contact us)

# Requirements:
- A computer that runs Mac OS X Yosemite or a more recent version (Mac OS X El Capitan is required to use TINU inside a macOS Recovery/Installer OS).
- A drive or a free partition of least 8 GB (9+ for Catalina, 12+ for Big Sur and newer versions) that you want to turn into a macOS/Mac OS X installer (NOTE: partitions are usable only if they belong to a drive which iuses the GUID partition format).
- A copy of a macOS/Mac OS X installer app (Maveriks or newer versions are supported), it's reccommended to have the app placed into the /Applications folder or in the root of a volume connected to your computer (excepted the drive/volume you want to turn into your macOS install media).

# Reccommended Download:
Since the latest stable release does not support Big Sur and Catalina please use the latest beta release: https://github.com/ITzTravelInTime/TINU/releases/tag/3.0_BETA_4_(82)

# All Downloads:
- You can download the pre-made executable of the app from the releases section of this repo that you can find here: https://github.com/ITzTravelInTime/TINU/releases

# Building/Compiling requirements: 
- To compile (or create) a copy this app using the source code provvided in this repo, Xcode 12.x is required and so a machine running at least Catalina is needed.

# Frequently asked questions
https://github.com/ITzTravelInTime/TINU/wiki/FAQs

# Useful links and contacts:
Thread (english) on insanelymac.com:
- http://www.insanelymac.com/forum/topic/326959-tinu-the-macos-installer-creator-app-mac-app/

Thread (italian) on insanelymac.com:
- https://www.insanelymac.com/forum/topic/333261-tinu-app-per-creare-chiavette-di-installazione-di-macos-thread-in-italiano/

Thread (english-german) on hackintosh-forum.de:
- https://www.hackintosh-forum.de/index.php/Thread/33630-TINU/ 

Contact the project creator (ITzTravelInTime aka Pietro):
- Reddit profile:          
    https://www.reddit.com/user/ITzTravelInTime
- email:                  
    piecaruso97@gmail.com

# Repository rules:
- If you want to create your own spin-off version of TINU please let the project maintainers know!
- If possible distribute your spin-off version of TINU on GitHub and respect the license please!
- If you believe that your changes may help with the main branch, create your own fork, apply the changes to it and then create a pull/merge request to the main branch here to let the changes be applyed more easily by the repository maintainers.
- Create an issue for any problems, bugs, spell/grammar errors, missplacements and suggestions (especially the ones from designers and developers are always welcome).

# Note that:
- This software is currently under GNU GPL v2 license so any new branch/mod/third party release must be open source and under the same license.
- We (the project creator and othe people involved with active developmment) assume no responsibility for any use of this app and this source code, use them at your own risk!
- We (the project creator and othe people involved with active developmment) do not guarantee support to you, this is only an open source project done in our free time, not a product released by a company!
- This project is born only for educational and demonstrative purposes, it's not intended to be used for commercial purposes.
- This is a no-profit project, born only to let people to create macOS install medias in a more simple way and also to let them learn how to create this kind of apps.

# Credits:
- Apple for macos and installer apps and scripts
- Special tahnks to:
Francesco Perchiazzi, Nicola Tomarelli, Roberto Sciortino, Raffaele Sonnessa, Ermanno Nicoletti, Tommaso Dimatore, Michele Vitiello Bonaventura, Massimiliano Faralli, Davide Dessì, Giorgio Dall'Aglio, Peter Paul Chato, the Facebook group ["Italian Hackintosh group!!"](https://www.facebook.com/groups/Italia.hackintosh/?fref=ts), the Telegram group ["Hackintosh Italia"](https://t.me/Hackintoshitalia).
- Gianmarco Gargiulo for the New app icon and usb drive image.
- Thomas Tempelmann for help with the UI, grammar and the code.
- Pietro Caruso (ITzTravelInTime) for creating, maintaing and developing this project.
