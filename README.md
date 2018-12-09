# TINU
TINU, the bootable macOS installer creation tool

[TINU Is Not Unibe**t]

This software is intended for creating a bootable macOS installer for Mac and Hackintosh computers. It's basically a GUI for the createinstallmedia executable that can be found in any macOS installer app from Mavericks (macOS 10.9) up to the most recent versions.

It allows you to easily create a macOS install USB stick or other installer media without messing around with the command line and without using Disk Utility. It also detects and prevents the most common errors with the creation of bootable vanilla macOS installers. 

# Features:
- Simple-to-use UI that allows you to easily start the bootable macOS installer creation process.
- It can work with every macOS installer app that has the createinstallmedia executable inside its resources folder (including also beta and newly released installers).
- You can use any erasable volume that is at least 7 GB of size (if the volume's drive is not in GUID format, TINU will re-format it accordingly).
- Can work with the Mac OS recovery system, so you can create a bootable macOS installer from the macOS installer itself or from the macOS recovery partition, and you can use TINU to install macOS, too.
- 100% clean: The bootable macOS installers created with this tool are vanilla, just as if you created them using the command line "createinstallmedia" method in Terminal.
- Open Source: You can verify what this program does on your computer and you can create your own version by downloading and playing with the source code.
- Does not require any special preparations. Just open the program, make sure you have a USB drive plugged in and have a macOS installer app on your disk.
- No need to use Disk Utility. TINU can format your drive or partition for you.
- Integrated EFI partition mounter tool.
- Uses recent, modern, APIs and SDKs and the Swift 3 language.
- Transparent graphics style available (type alt-S or choose from the menu bar: View -> Use transparent style).
- Works using the latest versions of macOS and will also support newer Mac installers out of the box without requiring an update.
- Offers advanced features to customize your bootable macOS installer.

Features that are planned for future versions:
- Install and configure [Clover](https://sourceforge.net/projects/cloverefiboot/).
- Install kexts into Clover's kexts folder.
- Clover drivers customization
- Use custom DSDT in Clover
- Integrated pre-made Clover config templates database from a remote and open repository.
- Support for other languages, at least Italian.

# Requirements:
- A computer that runs Mac OS X Yosemite or a more recent version (Mac OS X El Capitan is required to use TINU in a macOS recovery or installer).
- A drive or a free partition (on a drive which already supports GUID) of least 7 GB that you want to turn into a macOS/Mac OS X installer.
- A copy of a macOS/Mac OS X installer app (Maveriks or newer versions are supported) in the /Applications folder or in the root of any storage drive on your machine (excepted the drive or volume you want to turn into your macOS install media).

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

Post on Reddit:
- https://www.reddit.com/r/hackintosh/comments/a1h61d/tinu_vanilla_bootable_macos_installer_creation/

Facebook hackintosh help and beta testing (Italian only):
- https://www.facebook.com/groups/Italia.hackintosh/?fref=ts

Contact me (project creator):
- Insanelymac.com profile: http://www.insanelymac.com/forum/user/1390153-itztravelintime/
- email: piecaruso97@gmail.com

# Repository rules:
- Pease trust only official releases of this software, to avoid using any third party modified or recompiled versions, because third party developers can easily hide malweres inside of it
- If you want to create your own spin-off version of TINU please let the project creator to know!
- Distribute your spin-off version of TINU on GitHub and respect the license please!
- If you believe that your changes may help with the main branch, create your own fork, apply the changes to it and then create a pull/merge request to the main branch here to let the changes to be applyed more easily by the repository maintainers
- Contact the project creator for any problems, bugs, spell/grammar errors and missplacements to fix in the main repo, suggestions from designers and developers are always welcome

# Note that:
- This software is under GNU GPL v3 license so any new branch/mod/third party release must be open source and under the same license
- I (project creator) assume no responsibility for any use of this app and this source code, and also for any kind of hardware and software damage to any computer and any device or peripheral that may come from this app or source code during it's use and outside it's usage
- I (project creator) do not guarantee support to you, this is only an open source project, not a product released by a company!
- This project is born only for educational and demonstrative purposes, it's not intended to be used for commercial purposes and it will never be, don't use source code from this project to create apps or software for that aim.
- This is a no-profit project, born only to let people to create macOS install medias in a more simple way and also to learn how to create this kind of apps.

# Credits:
- Apple for macos and installer apps and scripts
- People that helped me a lot:
Francesco Perchiazzi, Nicola Tomarelli, Roberto Sciortino, Raffaele Sonnessa, Ermanno Nicoletti, Tommaso Dimatore, Michele Vitiello Bonaventura, Massimiliano Faralli, Davide Dessì, Giorgio Dall'Aglio, Peter Paul Chato.   
- Special thanks to Italian Hackintosh group!! for help (https://www.facebook.com/groups/Italia.hackintosh/?fref=ts)
- Thomas Tempelmann for help with the UI
- Pietro Caruso (ITzTravelInTime) for creating, maintaing and developing this project
