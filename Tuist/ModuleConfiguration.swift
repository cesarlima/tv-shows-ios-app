//
//  ModuleConfiguration.swift
//  Packages
//
//  Created by MacPro on 19/06/25.
//

import Foundation

struct ModuleConfiguration {
    let name: String
    let bundleId: String
    let organizationName: String
    
    var interfaceName: String { "\(name)Interface" }
    var testingName: String { "\(name)Testing" }
    var testsName: String { "\(name)Tests" }
    
    var moduleBundleId: String { "\(bundleId).\(name)" }
    var interfaceBundleId: String { "\(bundleId).\(interfaceName)" }
    var testingBundleId: String { "\(bundleId).\(testingName)" }
    var testsBundleId: String { "\(bundleId).\(testsName)" }
    
    init(name: String,
         bundleId: String = "br.com.cesarlima",
         organizationName: String = "Cesar Lima Consulting") {
        self.name = name
        self.bundleId = bundleId
        self.organizationName = organizationName
    }
}
