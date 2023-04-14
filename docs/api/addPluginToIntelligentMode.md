---
title: PluginHelper.addPluginToIntelligentMode
author: ruchuby
date: 2023-04-14
---

```ahk
/**
    * @description: 添加插件项到智能模式列表
    * @param name 插件id, 即文件名
    * @param title 插件项显示标题
    * @param matchHandler 插件项匹配函数 (obj, searchText, pastedContentType, pastedContent, workWinInfo, winInfoMatchFlag)=>number
    * 
    * obj指向添加的插件项对象; searchText为当前搜索内容;
    * 
    * pastedContentType为粘贴内容类型; pastedContentType为粘贴内容
    * 
    * workWinInfo为工作窗口信息; winInfoMatchFlag为是否开启工作窗口模式（没有选中任何内容时会开启工作窗口模式）
    * 
    * @param runHandler 鼠标双击、回车该插件项时执行的函数
    * (obj, searchText)=>any obj指向添加的插件项对象, searchText为搜索框文本内容
    * @param contextHandler 选填, 右键该插件项显示的菜单
    * @param hIcon 选填, 插件项显示的图标HICON, 默认使用插件的图标
    */
static addPluginToIntelligentMode(name, title, matchHandler, runHandler, contextHandler?, hIcon?)
```