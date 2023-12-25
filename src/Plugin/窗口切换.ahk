/**
 * @Name: 窗口切换
 * @Version: 0.0.1
 * @Author: AkiChase
 * @LastEditors: AkiChase
 * @LastEditTime: 2023-05-12
 * @Description: 窗口切换，支持使用拼音首字母检索窗口标题进行切换，类似Switcheroo
 */

/*
===Starter Plugin Info==>
{
    "author": "AkiChase",
    "version": "0.0.1",
    "introduction": "窗口切换，支持使用拼音首字母检索窗口标题进行切换，类似Switcheroo",
    "icon": "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAA81JREFUWEftll9oW3UUx7/nd9NMKqZTVtT1bjrSrXeNw4cW0iGjLY048GUKLXN/UF+UbdJ2Ix2ID8sQlC3q2jqQKfqkuGXIRAYTmtmOPZhBYKDE3m2pqe3dyli3ka7t/nT3d+TepNrWpLnZXPegPwiXJN9zvh/OOb/7+xEe8qKH7I//CAAzeQ8PqKS4VHaXGAMbKoanK3/fFag5FC8Zf3yJyiRUlqYKIhWgCgDWUwVYBWB9/3sxH1bYtUffqJ53DFAZGSkHTTULoNpOzqyybYInZ6QeAWAAZIDYYImLYDYg2IBUDHhuGzzuahSkvA7gKX502XpHACuPDgXB/L6VnAhnbQMpL1omxMK44zKNlLnCQAuZToZ61ZHUBiZxDJBvFgTwRobXC8gTTLwl2fzsN04MnGhWHh3qZWmeKghgCcE8eaHlmZedJHaqKQ4A0C80L982N3lp+49PL1qkeK0hB5B98tKs7rwQfPD6vhd/zQXlGED99JdNd2/eWnrzSnoCyBjN+JQCuA4gBcLvYEoC5gAxJZnoPQABKZXVNz5u1OdCzAvgCZ58hwS/AUZNJpCHQZRixqAABi0zk0VSlsjkxAeBy/nKXtYRPQYQp8NNrzoG8ASjG4nwLTPvJcHHpSJSNz4MXHXa25m6xcGeBib6Mh0OWFWbtfJWoGx3NA6mnnS46d1cpr61nzxhQtFYkkZkLrc1RHH95/bjc/VZgN50OPCPYc8L4An2hBQF31Wc7p8070JjkhpIVDGxRgwNQHnG1O75ULZFDQR83R9r25qjAs4AtLoDIYDWALQKsI1cACYAWAOkE+OcFKwTFF0Zu3oukQjdmTarruv0S1BMYfIlzrT+Nv374o6f6hmyb94KVPq7PS7iE9awAGYURKPEQp9i6MkzrYbT3mt13b2AeUqP7QwVBaCt7XwJTF/psbbZB4ZT56zu3gHs0iv1eqy1sUjPWfKiASJ/MBPtoEzvFxag8kgqRCT2MOBbEIDyWu9eEkp95p3GDQAusSk3J19b0bcQAN+X13q7pvtFhEE3XD8kWpZds3fzg2xBWUf0CwBL0uHAK/nm64EBlHWcbAY4woQtY/sDee8R/zrAyLo1Vq8bwDzMEPvHPmo6ON/uotX+zu1M9LYea3v+frZhVV1Xkpg/u7zuuZ7bbveVydHSUXxeO1UoJ2n+rhoQ4gTe1R9rP1AoINf/mr/rLRAOzX0VO8lln1I+f3e1KRABs89JUA7NJUBu1mM7+4qN/+uYrHph32NkurMXkOLSKI+444m+HePFRWXUBS+l95K0mJj/Af4E/+8XBQoX0rkAAAAASUVORK5CYII="
}
<==Starter Plugin Info===
*/


#Include ..\Utils\PluginHelper.ah2
PluginHelper.addEntryFunc((*) => Plugin_窗口切换.main()) ; 添加入口函数等待执行

#DllLoad "dwmapi" ; 预先加载dwmapi.dll

class Plugin_窗口切换 {

    static main() {
        SplitPath(A_LineFile, &name) ; 获取插件id即文件名
        this.name := name
        this.hwnd := PluginHelper.searchGuiHwnd

        this.addToStartupMode()
    }

    ; 获取所有窗口列表（结果和Alt+Tab一致）
    static getAllAltWinList() ; v0.21 by SKAN for ah2 on D51K/D51O @ autohotkey.com/r?t=99157
    {
        Static S_OK := 0 ; 非0时表示DwmGetWindowAttribute函数错误

        Local List := []
            , Style := 0
            , ExStyle := 0
            , hwnd := 0

        For , hwnd in WinGetList()
            If IsVisible(hwnd)
                && StyledRight(hwnd)
                && IsAltTabWindow(hwnd)
                List.Push(hwnd)

        Return List

        IsVisible(hwnd, Cloaked := 0)
        {
            If S_OK = 0
                S_OK := DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd
                    , "int", 14                   ; DWMWA_CLOAKED
                    , "uintp", &Cloaked
                    , "int", 4                    ; sizeof uint
                )

            Style := WinGetStyle(hwnd)
            Return (Style & 0x10000000) && !Cloaked         ; WS_VISIBLE
        }


        StyledRight(hwnd)
        {
            ExStyle := WinGetExStyle(hwnd)

            Return (ExStyle & 0x8000000) ? False                ; WS_EX_NOACTIVATE
            : (ExStyle & 0x40000) ? True                 ; WS_EX_APPWINDOW
                : (ExStyle & 0x80) ? False                ; WS_EX_TOOLWINDOW
                    : True
        }


        IsAltTabWindow(Hwnd)
        {

            ExStyle := WinGetExStyle(hwnd)
            If (ExStyle & 0x40000)                         ; WS_EX_APPWINDOW
                Return True

            While hwnd := DllCall("GetParent", "ptr", hwnd, "ptr")
            {
                If IsVisible(Hwnd)
                    Return False

                ExStyle := WinGetExStyle(hwnd)

                If (ExStyle & 0x80)                     ; WS_EX_TOOLWINDOW
                    && !(ExStyle & 0x40000)                  ; WS_EX_APPWINDOW
                    Return False
            }

            Return !Hwnd
        }
    }

    ; 获取匹配搜索的窗口信息列表
    static getWinList(searchText) {
        o := A_DetectHiddenWindows
        DetectHiddenWindows(false)

        out := []
        idList := this.getAllAltWinList()
        for id in idList {
            ; 窗口不存在则跳过
            if (!WinExist("ahk_id " id))
                continue

            title := WinGetTitle()
            if (
                id == this.hwnd || ; 是主程序窗口则跳过
                ; 带有搜索内容 且 标题或转拼音首字母后 都不包含搜索文本则跳过
                searchText &&
                !(
                    InStr(title, searchText) ||
                    Instr(PluginHelper.Utils.chineseFirstChar(title), searchText) ; 标题中文
                )
            )
                continue

            ; 获取hIcon
            if !(hIcon := SendMessage(0x7F, 0, 0))
                if !(hIcon := SendMessage(0x7F, 1, 0))
                    if (!(hIcon := SendMessage(0x7F, 2, 0)))
                        if (!(hIcon := DllCall("GetClassLongPtr", "Ptr", id, "Int", -14, "Ptr")))
                            if (!(hIcon := DllCall("GetClassLongPtr", "Ptr", id, "Int", -34, "Ptr")))
                                hIcon := DllCall("LoadIcon", "uint", 0, "uint", 32512) ; 使用默认图标

            ; 添加到输出列表
            out.push({ hwnd: id, title: title, hIcon: hIcon })
        }

        DetectHiddenWindows(o)

        if (out.Length >= 2) {
            ; 交换1,2元素位置
            tmp := out[1]
            out[1] := out[2]
            out[2] := tmp
        }
        return out
    }

    static addToStartupMode() {
        searchHandler(that, searchText) {
            that.pluginSearchResult := this.getWinList(searchText)

            ; 定义了loadImgsHandler，重载当前图像列表
            that.reloadLVIL(true)

            ; 重新加载列表
            that.listView.Opt("-Redraw")    ;禁用重绘

            ; that.listView.Delete() ; reloadLVIL中已经删除了
            for item in that.pluginSearchResult
                that.listView.Add("icon" that.imgPathToImgListIndex[item.hwnd], "  " item.title)

            that.resizeGui() ;根据搜索结果数量调整gui尺寸 并启用重绘
        }

        runHandler(that, rowNum) {
            ; 激活对应窗口然后隐藏搜索框
            hwnd := that.pluginSearchResult[rowNum].hwnd
            try WinActivate("ahk_id " hwnd)
            catch {
                ; 激活失败则重载搜索结果
                searchHandler(that, PluginHelper.searchText)
                return
            }
            PluginHelper.hideSearchGui()
        }

        loadImgsHandler(that) {
            static defaultHIcon := DllCall("LoadIcon", "uint", 0, "uint", 32512) ; 默认图标

            that.imgPathToImgListIndex["default"] := IL_Add(that.imgListID, "hIcon:*" defaultHIcon)
            for item in that.pluginSearchResult {
                ; hwnd作为路径
                index := IL_Add(that.imgListID, "hIcon:*" item.hIcon)
                ; 加载失败则使用默认图标
                that.imgPathToImgListIndex[item.hwnd] := index ? index : that.imgPathToImgListIndex["default"]
            }
        }

        PluginHelper.addPluginToStartupMode(
            this.name,
            "窗口切换",
            ["CKQH"],
            (*) => PluginHelper.showPluginMode(
                [],
                searchHandler,
                runHandler, {
                    loadImgsHandler: loadImgsHandler,
                    thumb: PluginHelper.getPluginHIcon(this.name)
                }
            )
        )
    }
}