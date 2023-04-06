class IntelligentMode {
    ; static listView := unset
    ; static menu := unset
    static imgListID := 0
    static rowHeight := 0
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
                if (value > GlobalData.intelligentSearchResult.Length + this.pluginSearchResult.Length)
                    value := 1
                else if (value == 0)
                    value := GlobalData.startupSearchResult.Length + this.pluginSearchResult.Length
                this.listView.Modify(value, "Select Focus Vis")
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
                    IntelligentMode.hideGui(), SearchGui.hideTime := A_Now
            }
            SetTimer(_autoHideFunc, value ? 1000 : 0)
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
        this.listView.OnEvent("ContextMenu", (_lv, rowNum, *) => !rowNum ?
            0 : rowNum > this.pluginSearchResult.Length ?
                this.menu.Show() : this.pluginSearchResult[rowNum].HasOwnProp("menu") ?
                    this.pluginSearchResult[rowNum].menu.Show() : 0
            )

        ; 启动模式热键处理函数
        this.hotkeyHandlerMap["~Esc"] := () => StrLen(SearchGui.edit.Value) ? SearchGui.searchText := SearchGui.edit.Value := "" : this.hideGui()
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

    ; run-with分组下的处理函数
    static runWithHandler(item) {
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

    ; search分组下的处理函数
    static searchHandler(item) {
        searchTxt := SearchGui.searchText

        if (item["match"]["mode"] == "reg") {
            reg := GlobalData.intelligentRegMap[item]
            searchTxt := RegExReplace(searchTxt, reg.exp, reg.replace, , 1)
        }

        Run(Format(item["url"], searchTxt))
    }

    ; 根据项目执行对应操作
    static intelligentRun(rowNum?) {
        static handler := Map("run-with", this.runWithHandler, "search", this.searchHandler)
        if (!IsSet(rowNum))
            rowNum := this.focusedRow
        if (rowNum > this.pluginSearchResult.Length) { ; 执行项
            item := GlobalData.intelligentSearchResult[rowNum]
            if (handler.Has(item["group"]))
                handler[item["group"]](this, item)
            this.hideGui()
        } else if (rowNum > 0) { ; 插件项
            plugin := this.pluginSearchResult[rowNum] ;当前搜索结果对应的正则
            content := RegExReplace(SearchGui.searchText, plugin.curReg[1], plugin.curReg[2], , 1)
            plugin.runHandler(content) ;传递正则替换后的结果
        }
    }

    ; 重新加载搜索列表图标资源
    static loadImgs(reloadIL := true) {
        SearchGui.placeholder := "正在加载智能模式搜索列表..."
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

        SearchGui.placeholder := "Hi, type something 😃"
    }

    ; 以智能模式显示gui
    static showGui(searchText := "") {
        if (SearchGui.hideTimeDiff()) {
            SearchGui.recoverGui()
            return
        }

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
        if (StrLen(keyword)) {
            GlobalData.intelligentSearchResult := []
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
        } else    ; 搜索词为空什么都不显示
            GlobalData.intelligentSearchResult := []

        ;显示新列表
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

        LVHeight := len > 0 ? Ceil((len >= 8 ? 8 : len) * this.rowHeight) : 0
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
        keyword := SearchGui.searchText
        if (StrLen(keyword)) {
            this.pluginSearchResult := []
            ; 匹配所有符合项
            for item in this.pluginData {
                for index, reg in item.reg
                    if RegExMatch(keyword, reg[1]) {
                        item.curReg := reg
                        item.regIndex := index
                        this.pluginSearchResult.Push(item)
                        break
                    }
            }
        } else    ; 搜索词为空什么都不显示
            this.pluginSearchResult := []

        ; 按regIndex从小到大
        QuickSort(this.pluginSearchResult, (itemA, itemB) => itemA.regIndex - itemB.regIndex)

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