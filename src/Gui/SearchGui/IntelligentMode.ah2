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
        this.listView := SearchGui.gui.Add("ListView", "x10 y50 w510 r8 -Multi -hdr -E0x200 Count Hidden" GlobalData.programData.Length, [""])
        this.listView.SetFont("s14 w700 c444444")
    }


    static hideGui() {
        ToolTip("暂无智能模式")
    }


    ; 超时自动隐藏
    static autoHide() {
        if (!WinActive(SearchGui.gui)) {
            this.hideGui()
        }
    }
}