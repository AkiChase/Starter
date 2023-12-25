---
title: addEntryFunc
author: AkiChase
order: 1
date: 2023-04-14
---
## 定义

```ahk
static PluginHelper.addEntryFunc(f)
```

## 类型

静态方法

## 说明

添加插件入口函数到执行队列，等待基本功能初始化后，函数将被执行

## 参数

- ### f \{[Closure](https://orz707.gitee.io/v2/docs/Functions.htm#closures)\}

```ahk
(*) => Any
```

插件**入口函数**，也可以称为插件的**初始化函数**