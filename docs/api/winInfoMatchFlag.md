---
title: winInfoMatchFlag
author: AkiChase
order: 1
date: 2023-04-15
---

## 定义

```ahk
static winInfoMatchFlag => SearchGui.winInfoMatchFlag
```

## 类型

动态属性 \{Bool\}

## 说明

返回一个布尔值，表示当前是否处于工作窗口模式。

:::tip
工作窗口模式是按下**智能搜索**快捷键时，若当前**没有选中任何内容**，则**Starter**将获取工作窗口信息，进入工作窗口模式下的智能模式搜索框。

搜索框会短暂显示工作窗口的信息，插件可以根据此时的工作窗口信息进行匹配
:::

## 返回值 \{Bool\}

返回一个布尔值，表示当前是否处于工作窗口模式。如果处于工作窗口模式，则返回 `true`，否则返回 `false`。