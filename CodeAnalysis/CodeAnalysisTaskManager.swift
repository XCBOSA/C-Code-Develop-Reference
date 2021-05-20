//
//  CodeAnalysisTaskManager.swift
//  C Code Develop
//
//  Created by xcbosa on 2021/4/5.
//  Copyright © 2021 xcbosa. All rights reserved.
//

import Foundation

class CodeAnalysisTaskManager {
    
    private var currentCode: String = ""
    var currentCodeLck: Bool = false
    var firstEnd: Bool = false
    private var taskThread: Thread?
    
    public var funcList = [String : String]()
    public var funcDeclareTypeList = [String : String]()
    public var structList = [String]()
    public var typeList = [String : String]()
    public var includeList = [String]()
    public var variableList = [String : String]()
    public var delegate: CodeAnalysisTaskDelegate?
    
    func trim(_ str: String) -> String {
        var strbuf = ""
        for ch in str {
            if ch != "_" {
                strbuf.append(ch.uppercased())
            }
        }
        return strbuf
    }
    
    public func fuzzySearchMap(withMap: [String : String], withLeft: String, writeTo: inout [String]) {
        for (foreachName, _) in withMap {
            if trim(foreachName).contains(trim(withLeft)) {
                writeTo.append(foreachName)
                continue
            } else {
                continue
            }
            var givenPtr = 0, foreachPtr = 0
            var matchLeft = true
            while givenPtr < withLeft.count && foreachPtr < foreachName.count {
                while foreachName[foreachPtr] == "*" {
                    foreachPtr += 1
                    if foreachPtr >= foreachName.count {
                        matchLeft = false
                        break
                    }
                }
                if !matchLeft { break }
                if withLeft[givenPtr].uppercased() != foreachName[foreachPtr].uppercased() {
                    matchLeft = false
                }
                givenPtr += 1
                foreachPtr += 1
            }
            if foreachPtr >= foreachName.count && givenPtr < withLeft.count {
                matchLeft = false
            }
            if matchLeft {
                writeTo.append(foreachName)
            }
        }
    }
    
    public func fuzzySearchList(withList: [String], withLeft: String, writeTo: inout [String]) {
        for foreachName in withList {
            if trim(foreachName).contains(trim(withLeft)) {
                writeTo.append(foreachName)
                continue
            } else {
                continue
            }
            var givenPtr = 0, foreachPtr = 0
            var matchLeft = true
            while givenPtr < withLeft.count && foreachPtr < foreachName.count {
                while foreachName[foreachPtr] == "*" {
                    foreachPtr += 1
                    if foreachPtr >= foreachName.count {
                        matchLeft = false
                        break
                    }
                }
                if !matchLeft { break }
                if withLeft[givenPtr].uppercased() != foreachName[foreachPtr].uppercased() {
                    matchLeft = false
                }
                givenPtr += 1
                foreachPtr += 1
            }
            if foreachPtr >= foreachName.count && givenPtr < withLeft.count {
                matchLeft = false
            }
            if matchLeft {
                writeTo.append(foreachName)
            }
        }
    }
    
    func trans(_ string: [String], _ withColor: UIColor, _ withType: CodeTipItemType) -> [CodeTipItem] {
        var list = [CodeTipItem]()
        for it in string {
            list.append(CodeTipItem(withColor, it, withType))
        }
        return list
    }
    
    public func fuzzySearchAll(withLeft: String) -> [CodeTipItem] {
        var matchList = [String]()
        var resultList = [CodeTipItem]()
        let colorTable = CLangColorTable.getColorTable()
        fuzzySearchMap(withMap: funcList, withLeft: withLeft, writeTo: &matchList)
        resultList.append(contentsOf: trans(matchList, colorTable.getMethodContentColor(), .Function))
        matchList.removeAll()
        fuzzySearchMap(withMap: typeList, withLeft: withLeft, writeTo: &matchList)
        resultList.append(contentsOf: trans(matchList, colorTable.getTypeContentColor(), .Type))
        matchList.removeAll()
        fuzzySearchMap(withMap: variableList, withLeft: withLeft, writeTo: &matchList)
        resultList.append(contentsOf: trans(matchList, colorTable.getUserDefinedContentColor(), .Variable))
        matchList.removeAll()
        fuzzySearchList(withList: structList, withLeft: withLeft, writeTo: &matchList)
        resultList.append(contentsOf: trans(matchList, colorTable.getStructContentColor(), .Struct))
        matchList.removeAll()
        fuzzySearchList(withList: [
            "break", "case", "char", "continue", "default", "do", "double", "else", "extern", "false", "FALSE", "float", "for", "goto", "if", "int", "long", "register", "const", "return", "short", "signed", "sizeof", "struct", "null", "static", "switch", "true", "TRUE", "typedef", "unsigned", "void", "while", "include"
        ], withLeft: withLeft, writeTo: &matchList)
        resultList.append(contentsOf: trans(matchList, colorTable.getKeywordColor(), .Keyword))
        matchList.removeAll()
        resultList.sort(by: {
            (lhs, rhs) in
            return (lhs.text.count - withLeft.count) < (rhs.text.count - withLeft.count)
        })
        return resultList
    }
    
    public func getTypeRegex() -> String? {
        let strbgn = "(?:\n|\\s|\\()(?:";
        let strend = ")(?=\\W|$)"
        if typeList.isEmpty { return nil }
        var regex = strbgn
        for (type, _) in typeList {
            for ch in type {
                if ch.isLetter || ch.isNumber || ch == "_" {
                    regex.append(ch)
                }
            }
            regex.append("|")
        }
        regex.removeLast()
        regex.append(strend)
        return regex
    }
    
    public func getStructRegex() -> String? {
        let strbgn = "(?:\n|\\s|\\()(?:";
        let strend = ")(?=\\W|$)"
        if structList.isEmpty { return nil }
        var regex = strbgn
        for type in structList {
            //regex.append("struct\\s")
            for ch in type {
                if ch.isLetter || ch.isNumber || ch == "_" {
                    regex.append(ch)
                }
                if ch == " " {
                    regex.append("\\s")
                }
            }
            regex.append("|")
        }
        regex.removeLast()
        regex.append(strend)
        return regex
    }
    
    public func getFuncRegex() -> String? {
        let strbgn = "(?:\n|\\s|\\()(?:";
        let strend = ")(?=\\W|$)"
        if funcList.isEmpty { return nil }
        var regex = strbgn
        for (_func, _) in funcList {
            for ch in _func {
                if ch.isLetter || ch.isNumber || ch == "_" {
                    regex.append(ch)
                }
            }
            regex.append("|")
        }
        regex.removeLast()
        regex.append(strend)
        return regex
    }
    
    public var code: String {
        get {
            return currentCode
        }
        set (val) {
            while currentCodeLck { sleep(0) }
            currentCodeLck = true
            currentCode = val
            currentCodeLck = false
        }
    }
    
    public var fileName = ""
    
    init(_ code: String, _ fileName: String, _ requireFirstLoad: Bool, _ delegate: CodeAnalysisTaskDelegate?) {
        self.code = code
        self.fileName = fileName
        self.delegate = delegate
        taskThread = Thread(target: self, selector: #selector(taskFunc), object: nil)
        taskThread!.start()
        if requireFirstLoad {
            while !firstEnd { sleep(0) }
        }
    }
    
    func stop() {
        taskThread!.cancel()
    }
    
    @objc func taskFunc() {
        while !taskThread!.isCancelled {
            let engine = CodeAnalysisEngine()
            engine.analysis(code, fileName, delegate)
            funcList = engine.funcList
            structList = engine.structList
            for it in 0..<structList.count {
                structList[it] = "struct \(structList[it])"
            }
            typeList = engine.typeList
            includeList = engine.includeList
            variableList = engine.variableList
            funcDeclareTypeList = engine.funcDeclareTypeList
            firstEnd = true
            usleep(200000)
        }
    }
    
}
