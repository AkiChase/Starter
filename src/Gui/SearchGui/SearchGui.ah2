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
                this._placeholder := Value
                EditCtrlFunc.setPlaceholder(SearchGui.edit, Value)
            }
        }
    }
    ;#endregion

    ;#region 设置搜索模式 -1: 插件模式,0: 启动模式, 1: 智能模式
    static _mode := -2
    static mode {
        get => this._mode
        set {
            if (this._mode == Value) {  ; 不需要切换时,强制激活指定的autoHide
                l := [PluginMode, StartupMode, IntelligentMode]
                curModeC := l[Value + 2], l.RemoveAt(Value + 2)
                curModeC.autoHideFlag := true
                for c in l
                    c.autoHideFlag := false
                return
            }
            ;将切换启动模式且存在非文本pastedContent时，切换前要清除pastedContent
            if (Value = 0 && this._pastedContentType != "text")
                this.clearPastedContent()

            ;将切换启动模式且窗口匹配模式开启时，切换前要关闭窗口匹配模式
            if (Value = 0 && this.winInfoMatchFlag)
                this.winInfoMatchFlag := false

            this._mode := Value
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
            } else if (this._pastedContentType = "file") {
                ; 文件
                fileList := Type(Value) == "Array" ? Value : StrSplit(Value, "`r`n") ; 自动处理数组或字符串类型

                hIcon := SubStr(fileList[1], InStr(fileList[1], ".", , , -1) + 1) = "exe" ?
                    LoadPicture(fileList[1], "icon1", &_) : PluginHelper.Utils.associatedHIcon(fileList[1])
                this.placeholder := "", this.edit.Move(50, , 455)
                this.contentThumb.Value := "HICON:" hIcon, this.contentThumb.Visible := true
                this.placeholder := "文件", this._pastedContent := fileList
                if (fileList.Length > 1)
                    this.showFileListInfo(fileList)
            } else {
                ; 视作文本
                this._pastedContentType := "text"
                this.placeholder := "", this.edit.Move(10, , 495)
                this.contentThumb.Visible := false, this._pastedContent := Value
                this.placeholder := [PluginMode, StartupMode, IntelligentMode][this.mode + 2].defaultPlaceholder
            }
        }
    }
    ;#endregion

    ; 长按获取的当前窗口信息
    static workWinInfo := {
        hwnd: 0,
        title: "",
        class: "",
        processPath: "",
        processName: ""
    }

    ;#region 是否处于窗口匹配
    static _winInfoMatchFlag := false
    static winInfoMatchFlag {
        get => this._winInfoMatchFlag
        set => this._winInfoMatchFlag := Value
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
        this.thumb.OnEvent("Click", (*) => this.winInfoMatchFlag ? this.showWinInfo() : 0)

        this.contentThumb := this.gui.AddPicture("x7 y7 w36 h36 +Border +Hidden")

        this.contentThumb.OnEvent("Click", (*) => this._pastedContentType = "file" ? this.showFileListInfo(this.pastedContent) : 0)

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

    ; 拖入添加
    static dropAddItem(fileList) {
        if (SearchGui.mode == 0) {
            for filePath in fileList {
                SplitPath(filePath, , , , &fileNameNoExt)
                GlobalData.startupData.Push([filePath, filePath, 0, fileNameNoExt, ChineseFirstChar(fileNameNoExt)])
            }
            StartupMode.loadImgs(false)    ;载入新图片，不重新加载其他图片
            StartupMode.search()
            Tip.show("拖入添加启动项", "添加成功, 新增 " fileList.Length " 个启动项", 2000)
        } else if (SearchGui.mode == 1) {
            SearchGui._pastedContentType := "file"
            SearchGui.pastedContent := fileList
            SearchGui.searchText := SearchGui.searchText ; 不修改内容，直接触发搜索
        } else if (SearchGui.mode == -1)
            PluginMode.onDropFiles(fileList)
    }

    ; 热键初始化
    static hotkeyInit() {
        capsLockHandler(key) {
            if (KeyWait("CapsLock", "T0.4")) { ; 非长按
                if (A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 300) {
                    StartupMode.showGui() ; 显示并清空搜索框
                }
            } else { ; 长按0.4秒
                clipSaved := ClipboardAll()
                content := GetSelectedText(0.1, &outType) ; 等待最多0.1s剪切板

                ; 获取窗口信息
                this.workWinInfo.hwnd := WinExist("A")
                this.workWinInfo.class := WinGetClass()
                this.workWinInfo.processPath := WinGetProcessPath()
                this.workWinInfo.processName := WinGetProcessName()
                this.workWinInfo.title := WinGetTitle()

                ; 是否进入窗口匹配模式
                if (!content && (outType = 'text' || outType = "timeout")) { ;
                    this.winInfoMatchFlag := true ; 开启窗口匹配模式
                } else
                    this.winInfoMatchFlag := false ; 关闭窗口匹配模式

                this.noRecover := true ; 保证能显示智能模式
                IntelligentMode.showGui(outType = 'text' ? content : "")  ; 显示并视情况填入搜索框

                if (this.winInfoMatchFlag) {
                    this.placeholder := "Hi, Window Match 💻"
                    this.showWinInfo()
                }


                if (outType != 'timeout') {
                    this._pastedContentType := outType
                    this.pastedContent := content
                }
                this.searchText := "" ; 触发搜索
                A_Clipboard := clipSaved
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

        ; Alt+数字快捷选中
        altHandler(key) {
            i := Integer(SubStr(key, 2))
            ; LVM_GETTOPINDEX := 0x1027
            LV := [PluginMode, StartupMode, IntelligentMode][this.mode + 2].listView
            topIndex := SendMessage(0x1027, 0, 0, , LV)
            if (topIndex + i <= LV.GetCount())
                LV.Modify(topIndex + i, "Select Focus Vis")
        }
        loop 10
            Hotkey("!" A_Index - 1, altHandler)
        HotIf()
    }

    ; 显示窗口匹配信息
    static showWinInfo() {
        WiseGuiHelper.WiseGui("workWinInfo", "Main: 0", "Theme: ,,,0", "FontSub: s14 ,雅痞-简",
            "Shadow: 1", "TextWidth: 530", "Transparency: 192", "Timer: 3000",
            "SubText: " Format("@工作窗口标题`n{}`n@工作窗口类`n{}`n@工作窗口程序`n{}"
                , this.workWinInfo.title, this.workWinInfo.class, this.workWinInfo.processName)
        )
        if (WinExist("WiseGui\workWinInfo ahk_class AutoHotkeyGUI")) {
            WinGetPos(&x, &y, , , this.gui)
            WinGetPos(, , , &h)
            WinMove(x, y - h - 10)
        }
    }

    ; 显示文件列表信息
    static showFileListInfo(fileList) {
        loop 3 {
            if (fileList.Has(A_Index))
                msg .= fileList[A_Index] "`n`n"
            else
                break
        }
        if (fileList.Has(4))
            msg .= "......"
        Tip.show("共" fileList.Length "个文件", msg, 4000)
    }

    ; 隐藏时间是否在时限
    static hideTimeDiff() {
        return DateDiff(A_Now, SearchGui.hideTime, "s") < 15
    }

    ; 恢复窗口
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