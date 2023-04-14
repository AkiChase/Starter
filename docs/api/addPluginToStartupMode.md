---
title: PluginHelper.addPluginToStartupMode
author: ruchuby
date: 2023-04-14
---

```ahk
/**
* @description: 添加插件项到启动模式列表
* @param name 插件id, 即文件名
* @param title 插件项显示标题
* @param keywords 插件项关键字
* @param startHandler 鼠标双击、回车该插件项时执行的函数 (obj, searchText)=>any obj指向添加的插件项对象
* @param doubleRightHandler 选填, 双击Right该插件项时执行的函数 (obj, searchText)=>any obj指向添加的插件项对象
* @param contextHandler 选填, 右键该插件项时的处理函数 (obj)=>any obj指向添加的插件项对象
* @param hIcon 选填, 插件项显示的图标HICON, 默认使用插件的图标
*/
static addPluginToStartupMode(name, title, keywords, startHandler, doubleRightHandler?, contextHandler?, hIcon?)
```

:::tip
obj 对象格式为 `{ name, title, keywords, startHandler, doubleRightHandler?, contextHandler?, hIcon?}`
:::