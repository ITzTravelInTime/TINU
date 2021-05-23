# TINU
TINU, the open tool to create bootable macOS installers 

[TINU Is Not Unibe**t]

This software is intended to be used to create a bootable macOS installer for computers capable of running Apple's macOS, this app is basically a GUI for the createinstallmedia executable that could be found in any macOS installer app from Mavericks up to the latest versions.

Allows you to create easily a macOS install media without messing around with command line stuff and without using disk utility, and also detects and prevents the most common errors with the creation of bootable vanilla macOS installers. 

# For the latest Source code check out the delopment branch!

# Features:
- Simple-to-use UI that allows you to easily start the bootable macOS installer creation process.
- Support for multiple languages (currently just italian, but more will be added with future updates once the system which allows it gets improoved)
- It can work with every macOS installer app that has the createinstallmedia executable inside its resources folder (including also beta and newly released installers).
- You can use any erasable volume that is at least 7 GB of size (if the volume's drive is not in GUID format, TINU will re-format it accordingly).
- Can work with the Mac OS recovery system, so you can create a bootable macOS installer from the macOS installer itself or from the macOS recovery partition, and you can use TINU to install macOS, too.
- 100% clean: The bootable macOS installers created with this tool are vanilla, just as if you created them using the command line "createinstallmedia" method in Terminal.
- Open Source: You can verify what this program does on your computer and you can create your own version by downloading and playing with the source code.
- Does not require any special preparations. Just open the program, make sure you have a USB drive plugged in and have a macOS installer app on your disk.
- No need to use Disk Utility. TINU can format your drive or partition for you.
- Integrated EFI partition mounter tool.
- Works using the latest versions of macOS and will also support newer Mac installers out of the box without requiring an update.
- Offers features to customize your bootable macOS installer.

 (To sugegst a new feature please contact us)

# Requirements:
- A computer that runs Mac OS X Yosemite or a more recent version (Mac OS X El Capitan is required to use TINU in a macOS recovery or installer).
- A drive or a free partition (on a drive which already supports GUID) of least 7 GB that you want to turn into a macOS/Mac OS X installer.
- A copy of a macOS/Mac OS X installer app (Maveriks or newer versions are supported) in the /Applications folder or in the root of any storage drive on your machine (excepted the drive or volume you want to turn into your macOS install media).

# Download:
- You can download the pre-made and code signed app from the releases section of this repo that you can find here: https://github.com/ITzTravelInTime/TINU/releases

- Or you can just build your own copy by just downloading the source code provvided here and then using Xcode (see the building/compiling requirements)

# Building/Compiling requirements: 
- To compile (or create) a copy this app using the source code provvided in this repo, Xcode 10.1.x is required and so a machine running at least high sierra is needed.

# Frequently asked questions
https://github.com/ITzTravelInTime/TINU/wiki/FAQs

# Wiki
https://github.com/ITzTravelInTime/TINU/wiki

# Useful links:
Thread (english) on insanelymac.com:
- http://www.insanelymac.com/forum/topic/326959-tinu-the-macos-installer-creator-app-mac-app/

Thread (italian) on insanelymac.com:
- https://www.insanelymac.com/forum/topic/333261-tinu-app-per-creare-chiavette-di-installazione-di-macos-thread-in-italiano/

Thread (english-german) on hackintosh-forum.de:
- https://www.hackintosh-forum.de/index.php/Thread/33630-TINU/ 

Facebook hackintosh help and beta testing (Italian only):
- https://www.facebook.com/groups/Italia.hackintosh/?fref=ts

Contact the project creator (ITzTravelInTime aka Pietro):
- Insanelymac.com profile: 
    http://www.insanelymac.com/forum/user/1390153-itztravelintime/
- Reddit profile:          
    https://www.reddit.com/user/ITzTravelInTime
- email:                  
    piecaruso97@gmail.com

# Repository rules:
- Pease trust only official releases of this software, to avoid using any third party modified or recompiled versions, because third party developers can easily hide malweres inside of it
- If you want to create your own spin-off version of TINU please let the project creator to know!
- Distribute your spin-off version of TINU on GitHub and respect the license please!
- If you believe that your changes may help with the main branch, create your own fork, apply the changes to it and then create a pull/merge request to the main branch here to let the changes to be applyed more easily by the repository maintainers
- Contact the project creator for any problems, bugs, spell/grammar errors and missplacements to fix in the main repo, suggestions from designers and developers are always welcome

# Note that:
- This software is under GNU GPL v3 license so any new branch/mod/third party release must be open source and under the same license.
- We (the project creator and othe people involved with active developmment) assume no responsibility for any use of this app and this source code, and also for any kind of hardware and software damage to any computer and any device or peripheral that may come from this app or source code during it's use and outside it's usage
- We do not guarantee support to you, this is only an open source project, not a product released by a company!
- This project is born only for educational and demonstrative purposes, it's not intended to be used for commercial purposes and it will never be.
- This is a no-profit project, born only to let people to create macOS install medias in a more simple way and also to learn how to create this kind of apps.

# Credits:
- Apple for macos and installer apps and scripts
- People that helped a lot:
Francesco Perchiazzi, Nicola Tomarelli, Roberto Sciortino, Raffaele Sonnessa, Ermanno Nicoletti, Tommaso Dimatore, Michele Vitiello Bonaventura, Massimiliano Faralli, Davide Dessì, Giorgio Dall'Aglio, Peter Paul Chato.   
- Special thanks to Italian Hackintosh group!! for help (https://www.facebook.com/groups/Italia.hackintosh/?fref=ts)
- Thomas Tempelmann for help with the UI, grammar and the code
- Pietro Caruso (ITzTravelInTime) for creating, maintaing and developing this project
