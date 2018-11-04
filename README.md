# TINU
TINU, the bootable macOS installer creation tool

[TINU Is Not Unibe**t]

This software is intended to be used to create a bootable macOS installer for mac and hackintosh, it's basically a GUI for the createinstallmedia executable that could be found in any macOS installer app from Mavericks up to the latest versions.

Allows you to create easily a macOS install media without messing around with command line stuff and without using disk utility, and also detects and prevents the most common errors with the creation of bootable vanilla macOS installers. 

# Features:
  - Simple to use UI that allows you to easily start the bootable macOS installer creation process
  - It can work with every macOS installer app that has the createinstallmedia executable inside of its resources folder (including also beta and newly released installers)
  - You can use any volume you want that can be erased and is at least 7 GB of size (if the volume's drive is not in GUID format, TINU will format it to make it GUID!)
  - Works on Mac OS recovery, so you can create a bootable macOS installer from the macOS installer itself or from the macOS recovery, and you can use TINU to install macOS too.
  - All vanilla, the bootable macOS installers created with this tool are 100% vanilla, just like you created them using the command line "createinstallmedia" method in the terminal
  - Open source, you will know what this program does on your computer and also you can create your own version by downloading and playing with the source code
  - Does not require to do anything of special first, just open the program, and make sure you have a USB drive pulugged in and that you have a macOS installer app in the system.
  - No need to go in disk utility first, TINU can format your drive/partition for you
  - Uses recent and more modern APIs and SDKs and Swift 3 language
  - Transparent graphics style available (use alt + s on the keyboard or View->Use transparent style)
  - Works using the latest versions of macOS and will also support newer Mac installers out of the box without needing for an update
  - Advanced section, to customize your bootable macOS installer
  
  Features that are planned for some future versions:
  - Integrated EFI partition mounter tool (TINU can already mount EFI partitions from version 2.0, but a dedicated section which allows to mount every EFI partition in the system will be added)
  - Install clover and configure clover
  - Install kexts inside the kexts folder of clover
  - Clover drivers customization
  - Use custom dsdt in clover
  - integrated pre-made clover config templates database from a remote and open repository
  - Support for other languages, at least Italian
 
# Rquirements:
 - A computer that runs Mac OS X Yosemite or a more recent version (Mac OS X El Capitan is required to use TINU in a macOS recovery or installer)
 - A drive or a free partition (on a drive which already supports GUID) of at least 7 GB that you want to turn into a macOS/Mac OS X installer
 - A copy of a macOS/Mac OS X installer app (Maveriks or newer versions are supported) in the /Applications folder or in the root of any storage drive in your machine (excepted the drive or volume you want to turn into your macOS install media)
 
# Download:
  - You can download the pre-made and code signed binary from the releases section of this repo that you can find here: https://github.com/ITzTravelInTime/TINU/releases
  
  - Or you can just build your own copy by just downloading the source code and then using Xcode (requires Xcode 8)
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
  
Contact me (project creator):
  - Insanelymac.com profile: http://www.insanelymac.com/forum/user/1390153-itztravelintime/
  - email: piecaruso97@gmail.com
  
# Repository rules:
 - Pease trust only official releases of this software, to avoid using any third party modified or recompiled versions, because third party developers can easily hide malweres inside of it
 - If you want to create your own spin-off version of TINU please let the project creator to know!
 - Distribute your spin-off version of TINU on GitHub please!
 - If you believe that your changes may help with the main branch, create your own fork instead and then create a pull/merge request instead to let the changes to be applyed more easily
 - Contact the project creator for problems, bugs and missplacements to fix, suggestions from designers and developers are always welcome
  
# Note that:
 - This software is under GNU GPL v3 license so any new branch/mod/third party release must be open source and under the same license
 - I (project creator) assume no responsibility for any use of this app and this source code, and also for any kind of hardware and software damage to any computer and any device or peripheral that may come from this app or source code during it's use and outside it's usage
 - I (project creator) do not guarantee support to you, this is only an open source project, not a product released by a company!
 - This project is born only for educational and demonstrative purposes, it's not intended to be used for commercial purposes and it will never be, don't use source code from this project to create apps or software for that aim.
 - This is a no-profit project, born only to let people to create macOS install medias in a more simple way and also to learn how to create this kind of apps.
 
 # Credits:
  - Apple for macos and installer apps and scripts
  - People that helped me a lot:
   Francesco Perchiazzi, Nicola Tomarelli, Roberto Sciortino, Raffaele Sonnessa, Ermanno Nicoletti, Tommaso Dimatore, Michele Vitiello Bonaventura, Massimiliano Faralli, Davide Dessì, Giorgio Dall'Aglio, Thomas Tempelmann, Peter Paul Chato.   
  - Special thanks to Italian Hackintosh group!! for help (https://www.facebook.com/groups/Italia.hackintosh/?fref=ts)
  - Pietro Caruso (ITzTravelInTime) for creating, maintaing and developing this project
