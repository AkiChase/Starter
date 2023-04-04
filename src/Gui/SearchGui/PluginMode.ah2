/**
 * @Name: PluginMode
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-04
 * @Description: 插件模式
 */

class PluginMode {
    ; static listView := unset

    static rowHeight := 0

    static menu := 0
    static imgListID := 0
    static imgPathToImgListIndex := Map()
    static hotkeyHandlerMap := Map()

    static searchHandler := (*) => 0
    static runHandler := (*) => 0
    static doubleLeftHandler := (*) => 0
    static loadImgsHandler := (*) => 0

    static pluginSearchData := []
    static pluginSearchResult := []

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
            if (value > this.pluginSearchResult.Length)
                value := 1
            else if (value == 0)
                value := this.pluginSearchResult.Length
            this.listView.Modify(value, "Select Focus Vis")
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
        this.listView := SearchGui.gui.Add("ListView", "x10 y50 w510 r8 -Multi -hdr -E0x200", [""])
        this.listView.SetFont("s14 w700 c444444")

        ; 鼠标双击运行
        this.listView.OnEvent("DoubleClick", (_lv, rowNum) => rowNum ? this.pluginRun(rowNum) : 0)
        ; 菜单栏
        this.listView.OnEvent("ContextMenu", (_lv, rowNum, *) => rowNum ? this.showMenu() : 0)

        ; 插件模式热键处理函数
        this.hotkeyHandlerMap["~Esc"] := () => StrLen(SearchGui.searchText) ?
            SearchGui.searchText := SearchGui.edit.Value := "" : SearchGui.mode := this.oldMode ;切回原来的模式

        this.hotkeyHandlerMap["~Left Up"] := () => (A_ThisHotkey == A_PriorHotkey && A_TimeSincePriorHotkey < 250) ? this.pluginRun(, true) : 0

        this.hotkeyHandlerMap["Down"] := () => this.focusedRow++
        this.hotkeyHandlerMap["Up"] := () => this.focusedRow--

        this._default_thumb := LoadPicture(GlobalData.imgDir "\plugin.png", "w64")
    }

    ; 重新加载搜索列表图标资源
    static reloadIL(ILFlag) {
        SearchGui.placeholder := "正在加载插件模式搜索列表..."
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


    static showPluginMode(pluginSearchData, searchHandler, runHandler, doubleLeftHandler?, loadImgsHandler?, menuInitHandler?, searchText := "", placeholder := "", thumb?) {
        this.oldMode := SearchGui.mode

        this.pluginSearchData := pluginSearchData
        this.searchHandler := searchHandler
        this.runHandler := runHandler
        this.doubleLeftHandler := IsSet(doubleLeftHandler) ? doubleLeftHandler : (*) => 0
        this.loadImgsHandler := IsSet(loadImgsHandler) ? loadImgsHandler : (*) => 0

        this.rowHeight := 0
        this.menu := 0
        if (IsSet(menuInitHandler))
            menuInitHandler(this)

        this.reloadIL(IsSet(loadImgsHandler))

        this.thumb := IsSet(thumb) ? thumb : 0
        SearchGui.mode := -1
        SearchGui.placeholder := placeholder

        SearchGui.edit.Value := SearchGui.searchText := searchText ;同时触发搜索

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

        LVHeight := len > 0 ? Round((len >= 8 ? 8 : len) * this.rowHeight) : 0
        ControlMove(, , , LVHeight, this.listView) ; 使用ControlMove避免DPI 缩放
        this.listView.ModifyCol(1, "480")
        this.focusedRow := 1    ;聚焦第一行
        this.listView.Opt("Redraw")
        WinMove(, , 500 * (A_ScreenDPI / 96), LVHeight + Round(55 * (A_ScreenDPI / 96)), SearchGui.gui)
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