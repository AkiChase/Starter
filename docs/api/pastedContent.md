---
title: pastedContent
author: ruchuby
date: 2023-04-15
---

## 定义

```ahk
static pastedContent => SearchGui._pastedContent
```

## 类型

动态属性 \{(Array|Int|String)\}

## 说明

返回**当前搜索框**粘贴的内容，或者按下**智能搜索框**时选中的内容。

根据[pastedContentType](./pastedContentType.md)的不同，可返回文件路径数组，位图句柄hBitmap、字符串。


## 返回值 \{(Array|Int|String)\}

根据[pastedContentType](./pastedContentType.md)的不同，可返回文件路径数组，hBitmap、字符串。