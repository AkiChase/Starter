class IntelligentMode {
    ; static listView := unset
    ; static menu := unset
    static imgListID := 0
    static rowHeight := 0
    static defaultPlaceholder := "Hi, type something 😃"
    static imgPathToImgListIndex := Map()
    static hotkeyHandlerMap := Map()

    static pluginData := []
    static pluginSearchResult := []

    static startupFocusedRow => this.focusedRow - this.pluginSearchResult.Length

    ;#region 聚焦行
    static focusedRow
    {
        get => this.listView.GetNext()
        set {
            if (GlobalData.intelligentSearchResult.Length || this.pluginSearchResult.Length) { ; 有内容才可修改
                if (Value > GlobalData.intelligentSearchResult.Length + this.pluginSearchResult.Length)
                    Value := 1
                else if (Value == 0)
                    Value := GlobalData.startupSearchResult.Length + this.pluginSearchResult.Length
                this.listView.Modify(Value, "Select Focus Vis")
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
                if (!WinActive(SearchGui.gui)){
                    SetTimer((*) => (IntelligentMode.hideGui(), SearchGui.hideTime := A_Now), -1000)
                    SetTimer(_autoHideFunc, 0)
                }
            }
            SetTimer(_autoHideFunc, Value ? 100 : 0)
        }
    }
    ;#endregion

    static init() {
        ; 本列表默认隐藏
        this.listView := SearchGui.gui.Add("ListView", "x10 y52 w560 r10 -Multi -hdr -E0x200 Hidden Count" 3, [""])
        this.listView.SetFont("s14 w700 c444444")

        this.loadImgs()

        ; 鼠标双击运行
        this.listView.OnEvent("DoubleClick", (_lv, rowNum) => this.intelligentRun(rowNum))
        ; 菜单栏
        showMenuHandler() {
            if (rowNum := this.focusedRow) {
                if (rowNum > this.pluginSearchResult.Length)
                    this.menu.Show()
                else
                    this.pluginSearchResult[rowNum].HasOwnProp("contextHandler") ?
                    this.pluginSearchResult[rowNum].contextHandler() : 0
            }
        }
        this.listView.OnEvent("ContextMenu", (*) => showMenuHandler())

        pasteHandler() {
            if (DllCall("OpenClipboard", "ptr", 0)) {
                if (DllCall("IsClipboardFormatAvailable", "uint", 2)) { ; 位图
                    DllCall("CloseClipboard")
                    SearchGui._pastedContentType := "bitmap"
                    SearchGui.pastedContent := "" ; 仅仅是为了触发其加载bitmap
                    SearchGui.searchText := SearchGui.searchText ; 不修改内容，直接触发搜索
                } else if (DllCall("IsClipboardFormatAvailable", "uint", 15)) { ; 文件
                    DllCall("CloseClipboard")
                    SearchGui._pastedContentType := "file"
                    SearchGui.pastedContent := A_Clipboard ; 会转化为数组
                    SearchGui.searchText := SearchGui.searchText ; 不修改内容，直接触发搜索
                } else {
                    DllCall("CloseClipboard")
                    Send("{Ctrl down}v{Ctrl up}") ; 正常的粘贴
                }
            } else ; 剪切板占用直接正常的粘贴
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
            else if (SearchGui._pastedContentType != "text")
                SearchGui.clearPastedContent(), SearchGui.searchText := "" ; 同时也要触发搜索
            else
                SearchGui.noRecover := true, this.hideGui()
        }
        this.hotkeyHandlerMap["~Esc"] := escHandler
        this.hotkeyHandlerMap["Down"] := () => this.focusedRow++
        this.hotkeyHandlerMap["Up"] := () => this.focusedRow--

        this.menuInit()
    }

    ; 智能模式列表右键菜单初始化
    static menuInit() {
        this.menu := Menu()
        this.menu.Add("执行选中项`t(&R)", (*) => this.intelligentRun(this.focusedRow))
        this.menu.Add("编辑选中项`t(&E)", (*) => this.toIntelligentEditGui(this.startupFocusedRow))

        this.menu.SetIcon("1&", GlobalData.imgDir "\run.ico")
        this.menu.SetIcon("2&", GlobalData.imgDir "\edit.ico")
    }

    ; 跳转至智能模式编辑界面
    static toIntelligentEditGui(rowNum) {
        selectedItem := GlobalData.intelligentSearchResult[rowNum]
        group := selectedItem["group"]
        for index, item in GlobalData.intelligentData[group] {
            if (item == selectedItem) {
                posIndex := index
                break
            }
        }

        this.hideGui()
        IntelligentEditGui.showGui([group, posIndex])
    }

    ; 运行run-with分组下项目
    static runRunWithGroupItem(item) {
        searchTxt := SearchGui.searchText
        if (item["match"]["mode"] == "reg") {
            reg := GlobalData.intelligentRegMap[item]
            searchTxt := RegExReplace(searchTxt, reg.exp, reg.replace, , 1)
        }

        if (item["script"]["mode"] == "arg") {    ; 传递单命令行参数
            arg := StrReplace(searchTxt, '"', '""')    ; 双引号转义为两个双引号
            Run(Format('"{}" "{}"', item["script"]["program"], arg))
        }
        else if (item["script"]["mode"] == "args")    ; 传递多命令行参数，不进行转义等操作
            Run(Format('"{}" {}', item["script"]["program"], searchTxt))
        else    ; type: none
            Run(searchTxt)
    }

    ; 运行search分组下项目
    static runSearchGroupItem(item) {
        searchTxt := SearchGui.searchText

        if (item["match"]["mode"] == "reg") {
            reg := GlobalData.intelligentRegMap[item]
            searchTxt := RegExReplace(searchTxt, reg.exp, reg.replace, , 1)
        }

        Run(Format(item["url"], searchTxt))
    }

    ; 根据项目执行对应操作
    static intelligentRun(rowNum?) {
        static handler := Map("run-with", this.runRunWithGroupItem, "search", this.runSearchGroupItem)
        if (!IsSet(rowNum))
            rowNum := this.focusedRow
        if (rowNum > this.pluginSearchResult.Length) { ; 执行项
            item := GlobalData.intelligentSearchResult[rowNum]
            if (handler.Has(item["group"]))
                handler[item["group"]](this, item)
            this.hideGui()
        } else if (rowNum > 0) { ; 插件项
            plugin := this.pluginSearchResult[rowNum] ;当前搜索结果对应插件项
            plugin.runHandler(SearchGui.searchText) ;直接传递搜索内容
        }
    }

    ; 重新加载搜索列表图标资源
    static loadImgs(reloadIL := true) {
        SearchGui.edit.Value := ""    ;清空搜索框
        this.listView.Delete()    ;清空智能列表
        if (reloadIL) {    ; reloadIL为false时是为了仅添加新资源
            this.imgPathToImgListIndex := Map()    ;重置图片路径与序号映射
            oldImgListID := this.imgListID ? this.imgListID : 0 ;标记需要删除旧图片列表
            this.imgListID := DllCall("ImageList_Create", "Int", 32, "Int", 32, "Int", 32, "Int", 1, "Int", 1)    ;创建新图片列表
            this.listView.SetImageList(this.imgListID, 1)

            ; 载入图片错误、根目录、插件的图标
            for name in ["\folder.png", "\noImg.png", "\plugin.ico"]
                this.imgPathToImgListIndex[GlobalData.imgDir name] := IL_Add(this.imgListID, GlobalData.imgDir name)
        }

        ; 为每个项目按需载入图标
        for name in GlobalData.intelligentGroups {
            if (GlobalData.intelligentData.Has(name)) {
                for item in GlobalData.intelligentData[name] {
                    if (!this.imgPathToImgListIndex.Has(item["thumb"])) {    ; 若图标尚未加载
                        index := IL_Add(this.imgListID, GlobalData.customImgDir "\" item["thumb"])
                        if (index)    ; 图片载入成功
                            this.imgPathToImgListIndex[item["thumb"]] := index
                    }
                }
            }
        }

        ; 重载插件图标
        this.pluginLoadImgs()

        if (reloadIL and oldImgListID)    ; 有需要销毁的图片列表
            DllCall("ImageList_Destroy", "Uint", oldImgListID)
    }

    ; 以智能模式显示gui
    static showGui(searchText := "") {
        if (!SearchGui.noRecover && SearchGui.hideTimeDiff()) {
            SearchGui.recoverGui()
            return
        }

        SearchGui.noRecover := false
        SearchGui.mode := 1
        SearchGui.edit.Value := SearchGui.searchText := searchText
        SearchGui.gui.Show()
        SearchGui.edit.Focus()
        IME_SET(0)
    }

    ; 智能模式下隐藏主界面
    static hideGui() {
        this.autoHideFlag := 0
        SearchGui.gui.hide()
    }

    ; 搜索即重置列表显示匹配的内容
    static search() {
        static customSort(itemA, itemB) {
            if (itemA["match"]["mode"] != itemB["match"]["mode"]) {
                ; 优先级大的在前
                return GlobalData.intelligentMatchPriority[itemB["match"]["mode"]] - GlobalData.intelligentMatchPriority[itemA["match"]["mode"]]
            } else if (itemA["match"]["mode"] == "reg") {
                ; 次序小的在前
                return GlobalData.intelligentRegMap[itemA].index - GlobalData.intelligentRegMap[itemB].index
            }
            return 0
        }


        keyword := SearchGui.searchText
        GlobalData.intelligentSearchResult := []

        ; 无粘贴内容且有搜索文本时，对原生搜索项进行匹配
        if (SearchGui._pastedContentType == 'text' && keyword) {
            ; 匹配所有符合项
            for name in GlobalData.intelligentGroups {
                if (GlobalData.intelligentData.Has(name)) {
                    for item in GlobalData.intelligentData[name] {
                        if (!item["enabled"])
                            continue
                        if (item["match"]["mode"] == "str")
                            GlobalData.intelligentSearchResult.Push(item)
                        else if (item["match"]["mode"] == "reg") {
                            for index, exp in item["match"]["exp"]
                                if RegExMatch(keyword, exp) {
                                    GlobalData.intelligentRegMap[item] := { exp: exp, replace: item["match"]["replace"][index], index: index }
                                    GlobalData.intelligentSearchResult.Push(item)
                                    break
                                }
                        }
                    }
                }
            }
            ; 按拟定的优先级降序排列
            QuickSort(GlobalData.intelligentSearchResult, customSort)
        }


        ;重置列表
        this.listView.Opt("-Redraw")    ;禁用重绘
        this.listView.Delete()

        ;插件搜索并添加插件项到列表
        this.pluginSearchAndAdd()

        ; 添加执行项到列表
        for item in GlobalData.intelligentSearchResult {
            if (this.imgPathToImgListIndex.Has(item["thumb"]))
                this.listView.Add("Icon" this.imgPathToImgListIndex[item["thumb"]], "  " item["title"])
            else    ; 无图标 使用特殊路径
                this.listView.Add("Icon" this.imgPathToImgListIndex[GlobalData.imgDir "\noImg.png"], "  " item["title"])
        }

        this.resizeGui()
    }

    ;重置listView和gui高度
    static resizeGui() {
        len := GlobalData.intelligentSearchResult.Length + this.pluginSearchResult.Length
        if (len && this.rowHeight == 0) {
            LV_XYstruct := Buffer(16, 0)
            SendMessage(0x1038, 1, LV_XYstruct.Ptr, , this.listView)
            if (rowH := NumGet(LV_XYstruct, 12, "UInt") - NumGet(LV_XYstruct, 4, "UInt"))
                this.rowHeight := rowH
        }

        if (!this.rowHeight)
            LVHeight := len * Ceil(26.4 * (A_ScreenDPI / 96))
        else
            LVHeight := len > 0 ? Ceil((len >= 10 ? 10 : len) * this.rowHeight) : 0
        ControlMove(, , , LVHeight, this.listView) ; 使用ControlMove避免DPI 缩放
        this.listView.ModifyCol(1, "530")
        this.focusedRow := 1    ;聚焦第一行
        this.listView.Opt("Redraw")
        WinMove(, , 550 * (A_ScreenDPI / 96), LVHeight + Ceil(55 * (A_ScreenDPI / 96)), SearchGui.gui)
    }

    ; 载入插件图片
    static pluginLoadImgs() {
        ; 为插件项目载入图标
        for i, plugin in this.pluginData {
            hIcon := plugin.HasOwnProp("hIcon") ? plugin.hIcon : PluginHelper.getPluginHIcon(plugin.name)
            plugin.index := i ;为每个插件项编号
            if (hIcon && index := IL_Add(this.imgListID, "HICON:*" hIcon))
                this.imgPathToImgListIndex[Format("Plugin:{}:{}", plugin.name, plugin.index)] := index
            ; 否则在search时使用默认图片
        }
    }

    ; 插件搜索并添加插件项到列表
    static pluginSearchAndAdd() {
        this.pluginSearchResult := []
        ; 有文件、位图时或者工作窗口或者有搜索内容时才进行匹配
        if (SearchGui._pastedContentType != "text" || SearchGui.winInfoMatchFlag || SearchGui.searchText) {
            ; 匹配所有符合项
            for item in this.pluginData {
                if (priority := item.matchHandler(SearchGui.searchText,
                    SearchGui._pastedContentType, SearchGui.pastedContent,
                    SearchGui.workWinInfo, SearchGui.winInfoMatchFlag)) {
                    item.priority := priority
                    this.pluginSearchResult.Push(item)
                }
            }
        }

        ; 按返回的优先级排序
        QuickSort(this.pluginSearchResult, (itemA, itemB) => itemB.priority - itemA.priority)


        ; 添加到搜索列表
        for item in this.pluginSearchResult {
            path := Format("Plugin:{}:{}", item.name, item.index)
            if (!this.imgPathToImgListIndex.Has(path))    ; 图标载入失败则使用默认图标
                this.listView.Add("Icon" this.imgPathToImgListIndex[GlobalData.imgDir "\plugin.ico"], "  " item.title)
            else
                this.listView.Add("Icon" this.imgPathToImgListIndex[path], "  " item.title)
        }
    }
}