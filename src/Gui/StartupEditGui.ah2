class StartupEditGui {
    ; static gui := unset
    ; static suListView := unset
    ; static editGroup := unset
    ; static kwListView := unset
    ; static _curItem := unset
    ; static kwMenu := unset

    static reloadILFlag := false
    static kwMenuRow := 0

    static _changeFlag := false
    static changeFlag {
        get => this._changeFlag
        set => this._changeFlag := this.saveBtn.Enabled := value
    }

    ;#region 当前编辑项
    static _curItem := []
    class curItem {
        static index := 0
        static outer := StartupEditGui

        static __Item[key] {
            get => this.%key%
            set => this.%key% := value
        }

        static filePath {
            get => this.outer._curItem[1]
            set {
                this.outer._curItem[1] := value
                this.outer.changeFlag := true
                if (this.outer.editGroup[1].Value == value)
                    return
                this.outer.editGroup[1].Value := value
            }
        }

        static icoPath {
            get => this.outer._curItem[2]
            set {
                this.outer._curItem[2] := value
                this.outer.reloadILFlag := this.outer.changeFlag := true
                if (this.outer.editGroup[2].Value == value)
                    return
                this.outer.editGroup[2].Value := value
            }
        }

        static priority {
            get => this.outer._curItem[3]
            set {
                if (value < 0)
                    value := 0
                else if (value > 999)
                    value := 999
                this.outer._curItem[3] := value
                this.outer.changeFlag := true
                if (this.outer.editGroup[3].Value == value)
                    return
                this.outer.editGroup[3].Value := value
            }

        }

        static name {
            get => this.outer._curItem[4]
            set {
                this.outer._curItem[4] := value
                this.outer.changeFlag := true
                if (this.outer.editGroup[4].Value == value)
                    return
                this.outer.editGroup[4].Value := value
            }
        }

        class keywords {
            static outer := StartupEditGui
            static __Item[index] {
                get => this.outer._curItem[index + 4]
                set {
                    this.outer._curItem[index + 4] := value
                    this.outer.changeFlag := true
                }
            }
            static Push(v) {
                this.outer._curItem.Push(v)
                this.outer.kwListView.Add(, v)
                this.outer.changeFlag := true
            }
            static RemoveAt(index) {
                this.outer._curItem.RemoveAt(4 + index)
                this.outer.kwListView.Delete(index)
                this.outer.changeFlag := true
            }
        }
    }
    ;#endregion

    ; 初始化
    static init() {
        this.gui := Gui("-Resize", "启动模式编辑界面")
        this.gui.BackColor := "FFFFFF"
        this.gui.SetFont("s14 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        this.gui.OnEvent("Close", (guiObj) => this.hideGui())
        this.gui.OnEvent("DropFiles", this.addItem)
        this.suListView := this.gui.Add("ListView", "x10 y10 w100 h380 -Multi -hdr Grid Count" GlobalData.startupData.Length, [""])
        this.suListView.ModifyCol(1, 80)
        this.suListView.SetFont("s12")
        ; 鼠标点击切换
        this.suListView.OnEvent("Click", (_lv, rowNum) => this.itemEdit(rowNum))
        ; 基本编辑
        this.editGroup := [
            this.addEditGroup("文件路径", 170, 25, "filePath")
            , this.addEditGroup("图标路径", 170, 75, "icoPath")
            , this.addEditGroup("优先级", 170, 175, "priority")
        ]
        this.editGroup[3].Opt("ReadOnly")
        this.gui.AddUpDown("Range0-999", 0)    ; 为了保证UpDown添加到优先级编辑框
        this.editGroup.Push(this.addEditGroup("显示名称", 170, 125, "name"))
        this.gui.AddButton("x505 y21 h28 w50", "选择").OnEvent("Click", (*) => this.choseFile("filePath"))
        this.gui.AddButton("x505 y71 h28 w50", "选择").OnEvent("Click", (*) => this.choseFile("icoPath"))
        ; 其他关键词编辑
        this.gui.AddGroupBox("x170 y215 w360 h175", "其他关键字").SetFont("s12")
        this.kwListView := this.gui.Add("ListView", "x175 y235 w350 h150 -Multi -hdr -ReadOnly -E0x200 Grid Count3", [""])
        this.kwListView.ModifyCol(1, "Center")
        this.kwListView.OnEvent("ItemEdit", (LV, rowNum) => this.keywordsEdit(rowNum))
        ; 其他关键词列表菜单
        this.kwListView.OnEvent("ContextMenu", (_lv, rowNum, *) => this.showMenu(rowNum))
        this.kwMenuInit()
        ; 添加按钮
        this.gui.AddButton("x10 y405 h32 w100", "添加").OnEvent("Click", (*) => this.chooseAddItem())
        ; 保存按钮
        this.saveBtn := this.gui.AddButton("x380 y405 h32 w100", "保存")
        this.saveBtn.OnEvent("Click", (*) => this.saveCurItem())
        ; 删除按钮
        this.gui.AddButton("x220 y405 h32 w100", "删除").OnEvent("Click", (*) => this.delCurItem())
        this.gui.Show("Hide w600 h450")
    }

    ; 关键字菜单初始化
    static kwMenuInit() {
        m := Menu()
        m.Add("添加关键词`t(&A)", (*) => this.curItem.keywords.Push(ChineseFirstChar(this.curItem.name)))
        m.Add("修改关键词`t(&E)", (*) => this.keywordsSendF2())
        m.Add("删除关键词`t(&X)", (*) => this.curItem.keywords.RemoveAt(this.kwMenuRow))
        m.SetIcon("1&", GlobalData.imgDir "\add.ico")
        m.SetIcon("2&", GlobalData.imgDir "\edit.ico")
        m.SetIcon("3&", GlobalData.imgDir "\delete.ico")
        this.kwMenu := m
    }

    ; 显示菜单
    static showMenu(rowNum) {
        this.kwMenuRow := rowNum
        if (rowNum)
            this.kwMenu.Enable("2&"), this.kwMenu.Enable("3&")
        else
            this.kwMenu.Disable("2&"), this.kwMenu.Disable("3&")
        this.kwMenu.Show()
    }

    ; 添加编辑框ui组件
    static addEditGroup(txt, xPos, yPos, propName) {
        textObj := this.gui.AddText("w80 x" xPos " y" yPos, txt)
        editObj := this.gui.AddEdit("w250 yp-5 xp+80")
        editObj.OnEvent("Change", this._eventEditChange.Bind(this, propName))
        return editObj
    }

    ; 事件回调修改changeFlag
    static _eventEditChange(propName, editCtrl, *) {
        this.curItem[propName] := editCtrl.Value
    }

    ; 重载启动项列表
    static reloadSULV() {
        this.suListView.Opt("-Redraw")    ;禁用重绘
        this.suListView.Delete()
        for item in GlobalData.startupData
            this.suListView.Add(, item[4])
        this.suListView.Opt("Redraw")
    }

    ; 显示Gui
    static showGui(index := 1) {
        Critical('On')    ;防止线程被中断
        for c in [SearchGui, IntelligentEditGui]
            if (WinExist(c.gui))
                c.hideGui()
        Hotkey("~CapsLock", "Off")    ; 关闭热键，防止数据冲突

        this.reloadSULV()    ; 重载启动项列表
        this.changeFlag := false

        if (GlobalData.startupData.Length >= index) {
            this.gui.Show()
            this.itemEdit(index)
            Critical('Off')
        } else {    ; 无任何项目时，curItem.index置0从而禁用各种按钮响应和关键字列表响应
            Critical('Off')
            MsgBox("启动列表内无可编辑项，请添加文件", "提示", 0x2040)
            if (this.chooseAddItem()) {
                this.gui.Show()
                this.itemEdit(1)
            }
            else {
                Hotkey("~CapsLock", "On")    ; 恢复热键
            }

        }
    }

    ; 隐藏Gui
    static hideGui() {
        Hotkey("~CapsLock", "On")    ; 恢复热键
        if (this.changeFlag) {
            if (MsgBox("是否将当前项修改内容保存？", "提示", 0x2044) = "Yes")
                this.saveCurItem()
        }
        this.gui.Hide()
    }

    ; 添加
    static chooseAddItem() {
        res := FileSelect("M35", , "请选择文件进行添加")
        if (res.Length) {
            this.addItem(res)
            return true
        }
        return false
    }

    ; 添加回调
    static addItem(args*) {
        fileList := args.Length == 1 ? args[1] : args[2]
        for filePath in fileList {
            SplitPath(filePath, , , , &fileNameNoExt)
            GlobalData.startupData.Push([filePath, filePath, 0, fileNameNoExt, ChineseFirstChar(fileNameNoExt)])
            StartupEditGui.suListView.Add(, fileNameNoExt)    ; 添加至列表
        }
        StartupMode.loadImgs(false)    ;载入新图片，不重置图片
        StartupMode.search(false)
    }

    ; 选择文件\图标路径
    static choseFile(key) {
        oldPath := this.curItem[key]
        if (key == "filePath")
            res := FileSelect("35", oldPath, "请选择文件")
        else if (key == "icoPath")
            res := FileSelect("3", oldPath, "请选择图标路径")
        else
            return

        if (StrLen(res) and oldPath !== res)
            this.curItem[key] := res
    }

    ; 删除当前项
    static delCurItem() {
        if (this.curItem.index > 0 and MsgBox("当前操作不可恢复，是否将当前项删除？", "提示", 0x2044) = "Yes") {
            this.changeFlag := false
            GlobalData.startupData.RemoveAt(this.curItem.index)
            this.suListView.Delete(this.curItem.index)
            ; 切换到下一项
            if (GlobalData.startupData.Length)
                this.itemEdit(Min(this.curItem.index, GlobalData.startupData.Length))
            else {
                this.hideGui()
                WiseGuiHelper.tooltip("提示", "启动列表内无可编辑项，请添加文件", 2500)
            }
        }
    }

    ; 保存当前项
    static saveCurItem() {
        for name in ["name", "filePath", "icoPath"] {
            if (!StrLen(this.curItem[name])) {
                WiseGuiHelper.tooltip("提示", "请完整输入参数", 1500)
                return
            }
        }

        this.suListView.Modify(this.curItem.index, , this.curItem.name)
        GlobalData.startupData[this.curItem.index] := this._curItem

        if (this.reloadILFlag) {    ; 需要完全重载图片
            StartupMode.loadImgs(true)
            this.reloadILFlag := false
        }

        this.changeFlag := false
        ToolTip("保存成功")
        SetTimer(() => ToolTip(), -1500)
    }

    ; 发送F2到listview开启编辑
    static keywordsSendF2() {
        this.kwListView.Focus()
        ControlSend("{F2}", this.kwListView, this.gui)
    }

    ; 编辑关键词回调
    static keywordsEdit(rowNum) {
        newKeyword := this.kwListView.GetText(rowNum)
        if (this.curItem.keywords[rowNum] !== newKeyword)
            this.curItem.keywords[rowNum] := newKeyword
    }

    ; 编辑项
    static itemEdit(rowNum) {
        if (rowNum > 0) {
            if (this.changeFlag) {
                if (MsgBox("是否将当前项修改内容保存？", "提示", 0x2044) = "Yes")
                    this.saveCurItem()
            }
            this.curItem.index := rowNum

            this.suListView.Modify(rowNum, "Select Focus Vis")

            oriItem := GlobalData.startupData[rowNum]
            this._curItem := []
            this._curItem.Length := 4

            ; 基本信息
            for name in ["filePath", "icoPath", "priority", "name"]
                this.curItem[name] := oriItem[A_Index]

            ; 关键词
            keywordsCount := oriItem.Length - 4
            this.kwListView.Opt("-Redraw")    ;禁用重绘
            this.kwListView.Delete()
            loop keywordsCount
                this.curItem.keywords.Push(oriItem[4 + A_Index])
            this.kwListView.Opt("Redraw")

            this.changeFlag := false

            ; 提示文件路径不存在
            if (!FileExist(this._curItem[1])) {
                WiseGuiHelper.tooltip("提示", "文件路径不存在，当前启动项无效", 2500)
            }
        }
    }
}