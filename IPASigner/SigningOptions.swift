//
//  SigningOptions.swift
//  IPASigner
//
//  Created by SWING on 2022/5/20.
//

import Foundation

struct SigningOptions {
    
    var ipaPath: String = ""
    var certURL: String = ""
    var profileURL: String = ""
    var appBundleId: String = ""
    var appDisplayName: String = ""
    var appVersion: String = ""
    var appMinimumiOSVersion: String = ""
    var ignorePluglnsfolder = false
    var ignoreWatch = true
    
    var app: ALTApplication?
    var signingCert: ALTCertificate?
    var signingProfile: ALTProvisioningProfile?
    
}
