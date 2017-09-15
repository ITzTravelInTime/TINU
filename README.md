# TINU
TINU, the macOS installer creation tool

[TINU Is Not Unibeast]

This software is intended to be used as a GUI to create a bootable mac os installer for mac and hackintosh, it's basically a GUI for the createinstallmedia script that could be found on any mac os installation apps.

Allows you to create easily a macOS install media without messing around with command line stuff. 

 Some features:
  - Simple to use UI that allows you to easily start the installer creation process
  - It can work with every Mac OS installer app that has the createinstallmedia executable inside it's resources folder (including also beta and newly released installers)
  - You can use any drive with a GUID partition sceme and HFS+ file system 
  - Works on Mac OS recovery, so you can create Mac OS installers from a bootable installer or from the recovery
  - All vanilla, the installers created with this tool are 100% vanilla mac os installers
  - Open source, you will know what this program runs on your computer
  - Creates working installers for Mac and hackintosh
  - Does not requires to change your system language, just open it up!
  - No need to go in disk utility first, TINU can format your drive for you!
 
 Coming soon features:
  - Installer customization
  - Kernelcache/prelinkedknerel and boot files replacement (a feature that can be handy while dealing with old Macs or with beta installers when you need to mod or change the boot files some times)
 
 Features that I'd like to add in the future:
  - Install clover and configure clover
  - Install kexts inside the kexts folder of clover
  - Clover drivers customization
  - Use custom dsdt in clover
  - integrated pre-made clover config tamplets database
  - Support for other languages, at least Italian
 
Requirements:
 - Mac OS X Yosemite or more recent version to run on standard macOS
 - Mac OS X El Capitan or more recent version to run on recovery mode/installer mode macOS

Useful links:

 Thread on insanelymac.com:
  - http://www.insanelymac.com/forum/topic/326959-tinu-the-macos-installer-creator-app-mac-app/#entry2491600
  
 Facebook hackintosh help (Italian only):
  - https://www.facebook.com/groups/Italia.hackintosh/?fref=ts
  
Contact me (project creator):
  - Insanelymac.com profile: http://www.insanelymac.com/forum/user/1390153-itztravelintime/
  - email: piecaruso97@gmail.com
  
Repository rules:
 - Pease do not recompile and redistribute as your own versions of this software outside this repo, and trust only official releases on the main branch of this software, to avoid using any third party modified or recompiled versions, because third party developers can easily hide malweres inside of it
 - If you want to create your own spin-off project create it in this repo in your own branch
 - Distribute your spin-off version in this repo in the releases section , specifying from which branch your binary comes from
 - For your spin-off version use the same version of swift that is used on the main branch
 - Do not commit, merge or edit the main branch, create your own instead and contact the project creator if you believe that your changes may help with the main branch
 - Contact the project creator for problems of the UI to fix
  
Note that:
 - this software is under GNU GPL v3 license so any new branch/mod/third party release must be open source and under the same license
 - I (project creator) assume no responsibility for any use of this app and this source code, and also for any kind of hardware and software damage to you computer and any device or perriferrial that may come from this app or source code during it's use and not
 - I (project creator) do not guarantee support to you, this is only an open source project, not a product released by a company!
