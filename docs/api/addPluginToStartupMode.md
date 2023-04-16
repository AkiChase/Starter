---
title: addPluginToStartupMode
author: ruchuby
order: 1
date: 2023-04-15
---

## 定义

```ahk
static addPluginToStartupMode(
    name,
    title,
    keywords,
    startHandler,
    doubleRightHandler?,
    contextHandler?,
    hIcon?
)
```

## 类型

静态方法

## 说明

添加**插件启动项**，应用方式见[插件启动项](../dev/startup/)

## 参数

- ### name \{String\}

插件id，即插件文件名

- ### title \{String\}

插件启动项显示标题

- ### keywords \{Array\}

插件启动项其他关键字，比如 `["其他","QTGJZ"]`

- ### startHandler \{[Closure](https://orz707.gitee.io/v2/docs/Functions.htm#closures)\}

```ahk
(obj, searchText) => Any
```

- 接收参数
    - `obj`：指向添加的插件启动项对象。
    - `searchText`：当前搜索内容。

运行（鼠标双击或回车）该插件启动项时执行的函数。

- ### doubleRightHandler \{[Closure](https://orz707.gitee.io/v2/docs/Functions.htm#closures)\} （可选）

```ahk
(obj, searchText) => Any
```

- 接收参数
    - `obj`：指向添加的插件启动项对象。
    - `searchText`：当前搜索内容。

选填，选中该插件启动项后，双击 `Right` 按键时执行的函数。

- ### contextHandler \{[Closure](https://orz707.gitee.io/v2/docs/Functions.htm#closures)\} （可选）

```ahk
(obj) => Any
```

- 接收参数
    - `obj`：指向添加的插件启动项对象。

选填，右键该插件启动项时的处理函数。

- ### hIcon \{Int\} （可选）

插件启动项显示的图标hIcon，忽略则使用插件的图标。