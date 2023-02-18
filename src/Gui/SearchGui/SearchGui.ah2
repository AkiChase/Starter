class SearchGui {
    ; static gui := unset
    ; static edit := unset
    static thumbList := []
    static curMode := 0

    static init() {
        this.gui := Gui("Owner AlwaysOnTop -Resize -Caption", "Starter")
        this.gui.BackColor := "FFFFFF"
        this.gui.SetFont("s20 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        this.gui.MarginY := 0

        this.edit := this.gui.AddEdit("x10 y10 h30 w445 -E0x200")
        this.setEditplaceholder('Hi, Starter')
        this.edit.Focus()

        search(edit, info) {    ;防抖
            static f := this.search.Bind(this)
            SetTimer(f, 0)
            SetTimer(f, -50)
        }
        this.edit.OnEvent("Change", search)    ; 文本变动事件
        this.gui.OnEvent("DropFiles", StartupMode.dropAddItem)    ; 文件拖入事件

        this.thumbList := [this.gui.AddPicture("x460 y10 w30 h30", GlobalData.imgDir "\Starter.png")
            , this.gui.AddPicture("x460 y10 w30 h30 Hidden", GlobalData.imgDir "\AI.png")]

        this.gui.AddButton("Default Hidden").OnEvent("Click", this.enterButtonEvent.Bind(this))

        this.gui.Show("Hide y" Round(A_ScreenHeight / 5))
        StartupMode.init()
        IntelligentMode.init()

        this.hotkeyInit()
    }

    ; 回车触发按钮事件
    static enterButtonEvent(*) {
        if (this.curMode) {
            IntelligentMode.intelligentHandler()
        } else {
            StartupMode.startSelectedFile()
        }
    }

    ; 热键初始化
    static hotkeyInit() {
        ; 以启动模式激活
        Hotkey("~CapsLock Up", key => (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 300) ? StartupMode.showGui() : 0)

        ; 根据模式和热键内容执行
        hotkeyHandler(key) {
            if (this.curMode) {
                if (IntelligentMode.hotkeyHandlerMap.Has(key))
                    IntelligentMode.hotkeyHandlerMap[key]()
            } else {
                if (StartupMode.hotkeyHandlerMap.Has(key))
                    StartupMode.hotkeyHandlerMap[key]()
            }
        }

        ;===仅当窗口激活时有效===
        HotIfWinActive("ahk_id " this.gui.Hwnd)

        Hotkey("Tab Up", key => this.toggleMode(!this.curMode))
        ; 清空、隐藏
        Hotkey("+Esc", hotkeyHandler)
        ; 文件夹中显示
        Hotkey("~Left Up", hotkeyHandler)
        ; 上下移动焦点行
        Hotkey("Down", hotkeyHandler)
        Hotkey("Up", hotkeyHandler)
        HotIf()
    }

    ; 按需切换模式 0: StartupMode, 1: IntelligentMode
    static toggleMode(mode := 0) {
        if (this.curMode == mode)    ; 不需要切换时直接停止
            return

        this.curMode := mode
        if (mode) {    ; IntelligentMode
            this.thumbList[1].Visible := false
            this.thumbList[2].Visible := true
            this.setEditplaceholder('Hi, type something 😃')
            SetTimer(StartupMode.autoHideFunc, 0)    ; 关闭另一模式下的自动隐藏
            StartupMode.listView.Visible := false    ; 隐藏另一模式的列表
            IntelligentMode.listView.Visible := true

            this.search()    ;不清空内容直接搜索
            SetTimer(IntelligentMode.autoHideFunc, 1000)    ; 启动本模式自动隐藏

        } else {    ; StartupMode
            this.thumbList[1].Visible := true
            this.thumbList[2].Visible := false
            this.setEditplaceholder('Hi, Starter')
            SetTimer(IntelligentMode.autoHideFunc, 0)    ; 关闭另一模式下的自动隐藏
            IntelligentMode.listView.Visible := false    ; 隐藏另一模式的列表
            StartupMode.listView.Visible := true

            this.search()    ;不清空内容直接搜索
            SetTimer(StartupMode.autoHideFunc, 1000)    ; 启动本模式自动隐藏
        }
    }

    ; 根据模式进行搜索
    static search() {
        if (this.curMode) {
            IntelligentMode.search()
        } else {
            StartupMode.search()
        }
    }

    ; 根据模式隐藏主界面
    static hideGui() {
        if (this.curMode) {
            IntelligentMode.hideGui()
        } else {
            StartupMode.hideGui()
        }
    }

    ; 设置搜索框占位符
    static setEditplaceholder(text) {
        DllCall("User32.dll\SendMessageW", "Ptr", SearchGui.edit.Hwnd, "Uint", (0x1500 + 1), "Ptr", True, "WStr", text)
    }
}