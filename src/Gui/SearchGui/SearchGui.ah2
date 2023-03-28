class SearchGui {
    ; static gui := unset
    ; static edit := unset
    ; static thumbList := unset

    ;#region 设置搜索框占位符
    static placeholder {
        set => DllCall("User32.dll\SendMessageW", "Ptr", SearchGui.edit.Hwnd, "Uint", (0x1500 + 1), "Ptr", True, "WStr", value)
    }
    ;#endregion

    ;#region 设置搜索模式 0: 启动模式, 1: 智能模式
    static _mode := 0
    static mode {
        get => this._mode
        set {
            if (this._mode == value)    ; 不需要切换时直接返回
                return
            this._mode := value
            if (this._mode) {    ; IntelligentMode
                this.thumbList[1].Visible := false
                this.thumbList[2].Visible := true
                this.placeholder := "Hi, type something 😃"
                StartupMode.autoHideFlag := false    ; 关闭另一模式下的自动隐藏
                StartupMode.listView.Visible := false    ; 隐藏另一模式的列表
                IntelligentMode.listView.Visible := true

                this.searchText := this.searchText    ;不清空内容直接搜索
                IntelligentMode.autoHideFlag := true    ; 启动本模式自动隐藏

            } else {    ; StartupMode
                this.thumbList[1].Visible := true
                this.thumbList[2].Visible := false
                this.placeholder := "Hi, Starter"
                IntelligentMode.autoHideFlag := false    ; 关闭另一模式下的自动隐藏
                IntelligentMode.listView.Visible := false    ; 隐藏另一模式的列表
                StartupMode.listView.Visible := true

                this.searchText := this.searchText    ;不清空内容直接搜索
                StartupMode.autoHideFlag := true    ; 启动本模式自动隐藏
            }
        }
    }
    ;#endregion

    ;#region 搜索内容
    static _searchText := ""
    static searchText {
        get => this._searchText
        set {
            this._searchText := Value
            if (this.mode) {
                IntelligentMode.search()
            } else {
                StartupMode.search()
            }
        }
    }
    ;#endregion

    ; 初始化
    static init() {
        this.gui := Gui("Owner AlwaysOnTop -Resize -Caption", "Starter")
        this.gui.BackColor := "FFFFFF"
        this.gui.SetFont("s20 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        this.gui.MarginY := 0

        this.edit := this.gui.AddEdit("x10 y10 h30 w445 -E0x200")
        this.placeholder := "Hi, Starter"
        this.edit.Focus()

        search(edit, info) {    ;防抖
            static f := (*) => this.searchText := this.edit.Value
            SetTimer(f, 0)
            SetTimer(f, -50)
        }
        this.edit.OnEvent("Change", search)    ; 文本变动事件
        this.gui.OnEvent("DropFiles", (g, c, fileList, *) => this.dropAddItem(fileList))    ; 文件拖入事件

        this.thumbList := [this.gui.AddPicture("x460 y10 w30 h30", GlobalData.imgDir "\Starter.png")
            , this.gui.AddPicture("x460 y10 w30 h30 Hidden", GlobalData.imgDir "\AI.png")]

        ; 回车触发
        this.gui.AddButton("Default Hidden").OnEvent("Click", (*) => this.mode ? IntelligentMode.intelligentRun() : StartupMode.startSelectedFile())

        this.gui.Show("Hide y" Round(A_ScreenHeight / 5))
        StartupMode.init()
        IntelligentMode.init()

        this.hotkeyInit()
    }

    ; 拖拽添加
    static dropAddItem(fileList) {
        for filePath in fileList {
            SplitPath(filePath, , , , &fileNameNoExt)
            GlobalData.startupData.Push([filePath, filePath, 0, fileNameNoExt, ChineseFirstChar(fileNameNoExt)])
        }

        StartupMode.loadImgs(false)    ;载入新图片，不重新加载其他图片

        if (SearchGui.mode !== 0)    ; 非启动模式下，转为启动模式
            SearchGui.mode := 0    ; 转换启动模式时会搜索一次
        else
            StartupMode.search()
    }

    ; 热键初始化
    static hotkeyInit() {
        capsLockHandler(key) {
            if (KeyWait("CapsLock", "T0.5")) {
                if (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 300) {
                    StartupMode.showGui()
                }
            } else {
                StartupMode.showGui(GetSelectedText())
                KeyWait("CapsLock")    ;等待松开
                SetCapsLockState(!GetKeyState("CapsLock", "T"))    ; 长按会修改1次状态，此处修改回原来的
                ; 搜索获取选中内容
            }
        }

        ; 以启动模式激活
        Hotkey("~CapsLock", capsLockHandler)

        ; 根据模式和热键内容执行
        hotkeyHandler(key) {
            if (this.mode) {
                if (IntelligentMode.hotkeyHandlerMap.Has(key))
                    IntelligentMode.hotkeyHandlerMap[key]()
            } else {
                if (StartupMode.hotkeyHandlerMap.Has(key))
                    StartupMode.hotkeyHandlerMap[key]()
            }
        }

        ;===仅当窗口激活时有效===
        HotIfWinActive("ahk_id " this.gui.Hwnd)

        Hotkey("Tab Up", key => this.mode := !this.mode)
        ; 清空、隐藏
        Hotkey("+Esc", hotkeyHandler)
        ; 文件夹中显示
        Hotkey("~Left Up", hotkeyHandler)
        ; 上下移动焦点行
        Hotkey("Down", hotkeyHandler)
        Hotkey("Up", hotkeyHandler)
        HotIf()
    }

    ; 根据模式隐藏主界面
    static hideGui() {
        if (this.mode) {
            IntelligentMode.hideGui()
        } else {
            StartupMode.hideGui()
        }
    }
}