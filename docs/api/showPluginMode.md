---
title: showPluginMode
author: AkiChase
order: 1
date: 2023-04-15
---

## 定义

```ahk
static showPluginMode(pluginSearchData, searchHandler, runHandler, options := {})
```

## 类型

静态方法

## 说明

启动插件模式。参考[插件模式](../dev/plugin-mode/)。

## 参数

- \{Array\} `pluginSearchData`: **必填参数**，用于插件模式搜索的数据。
- \{(that, searchText) => any\} `searchHandler`: **必填参数**，插件模式搜索处理函数，**额外说明见下方**。
- \{(that, searchText) => any\} `runHandler`: **必填参数**，插件模式回车、双击任意项时的处理函数。
- \{Object\} `options`: 可选参数，**具体使用见下方说明**。

### options 中可选参数的说明

- `doubleRightHandler`（可选）\{(that, rowNum) => void\}
    - 插件模式双击 Right 键时的处理函数，`rowNum` 为当前选中项的行号。

- `loadImgsHandler`（可选）\{(that) => void\}
    - 加载插件模式图片的处理函数，若需要显示图标一定要带有此参数。

- `toBottomHandler`（可选）\{(that) => void\}
    - 列表最后一行可见（触底）处理函数。

- `pasteContentHandler`（可选）\{(that, typeName, content?) => bool\}
    - `Ctrl + V` 粘贴内容时的处理函数，如果粘贴的是 bitmap 或者 file 类型，需要额外特殊处理，**具体使用见下方说明**。

- `dropFilesHandler`（可选）\{(that, fileList, pre) => bool\}
    - 拖入文件到搜索框的处理函数，**具体使用见下方说明**。

- `initHandler`（可选）\{(that) => void\}
    - 初始化处理函数，在进入插件模式后被调用。

- `searchText`（可选）: 启动时设置搜索框文本。
- `placeholder`（可选）: 设置搜索框占位符。
- `thumb`（可选）: hICON，设置插件模式搜索框图标。

### searchHandler 处理函数说明{#searchHandler}

```ahk
(that, searchText) => any
```

为规范使用，请将搜索结果存放至 that.pluginSearchResult 然后对其进行渲染（添加到 listview）。

### pasteContentHandler 处理函数说明{#pastecontenthandler}

- 函数形式: 
    1. `(that, typeName) => bool` 
    2. `(that, typeName, content) => any`

- 函数返回值: 
    1. 在粘贴**bitmap/file**内容前会以形式一调用，则需要返回一个布尔值，表示是否允许进行粘贴操作（一般可以通过 typeName 判断是否是需要支持的粘贴内容）。
    2. 在粘贴**bitmap/file**内容后还会以形式二调用，作为粘贴完成的通知

:::tip
typeName: file 则 content为文件路径数组 \{Array\}

typeName: bitmap 则 content为位图句柄 hBitmap \{Int\}
:::

### dropFilesHandler 处理函数说明{#dropFilesHandler}

- 函数形式: 
    1. `(that, fileList, true) => bool` 
    2. `(that, fileList, false) => any`

- 函数返回值: 
    1. 在拖入文件后会以形式一触发，则需要返回一个布尔值，表示是否允许拖入操作生效。
    2. 拖入生效后还会以形式二触发，作为拖入生效的通知。