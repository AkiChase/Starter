---
title: addPluginToIntelligentMode
author: ruchuby
date: 2023-04-15
---

## 定义

```ahk
static addPluginToIntelligentMode(
    name, title, matchHandler, runHandler, contextHandler?, hIcon?
)
```

## 类型

静态方法

## 说明

添加**插件智能项**，应用方式见[插件智能项](../dev/intelligent/)

## 参数

- ### name {String}

插件id，即插件文件名

- ### title {String}

插件智能项显示标题

- ### matchHandler {[Closure](https://orz707.gitee.io/v2/docs/Functions.htm#closures)}

```ahk
(
    obj,
    searchText,
    pastedContentType,
    pastedContent,
    workWinInfo,
    winInfoMatchFlag
) => Number
```
- 接收参数
    - `obj`：指向添加的插件智能项对象。
    - `searchText`：当前搜索内容。
    - `pastedContentType`：粘贴内容类型。
    - `pastedContent`：粘贴内容。
    - `workWinInfo`：工作窗口信息对象
    - `winInfoMatchFlag`：是否开启工作窗口模式
- 返回值
    - 1：显示该插件智能项
    - 0：不显示该插件智能项

智能插件项的自定义匹配函数，返回值决定当前插件项是否显示

:::tip
工作窗口模式是按下**智能搜索**快捷键时，若当前**没有选中任何内容**，则**Starter**将获取工作窗口信息，进入工作窗口模式下的智能模式搜索框。

搜索框会短暂显示工作窗口的信息，插件可以根据此时的工作窗口信息进行匹配
:::

- ### runHandler {[Closure](https://orz707.gitee.io/v2/docs/Functions.htm#closures)}

```ahk
(obj, searchText) => Any
```

- 接收参数
    - `obj`：指向添加的插件智能项对象。
    - `searchText`：当前搜索内容。

运行（鼠标双击或回车）该插件智能项时执行的函数。

- ### contextHandler {[Closure](https://orz707.gitee.io/v2/docs/Functions.htm#closures)} （可选）

```ahk
(obj) => Any
```
- 接收参数
    - `obj`：指向添加的插件智能项对象。

选填，右键该插件智能项时执行的函数。

- ### hIcon {Int} （可选）

选填，插件智能项显示的图标hIcon，忽略则使用插件的图标。