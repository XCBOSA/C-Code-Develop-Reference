# Code Analyzer
This is the code analyzer implement of C Code Develop App.

## CodeAnalysisEngine.swift
对于每一个文件都包含一个分析器实例，存储了所有读取出的文件信息。同时，在include时递归的对所有包含的文件创建分析器实例。

## CodeAnalysisReader.swift
提供对源码的流式访问。（Helloworld词法分析器？）

## CodeAnalysisTaskDelegate.swift
委托，用于处理文件读写。需要实现一个给定文件名后的文件读写方法。

## CodeAnalysisTaskManager.swift
Helloworld代码分析任务调度器（通过分析用户输入的字符来获取提示列表）

## CodeFormatTool.swift
我称之为[最短的代码格式化实现]。不过并不是分析代码格式化的，但是也处理了字符串等不应该格式化的场景。

## CodePartAnalysis.swift
入口点，一看定义就懂了
`func analysisCurrent(_ code: String, _ cursor: Int, _ task: CodeAnalysisTaskManager) -> [CodeTipItem]`
