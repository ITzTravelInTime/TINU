//
//  InstallingViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 27/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa
import SecurityFoundation

class InstallingViewController: NSViewController{
    @IBOutlet weak var driveName: NSTextField!
    @IBOutlet weak var driveImage: NSImageView!
    
    @IBOutlet weak var appImage: NSImageView!
    @IBOutlet weak var appName: NSTextField!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet var logText: NSTextView!
    
    @IBOutlet weak var logView: NSScrollView!
    
    @IBOutlet weak var cancelButton: NSButton!
    
    @IBOutlet weak var background: NSVisualEffectView!
    
    //variables used to check the sucess of the authentication
    private var osStatus: OSStatus = 0
    private var osStatus2: OSStatus = 0
    //references we need to free the permitions later
    private var authRef2: AuthorizationRef?
    private var authFlags = AuthorizationFlags([])
    
    //timer to trace the process
    private var timer = Timer()
    
    private var pid = Int32()
    private var output : [String] = []
    private var error : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //if we are into the recoverry we don't need fancy graphics
        if sharedIsOnRecovery || !sharedUseVibrant {
            background.isHidden = true
        }
        
        //disable the close button of the window
        
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = false
            w.isClosingEnabled = false
            w.canHide = false
        }
        
 
        /*if let a = NSApplication.shared().delegate as? AppDelegate{
            a.QuitMenuButton.isEnabled = false
        }*/
        
        //just prints some separators to allow me to see where this windows opens in the output
        print("****************************")
        print("* CREATION PROCESS STARTED *")
        print("****************************")

        
        print("macOS install media creation window opened")
        //this code checks if the app and the drive provided are correct
        var notDone = false
        
        if let sa = sharedApp{
            print(sa)
            appImage.image = NSWorkspace.shared().icon(forFile: sa)
            appName.stringValue = FileManager.default.displayName(atPath: sa)
            print("Installer app that will be used is: " + sa)
        }else{
            notDone = true
        }
        
        if let sv = sharedVolume{
            print(sv)
            var sr = sv
            
            
            if !FileManager.default.fileExists(atPath: sv){
                if let sb = sharedBSDDrive{
                    
                    sr = getDriveNameFromBSDID(sb)
                    sharedVolume = sr
                    print("Corrected the name of the target volume" + sr)
                }else{
                    notDone = true
                }
            }
            
            driveImage.image = NSWorkspace.shared().icon(forFile: sr)
            driveName.stringValue = FileManager.default.displayName(atPath: sr)
            print("The target volume is: " + sr)
        }else{
            notDone = true
        }
        
        //used to simulate a fail to gett drive or app data
        if simulateInstallGetDataFail{
            notDone = true
        }
        
        //if it can't get usable drive and app information, it goes back to the previuos window
        if notDone {
            print("Couldn't get valid info about the installer app and/or the drive")
            //temporary dialong util a soulution for the go back in the view controller problem is solved
            if !dialogYesNo(question: "Quit the app?", text: "There was an error while trying to get drive or installer app data, do you want to quit the app?", style: .critical){
                NSApplication.shared().terminate(self)
            }else{
                sharedWindow.contentViewController?.openSubstituteWindow(windowStoryboardID: "Confirm", sender: self.view)
            }
        }else{
            print("Everything is ready to start the macOS install media creation process")
            
            spinner.startAnimation(self)
            
            //calls the install function to start the installer creation process
            install()
        }
    }
    
    public func install(){
        cancelButton.isEnabled = false
        
        //to have an usable UI during the install we need to use a parallel thread
        DispatchQueue.global(qos: .background).async {
            //just to avoid problems, the log function in this thred is called inside the Ui thread
            DispatchQueue.main.async {
                log("Starting installer creation process ...")
                log("Asking for user authentication ...")
            }
            
            sharedIsPreCreationInProgress = true
            
            //gets the bundle becase it's needed when asking for the password
            let b = Bundle.main
            //if we are not in the reoot user in rcovery mode, we just skip that
            if !sharedIsOnRecovery{
                //asks for authentication using the apis
                
                var authRef: AuthorizationRef? = nil
                
                self.osStatus = AuthorizationCreate(nil, nil, self.authFlags, &authRef)
                var myItems = [
                    AuthorizationItem(name: b.bundleIdentifier! + ".sudo", valueLength: 0, value: nil, flags: 0),
                    AuthorizationItem(name: b.bundleIdentifier! + ".createinstallmedia", valueLength: 0, value: nil, flags: 0)
                ]
                var myRights = AuthorizationRights(count: UInt32(myItems.count), items: &myItems)
                let myFlags : AuthorizationFlags = [.interactionAllowed, .extendRights, .destroyRights, .preAuthorize]
                
                self.osStatus2 = AuthorizationCreate(&myRights, nil, myFlags, &self.authRef2)
            }
            
            //simulates an uthentication fail or cancel
            if simulateFirstAuthCancel{
                self.osStatus = 1
                self.osStatus2 = 1
            }
            
            //checks if the authentication is sucessfoul
            if self.osStatus == 0 && self.osStatus2 == 0{
                DispatchQueue.main.async {
                    log("User successfully authenticated")
                }
                
                //format skip testing
                if simulateFormatSkip{
                    sharedVolumeNeedsPartitionMethodChange = nil
                    //sharedVolumeNeedsFormat = nil
                }
                
                // variables used to determinate if the format was sucessfoul
                var didChangePS = true
                //var didChangeFS = true
                
                //chck if volume needs to be formatted, in particular if it needs to be repartitioned and completely erased
                if let s = sharedVolumeNeedsPartitionMethodChange {
                    if s{
                        
                        DispatchQueue.main.async {
                            log("Starting volume partition scheme change")
                        }
                        //we set this to false just in case of failure
                        didChangePS = false
                        
                        //this code gets the bsd name of the drive from the bsd name of the partition selcted
                        var tmpBSDName = ""
                        var ns = 0
                        
                        for cc in sharedBSDDrive.characters{
                            let c = String(cc)
                            if c.lowercased() == "s"{
                                ns += 1
                            }
                            if ns == 1{
                                if let _ = Int(c){
                                    tmpBSDName += c
                                }
                            }
                        }
                        var out: String!
                        
                        //let nm = URL.init(fileURLWithPath: sharedVolume, isDirectory: true).lastPathComponent
                        //this is the command used to erase the disk and create on just one partition with the GUID table
                        let cmd = "diskutil eraseDisk JHFS+ " + "Installer" + " /dev/disk" + tmpBSDName
                        
                        DispatchQueue.main.async {
                            log("Formatting disk and change partition scheme with the command:")
                            log("      " + cmd)
                        }
                        
                        //gets the output of the format script
                        out = getOutWithSudo(cmd: cmd)
                        
                        //out is nil only if the authentication has failed
                        if out == nil{
                            DispatchQueue.main.async {
                                self.freeAuth()
                                
                                log("Get password failed")
                                self.goBack()
                                return
                            }
                        }else{
                            //output separated in parts
                            let c = out.components(separatedBy: "\n")
                            //the text we are looking for
                            let finishedMark = "Finished erase on disk"
                            //checks if the erase has been completed with success
                            if c[c.count - 2].contains(finishedMark) || c.last!.contains(finishedMark){
                                //we can set this boolean to true because the process has been successfoul
                                didChangePS = true
                                //setup variables for the \createinstall media, the target partition is always the second partition into the drive, the first one is the EFI partition
                                sharedBSDDrive = "/dev/disk" + tmpBSDName + "s2"
                                sharedVolume = getDriveNameFromBSDID(sharedBSDDrive)
                                
                                DispatchQueue.main.async {
                                    if let name = sharedVolume{
                                        self.driveImage.image = NSWorkspace.shared().icon(forFile: name)
                                        self.driveName.stringValue = FileManager.default.displayName(atPath: name)
                                    }
                                    
                                    log("Volume partition scheme changed with sucess")
                                }
                            }else{
                                //the format has failed, so the boolean is false and a screen with installer creation failed will be displayed
                                DispatchQueue.main.async {
                                    log("Volume partition scheme change fail: ")
                                    log("      Format script output: \n" + out)
                                }
                            }
                        }
                        
                    }
                }
            
            //the format code is ignored for now because createinstallmedia can do it by itself, but just in case it's needed it's keeped here
            /*
                if let s = sharedVolumeNeedsFormat {
                    if s{
                        DispatchQueue.main.async {
                            self.log("Starting volume file system format")
                        }
                        didChangeFS = false
                        //format file system here
                        
                        var out: String!
                        let cmd = "diskutil eraseVolume JHFS+ Installer " + sharedBSDDrive
                        
                        DispatchQueue.main.async {
                            self.log("Formatting volume with the command:")
                            self.log("      " + cmd)
                        }
                        
                        out = self.getOutWithSudo(cmd: cmd)
             
                        //out is nil only if the authentication has failed
                        if out == nil{
             
                            //since into the recovery we do not need the spacial authorization, we just free it when running on a normal mac os environment
                            if !sharedIsOnRecovery{
                                //we no longer need the special authorization, so it is freed
                                if AuthorizationFree(authRef2!, authFlags) == 0{
                                    DispatchQueue.main.async {
                                        log("AutorizationFree executed successfully")
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        log("AutorizationFree failed")
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                log("Get password failed")
                                self.goBack()
                                return
                            }
                        }else{
             
                        if out.components(separatedBy: "\n").last!.contains("Finished erase on disk"){
                            didChangeFS = true
                            sharedVolume = getDriveNameFromBSDID(sharedBSDDrive)
                                DispatchQueue.main.async {
                                    if let name = sharedVolume{
                                        self.driveImage.image = NSWorkspace.shared().icon(forFile: name)
                                        self.driveName.stringValue = FileManager.default.displayName(atPath: name)
                                    }
                 
                                    log("Volume formatted with sucess")
                                }
                        }else{
                            DispatchQueue.main.async {
                                self.log("Volume format failed: ")
                                self.log("      Format script output: " + out)
                            }
                        }
                    }
                    }
                }
              */
            
                //this code simulates when the format has failed
                if simulateFormatFail{
                    didChangePS = false
                    //didChangeFS = false
                }
                
                //if the drive has benn successfully formatted, procede
                if /*didChangeFS &&*/ didChangePS{
                    //adds the \ before the spaces in the string of the installer app's path, because it's needed for the scripts
                    var path = ""
                    for ii in sharedApp.characters{
                        let i = String(ii)
                        if i == " "{
                            path += "\\ "
                        }else{
                            path += i
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        log("The application that will be used to create the installer is: " + sharedApp)
                    }
                    
                    //adds the \ before the spaces in the string of the selected drive's path, because it's needed for the scripts
                    var drv = ""
                    for ii in sharedVolume.characters{
                        let i = String(ii)
                        if i == " "{
                            drv += "\\ "
                        }else{
                            drv += i
                        }
                    }
                    DispatchQueue.main.async {
                        log("The target drive is: " + sharedVolume)
                    }
                    //this strting is used to define the main command to use, then the prefix is added
                    var mainCMD = path + "/Contents/Resources/" + sharedExecutableName + " --volume " + drv + " --applicationpath " + path
                    
                    //if tinu have to create a mac os installation on the selected drive (experimental, not used bacause it does not seems to work)
                    if sharedInstallMac{
                        
                        ///Volumes/Image\ Volume/Install\ macOS\ High\ Sierra.app/Contents/Resources/startosinstall --volume /Volumes/MAC --converttoapfs NO
                        mainCMD += " --agreetolicense --converttoapfs NO;exit;"
                    }else{
                        //we are just on the standard createinstallmedia, so let's add what is missing
                        mainCMD += " --nointeraction;exit;"
                    }
                    
                    //this code is used to simulate results of createinstll media, saves time hen tesing the fial screen
                    if let scf = simulateCreateinstallmediaFail{
                        if !scf{
                            mainCMD = "echo \"done test\""
                        }else{
                            mainCMD = "echo \"failed test\""
                        }
                    }
                    
                    DispatchQueue.main.async {
                        //logs the performed script and takes care of hiding the password
                        log("The script that will be performed is: " + mainCMD)
                        log("Installer creation started, waiting for createinstallmedia to finish ...")
                    }
                    
                    //sets to tru this booler that tells to the rest of the app if the creation of the installer is active
                    sharedIsCreationInProgress = true
                    
                    //run the script with sudo permitions and then analyze the outputs
                    if let r = startCommandWithSudo(cmd: "/bin/sh", args: ["-c", mainCMD]){
                        sharedIsPreCreationInProgress = false
                        
                        //assign processes variables
                        process = r.process
                        errorPipe = r.errorPipe
                        outputPipe = r.outputPipe
                        
                        
                        DispatchQueue.main.sync {
                            //cancel button and the close button can be restored
                            self.cancelButton.isEnabled = true
                            
                            if let ww = sharedWindow{
                                //ww.isMiniaturizeEnaled = false
                                ww.isClosingEnabled = true
                                //ww.canHide = false
                            }
                            
                            self.timer.invalidate()
                            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkProcessFinished(_:)), userInfo: nil, repeats: true)
                        }
                        
                        //code used if the timer is not used
                        //r.process.waitUntilExit()
                        
                        //install is finished, so we call this function
                        //self.installFinished()
                        
                        //old code, still keeped here as a backup
                        //now this code is executed only when the script finishes it's execution
                        //now the installer creation process has finished running, so our boolean must be false now
                        
                        /*sharedIsCreationInProgress = false
                        
                        let outdata = r.outputPipe.fileHandleForReading.readDataToEndOfFile()
                        if var string = String(data: outdata, encoding: .utf8) {
                            string = string.trimmingCharacters(in: .newlines)
                            self.output = string.components(separatedBy: "\n")
                        }
                        
                        let errdata = r.errorPipe.fileHandleForReading.readDataToEndOfFile()
                        if var string = String(data: errdata, encoding: .utf8) {
                            string = string.trimmingCharacters(in: .newlines)
                            self.error = string.components(separatedBy: "\n")
                        }
                        
                        //now we do not need the password anymore
                        erasePassword()
                        
                        //since into the recovery we do not need the spacial authorization, we just free it when running on a normal mac os environment
                        if !sharedIsOnRecovery{
                            //we no longer need the special authorization, so it is freed
                            if AuthorizationFree(authRef2!, authFlags) == 0{
                                DispatchQueue.main.async {
                                    log("AutorizationFree executed successfully")
                                }
                            }else{
                                DispatchQueue.main.async {
                                    log("AutorizationFree failed")
                                }
                            }
                        }
                        
                        var rc = r.process.terminationStatus
                        
                        if simulateAbnormalExitcode{
                            rc = 1
                        }
                        
                        
                        DispatchQueue.main.async {
                            
                            //if there is a not normal code it will be logged
                            log("Installer creation finished, createinstallmedia has finished")
                            if rc != 0{
                                log("Createinstallmedia exit code produced: \n      \(rc)")
                            }
                            
                            log("Createinstallmedia output produced: ")
                            //logs the output of the process
                            for o in self.output{
                                log("      " + o)
                            }
                            
                            if !self.error.isEmpty{
                                if !((self.error.first?.contains("Erasing Disk: 0%... 10%... 20%... 30%...100%..."))! && self.error.first == self.error.last){
                                    log("Createinstallmedia error/s produced: ")
                                    //logs the errors produced by the process
                                    if !self.error.isEmpty{
                                        for o in self.error{
                                            log("      " + o)
                                        }
                                    }else{
                                        log("      No errors found")
                                    }
                                }
                            }
                            
                            //now we checks if the installer creation has been completed sucessfully
                            if (self.output.last?.uppercased().contains("DONE"))!{
                                //here createinstall media succedes in creating the installer
                                log("Installer created successfully!")
                                //ok the installer creation has been completed with sucess, so it sets up the final widnow and then it's showed up
                                self.goToFinalScreen(title: "macOS install media created successfully", success: true)
                            }else if (self.error.last?.contains("A error occurred erasing the disk."))! {
                                //here createinstall media failed to create the installer, bacuse of a format failure
                                log("Installer creation failed, createinstallmedia returned an error while formatting the installer, please, erase this dirve with disk utility and retry")
                                //the installer creation has failed, so it does setup the final windows to show the failure an the error and then it's called
                                self.goToFinalScreen(title: "macOS install media creation failed to format the target drive, check the log for details", success: false)
                            }else if (self.error.last?.contains("does not appear to be a valid OS installer application"))!{
                                //here createinstall media failed to create the installer, bacuse of the downloaded app not being a valid one
                                log("Installer creation failed, createinstallmedia returned an error about the app yoiu are using, please, check your mac instalaltion app and if needed download it again")
                                //showing tp the installer screen
                                self.goToFinalScreen(title: "macOS install media creation failed to beacuse of a bad macOS application, check the log for details", success: false)
                            }else{
                                //shows different screen basing on the erros
                                if rc == 0{
                                    //here createinstall media failed to create the installer
                                    log("Installer creation failed, createinstallmedia returned an error while creating the installer, please, erase this dirve with disk utility and retry")
                                    //the installer creation has failed, so it does setup the final windows to show the failure an the error and then it's called
                                    self.goToFinalScreen(title: "macOS install media creation failed, check the log for details", success: false)
                                }else{
                                    //process exite with a not nomal exit code
                                    log("macOS install media creation exited with a not normal exit code")
                                    self.goToFinalScreen(title: "macOS install media creation exited with not normal code, check the log for details", success: false)
                                }
                            }
                        }*/
                        
                        return
                    }else{
                        //here the second authentication is failed, so we come back to the previus screen, but we need to release permitions
                        self.freeAuth()
                        
                        //now the installer creation process has finished running, so our boolean must be false now
                        sharedIsCreationInProgress = false
                        
                        DispatchQueue.main.async {
                            log("Get password failed")
                            self.goBack()
                            return
                        }
                        
                    }
                }else{
                    //here the format script to erase the drive has failed, we also need to realse permitions here
                    
                    self.freeAuth()
                    
                    DispatchQueue.main.sync {
                        log("Installer creation failed, drive format or partition table changement failed, please erase this drive manually with disk utility and then retry")
                        //the driver format has failed, so it does setup the final windows to show the failure an the error and then it's called
                        self.goToFinalScreen(title: "macOS install media creation failed to format the target drive, check the log for details", success: false)
                        return
                    }
                }
            }else{
                //the user does not gives the authentication, so we came back to previous window
                DispatchQueue.main.sync {
                    log("Authentication aborted")
                    self.goBack()
                    return
                }
            }
        }
    }
    
    //unused, still work in progress
    
    var seconds: UInt64 = 0
    //function that checks if the process has finished
    @objc func checkProcessFinished(_ sender: AnyObject){
        seconds += 1
        print(String(seconds) + " seconds passed from start")
        DispatchQueue.global(qos: .background).async{
        //log("Checking createinstallmedia status check: \(self.seconds) seconds passed")
        /*if let string = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
            DispatchQueue.main.async {
                log(string.trimmingCharacters(in: .newlines))
            }
        }*/
        /*
        if let string = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
            log(string.trimmingCharacters(in: .newlines))
        }*/
        
        
            if !process.isRunning{
                sharedIsCreationInProgress = false
                DispatchQueue.main.async {
                    log("macOS install media creation took " + String(self.seconds) + " seconds to finish")
                    self.timer.invalidate()
                    self.installFinished()
                }
            }
        }
    }
    
    private func installFinished(){
        //now the installer creation process has finished running, so our boolean must be false now
        sharedIsCreationInProgress = false
        
        //we have finished, so the controls opf the window are restored
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = true
            w.isClosingEnabled = true
            w.canHide = true
        }
        
        //this code get's the output of teh process
        let outdata = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            self.output = string.components(separatedBy: "\n")
        }
        
        //this code gets the errors of the process
        let errdata = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            self.error = string.components(separatedBy: "\n")
        }
        
        //now we do not need the password anymore
        erasePassword()
        
        //the process is finished, so authentication is no longer needed
        freeAuth()
        
        //gets the termination status for comparison
        var rc = process.terminationStatus
        
        //code used to test if the process has exited with an abnormal code
        if simulateAbnormalExitcode{
            rc = 1
        }
        
        //if there is a not normal code it will be logged
        log("macOS install media creation finished, createinstallmedia has finished")
        
        //if the exit code produced is not normal, it's logged
        if rc != 0{
            log("macOS install media creation exit code produced: \n      \(rc)")
        }
        
        log("macOS install media creation output produced: ")
        //logs the output of the process
        for o in self.output{
            log("      " + o)
        }
        
        //if the output is empty opr if it's just the standard output of the creation process, it's not logged
        if !self.error.isEmpty{
            if !((self.error.first?.contains("Erasing Disk: 0%... 10%... 20%... 30%...100%..."))! && self.error.first == self.error.last){
                log("macOS install media creation error/s produced: ")
                //logs the errors produced by the process
                for o in self.error{
                    log("      " + o)
                }
            }
        }
        
        //now we checks if the installer creation has been completed sucessfully
        if (self.output.last?.uppercased().contains("DONE"))!{
            
            //here createinstall media succedes in creating the installer
            log("macOS install media created successfully!")
            
            //ok the installer creation has been completed with sucess, so it sets up the final widnow and then it's showed up
            self.goToFinalScreen(title: "macOS install media created successfully", success: true)
            
        }else if (self.error.last?.contains("A error occurred erasing the disk."))! || (self.output.last?.contains("A error occurred erasing the disk."))! {
            
            //here createinstall media failed to create the installer, bacuse of a format failure
            log("macOS install media creation failed, createinstallmedia returned an error while formatting the installer, please, erase this dirve with disk utility and retry")
            
            //the installer creation has failed, so it does setup the final windows to show the failure an the error and then it's called
            self.goToFinalScreen(title: "macOS install media creation failed to format the target drive, check the log for details", success: false)
            
        }else if (self.error.last?.contains("does not appear to be a valid OS installer application"))! || (self.error.last?.contains("does not appear to be a valid OS installer application"))! {
            
            //here createinstall media failed to create the installer, bacuse of the downloaded app not being a valid one
            log("macOS install media creation failed, createinstallmedia returned an error about the app yoiu are using, please, check your mac instalaltion app and if needed download it again")
            
            //showing tp the installer screen
            self.goToFinalScreen(title: "macOS install media creation failed to beacuse of a bad macOS application, check the log for details", success: false)
            
        }else{
            //shows different screen basing on the erros
            if rc == 0{
                
                //here createinstall media failed to create the installer
                log("macOS install media creation failed, createinstallmedia returned an error while creating the installer, please, erase this dirve with disk utility and retry")
                
                //the installer creation has failed, so it does setup the final windows to show the failure an the error and then it's called
                self.goToFinalScreen(title: "macOS install media creation failed, check the log for details", success: false)
                
            }else{
                
                //process exite with a not nomal exit code
                log("macOS install media creation exited with a not normal exit code")
                
                self.goToFinalScreen(title: "macOS install media creation exited with not normal code, check the log for details", success: false)
                
            }
        }
    }
    
    //this functrion frees the auth from apis
    private func freeAuth(){
        //free auth is called only when the processes are finished, so let's make them false
        sharedIsPreCreationInProgress = false
        sharedIsCreationInProgress = false
        
        //since into the recovery we do not need the spacial authorization, we just free it when running on a normal mac os environment
        if !sharedIsOnRecovery{
            
            if authRef2 != nil{
            //we no longer need the special authorization, so it is freed
            if AuthorizationFree(authRef2!, authFlags) == 0{
                DispatchQueue.main.async {
                    log("AutorizationFree executed successfully")
                }
            }else{
                DispatchQueue.main.async {
                    log("AutorizationFree failed")
                }
            }
            }
        }
    }
    
    private func goToFinalScreen(title: String, success: Bool){
        //this code opens the final window
        sharedIsPreCreationInProgress = false
        sharedIsCreationInProgress = false
        sharedTitle = title
        sharedIsOk = success
        spinner.isHidden = true
        spinner.stopAnimation(self)
        let _ = self.openSubstituteWindow(windowStoryboardID: "MainDone", sender: self)
    }
    
    private func goBack(){
        //this code opens the previus window
        sharedIsPreCreationInProgress = false
        sharedIsCreationInProgress = false
        spinner.isHidden = true
        spinner.stopAnimation(self)
        let _ = self.openSubstituteWindow(windowStoryboardID: "Confirm", sender: self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        //displays a dialog to check if the user is sure that he/she wants to stop the installer creation
        if !dialogYesNo(question: "Stop the process?", text: "Do you want to abort the Installer cration process?", style: .informational){
            
            //if the user wnat to exit from the installer creation, this function is called and it does stop the createinstallmedia process
            stop()
            
            //now the installer cration is stopped, so we come back to the previous window
            goBack()
        }
    }
    
    //this function gets the pid of the createinstallmedia and then stops it, it does runs sudo using the password stored in memory
    public func stop(){
        //if the installer creation is not in progress, we do not need to stop it
        if !sharedIsCreationInProgress{
            return
        }
        
        //if the installer pre creation is in progress, we don't have to stop createinstallmedia
        if sharedIsPreCreationInProgress{
            return
        }
        
        //get the name of the executable
        let word = sharedExecutableName
        //try to get the pid for the executable
        let cpid = getOut(cmd: "ps -Ac -o pid,comm | awk '/^ *[0-9]+ " + word + "$/ {print $1}'")
        log("createinstllmedia is on pid: " + cpid)
        //checks if the script has returned a pid
        if cpid != ""{
            //this code trys to kill the executable, but it does require sudo on an user environment
            if let out = getOutWithSudo(cmd: "kill " + cpid){
                //just to see if the operation succedes
                if out != "" && out != "Password:"{
                    //kill just failed here
                    log(out)
                }else{
                    //we have finished, so the password is erased
                    erasePassword()
                    
                    //just tell to the rest of the app that the installer creation is no longer running
                    sharedIsCreationInProgress = false
                    
                    //dispose timer, bacause it's no longer needed
                    timer.invalidate()
                    
                    //auth is no longer needed
                    freeAuth()
                }
            }else{
                //if !dialogYesNo(question: "Stop the process?", text: "Do you want to abort the Installer cration process?", style: .informational){
                stop()
                //}else{
                //return
                //}
            }
        }else{
            log("Can't get the pid for " + word + " or " + word + " already killed")
        }
    }
    
    //shows the log window
    @IBAction func showLog(_ sender: Any) {
        /*if let b = sender as? NSButton{
         if logView.isHidden{
         b.title = "Hide log"
         }else{
         b.title = "Show log"
         }
         }
         
         logView.isHidden = !logView.isHidden
         */
        
        if logWindow == nil {
            logWindow = LogWindowController()
        }
        
        logWindow!.showWindow(self)
    }
    
    
    //just to be sure, if the view does disappear the installer creation is stopped
    override func viewWillDisappear() {
        if sharedIsCreationInProgress{
            stop()
        }
    }
    
}
