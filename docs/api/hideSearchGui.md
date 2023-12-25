---
title: hideSearchGui
author: AkiChase
order: 1
date: 2023-04-15
---

## 定义

```ahk
static hideSearchGui(recordHideTime:=false)
```

## 类型

静态方法

## 说明

隐藏搜索框。

如果 recordHideTime 值为 true，则会记录隐藏时间，15s内按**呼出搜索框**快捷键可恢复窗口。

## 参数

- ### recordHideTime \{Bool\}

默认为 `false`。如果设置为 `true`，则会记录隐藏时间，15s内按**呼出搜索框**快捷键可恢复搜索框内容。