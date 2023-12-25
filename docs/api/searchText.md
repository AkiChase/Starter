---
title: searchText
author: AkiChase
order: 1
date: 2023-04-15
---

## 定义

```ahk
static searchText {
    get => SearchGui.searchText
    set => SearchGui.edit.Value := SearchGui.searchText := value
}
```

## 类型

动态属性 \{String\}

## 说明

**获取**、**设置**搜索框当前的文本内容。