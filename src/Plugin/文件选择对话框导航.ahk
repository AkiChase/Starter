/**
 * @Name: 文件选择对话框导航
 * @Version: 0.0.2
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-26
 * @Description: 文件选择对话框路径导航
 */

/*
===Starter Plugin Info==>
{
    "author": "ruchuby",
    "version": "0.0.2",
    "introduction": "文件选择对话框路径导航",
    "icon": "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"
}
<==Starter Plugin Info===
*/


#Include ..\Utils\PluginHelper.ah2

PluginHelper.addEntryFunc((*) => Plugin_文件选择对话框导航.main()) ; 添加入口函数等待执行

class Plugin_文件选择对话框导航 {

    static main() {
        SplitPath(A_LineFile, &name) ; 获取插件id即文件名
        this.name := name

        this.addToIntelligentMode()
    }

    static addToIntelligentMode() {
        ; 仅匹配窗口
        matchHandler(obj, searchText, pastedContentType, pastedContent, workWinInfo, winInfoMatchFlag) {
            hwnd := workWinInfo.hwnd
            cName := workWinInfo.class
            ; 匹配文件选择对话框 winInfoMatchFlag开启，才能保证cName是最新的
            if (winInfoMatchFlag && cName == "#32770") {
                obj.matchData := { hwnd: hwnd }
                return PluginHelper.Utils.strStartWith("WJXZDHK", searchText) ? 3 : 2 ; 优先级
            }
            return 0
        }

        ; 插件模式初始化
        init(hwnd, that) {
            that.pluginSearchData := this.getExplorerPathList()
            that.pluginOtherData := { hwnd: hwnd }
        }

        ; 插件模式下搜索
        searchHandler(that, searchText) {
            that.pluginSearchResult := []
            if (searchText) {
                ; 搜索结果
                for item in that.pluginSearchData {
                    if (InStr(item.title, searchText) || InStr(item.titlePY, searchText)) ; 原文匹配或者拼音首字母部分匹配
                        that.pluginSearchResult.Push(item)
                }
            } else ; 搜索内容为空时显示所有
                that.pluginSearchResult := that.pluginSearchData

            ; 搜索结果按标题排序
            PluginHelper.Utils.QuickSort(that.pluginSearchResult, (itemA, tiemB) => StrCompare(itemA.title, tiemB.title))
            ;重置列表
            that.listView.Opt("-Redraw")    ;禁用重绘
            that.listView.Delete()
            ; 添加搜索结果到列表
            for item in that.pluginSearchResult {
                that.listView.Add(, "  " item.title)
            }

            that.resizeGui() ;根据搜索结果数量调整gui尺寸 并启用重绘
        }

        ;定义插件模式下回车、双击处理函数
        runHandler(that, rowNum) {
            if (rowNum) {
                ; hwnd在ini函数中赋值到了pluginOtherData.hwnd
                PluginHelper.hideSearchGui()
                this.jumpToPath(that.pluginOtherData.hwnd, that.pluginSearchResult[rowNum].path)
            }
        }

        ; 添加插件项到智能模式搜索界面
        PluginHelper.addPluginToIntelligentMode(
            this.name,
            "文件选择对话框路径导航",
            matchHandler,
            (obj, searchText) => (
                PluginHelper.showPluginMode( ; 启动插件模式
                    [], ; 在ini函数中中动态设定
                    searchHandler,
                    runHandler, {
                        initHandler: init.Bind(obj.matchData.hwnd),
                        placeholder: "选择导航路径",
                        thumb: PluginHelper.getPluginHIcon(this.name)
                    }
                )
            ), , PluginHelper.getPluginHIcon(this.name)
        )
    }


    ; 获取当前运行的资源管理器路径
    static getExplorerPathList() {
        pathList := Map()
        for item in ComObject("Shell.Application").Windows {
            try folder := item.Document.Folder.Self.Path
            if (!folder || pathList.Has(folder))
                Continue
            pathList[folder] := true
        }
        out := []
        out.Capacity := pathList.Count
        for k, v in pathList {
            title := PluginHelper.Utils.pathStrCompact(k, 50)
            out.Push({ title: title, path: k, titlePY: PluginHelper.Utils.chineseFirstChar(title) }) ; 压缩到50字符内
        }
        return out
    }

    ; 指定对话框导航到指定路径
    static jumpToPath(hwnd, path) {
        if (WinExist("ahk_id " hwnd)) {
            ctrls := WinGetControls("A")

            ControlSend("{F4}")
            ctrlNN := ""
            for i, ctrl in ctrls {
                if (InStr(ctrl, "Edit"))
                    ctrlNN := ctrl
            }
            ControlFocus(ctrlNN)
            ControlSetText(path, ctrlNN)
            ControlSend("{Enter}", ctrlNN)
            PluginHelper.Utils.tip("文件选择对话框路径导航", "路径已导航至:`n`n" path, 2000)
        } else
            PluginHelper.Utils.tip("文件选择对话框路径导航", "对话框窗口不存在，导航失败", 2000)

    }
}