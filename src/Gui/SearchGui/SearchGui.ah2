class SearchGui {
    ; static gui := unset
    ; static edit := unset
    ; static thumbList := unset
    ; static thumb := unset

    static hideTime := 0

    ;#region 设置搜索框占位符
    static placeholder {
        set => DllCall("User32.dll\SendMessageW", "Ptr", SearchGui.edit.Hwnd, "Uint", (0x1500 + 1), "Ptr", True, "WStr", value)
    }
    ;#endregion

    ;#region 设置搜索模式 0: 启动模式, 1: 智能模式 ,-1: 插件模式
    static _mode := -2
    static mode {
        get => this._mode
        set {
            if (this._mode == value)    ; 不需要切换时直接返回
                return
            this._mode := value
            if (this._mode == 1) {    ; IntelligentMode
                this.thumb.Value := "hBitmap:*" this.thumbList[2]
                this.placeholder := "Hi, type something 😃"
                for c in [StartupMode, PluginMode]
                    c.autoHideFlag := c.listView.Visible := false
                IntelligentMode.listView.Visible := true

                this.searchText := this.searchText    ;不清空内容直接搜索
                IntelligentMode.autoHideFlag := true    ; 启动本模式自动隐藏

            } else if (this._mode == 0) {    ; StartupMode
                this.thumb.Value := "hBitmap:*" this.thumbList[1]
                this.placeholder := "Hi, Starter"
                for c in [IntelligentMode, PluginMode]
                    c.autoHideFlag := c.listView.Visible := false
                StartupMode.listView.Visible := true

                this.searchText := this.searchText    ;不清空内容直接搜索
                StartupMode.autoHideFlag := true    ; 启动本模式自动隐藏
            } else { ; PluginMode
                ; 根据图像句柄类型载入
                If (DllCall("GetObjectType", "Ptr", PluginMode.thumb) = 7) ;  OBJ_BITMAP = 7
                    this.thumb.Value := "hBitmap:*" PluginMode.thumb
                else
                    this.thumb.Value := "hIcon:*" PluginMode.thumb

                for c in [IntelligentMode, StartupMode]
                    c.autoHideFlag := c.listView.Visible := false
                PluginMode.listView.Visible := true
                PluginMode.autoHideFlag := true    ; 启动本模式自动隐藏
                ; searchText的调整留给切换程序
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
            if (this.mode == 1) {
                IntelligentMode.search()
            } else if (this.mode == 0) {
                StartupMode.search()
            } else {
                PluginMode.searchHandler(Value)
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


        this.thumbList := [LoadPicture(GlobalData.imgDir "\Starter.png", "w64"), LoadPicture(GlobalData.imgDir "\AI.png", "w64")]
        this.thumb := this.gui.AddPicture("x460 y10 w30 h30", "hBitmap:*" this.thumbList[1])

        ; 回车触发
        this.gui.AddButton("Default Hidden").OnEvent("Click", (*) => this.mode == 0 ?
            StartupMode.startupRun() : this.mode == 1 ?
                IntelligentMode.intelligentRun() : PluginMode.pluginRun())

        this.gui.Show("Hide y" Round(A_ScreenHeight / 5))
        StartupMode.init()
        IntelligentMode.init()
        PluginMode.init()

        this.hotkeyInit()

        this.hideTime := DateAdd(A_Now, -10, "m") ; 保证初始hideTime足够早
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
                IntelligentMode.showGui(GetSelectedText())
                KeyWait("CapsLock")    ;等待松开
            }
        }

        Hotkey("~CapsLock", capsLockHandler, "Off") ;先不开启热键，等加载完毕后再开启

        ; 根据模式和热键内容执行
        hotkeyHandler(key) {
            if (this.mode == 1) {
                if (IntelligentMode.hotkeyHandlerMap.Has(key))
                    IntelligentMode.hotkeyHandlerMap[key]()
            } else if (this.mode == 0) {
                if (StartupMode.hotkeyHandlerMap.Has(key))
                    StartupMode.hotkeyHandlerMap[key]()
            } else {
                if (PluginMode.hotkeyHandlerMap.Has(key))
                    PluginMode.hotkeyHandlerMap[key]()
            }
        }

        ;===仅当窗口激活时有效===
        HotIfWinActive("ahk_id " this.gui.Hwnd)

        Hotkey("Tab Up", key => this.mode >= 0 ? this.mode := !this.mode : 0) ;0,1模式下互相切换,-1模式下忽略
        ; 清空、隐藏
        Hotkey("~Esc", hotkeyHandler)
        ; 文件夹中显示
        Hotkey("~Left Up", hotkeyHandler)
        ; 上下移动焦点行
        Hotkey("Down", hotkeyHandler)
        Hotkey("Up", hotkeyHandler)
        HotIf()
    }

    ; 隐藏时间是否在时限
    static hideTimeDiff() {
        return DateDiff(A_Now, SearchGui.hideTime, "s") < 15
    }

    static recoverGui() {
        if (this.mode == 0) {
            StartupMode.autoHideFlag := 1
        } else if (this.mode == 1) {
            IntelligentMode.autoHideFlag := 1
        } else {
            PluginMode.autoHideFlag := 1
        }
        this.gui.Show()
        this.edit.Focus()
        IME_SET(0)
    }

    ; 根据模式隐藏主界面
    static hideGui() {
        if (this.mode == 0) {
            StartupMode.hideGui()
        } else if (this.mode == 1) {
            IntelligentMode.hideGui()
        } else {
            PluginMode.hideGui()
        }
    }
}