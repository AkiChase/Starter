class SearchGui {
    ; static gui := unset
    ; static edit := unset
    ; static thumbList := unset
    ; static thumb := unset
    ; static contentThumb := unset

    static noRecover := true
    static hideTime := A_Now

    ;#region 设置搜索框占位符
    static _placeholder := ""
    static placeholder {
        get => this._placeholder
        set {
            if (this._placeholder != Value) {
                this._placeholder := value
                EditCtrlFunc.setPlaceholder(SearchGui.edit, value)
            }
        }
    }
    ;#endregion

    ;#region 设置搜索模式 -1: 插件模式,0: 启动模式, 1: 智能模式
    static _mode := -2
    static mode {
        get => this._mode
        set {
            if (this._mode == value) {  ; 不需要切换时,强制激活指定的autoHide
                l := [PluginMode, StartupMode, IntelligentMode]
                curModeC := l[Value + 2], l.RemoveAt(Value + 2)
                curModeC.autoHideFlag := true
                for c in l
                    c.autoHideFlag := false
                return
            }
            ;非智能模式下且存在非文本pastedContent时，切换前要清除pastedContent
            if (value != 1 && this._pastedContentType != "text")
                this.clearPastedContent()

            this._mode := value
            if (this._mode == 1) {    ; IntelligentMode
                this.thumb.Value := "hBitmap:*" this.thumbList[2]
                this.placeholder := IntelligentMode.defaultPlaceholder
                for c in [StartupMode, PluginMode]
                    c.autoHideFlag := c.listView.Visible := false
                IntelligentMode.listView.Visible := true

                this.searchText := this.searchText    ;不清空内容直接搜索
                IntelligentMode.autoHideFlag := true    ; 启动本模式自动隐藏

            } else if (this._mode == 0) {    ; StartupMode
                this.thumb.Value := "hBitmap:*" this.thumbList[1]
                this.placeholder := StartupMode.defaultPlaceholder
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

    ;#region 粘贴内容
    static clearPastedContent := (this) => (this._pastedContentType := "text", this.pastedContent := "")
    static _pastedContentType := "text"
    static _pastedContent := ""
    static pastedContent {
        get => this._pastedContent
        set {
            if (this._pastedContentType = "bitmap"
                && DllCall("OpenClipboard", "ptr", 0) && DllCall("IsClipboardFormatAvailable", "uint", 2)) {
                ; 位图
                hBitmap := DllCall("GetClipboardData", "uint", 2, "ptr") ; 指向剪切板内数据
                hBitmap := LoadPicture("HBITMAP:*" hBitmap) ;复制一份
                DllCall("CloseClipboard")

                this.placeholder := "", this.edit.Move(50, , 455)
                this.contentThumb.Value := "HBITMAP:*" hBitmap, this.contentThumb.Visible := true
                this.placeholder := "图片", this._pastedContent := hBitmap
            } else if (this._pastedContentType = "file" && FileExist(value)) {
                ; 文件
                hIcon := SubStr(Value, InStr(Value, ".", , , -1) + 1) = "exe" ?
                    LoadPicture(Value, "icon1", &_) : PluginHelper.Utils.associatedHIcon(value)
                this.placeholder := "", this.edit.Move(50, , 455)
                this.contentThumb.Value := "HICON:" hIcon, this.contentThumb.Visible := true
                this.placeholder := "文件", this._pastedContent := value
            } else {
                ; 视作文本
                this._pastedContentType := "text"
                this.placeholder := "", this.edit.Move(10, , 495)
                this.contentThumb.Visible := false, this._pastedContent := value
                this.placeholder := [PluginMode, StartupMode, IntelligentMode][this.mode + 2].defaultPlaceholder
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

        this.edit := this.gui.AddEdit("x10 y10 h30 w495 -E0x200")
        this.edit.OnEvent("ContextMenu", (*) => 0)

        search(edit, info) {    ;防抖
            static f := (*) => this.searchText := this.edit.Value
            SetTimer(f, 0)
            SetTimer(f, -50)
        }
        this.edit.OnEvent("Change", search)    ; 文本变动事件
        this.gui.OnEvent("DropFiles", (g, c, fileList, *) => this.dropAddItem(fileList))    ; 文件拖入事件


        this.thumbList := [LoadPicture(GlobalData.imgDir "\Starter.png", "w64"), LoadPicture(GlobalData.imgDir "\AI.png", "w64")]
        this.thumb := this.gui.AddPicture("x510 y10 w30 h30", "hBitmap:*" this.thumbList[1])

        this.contentThumb := this.gui.AddPicture("x7 y7 w36 h36 +Border +Hidden")

        ; 回车触发
        this.gui.AddButton("Default Hidden").OnEvent("Click", (*) => this.mode == 0 ?
            StartupMode.startupRun() : this.mode == 1 ?
                IntelligentMode.intelligentRun() : PluginMode.pluginRun())

        this.gui.Show("w550 Hide y" Ceil(A_ScreenHeight / 5))
        StartupMode.init()
        IntelligentMode.init()
        PluginMode.init()

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
                content := GetSelectedText(, &outType)
                this.noRecover := true ; 保证能显示智能模式
                IntelligentMode.showGui(content) ; 填入内容
                if (outType != 'timeout') {
                    this._pastedContentType := outType
                    this.pastedContent := content
                }
                KeyWait("CapsLock")    ;等待松开, 避免重复调用
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
        Hotkey("~Right Up", hotkeyHandler)
        ; 上下移动焦点行
        Hotkey("Down", hotkeyHandler)
        Hotkey("Up", hotkeyHandler)
        Hotkey("$^V", hotkeyHandler)
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
    static hideGui(recordHideTime := false) {
        if (this.mode == 0) {
            StartupMode.hideGui()
        } else if (this.mode == 1) {
            IntelligentMode.hideGui()
        } else {
            PluginMode.hideGui()
        }
        if (recordHideTime) ;记录关闭时间，15s内可恢复
            SearchGui.hideTime := A_Now
    }
}