//
//  ProjectOptions+Extension.swift
//  Packages
//
//  Created by MacPro on 19/06/25.
//

import ProjectDescription

extension Project.Options {
    static let standardOptions: Project.Options = .options(
        automaticSchemesOptions: .disabled,
        disableBundleAccessors: false
    )
}
