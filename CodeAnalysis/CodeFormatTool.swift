//
//  CodeFormatTool.swift
//  C Code Develop
//
//  Created by xcbosa on 2021/4/23.
//  Copyright © 2021 xcbosa. All rights reserved.
//

import Foundation

func formatCode(withSourceCode code: String, selectLocation: Int) -> (String, Int) {
    let stream = CodeAnalysisReader(code)
    //            SYM L/RSPACE IF(L/RCHAR=KEY)->SPACE=VALUE
    let lspace : [Character : (Int, [Character : Int])]
        =        ["=" : (1, ["^" : 0, "+" : 0, "|" : 0, "&" : 0, "~" : 0, "-" : 0, "=" : 0, "*" : 0, "/" : 0, ">" : 0, "<" : 0, "!": 0]),
                  "+" : (1, ["+" : 0]),
                  "-" : (1, ["-" : 0]),
                  "%" : (1, [:]),
                  ">" : (1, [">" : 0, "-" : 0]),
                  "<" : (1, ["<" : 0]),
                  "?" : (1, [:]),
                  "^" : (1, [:])]
    let rspace : [Character : (Int, [Character : Int])]
        =        ["=" : (1, ["=" : 0]),
                  "+" : (1, ["+" : 0, "=" : 0, ";" : 0, "," : 0]),
                  "-" : (1, ["-" : 0, "=" : 0, ";" : 0, "," : 0, ">" : 0]),
                  "%" : (1, ["=" : 0]),
                  ">" : (1, [">" : 0, "=" : 0]),
                  "<" : (1, ["<" : 0, "=" : 0]),
                  "," : (1, [:]),
                  "?" : (1, [:]),
                  "^" : (1, ["=" : 0]),
                  ";" : (1, ["\n" : 0]),
                  ")" : (1, [")" : 0, ";" : 0, "[" : 0])]
    var destCode = "", cursorChange = 0, lastChar = Character("\0")
    var deep = 0
    while !stream.eof() {
        let ch = stream.nextAny()
        if ch == "{" { deep += 1 }
        if ch == "}" { deep -= 1 }
        var noAppend = false
        if ch == "\n" {
            destCode.append("\n")
            if deep < 0 { continue }
            while " \t".contains(stream.nextAny()) {
                if stream.ptr <= selectLocation { cursorChange -= 1 }
            }
            stream.ptr -= 1
            var usedeep = deep
            if stream.nextAny() == "}" {
                usedeep -= 1
            }
            stream.ptr -= 1
            if usedeep < 0 { continue }
            for _ in 0..<usedeep {
                destCode.append("\t")
                if stream.ptr <= selectLocation { cursorChange += 1 }
            }
            continue
        }
        if stream.inStr || stream.inCommet || stream.bigQuoteDeep == 0 {
            destCode.append(ch)
            lastChar = ch
            continue
        }
        if let (lspace, exceptLastCharDict) = lspace[ch] {
            if lspace > 0 && lastChar != " " {
                if let nowChar = exceptLastCharDict[lastChar] {
                    if nowChar > 0 {
                        destCode.append(" ")
                        if stream.ptr <= selectLocation { cursorChange += 1 }
                    }
                } else {
                    var performAdd = true
                    if ch == "+" {
                        if stream.nextAny() == "+" { performAdd = false }
                        stream.ptr -= 1
                    }
                    if ch == "-" {
                        if stream.nextAny() == "-" { performAdd = false }
                        stream.ptr -= 1
                    }
                    if performAdd {
                        destCode.append(" ")
                        if stream.ptr <= selectLocation { cursorChange += 1 }
                    }
                }
            }
        }
        if let (rspace, exceptLastCharDict) = rspace[ch] {
            let nextChar = stream.nextAny()
            stream.ptr -= 1
            if rspace > 0 && nextChar != " " {
                if let nowChar = exceptLastCharDict[nextChar] {
                    if nowChar > 0 {
                        destCode.append(ch)
                        destCode.append(" ")
                        noAppend = true
                        if stream.ptr <= selectLocation { cursorChange += 1 }
                    }
                } else {
                    if (ch == "+" && lastChar == "+") || (ch == "-" && lastChar == "-") {
                        
                    } else {
                        destCode.append(ch)
                        destCode.append(" ")
                        noAppend = true
                        if stream.ptr <= selectLocation { cursorChange += 1 }
                    }
                }
            }
        }
        if !noAppend {
            destCode.append(ch)
        }
        lastChar = ch
    }
    return (destCode, cursorChange)
}
