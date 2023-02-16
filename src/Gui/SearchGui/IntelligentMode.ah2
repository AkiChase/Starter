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
                        else if (item["match"]["type"] == "reg" and RegExMatch(keyword, item["match"]["exp"]))
                            GlobalData.intelligentSearchResult.Push(item)
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


    ; 超时自动隐藏
    static autoHide() {
        if (!WinActive(SearchGui.gui)) {
            this.hideGui()
        }
    }
}