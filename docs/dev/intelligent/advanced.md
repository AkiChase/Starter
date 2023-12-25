---
title: 进阶
icon: circle-right
author: AkiChase
date: 2023-04-14
order: 2
---

自定义匹配函数的进阶应用自然是各种匹配条件**混合使用**，此外还有一个排序优先级的概念。

## 匹配优先级

`matchHandler` 自定义匹配函数返回的值 `!= 0` 则匹配，而返回值越大，当前插件智能项在搜索结果中越靠前

:::tip
优先级约定俗成:

- ` 1 ` - 当前匹配条件比较广泛，所以设为基础的优先级
- ` 2 ` - 当前匹配条件稍微严格，设为更高的优先级
- `>=3` - 当前匹配条件苛刻，必须排序靠前、置顶
- `< 0` - 当前匹配条件下不需要优先，置于最后
:::

给出一个常用的文本匹配的优先级示例

```ahk
; 添加插件智能项
static addIntelligentItem() {
    ; 添加参照物
    PluginHelper.addPluginToIntelligentMode(this.name,
        "必定匹配且优先级为1.5的参照", ; 虽然可以使用浮点数，但是一般情况下都是用整数作为优先级
        (*) => 1.5, ; 无论如何都返回1.5
        (obj, *) => PluginHelper.Utils.tip(this.name, obj.title)
    )

    ; 自定义匹配函数
    matchHandler(obj, searchText, pastedContentType, *) { ; 使用*忽略多余参数
        ; 带有非文本类型的都不匹配
        if (pastedContentType != 'text')
            return 0

        if (PluginHelper.Utils.strStartWith("PPYXJ", searchText)) {
            ; 搜索文本PPYXJ的开头
            return 2 ; 更高优先级
        } else ; 否则优先级为1
            return 1 ; 基本优先级
        
        ; 注意，当未输入任何内容时，智能模式不会进行匹配，所以输入框为空时没有任何智能项
    }

    PluginHelper.addPluginToIntelligentMode(this.name,
        "匹配优先级",
        matchHandler,
        (obj, *) => PluginHelper.Utils.tip(this.name, obj.title)
    )
}
```

上述代码效果如图

![匹配优先级1](../images/intelligent-4.jpg)

![匹配优先级2](../images/intelligent-5.jpg)

![匹配优先级3](../images/intelligent-6.jpg)


:::warning
当**未输入任何内容**（文件、图片也是输入内容的一种）时，智能模式不会进行匹配，所以输入框为空时**没有任何**智能项
:::

## 混合匹配条件

混合匹配条件相对比较简单，是为之后**动态修改插件智能项**做铺垫

这里以[文件搜索](../../plugin/file-find.md)插件源码中的 `matchHandler` 稍作修改后作为例子

```ahk
static addIntelligentItem() {
    ; 混合匹配条件
    matchHandler(obj, searchText, pastedContentType, pastedContent, workWinInfo, winInfoMatchFlag) {
        ; 是否为窗口匹配模式
        if (winInfoMatchFlag) {
            pName := workWinInfo.processName
            cName := workWinInfo.class
            path := workWinInfo.title ; 资源管理器的标题一般为当前文件夹路径

            ; 匹配资源管理器 且 标题指向的文件夹存在
            if ((pName == 'explorer.exe' || cName == "CabinetWClass" || cName == "ExploreWClass")
                && InStr(FileExist(path), "D")
            ) {
                if (PluginHelper.Utils.strStartWith("Everything", searchText)
                    || PluginHelper.Utils.strStartWith("WJSS", searchText)) {
                    ; 搜索文本为Everything或者WJSS的开头
                    return 2 ; 更高优先级
                } else
                    return 1 ; 基本优先级
            }
        } else {
            if (pastedContentType == 'text' && searchText) {
                return 1 ; 基本优先级
            } else if (pastedContentType == 'file' && pastedContent.Length = 1 && InStr(FileExist(pastedContent[1]), "D")) {
                if (PluginHelper.Utils.strStartWith("Everything", searchText)
                    || PluginHelper.Utils.strStartWith("WJSS", searchText)) {
                    ; 搜索文本为Everything或者WJSS的开头
                    return 2 ; 更高优先级
                } else
                    return 1 ; 基本优先级
            }
        }
        return 0 ; 其他情况不匹配
    }

    PluginHelper.addPluginToIntelligentMode(this.name,
        "混合匹配条件",
        matchHandler,
        (obj, *) => PluginHelper.Utils.tip(this.name, obj.title)
    )
}
```
这个自定义匹配函数的处理方式看起来可能会让人有点疑惑，但匹配函数确确实实用了很多**混合匹配条件**。

## 动态修改插件智能项对象

自定义匹配函数在执行过程中能够直接访问到插件智能项对象 `obj` 

所以，可以在匹配时中动态的修改 `obj` 属性，来达到存储数据、修改匹配表现的目的

续接之前的[混合匹配条件](#混合匹配条件)代码例子：

```ahk
; 添加插件智能项
static addIntelligentItem() {
    ; 混合匹配条件
    matchHandler(obj, searchText, pastedContentType, pastedContent, workWinInfo, winInfoMatchFlag) {
        if (winInfoMatchFlag) {
            pName := workWinInfo.processName
            cName := workWinInfo.class
            path := workWinInfo.title ; 资源管理器的标题一般为当前文件夹路径
            ; 匹配资源管理器 且 标题指向的文件夹存在
            if ((pName == 'explorer.exe' || cName == "CabinetWClass" || cName == "ExploreWClass")
                && InStr(FileExist(path), "D")
            ) {
                if (PluginHelper.Utils.strStartWith("Everything", searchText)
                    || PluginHelper.Utils.strStartWith("WJSS", searchText)) {
                    ; 搜索文本为Everything或者WJSS的开头
                    obj.matchData := { type: "window", searchTextFlag: false, path: path }
                    obj.title := "在工作窗口目录内搜索" ; 修改显示标题
                    return 2 ; 更高优先级
                } else {
                    obj.matchData := { type: "window", searchTextFlag: true, path: path }
                    obj.title := "在工作窗口目录内搜索输入内容" ; 修改显示标题
                    return 1 ; 基本优先级
                }
            }
        } else {
            if (pastedContentType == 'text' && searchText) {
                obj.matchData := { type: "text" } ; 标记匹配类型，方便进入插件模式前区分进入方式
                obj.title := "使用Everything搜索输入内容" ; 修改显示标题
                return 1 ; 基本优先级
            } else if (pastedContentType == 'file' && pastedContent.Length = 1 && InStr(FileExist(pastedContent[1]), "D")) {
                if (PluginHelper.Utils.strStartWith("Everything", searchText)
                    || PluginHelper.Utils.strStartWith("WJSS", searchText)) {
                    ; 搜索文本为Everything或者WJSS的开头
                    obj.matchData := { type: "file", searchTextFlag: false } ; 标记最后不要传入searchText
                    obj.title := "使用Everything在文件夹内搜索" ; 修改显示标题
                    return 2 ; 更高优先级
                } else {
                    obj.matchData := { type: "file", searchTextFlag: true }
                    obj.title := "使用Everything在文件夹内搜索输入内容" ; 修改显示标题
                    return 1 ; 基本优先级
                }
            }
        }
        return 0 ; 不匹配
    }

    PluginHelper.addPluginToIntelligentMode(this.name,
        "匹配优先级",
        matchHandler,
        (obj, *) => PluginHelper.Utils.tip(this.name, obj.title)
    )
}
```
上述代码中，有通过 `obj.matchData := { type: "xxx", searchTextFlag: false, path: "xxx" }` 来动态添加额外数据到 `obj` 对象中，
从而在 `runHandler(obj, searchText)` 运行函数中可以根据这些额外数据执行相应的操作。

当然，`matchData`这个键名不是固定的，你可以使用任意不与原 `obj` 属性冲突的键名。

此外，还有通过 `obj.title := "xxx"` 可以动态修改插件智能项的标题

如此，**只添加一个插件智能项，却能发挥出n个智能项的效果**

:::warning
智能模式搜索框中的内容每次发生变动，Starter都会依次调用一遍每个插件智能项的自定义匹配函数，以判断插件智能项是否匹配。

所以匹配函数尽快返回结果，避免调用进度因此卡顿
:::