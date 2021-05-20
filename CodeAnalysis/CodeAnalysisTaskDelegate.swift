//
//  CodeAnalysisTaskDelegate.swift
//  C Code Develop
//
//  Created by xcbosa on 2021/4/5.
//  Copyright © 2021 xcbosa. All rights reserved.
//

import Foundation

protocol CodeAnalysisTaskDelegate {
    
    func codeAnalysisTaskRequireCode(includeFile: String!) -> String
    
}
