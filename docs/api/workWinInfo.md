---
title: workWinInfo
author: ruchuby
order: 1
date: 2023-04-15
---

## 定义

```ahk
static workWinInfo => SearchGui.workWinInfo
```

## 类型

动态属性 \{Object\}

## 说明

返回当前活动窗口的相关信息。

## 返回值 \{Object\}

返回一个包含活动窗口信息的对象。对象包含以下属性：

- `hwnd`: 窗口句柄
- `title`: 窗口标题
- `class`: 窗口类名
- `processPath`: 程序路径
- `processName`: 程序名称