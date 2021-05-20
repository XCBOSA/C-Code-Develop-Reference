//
//  CodeAnalysisEngine.swift
//  C Code Develop
//
//  Created by xcbosa on 2021/4/1.
//  Copyright © 2021 xcbosa. All rights reserved.
//

import Foundation

class CodeAnalysisEngine {
    
    public var funcList = [String : String]()
    public var funcDeclareTypeList = [String : String]()
    public var structList = [String]()
    public var typeList = [String : String]()
    public var includeList = [String]()
    public var variableList = [String : String]()
    
    func combine(_ engine: CodeAnalysisEngine) {
        for (funcName, funcArgs) in engine.funcList {
            funcList[funcName] = funcArgs
        }
        for stu in engine.structList {
            if !structList.contains(stu) {
                structList.append(stu)
            }
        }
        for (type, typeImpl) in engine.typeList {
            typeList[type] = typeImpl
        }
        for (vari, variType) in engine.variableList {
            variableList[vari] = variType
        }
        for (funcName, funcType) in engine.funcDeclareTypeList {
            funcDeclareTypeList[funcName] = funcType
        }
    }
    
    func analysis_atype(_ stream: CodeAnalysisReader) -> String {
        var firstToken = stream.nextToken()
        let longTypeToken = ["unsigned", "register", "static", "export", "struct", "const"]
        if firstToken == "struct" {
            var isStructImpl = false
            var structName = ""
            analysis_struct(stream, isStructImplement: &isStructImpl, structName: &structName)
            if isStructImpl {
                return "Struct Implemention"
            } else {
                firstToken += " "
                firstToken += structName
            }
        }
        var typeName = firstToken
        if longTypeToken.contains(firstToken) {
            while true {
                let nextToken = stream.nextToken()
                if typeName != "" { typeName.append(" ") }
                typeName.append(nextToken)
                if !longTypeToken.contains(nextToken) {
                    break
                }
            }
        }
        return typeName
    }
    
    func analysis_struct(_ stream: CodeAnalysisReader, isStructImplement: inout Bool, structName: inout String) {
        let nameToken = stream.nextToken()
        stream.nextEmpty()
        if stream.peek() == "{" {
            structList.append(nameToken)
            _ = stream.nextTo(includeInStringCharacter: "}")
            isStructImplement = true
        } else {
            isStructImplement = false
        }
        structName = nameToken
    }
    
    func analysis_typedef(_ stream: CodeAnalysisReader) {
        let type = analysis_atype(stream)
        let typeName = stream.nextToken()
        typeList[typeName] = type
        let endTokens = stream.nextTo(includeInStringCharacter: ";")
        let reader = CodeAnalysisReader(endTokens)
        reader.nextEmpty()
        while !reader.eof() {
            let tokenVariable = reader.nextToken()
            variableList[tokenVariable] = typeName
            if reader.nextOperator() != "," { break }
        }
    }
    
    func analysis_outQuoteStatement(_ stream: CodeAnalysisReader) {
        stream.setBackup()
        let firstToken = stream.nextToken()
        if firstToken == "typedef" {
            analysis_typedef(stream)
        } else {
            stream.resumeBackup()
            let type = analysis_atype(stream)
            let name = stream.nextToken()
            let op = stream.nextSingleOperator()
            // print(op)
            switch op {
            case "(":
                // funcdef
                let args = stream.nextTo(includeInStringCharacter: ")")
                funcList[name] = args
                funcDeclareTypeList[name] = type
                _ = stream.nextOperator()
                break
            case ",":
                // continue variable define
                variableList[name] = type
                let leftRemind = stream.nextTo(includeInStringCharacter: "=;")
                let leftStream = CodeAnalysisReader(leftRemind)
                while !leftStream.eof() {
                    let tokenVariable = leftStream.nextToken()
                    variableList[tokenVariable] = type
                    if leftStream.nextOperator() != "," { break }
                }
                _ = stream.nextTo(includeInStringCharacter: ";")
                break
            case "=":
                // end variable define
                _ = stream.nextTo(includeInStringCharacter: ";")
                break
            case ";":
                // end variable define
                variableList[name] = type
                break
            default:
                _ = stream.nextTo(includeInStringCharacter: ";")
                break
            }
        }
    }
    
    func analysis_importBuiltin() {
        typeList["int"] = "builtin"
        typeList["void"] = "builtin"
        typeList["char"] = "builtin"
        typeList["long"] = "builtin"
        typeList["short"] = "builtin"
        typeList["float"] = "builtin"
        typeList["double"] = "builtin"
    }
    
    func analysis(_ code: String, _ fileName: String, _ delegate: CodeAnalysisTaskDelegate?) {
        var includedSet = [String]()
        analysis(code, fileName, delegate, &includedSet)
    }
    
    func analysis(_ code: String, _ fileName: String, _ delegate: CodeAnalysisTaskDelegate?, _ includedSet: inout [String]) {
        //analysis_importBuiltin()
        let test = CodeAnalysisReader(code)
        test.focusDeep0 = true
        var str = ""
        while !test.eof() {
            str.append(test.next())
        }
        let stream = CodeAnalysisReader(str)
        while !stream.eof() {
            stream.setBackup()
            let firstChar = stream.nextOperator()
            if firstChar == "#" {
                if stream.nextToken() == "include" {
                    let includeOp = stream.nextOperator()
                    if includeOp == "<" || includeOp == "\"" {
                        includeList.append(stream.nextTo(includeInStringCharacter: "\">"))
                    }
                } else {
                    _ = stream.nextTo(includeInStringCharacter: "\n")
                }
            }
            else {
                stream.resumeBackup()
                analysis_outQuoteStatement(stream)
            }
        }
        includedSet.append(fileName)
        if let delg = delegate {
            for incl in includeList {
                if !includedSet.contains(incl) {
                    let eng = CodeAnalysisEngine()
                    eng.analysis(delg.codeAnalysisTaskRequireCode(includeFile: incl), incl, delegate, &includedSet)
                    combine(eng)
                }
            }
        }
    }
    
}
