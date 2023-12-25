---
title: pastedContentType
author: AkiChase
order: 1
date: 2023-04-15
---

## 定义

```ahk
static pastedContentType => SearchGui._pastedContentType
```

## 类型

动态属性 \{String\}

## 说明

返回**当前搜索框**粘贴的内容的**类型**，或者按下**智能搜索框**时选中的内容的**类型**。可返回 "file", "bitmap", "text"。

## 返回值 \{String\}

返回字符串类型，代表粘贴的内容类型。可返回 "file", "bitmap", "text"。