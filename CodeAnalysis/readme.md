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

## 简单的最外侧分析规则：
C中任何在最外侧的定义只有一种格式：  
Assign `<Type> <ValueName> [,ValueName2, ValueName3...] [=InitalValue];`  
其中的Type可以是已经存在的Type，或者是struct Structure引导的临时Type，或者是当前用typedef定义的type。  
返回Type的语句有：  
TypeDef `typedef <ExistType> <TypeAlias>`  
Struct `struct <StructMetadata>`  
  返回StructMetadata的语句有：  
  -- StructImplemention `[StructName] { Some Code }`  
  -- ExistStruct `<ExistStructName>`  
比如处理：  
```
typedef struct {
   xxx
} MyType myTypeInstance;
```
先按照Assign处理，碰到typedef递归的交给TypeDef处理，TypeDef碰到struct递归的交给Struct处理，退出两层递归后返回Assign，此时Assign处理<ValueName>，下标在myTypeInstance处...  
```
Assign <TypeDef <struct { xxx }> <MyType>> <myTypeInstance> [=None];
```
