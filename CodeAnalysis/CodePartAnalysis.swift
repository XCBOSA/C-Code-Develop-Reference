//
//  CodePartAnalysis.swift
//  C Code Develop
//
//  Created by xcbosa on 2021/4/5.
//  Copyright © 2021 xcbosa. All rights reserved.
//

import Foundation

func analysisCurrent(_ code: String, _ cursor: Int, _ task: CodeAnalysisTaskManager) -> [CodeTipItem] {
    let stream = CodeAnalysisReader(code)
    stream.ptr = cursor
    var stack = Stack<Character>()
    while !stream.eof() {
        let ch = stream.last()
        if ch.isNumber || ch.isLetter || ch == "_" {
            stack.push(ch)
        } else {
            break
        }
    }
    let alreadyInput = Stack<Any>.toString(&stack)
    if alreadyInput.count == 0 {
        return []
    }
    let matches = task.fuzzySearchAll(withLeft: alreadyInput)
    return matches
}
