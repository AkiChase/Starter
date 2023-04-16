---
title: getPluginIconBase64
author: ruchuby
order: 1
date: 2023-04-15
---

## 定义

```ahk
static getPluginIconBase64(pluginName)
```

## 类型

静态方法

## 说明

获取指定插件的图标的无头部 `Base64`

如果插件存在图标则返回无头部 `Base64`，如果插件不存在图标则返回 0。

## 参数

- ### pluginName \{String\}

插件名称，即插件文件名。

## 返回值 \{(String|Int)\}

如果插件存在图标则返回无头部 `Base64`，如果插件不存在图标则返回 0。