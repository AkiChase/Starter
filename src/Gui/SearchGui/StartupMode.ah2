class StartupMode {
    ; static listView := unset
    ; static menu := unset

    static imgListID := 0
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
            if (value > GlobalData.startupSearchResult.Length + this.pluginSearchResult.Length)
                value := 1
            else if (value == 0)
                value := GlobalData.startupSearchResult.Length + this.pluginSearchResult.Length
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
                    StartupMode.hideGui(), SearchGui.hideTime := A_Now
            }
            SetTimer(_autoHideFunc, value ? 1000 : 0)
        }
    }
    ;#endregion

    ; 初始化
    static init() {
        this.listView := SearchGui.gui.Add("ListView", "x10 y50 w510 r8 -Multi -hdr -E0x200 Count" GlobalData.startupData.Length, [""])
        this.listView.SetFont("s14 w700 c444444")

        this.loadImgs(true)
        this.search()

        ; 鼠标双击运行
        this.listView.OnEvent("DoubleClick", (_lv, rowNum) => rowNum ? this.startupRun(rowNum) : 0)
        ; 菜单栏
        this.listView.OnEvent("ContextMenu", (_lv, rowNum, *) => !rowNum ?
            0 : rowNum > this.pluginSearchResult.Length ?
                this.menu.Show() : this.pluginSearchResult[rowNum].HasOwnProp("menu") ?
                    this.pluginSearchResult[rowNum].menu.Show() : 0
            )

        ; 启动模式热键处理函数
        this.hotkeyHandlerMap["~Esc"] := () => StrLen(SearchGui.searchText) ?
            SearchGui.searchText := SearchGui.edit.Value := "" : this.hideGui()

        this.hotkeyHandlerMap["~Left Up"] := () => (A_ThisHotkey != A_PriorHotkey || A_TimeSincePriorHotkey > 250) ?
            0 : this.focusedRow > this.pluginSearchResult.Length ?
                this.openSelectedFileInFolder() : !this.pluginSearchResult[this.focusedRow].HasOwnProp("doubleLeftHandler") ?
                    0 : this.pluginSearchResult[this.focusedRow].doubleLeftHandler(SearchGui.searchText)

        this.hotkeyHandlerMap["Down"] := () => this.focusedRow++
        this.hotkeyHandlerMap["Up"] := () => this.focusedRow--

        ; 启动模式菜单初始化
        this.menuInit()
    }

    ; 启动模式列表右键菜单初始化
    static menuInit() {
        this.menu := Menu()
        this.menu.Add("启动选中项`t(&R)", (*) => this.startSelectedFile(this.focusedRow))
        this.menu.Add("文件夹中打开`t(&O)", (*) => this.openSelectedFileInFolder(this.focusedRow))
        this.menu.Add("编辑选中项`t(&E)", (*) => this.toStartupEditGui(this.focusedRow))
        this.menu.Add("删除选中项`t(&X)", (*) => this.deleteItem(this.focusedRow))

        this.menu.SetIcon("1&", GlobalData.imgDir "\run.ico")
        this.menu.SetIcon("2&", GlobalData.imgDir "\folder.ico")
        this.menu.SetIcon("3&", GlobalData.imgDir "\edit.ico")
        this.menu.SetIcon("4&", GlobalData.imgDir "\delete.ico")
    }

    ; 跳转至启动模式编辑界面
    static toStartupEditGui(rowNum) {
        if (GlobalData.startupSearchResult !== GlobalData.startupData) {    ; 当处于搜索结果时，需要遍历查找到位置
            selectedItem := GlobalData.startupSearchResult[rowNum]
            for index, item in GlobalData.startupData {
                if (item == selectedItem) {
                    rowNum := index
                    break
                }
            }

        }
        this.hideGui()
        StartupEditGui.showGui(rowNum)
    }

    ; 以启动模式显示搜索界面
    static showGui(searchText := "") {
        if (SearchGui.hideTimeDiff()) {
            SearchGui.recoverGui()
            return
        }
        SearchGui.mode := 0
        SearchGui.edit.Value := SearchGui.searchText := searchText
        SearchGui.gui.Show()
        SearchGui.edit.Focus()
        IME_SET(0)
    }

    ; 启动模式下隐藏搜索
    static hideGui() {
        this.autoHideFlag := 0
        SearchGui.gui.hide()
    }

    ; 删除项
    static deleteItem(rowNum) {
        Critical('On')    ;防止线程被中断
        item := GlobalData.startupSearchResult[rowNum]
        GlobalData.startupSearchResult.RemoveAt(rowNum)
        if (GlobalData.startupSearchResult != GlobalData.startupData) {    ; 当并非直接指向时还须再删除
            for index, oriItem in GlobalData.startupData {
                if (item == oriItem)
                    GlobalData.startupData.RemoveAt(index)
            }
        }
        this.listView.Delete(rowNum)

        ;重置listView和gui高度
        LVHeight := Round((GlobalData.startupSearchResult.Length >= 8 ? 8 : GlobalData.startupSearchResult.Length) * 26.4)    ; 此处不需要DPI缩放计算
        this.listView.Move(, , , LVHeight)
        this.listView.ModifyCol(1, "480")
        WinMove(, , 500 * (A_ScreenDPI / 96), Round((LVHeight + 55) * (A_ScreenDPI / 96)), SearchGui.gui)
        Critical('Off')
    }

    ; 回车和双击触发
    static startupRun(rowNum?) {
        if (!IsSet(rowNum))
            rowNum := this.focusedRow
        if (rowNum > this.pluginSearchResult.Length) { ; 启动项
            rowNum -= this.pluginSearchResult.Length
            this.startSelectedFile(rowNum)
        } else if (rowNum > 0) { ; 插件项
            this.pluginSearchResult[rowNum].startHandler(SearchGui.searchText)
        }
    }

    ; 运行选中文件
    static startSelectedFile(rowNum?) {
        if (!IsSet(rowNum))
            rowNum := this.startupFocusedRow
        if (rowNum > 0) {
            if (GlobalData.startupSearchResult[rowNum][3] < 999)
                GlobalData.startupSearchResult[rowNum][3]++

            Start.startFile(GlobalData.startupSearchResult[rowNum][1], , , this.hideGui.Bind(this))
        }
    }

    ; 在文件夹中显示选中文件
    static openSelectedFileInFolder(rowNum?) {
        if (!IsSet(rowNum))
            rowNum := this.startupFocusedRow
        if (rowNum > 0) {
            if (GlobalData.startupSearchResult[rowNum][3] < 999)
                GlobalData.startupSearchResult[rowNum][3]++

            Start.openFileInFolder(GlobalData.startupSearchResult[rowNum][1])
            this.hideGui()
        }
    }


    ; 重新加载搜索列表图标资源
    static loadImgs(reloadIL := true) {
        SearchGui.placeholder := "正在加载启动模式搜索列表..."
        this.listView.Delete()    ;清空搜索列表

        if (reloadIL) {    ;完全重新加载，否则仅加载未载入的
            general := ["error.png", "autohotkey.png", "img.png", "folder.png", "program.png", "txt.png", "plugin.ico"]
            this.imgPathToImgListIndex := Map()    ;重置图片路径与序号映射
            oldImgListID := this.imgListID ? this.imgListID : 0 ;标记需要删除旧图片列表
            this.imgListID := DllCall("ImageList_Create", "Int", 32, "Int", 32, "Int", 32, "Int", 1, "Int", 1)    ;创建新图片列表
            this.listView.SetImageList(this.imgListID, 1)
            ; 载入通用图标
            for img in general
                this.imgPathToImgListIndex[GlobalData.imgDir "\" img] := IL_Add(this.imgListID, GlobalData.imgDir "\" img)
        }

        ; 为每个项目按需载入图标
        changeFlag := false
        for item in GlobalData.startupData {
            item[3] := Integer(item[3])    ; 转为整数

            if (InStr(FileExist(item[2]), "D")) {    ;文件夹类型
                item[2] := GlobalData.imgDir "\folder.png"
            } else if (!this.imgPathToImgListIndex.Has(item[2])) {    ;未载入则添加进字典中
                ext := SubStr(item[1], -4)    ;对原文件类型进行判断
                if (ext = '.lnk' and FileExist(item[1])) {    ;快捷方式则转为其指向文件
                    FileGetShortcut(item[1], &target, , , , &outIcon)
                    if (!outIcon)
                        outIcon := target
                    item[2] := outIcon
                    ext := SubStr(target, -4)
                }

                index := IL_Add(this.imgListID, item[2])
                if (!index)    ; 图片载入失败
                {
                    img := "program.png"    ;默认图标
                    switch ext, 0 {
                        case ".ahk", ".ah2": img := "autohotkey.png"
                        case ".jpg", ".jpeg", ".png", ".ico": img := "img.png"
                        case ".txt": img := "txt.png"
                    }
                    changeFlag := true
                    item[2] := GlobalData.imgDir "\" img    ;使用默认图片
                }
                else
                    this.imgPathToImgListIndex[item[2]] := index
            }
            ; 否则图标已加载
        }

        ; 重载插件图标
        this.pluginLoadImgs()

        if (reloadIL and oldImgListID)
            DllCall("ImageList_Destroy", "Uint", oldImgListID)

        SearchGui.placeholder := "Hi, Starter"
    }

    ; 搜索即重置列表显示匹配的内容
    static search(sortFlag := true) {
        keyword := SearchGui.searchText
        if (StrLen(keyword)) {
            GlobalData.startupSearchResult := []
            ;匹配（任意关键词包含搜索内容时匹配）
            for item in GlobalData.startupData {
                loop item.Length - 3 {    ;依次对关键词（包括显示名称）进行判断，忽略大小写
                    k := item[3 + A_Index]
                    if (InStr(k, keyword)) {
                        GlobalData.startupSearchResult.Push(item)
                        break
                    }
                }
            }
        } else    ;搜索词为空时显示所有
            GlobalData.startupSearchResult := GlobalData.startupData

        ;排序(优先级降序，其次按显示名称)
        if (sortFlag)    ;有时不需要重排顺序
            QuickSort(GlobalData.startupSearchResult, (itemA, itemB) => itemB[3] == itemA[3] ? StrCompare(itemA[4], itemB[4]) : itemB[3] - itemA[3])

        ;显示新列表
        this.listView.Opt("-Redraw")    ;禁用重绘
        this.listView.Delete()
        ;插件搜索并添加插件项到列表
        this.pluginSearchAndAdd()
        ; 添加启动项到列表
        for item in GlobalData.startupSearchResult {
            if (!FileExist(item[1]))    ; 文件不存在则使用error图标
                this.listView.Add("Icon" this.imgPathToImgListIndex[GlobalData.imgDir "\error.png"], "  " item[4])
            else
                this.listView.Add("Icon" this.imgPathToImgListIndex[item[2]], "  " item[4])
        }
        ;重置listView和gui高度
        len := GlobalData.startupSearchResult.Length + this.pluginSearchResult.Length
        LVHeight := Round((len >= 8 ? 8 : len) * 26.4)    ; 此处不需要DPI缩放计算
        this.listView.Move(, , , LVHeight)
        this.listView.ModifyCol(1, "480")
        this.focusedRow := 1    ;聚焦第一行
        this.listView.Opt("Redraw")
        WinMove(, , 500 * (A_ScreenDPI / 96), Round((LVHeight + 55) * (A_ScreenDPI / 96)), SearchGui.gui)
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
            ;匹配（标题或任意关键词包含搜索内容时匹配）
            for item in this.pluginData {
                if (InStr(item.title, keyword)) {
                    this.pluginSearchResult.Push(item)
                    continue
                }
                for kw in item.keywords {
                    if (InStr(kw, keyword)) {
                        this.pluginSearchResult.Push(item)
                        break
                    }
                }
            }
        } else    ;搜索词为空时显示所有
            this.pluginSearchResult := this.pluginData

        for item in this.pluginSearchResult {
            path := Format("Plugin:{}:{}", item.name, item.index)
            if (!this.imgPathToImgListIndex.Has(path))    ; 图标载入失败则使用默认图标
                this.listView.Add("Icon" this.imgPathToImgListIndex[GlobalData.imgDir "\plugin.ico"], "  " item.title)
            else
                this.listView.Add("Icon" this.imgPathToImgListIndex[path], "  " item.title)
        }
    }
}