/**
 * @Name: PluginMode
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-07
 * @Description: 插件模式
 */

class PluginMode {
    ; static listView := unset

    static rowHeight := 0

    static menu := 0
    static imgListID := 0
    static defaultPlaceholder := ""
    static imgPathToImgListIndex := Map()
    static hotkeyHandlerMap := Map()
    static enabledPasteContent := false

    static searchHandler := (*) => 0
    static runHandler := (*) => 0
    static doubleLeftHandler := (*) => 0
    static loadImgsHandler := (*) => 0
    static toBottomHandler := (*) => 0
    static pasteContentHandler := (*) => 0

    static pluginSearchData := []
    static pluginSearchResult := []
    static pluginOtherData := 0 ; 可自定义此数据

    static _default_thumb := 0
    static _thumb := 0
    static thumb {
        get => this._thumb ? this._thumb : this._default_thumb
        set {
            this._thumb := value ? value : this._default_thumb
        }
    }

    ;#region 聚焦行
    static focusedRow
    {
        get => this.listView.GetNext()
        set {
            if (this.pluginSearchResult.Length) {  ; 有内容才可修改
                if (value > this.pluginSearchResult.Length)
                    value := 1
                else if (value == 0)
                    value := this.pluginSearchResult.Length
                this.listView.Modify(value, "Select Focus Vis")
                this.toBottomNotify() ; 触发检测
            }
        }
    }
    ;#endregion

    ;#region 失去焦点自动隐藏开关
    static _autoHideFlag := 0
    static autoHideFlag {
        get => this._autoHideFlag
        set {
            _autoHideFunc() {
                if (!WinActive(SearchGui.gui))
                    PluginMode.hideGui(), SearchGui.hideTime := A_Now
            }
            SetTimer(_autoHideFunc, value ? 1000 : 0)
        }
    }
    ;#endregion

    ; 初始化
    static init() {
        this.listView := SearchGui.gui.Add("ListView", "x10 y52 w560 r10 -Multi -hdr -E0x200", [""])
        this.listView.SetFont("s14 w700 c444444")

        ; 鼠标双击运行
        this.listView.OnEvent("DoubleClick", (_, rowNum) => rowNum ? this.pluginRun(rowNum) : 0)
        ; 菜单栏
        this.listView.OnEvent("ContextMenu", (_, rowNum, *) => rowNum ? this.showMenu() : 0)

        LVN_ENDSCROLL := -181
        this.listView.OnNotify(LVN_ENDSCROLL, this.toBottomNotify) ;滚动结束时检测是否触底


        pasteHandler() {
            if (this.enabledPasteContent && DllCall("OpenClipboard", "ptr", 0)) {
                if (DllCall("IsClipboardFormatAvailable", "uint", 2)) { ; 位图
                    DllCall("CloseClipboard")
                    if (this.pasteContentHandler("bitmap")) {
                        SearchGui._pastedContentType := "bitmap"
                        SearchGui.pastedContent := ""
                        this.pasteContentHandler("bitmap", SearchGui.pastedContent)
                    }
                } else if (DllCall("IsClipboardFormatAvailable", "uint", 15)) { ; 文件
                    DllCall("CloseClipboard")
                    if (this.pasteContentHandler("file")) {
                        tmp := A_Clipboard
                        SearchGui._pastedContentType := "file"
                        SearchGui.pastedContent := tmp
                        this.pasteContentHandler("file", SearchGui.pastedContent)
                    }
                } else {
                    DllCall("CloseClipboard")
                    Send("{Ctrl down}v{Ctrl up}") ; 正常的粘贴
                }
            } else ; 禁用粘贴内容或剪切板占用直接正常的粘贴
                Send("{Ctrl down}v{Ctrl up}")
        }
        this.hotkeyHandlerMap["$^V"] := pasteHandler

        escHandler() {
            ; 有输入法窗口(同pid但不同class时不执行)
            pid := ProcessExist()
            idList := WinGetList("ahk_pid " pid)
            for id in idList {
                if (WinGetClass("ahk_id " id) != "AutoHotkeyGUI")
                    return
            }

            if (SearchGui.searchText)
                SearchGui.searchText := SearchGui.edit.Value := ""
            else if (this.enabledPasteContent && SearchGui._pastedContentType != "text")
                SearchGui.clearPastedContent()
            else
                SearchGui.mode := this.oldMode ;切回原来的模式
        }
        this.hotkeyHandlerMap["~Esc"] := escHandler

        rightUpHandler() {
            static lastEndFlag := false
            EditCtrlFunc.getSelection(&s, &e, SearchGui.edit)
            if (s == e && e == StrLen(SearchGui.searchText)) { ; 选区是否位于最后
                if ((A_ThisHotkey == A_PriorHotkey && A_TimeSincePriorHotkey < 250) && (rowNum := this.focusedRow) && lastEndFlag) {
                    this.pluginRun(, true)
                }
                lastEndFlag := true
            } else
                lastEndFlag := false
        }
        this.hotkeyHandlerMap["~Right Up"] := rightUpHandler

        this.hotkeyHandlerMap["Down"] := () => this.focusedRow++
        this.hotkeyHandlerMap["Up"] := () => this.focusedRow--

        this._default_thumb := LoadPicture(GlobalData.imgDir "\plugin.png", "w64")
    }

    ; 检测是否触底并发出通知
    static toBottomNotify(*) {
        static LVM_ISITEMVISIBLE := 0x10B6
        index := PluginMode.pluginSearchResult.Length
        if (index) {
            res := SendMessage(LVM_ISITEMVISIBLE, index - 1, 0, PluginMode.listView)
            if (res)
                PluginMode.toBottomHandler() ;调用触底处理函数
        }
    }

    ; 重置列表和图标资源
    static reloadLVIL(ILFlag) {
        this.listView.Opt("-Redraw")
        this.listView.Delete()    ;清空搜索列表

        if (ILFlag) {
            this.imgPathToImgListIndex := Map()    ;重置图片路径与序号映射
            oldImgListID := this.imgListID ? this.imgListID : 0 ;标记需要删除旧图片列表
            this.imgListID := DllCall("ImageList_Create", "Int", 32, "Int", 32, "Int", 32, "Int", 1, "Int", 1)    ;创建新图片列表
            this.listView.SetImageList(this.imgListID, 1)

            this.loadImgsHandler() ;调用载入图片处理函数

            if (oldImgListID)
                DllCall("ImageList_Destroy", "Uint", oldImgListID)
        } else {
            this.listView.SetImageList(0, 1)
            ; 先切换为list视图再切回report, 保证图标空间消失
            this.listView.Opt("+List")
            this.listView.Opt("+Report")
        }
        this.listView.Opt("Redraw")
    }

    static showPluginMode(pluginSearchData, searchHandler, runHandler, options := {}) {
        this.oldMode := SearchGui.mode

        this.pluginSearchData := pluginSearchData
        this.searchHandler := searchHandler
        this.runHandler := runHandler
        this.doubleLeftHandler := options.HasOwnProp("doubleLeftHandler") ? options.doubleLeftHandler : (*) => 0
        this.loadImgsHandler := options.HasOwnProp("loadImgsHandler") ? options.loadImgsHandler : (*) => 0
        this.toBottomHandler := options.HasOwnProp("toBottomHandler") ? options.toBottomHandler : (*) => 0

        this.enabledPasteContent := options.HasOwnProp("pasteContentHandler")
        this.pasteContentHandler := options.HasOwnProp("pasteContentHandler") ? options.pasteContentHandler : (*) => 0

        this.pluginOtherData := 0
        this.rowHeight := 0
        this.menu := 0

        if (options.HasOwnProp("initHandler"))
            options.initHandler.Call(this)

        this.thumb := options.HasOwnProp("thumb") ? options.thumb : 0

        SearchGui.mode := -1

        placeholder := options.HasOwnProp("placeholder") ? options.placeholder : ""
        this.defaultPlaceholder := placeholder
        SearchGui.placeholder := placeholder
        ; 隐藏多余部分
        WinMove(, , 550 * (A_ScreenDPI / 96), Ceil(55 * (A_ScreenDPI / 96)), SearchGui.gui)
        this.reloadLVIL(options.HasOwnProp("loadImgsHandler"))

        searchText := options.HasOwnProp("searchText") ? options.searchText : ""
        SearchGui.edit.Value := SearchGui.searchText := searchText ;同时触发搜索
        EditCtrlFunc.editSelect(SearchGui.edit, StrLen(searchText), -1) ; 指示器移动到最后


        if (!WinActive(SearchGui.gui)) { ; 窗口未激活
            SearchGui.gui.Show()
            SearchGui.edit.Focus()
            IME_SET(0)
        }
    }

    static resizeGui() {
        ;重置listView和gui高度
        len := this.pluginSearchResult.Length
        if (len && this.rowHeight == 0) {
            LV_XYstruct := Buffer(16, 0)
            SendMessage(0x1038, 1, LV_XYstruct.Ptr, , this.listView)
            if (rowH := NumGet(LV_XYstruct, 12, "UInt") - NumGet(LV_XYstruct, 4, "UInt"))
                this.rowHeight := rowH
        }

        LVHeight := len > 0 ? Ceil((len >= 8 ? 8 : len) * this.rowHeight) : 0
        ControlMove(, , , LVHeight, this.listView) ; 使用ControlMove避免DPI 缩放
        this.listView.ModifyCol(1, "530")
        this.focusedRow := 1    ;聚焦第一行
        this.listView.Opt("Redraw")
        WinMove(, , 550 * (A_ScreenDPI / 96), LVHeight + Ceil(55 * (A_ScreenDPI / 96)), SearchGui.gui)
    }

    static pluginRun(rowNum?, doubleLeft := false) {
        if (!IsSet(rowNum))
            rowNum := this.focusedRow
        ; 此处rowNum可能为0
        doubleLeft ? this.doubleLeftHandler(rowNum) : this.runHandler(rowNum)
    }

    static showMenu() {
        if (Type(this.menu) == "Menu")
            this.menu.Show()
    }

    static hideGui() {
        this.autoHideFlag := 0
        SearchGui.gui.hide()
    }
}