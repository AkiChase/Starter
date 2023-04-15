---
title: setSearchTextSel
author: ruchuby
date: 2023-04-15
---

## 定义

```ahk
static setSearchTextSel(start := 0, end := -1)
```

## 类型

静态方法

## 说明

设置搜索框的选中文本区域。

## 参数

- `start`: 选中文本区域的开始位置，默认值为 `0`，表示从第一个文本之前开始选中。
- `end`: 选中文本区域的结束位置，默认值为 `-1`，表示选中最后一个文本。

:::tip
当 `start` 和 `end` 的值相同时，表示将游标移动到指定位置。

使用 `setSearchTextSel(StrLen(searchText), 1)` 将游标移动到最后
:::