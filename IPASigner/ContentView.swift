//
//  ContentView.swift
//  IPASigner
//
//  Created by SWING on 2522/5/18.
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var signingOptions: SigningOptions = SigningOptions()
    
    @State private var showingAlert = false
    @State private var alertTitle: String = "提示"
    @State private var alertMessage: String = ""
    @State private var stateString = ""
    
    let fileManager = FileManager.default
    let bundleID = Bundle.main.bundleIdentifier
    let mktempPath = "/usr/bin/mktemp"
    let tarPath = "/usr/bin/tar"
    let unzipPath = "/usr/bin/unzip"
    let zipPath = "/usr/bin/zip"
    
    enum ImportResourceType {
        case Cert
        case Profile
        case IPA
    }

    var body: some View {
        DispatchQueue.main.async {
            if let p12Data = AppDefaults.shared.signingCertificate {
                self.signingOptions.signingCert = ALTCertificate.init(p12Data: p12Data, password: AppDefaults.shared.signingCertificatePassword)
                self.signingOptions.certURL = self.signingOptions.signingCert == nil ? "" : self.signingOptions.signingCert!.name
            }
            if let profileData = AppDefaults.shared.signingProvisioningProfile {
                self.signingOptions.signingProfile = ALTProvisioningProfile.init(data: profileData)
                self.signingOptions.profileURL = self.signingOptions.signingProfile == nil ? "" : self.signingOptions.signingProfile!.name
            }
        }
        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("IPA File：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "IPA File path",
                    text: $signingOptions.ipaPath
                )
                .frame(width: 500, height: 30, alignment: .center)
                
                Button {
                    doBrowse(resourceType: .IPA)
                } label: {
                    Text("导入")
                }
                .foregroundColor(.blue)
                .frame(width: 80, height: 30, alignment: .center)
            }.padding(.top, 20)
            
            HStack {
                Text("Signing Certificate：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "Certificate File path",
                    text: $signingOptions.certURL
                )
                .frame(width: 500, height: 30, alignment: .center)
                
                Button {
                    doBrowse(resourceType: .Cert)
                } label: {
                    Text("导入")
                }
                .foregroundColor(.blue)
                .frame(width: 80, height: 30, alignment: .center)
            }
            
            HStack {
                Text("Provisioning Profile：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "ProvisioningProfile File path",
                    text: $signingOptions.profileURL
                )
                .frame(width: 500, height: 30, alignment: .center)
                
                Button {
                    doBrowse(resourceType: .Profile)
                } label: {
                    Text("导入")
                }
                .foregroundColor(.blue)
                .frame(width: 80, height: 30, alignment: .center)
            }
            
            HStack {
                Text("App Display Name：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app title on the home screen",
                    text: $signingOptions.appDisplayName
                )
                .frame(width: 500, height: 30, alignment: .center)
            }
            
            HStack {
                Text("App Bundle ID：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app bundle identifier",
                    text: $signingOptions.appBundleId
                )
                .frame(width: 500, height: 30, alignment: .center)
                
            }
            
            HStack {
                Text("App Version：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app version number",
                    text: $signingOptions.appVersion
                )
                .frame(width: 400, height: 30, alignment: .center)
                
                
                Toggle(isOn: $signingOptions.ignorePluglnsfolder) {
                    Text("Ignore Pluglns folder")
                }
                
            }
            
            HStack {
                Text("Minimum iOS Version：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app minimum iOS version",
                    text: $signingOptions.appMinimumiOSVersion
                )
                .frame(width: 400, height: 30, alignment: .center)
                
                Toggle(isOn: $signingOptions.ignoreWatch) {
                    Text("Ignore Watch")
                }
            }
            
            HStack {
                Text("Signing State：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                
                Text(stateString)
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 500, height: 40)
                
                Button {
                    startSigning()
                } label: {
                    Text("签名")
                }
                .foregroundColor(.blue)
                .frame(width: 80, height: 30, alignment: .center)
            }
            
        }
        .frame(width:750, height: 400, alignment: .top)
        .alert(isPresented: $showingAlert) {
            getAlert()
        }        
    }
    
    func validate(name: String) {
//        if let p12Data = AppDefaults.shared.signingCertificate, let password = AppDefaults.shared.signingCertificatePassword {
//            self.cert = ALTCertificate.init(p12Data: p12Data, password: password)
//        }
    }
    
    func getAlert() -> Alert {
        return Alert(title: Text(alertTitle),
                     message: Text(alertMessage),
                     dismissButton: .default(Text("OK")))
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    
    func doBrowse(resourceType: ImportResourceType) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let url = panel.urls.first {
                    print("选择的File：\(url.absoluteString)")
                    switch resourceType {
                    case .Cert:
                        if url.pathExtension.lowercased() == "p12" {
                            if let data: Data = NSData.init(contentsOf: url) as Data? {
                                if let inputCert = ALTCertificate.init(p12Data: data, password: "123") {
                                    AppDefaults.shared.reset()
                                    self.signingOptions.signingProfile = nil
                                    self.signingOptions.signingCert = inputCert
                                    self.signingOptions.certURL = inputCert.name
                                    self.signingOptions.profileURL = ""
                                    AppDefaults.shared.signingCertificate = data
                                    AppDefaults.shared.signingCertificatePassword = "123"
                                    AppDefaults.shared.signingCertificateName = inputCert.name
                                    AppDefaults.shared.signingCertificateSerialNumber = inputCert.serialNumber
                                } else {
                                    self.alertMessage = "证书无效或密码错误"
                                    self.showingAlert = true
                                }
                            } else {
                                self.alertMessage = "证书无效"
                                self.showingAlert = true
                            }
                        } else {
                            self.alertMessage = "请选择p12"
                            self.showingAlert = true
                        }
                        
                    case .Profile:
                        if url.pathExtension.lowercased() == "mobileprovision" {
                            if let cert = self.signingOptions.signingCert {
                                if let inputProfile = ALTProvisioningProfile.init(url: url) {
                                    var matched = false
                                    for profileCertificate in inputProfile.certificates {
                                        if cert.serialNumber == profileCertificate.serialNumber {
                                            matched = true
                                        }
                                    }
                                    if matched {
                                        self.signingOptions.signingProfile = inputProfile
                                        AppDefaults.shared.signingProvisioningProfile = inputProfile.data
                                        self.signingOptions.profileURL = inputProfile.name
                                    } else {
                                        self.alertMessage = "所导入的mobileprovision和p12证书不匹配"
                                        self.showingAlert = true
                                    }
                                } else {
                                    self.alertMessage = "所导入的mobileprovision无效"
                                    self.showingAlert = true
                                }
                            } else {
                                self.alertMessage = "请先导入p12证书再导入mobileprovision"
                                self.showingAlert = true
                            }
                          
                        } else {
                            self.alertMessage = "请选择mobileprovision"
                            self.showingAlert = true
                        }
                    case .IPA:
                        if url.pathExtension.lowercased() == "ipa" {
                            self.signingOptions.ipaPath = url.path
                            self.unzipIPA(self.signingOptions.ipaPath)
                        } else if url.pathExtension.lowercased() == "app" {
                            
                        } else {
                            self.alertMessage = "请选择ipa或者app"
                            self.showingAlert = true
                        }
                    }
                }
            }
        }
    }
    
    func unzipIPA(_ inputFile: String) {
        //MARK: Create working temp folder
        var tempFolder: String! = nil
        if let tmpFolder = makeTempFolder() {
            tempFolder = tmpFolder
        } else {
            return
        }
        let workingDirectory = tempFolder.stringByAppendingPathComponent("out")
        let payloadDirectory = workingDirectory.stringByAppendingPathComponent("Payload/")
        
        do {
            let appBundleURL = try fileManager.unzipAppBundle(at: URL.init(fileURLWithPath: inputFile), toDirectory: URL.init(fileURLWithPath: payloadDirectory))
            setStatus("Extracting ipa file: \(appBundleURL.absoluteString)")
            if let application = ALTApplication.init(fileURL: appBundleURL) {
                self.signingOptions.app = application
                self.signingOptions.appVersion = application.version
                self.signingOptions.appDisplayName = application.name
                self.signingOptions.appBundleId = application.bundleIdentifier
                self.signingOptions.appMinimumiOSVersion = application.minimumiOSVersion.stringValue
            } else {
                setStatus("Invalid ipa file")
                cleanup(tempFolder); return
            }
            self.signingOptions.app = ALTApplication.init(fileURL: appBundleURL)
            
        } catch {
            setStatus("Error extracting ipa file")
            cleanup(tempFolder); return
        }
        
        //        do {
        //            try fileManager.createDirectory(atPath: workingDirectory, withIntermediateDirectories: true, attributes: nil)
        //            setStatus("Extracting ipa file: \(workingDirectory)")
        //            let unzipTask = self.unzip(inputFile, outputPath: workingDirectory)
        //            if unzipTask.status != 0 {
        //                setStatus("Error extracting ipa file")
        //                cleanup(tempFolder); return
        //            }
        //        } catch {
        //            setStatus("Error extracting ipa file")
        //            cleanup(tempFolder); return
        //        }
    }
    
    func startSigning() {
        if let app = self.signingOptions.app, let cert = self.signingOptions.signingCert, let profile = self.signingOptions.signingProfile {
            AppSigner().signApp(withAplication: app, certificate: cert, provisioningProfile: profile) { log in
                self.setStatus(log)
            } completionHandler: { success, error, ipaURL in
                if success {
                    self.setStatus("签名成功：\(ipaURL?.absoluteString)")
                } else {
                    self.setStatus("签名失败：\(error.debugDescription)")
                }
            }
        } else {
            if self.signingOptions.app == nil {
                self.alertMessage = "请导入IPA"
                self.showingAlert = true
            } else if self.signingOptions.signingCert == nil {
                self.alertMessage = "请导入签名证书"
                self.showingAlert = true
            } else if self.signingOptions.signingProfile == nil {
                self.alertMessage = "请导入描述文件"
                self.showingAlert = true
            }
                        
        }
    }
    
    
    func makeTempFolder() -> String? {
        let tempTask = Process().execute(mktempPath, workingDirectory: nil, arguments: ["-d", "-t", bundleID!])
        if tempTask.status != 0 {
            return nil
        }
        return tempTask.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func unzip(_ inputFile: String, outputPath: String) -> AppSignerTaskOutput {
        return Process().execute(unzipPath, workingDirectory: nil, arguments: ["-q", inputFile, "-d", outputPath])
    }
    
    func zip(_ inputPath: String, outputFile: String) -> AppSignerTaskOutput {
        return Process().execute(zipPath, workingDirectory: inputPath, arguments: ["-qry", outputFile, "."])
    }
    
    func cleanup(_ tempFolder: String){
        do {
            Log.write("Deleting: \(tempFolder)")
            try fileManager.removeItem(atPath: tempFolder)
        } catch let error as NSError {
            setStatus("Unable to delete temp folder")
            Log.write(error.localizedDescription)
        }
    }
        
    func setStatus(_ status: String){
        stateString = status
        Log.write(status)
    }
  
}


