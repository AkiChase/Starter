---
title: getPluginHIcon
author: ruchuby
order: 1
date: 2023-04-15
---

## 定义

```ahk
static PluginHelper.getPluginHIcon(pluginName)
```

## 类型

静态方法

## 说明

获取指定插件的图标 `hIcon`

:::warning
使用 `hIcon` 时请加 `*` 以使用副本，如 `hIcon:* 123456`，避免原图标句柄用后销毁
:::

## 参数

- ### pluginName \{String\}

插件名称，即插件文件名、插件id

## 返回值

- ### hIcon \{Int\}

如果插件有图标，则返回hIcon，否则返回0