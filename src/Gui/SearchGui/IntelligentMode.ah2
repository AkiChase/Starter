class IntelligentMode {
    static listView := unset
    static menu := unset
    static menuRow := 0
    static imgListID := 0
    static imgPathToImgListIndex := Map()
    static hotkeyHandlerMap := Map()
    static autoHideFunc := this.autoHide.Bind(this)

    static init() {
        ; 本列表默认隐藏
        this.listView := SearchGui.gui.Add("ListView", "x10 y50 w510 r8 -Multi -hdr -E0x200 Hidden Count" 3, [""])
        this.listView.SetFont("s14 w700 c444444")

        this.reloadSearchList()

        ; 鼠标双击运行
        this.listView.OnEvent("DoubleClick", (_lv, rowNum) => this.intelligentHandler(rowNum))
        ; ; 菜单栏
        ; this.listView.OnEvent("ContextMenu", (_lv, rowNum, *) => this.showMenu(rowNum))

        ; 启动模式热键处理函数
        this.hotkeyHandlerMap["+Esc"] := () => StrLen(SearchGui.edit.Value) ? this.clearSearchWords() : this.hideGui()
        this.hotkeyHandlerMap["Down"] := () => this.focusNextRow()
        this.hotkeyHandlerMap["Up"] := () => this.focusNextRow(true)


    }

    static runWithHandler(item) {
        editVal := SearchGui.edit.Value
        script := item["script"]
        if (script["type"] == "arg") {    ; 传递单命令行参数
            arg := StrReplace(editVal, '"', '""')    ; 双引号转义为两个双引号
            Run(Format('"{}" "{}"', script["program"], arg))
        }
        else if (script["type"] == "args") {    ; 传递多命令行参数，不进行转义等操作
            Run(Format('"{}" {}', script["program"], editVal))
        }
        else    ; type: none
            Run(editVal)
    }

    static searchHandler(item) {
        Run(Format(item["url"], SearchGui.edit.Value))
    }

    ; 根据项目执行对应操作
    static intelligentHandler(rowNum := -1) {
        static handler := Map("run-with", this.runWithHandler, "search", this.searchHandler)
        if (rowNum == -1)    ;说明需要获取焦点所在行
            rowNum := this.listView.GetNext(, "F")
        if (rowNum) {
            item := GlobalData.intelligentSearchResult[rowNum]
            if (handler.Has(item["group"]))
                handler[item["group"]](this, item)
            else
                MsgBox("非法项目", "提示", 0x2040)

            this.hideGui()
        }
    }

    ; 重新加载搜索列表图标资源
    static reloadSearchList(reloadIL := true) {
        SearchGui.setEditplaceholder("正在加载智能列表...")
        SearchGui.edit.Value := ""    ;清空搜索框
        this.listView.Delete()    ;清空智能列表
        if (reloadIL) {    ; reloadIL为false时是为了仅添加新资源
            this.imgPathToImgListIndex := Map()    ;重置图片路径与序号映射
            oldImgListID := 0
            if (this.imgListID)
                oldImgListID := this.imgListID    ;标记需要删除旧图片列表
            this.imgListID := DllCall("ImageList_Create", "Int", 32, "Int", 32, "Int", 32, "Int", 1, "Int", 1)    ;创建新图片列表
            this.listView.SetImageList(this.imgListID, 1)
        }
        ; 载入表示图片错误的图标
        this.imgPathToImgListIndex[GlobalData.imgDir "\noImg.png"] := IL_Add(this.imgListID, GlobalData.imgDir "\noImg.png")
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
        if (reloadIL and oldImgListID)    ; 有需要销毁的图片列表
            DllCall("ImageList_Destroy", "Uint", oldImgListID)
        SearchGui.setEditplaceholder('Hi, Starter')
    }
    ; 搜索即重置列表显示匹配的内容
    static search() {
        keyword := SearchGui.edit.Value
        if (StrLen(keyword)) {
            GlobalData.intelligentSearchResult := []
            ; 匹配所有符合项
            for name in GlobalData.intelligentGroups {
                if (GlobalData.intelligentData.Has(name)) {
                    for item in GlobalData.intelligentData[name] {
                        if (item["match"]["type"] == "str")
                            GlobalData.intelligentSearchResult.Push(item)
                        else if (item["match"]["type"] == "reg") {
                            for exp in item["match"]["exp"]
                                if RegExMatch(keyword, exp) {
                                    GlobalData.intelligentSearchResult.Push(item)
                                    break
                                }
                        }
                    }
                }
            }
            ; 按拟定的优先级降序排列
            QuickSort(GlobalData.intelligentSearchResult, (itemA, itemB) => GlobalData.intelligentMatchPriority[itemB["match"]["type"]] - GlobalData.intelligentMatchPriority[itemA["match"]["type"]])
        } else    ; 搜索词为空什么都不显示
            GlobalData.intelligentSearchResult := []
        ;显示新列表
        this.listView.Opt("-Redraw")    ;禁用重绘
        this.listView.Delete()
        for item in GlobalData.intelligentSearchResult {
            if (this.imgPathToImgListIndex.Has(item["thumb"]))
                this.listView.Add("Icon" this.imgPathToImgListIndex[item["thumb"]], "  " item["title"])
            else    ; 无图标 使用特殊路径
                this.listView.Add("Icon" this.imgPathToImgListIndex[GlobalData.imgDir "\noImg.png"], "  " item["title"])
        }
        ;重置listView和gui高度
        LVHeight := Round((GlobalData.intelligentSearchResult.Length >= 8 ? 8 : GlobalData.intelligentSearchResult.Length) * 26.4)    ; 此处不需要DPI缩放计算
        this.listView.Move(, , , LVHeight)
        this.listView.ModifyCol(1, "480")
        this.listView.Modify(1, "Select Focus Vis")    ;聚焦第一行
        this.listView.Opt("Redraw")
        WinMove(, , 500 * (A_ScreenDPI / 96), Round((LVHeight + 55) * (A_ScreenDPI / 96)), SearchGui.gui)
    }

    ; 智能模式下隐藏主界面
    static hideGui() {
        SetTimer(this.autoHideFunc, 0)
        SearchGui.edit.Value := ""
        SearchGui.gui.hide()
    }

    ; 聚焦下一行（循环）
    static focusNextRow(reverse := false) {
        rowNum := this.listView.GetNext(, "F")
        if (reverse) {
            if (rowNum > 1)
                this.listView.Modify(rowNum - 1, "Select Focus Vis")
            else
                this.listView.Modify(this.listView.GetCount(), "Select Focus Vis")
        } else {
            if (rowNum < this.listView.GetCount())
                this.listView.Modify(rowNum + 1, "Select Focus Vis")
            else
                this.listView.Modify(1, "Select Focus Vis")
        }
    }

    ; 清空搜索框
    static clearSearchWords() {
        SearchGui.edit.Value := ""
        this.search()
    }

    ; 超时自动隐藏
    static autoHide() {
        if (!WinActive(SearchGui.gui)) {
            this.hideGui()
        }
    }
}