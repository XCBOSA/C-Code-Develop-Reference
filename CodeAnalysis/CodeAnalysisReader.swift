//
//  CodeAnalysisReader.swift
//  C Code Develop
//
//  Created by xcbosa on 2021/4/1.
//  Copyright © 2021 xcbosa. All rights reserved.
//

import Foundation

class CodeAnalysisReader {
    
    let ceof: Character = "\0"
    
    var chars: [Character]
    var ptr: Int = 0
    
    var inStr: Bool = false
    var inStrTrans: Bool = false
    var bigQuoteDeep: Int = 0
    var inCommet: Bool = false
    var commetTypeSingleLine: Bool = false
    
    var focusDeep0: Bool = false
    
    var backup: Int = 0
    
    init(_ code: String) {
        chars = Array<Character>(code)
        ptr = 0
    }
    
    /**
     * 查看下一个字符
     */
    public func peek() -> Character {
        if (ptr < 0 || ptr >= chars.count) {
            return "\0"
        }
        return chars[ptr]
    }
    
    public func next() -> Character {
        if focusDeep0 {
            while true {
                let ch = nextAny()
                if ch == "\0" {
                    return "\0"
                }
                if (bigQuoteDeep == 0) || (bigQuoteDeep == 1 && !inStr && !inCommet && ch == "{") {
                    return ch
                }
            }
        } else {
            return nextAny()
        }
    }
    
    /**
     * 查看下一个字符并提高一个位置
     */
    public func nextAny() -> Character {
        let ch = peek()
        
        if ch == "/" {
            ptr -= 1
            let last = peek()
            if last == "/" {
                inCommet = true
                commetTypeSingleLine = true
            }
            ptr += 1
        }
        
        if ch == "*" {
            ptr -= 1
            let last = peek()
            if last == "/" {
                inCommet = true
                commetTypeSingleLine = false
            }
            ptr += 1
        }
        
        if ch == "/" {
            ptr -= 1
            let last = peek()
            if last == "*" {
                inCommet = false
                commetTypeSingleLine = false
            }
            ptr += 1
        }
        
        if ch == "\n" {
            if inCommet && commetTypeSingleLine {
                inCommet = false
            }
        }
        
        if ch == "\0" {
            inCommet = false
        }
        
        if !inCommet {
            if inStrTrans {
                inStrTrans = false
            }
            else if ch == "\"" && !inStrTrans {
                inStr = !inStr
            }
            else if ch == "\\" && !inStrTrans {
                inStrTrans = true
            }
            if (!inStr) {
                if (ch == "{") { bigQuoteDeep += 1 }
                if (ch == "}") { bigQuoteDeep -= 1 }
            }
        }
        
        ptr += 1
        return ch
    }
    
    /**
     * 查看下一个Token并提高一个位置
     */
    public func nextToken() -> String {
        var chars = ""
        nextEmpty()
        while true {
            let char = next()
            if char.isNumber || char.isLetter || char == "*" || char == "_" {
                if char == "\0" {
                    return chars
                }
                chars.append(char)
            } else {
                ptr -= 1
                break
            }
        }
        return chars
    }
    
    public func nextOperator() -> String {
        var chars = ""
        let ops = "~!@#$%^&*()_-+={[}]|\\:;'<,>.?/'\""
        nextEmpty()
        while true {
            let char = next()
            if ops.contains(char) {
                if char == "\0" {
                    return chars
                }
                chars.append(char)
            } else {
                ptr -= 1
                break
            }
        }
        return chars
    }
    
    public func nextSingleOperator() -> String {
        let ops = "~!@#$%^&*()_-+={[}]|\\:;'<,>.?/'\""
        nextEmpty()
        let char = next()
        if ops.contains(char) {
            return char.description
        } else {
            return ""
        }
    }
    
    public func nextTo(includeInStringCharacter: String) -> String {
        var chars = ""
        nextEmpty()
        while true {
            let char = next()
            if (inCommet) {
                continue
            }
            if !includeInStringCharacter.contains(char) {
                if char == "\0" {
                    return chars
                }
                chars.append(char)
            } else {
                break
            }
        }
        return chars
    }
    
    @inlinable public func nextCommet() {
        _ = next()
        _ = next()
        ptr -= 2
        while inCommet {
            _ = next()
        }
    }
    
    @inlinable public func nextEmpty() {
        nextCommet()
        while true {
            let ch = next()
            if !" \t\n".contains(ch) {
                ptr -= 1
                break
            }
        }
        nextCommet()
    }
    
    public func peekToken() -> String {
        setBackup()
        let str = nextToken()
        resumeBackup()
        return str
    }
    
    public func last() -> Character {
        ptr -= 1
        return peek()
    }
    
    public func lastTo(_ ch: Character) -> String? {
        var chs = Stack<Character>()
        while peek() != ch {
            if peek() == "\0" { return nil }
            chs.push(peek())
            ptr -= 1
        }
        var str = ""
        while !chs.isEmpty {
            str.append(chs.pop()!)
        }
        return str
    }
    
    public func lastTo(_ ch: Character, explicitTo: [Character]) -> String? {
        var chs = Stack<Character>()
        while peek() != ch {
            if peek() == "\0" { return nil }
            if explicitTo.contains(peek()) {
                return nil
            }
            chs.push(peek())
            ptr -= 1
        }
        var str = ""
        while !chs.isEmpty {
            str.append(chs.pop()!)
        }
        return str
    }
    
    public func setBackup() {
        backup = ptr
    }
    
    public func resumeBackup() {
        ptr = backup
    }
    
    public func eof() -> Bool {
        return peek() == "\0"
    }
    
    public func realPtr() -> Int {
        if ptr < 0 {
            return 0
        }
        if ptr >= chars.count {
            return chars.count - 1
        }
        return ptr
    }
    
}
