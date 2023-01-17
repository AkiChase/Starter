class EditGui {
    static gui := unset
    static listView := unset
    static editGroup := unset
    static keywordsListView := unset
    static curItem := unset
    static menu := unset
    static menuRow := 0
    static curItemIndex := 0
    static changeFlag := false
    static reloadILFlag := false


    static init() {
        this.gui := Gui("-Resize", "编辑界面")
        this.gui.BackColor := "FFFFFF"
        this.gui.SetFont("s14 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体

        this.gui.OnEvent("Close", (guiObj) => this.hideGui())
        this.gui.OnEvent("DropFiles", this.addItem)

        this.listView := this.gui.Add("ListView", "x10 y10 w100 h380 -Multi -hdr Grid Count" GlobalData.programData.Length, [""])
        this.listView.ModifyCol(1, 80)
        this.listView.SetFont("s12")
        ; 鼠标点击切换
        this.listView.OnEvent("Click", (_lv, rowNum) => this.itemEdit(rowNum))

        ; 基本编辑
        this.editGroup := [
            this.addEditGroup("文件路径", 170, 25)
            , this.addEditGroup("图标路径", 170, 75)
            , this.addEditGroup("优先级", 170, 175)
        ]
        this.editGroup[3].Opt("ReadOnly")
        this.gui.AddUpDown("Range0-999", 0)
        this.editGroup.Push(this.addEditGroup("显示名称", 170, 125))

        this.gui.AddButton("x505 y21 h28 w50", "选择").OnEvent("Click", (*) => this.choseFile(1))
        this.gui.AddButton("x505 y71 h28 w50", "选择").OnEvent("Click", (*) => this.choseFile(2))


        ; 其他关键词编辑
        this.gui.AddGroupBox("x170 y215 w360 h175", "其他关键字").SetFont("s12")
        this.keywordsListView := this.gui.Add("ListView", "x175 y235 w350 h150 -Multi -hdr -ReadOnly -E0x200 Grid Count3", [""])
        this.keywordsListView.ModifyCol(1, "Center")
        this.keywordsListView.OnEvent("ItemEdit", (LV, rowNum) => this.keywordsEdit(rowNum))
        ; 其他关键词列表菜单
        this.keywordsListView.OnEvent("ContextMenu", (_lv, rowNum, *) => this.showMenu(rowNum))
        this.MenuInit()

        ; 添加按钮
        this.gui.AddButton("x10 y405 h32 w100", "添加").OnEvent("Click", (*) => this.chooseAddItem())
        ; 保存按钮
        this.gui.AddButton("x380 y405 h32 w100", "保存").OnEvent("Click", (*) => this.saveCurItem())
        ; 删除按钮
        this.gui.AddButton("x220 y405 h32 w100", "删除").OnEvent("Click", (*) => this.delCurItem())

        this.gui.Show("Hide w600 h450")
    }

    static MenuInit() {
        this.menu := Menu()
        this.menu.Add("添加关键词`t(&A)", (*) => this.keywordsAdd())
        this.menu.Add("修改关键词`t(&E)", (*) => this.keywordsSendF2())
        this.menu.Add("删除关键词`t(&X)", (*) => this.keywordsDel(this.menuRow))

        this.menu.SetIcon("1&", GlobalData.imgDir "\grey-run.png")
        this.menu.SetIcon("2&", GlobalData.imgDir "\grey-edit.png")
        this.menu.SetIcon("3&", GlobalData.imgDir "\grey-delete.png")
    }


    ; 显示菜单
    static showMenu(rowNum) {
        if (!this.curItemIndex)
            return

        if (rowNum) {
            this.menuRow := rowNum
            this.menu.Enable("2&"), this.menu.Enable("3&")
        } else {
            this.menu.Disable("2&"), this.menu.Disable("3&")
        }
        this.menu.Show()
    }

    ; 添加编辑框ui组件
    static addEditGroup(txt, xPos, yPos) {
        textObj := this.gui.AddText("w80 x" xPos " y" yPos, txt)
        editObj := this.gui.AddEdit("w250 yp-5 xp+80")
        editObj.OnEvent("Change", this._eventChangeFlag)
        return editObj
    }

    ; 事件回调修改changeFlag
    static _eventChangeFlag(*) {
        EditGui.changeFlag := true
    }


    ; 显示Gui
    static showGui(index := 1) {
        Critical('On')    ;防止线程被中断
        Hotkey("~CapsLock Up", "Off")    ; 关闭热键，防止数据冲突
        SearchGui.hideGui()

        if (GlobalData.programData.Length >= index) {
            this.listView.Opt("-Redraw")    ;禁用重绘
            this.listView.Delete()
            for item in GlobalData.programData
                this.listView.Add(, item[4])
            this.listView.Modify(index, "Select Focus Vis")
            this.listView.Opt("Redraw")
            this.itemEdit(index)
        } else {    ; 无任何项目时，curItemIndex置0从而禁用各种按钮响应和关键字列表响应
            this.changeFlag := false
            this.curItemIndex := 0
            this.curItem := unset
            loop 4
                this.editGroup[A_Index].Value := ""
            this.keywordsListView.Delete()
        }


        this.gui.Show()
        Critical('Off')
    }

    ; 隐藏Gui
    static hideGui() {
        Hotkey("~CapsLock Up", "On")    ; 恢复热键
        if (this.changeFlag) {
            if (MsgBox("是否将当前项修改内容保存？", "提示", 0x2044) = "Yes")
                this.saveCurItem()
        }
        this.gui.Hide()
    }

    ; 添加
    static chooseAddItem() {
        res := FileSelect("M35", , "请选择文件")
        if (res.Length) {
            this.addItem(res)
        }
    }

    ; 添加回调
    static addItem(args*) {
        fileList := args.Length == 1 ? args[1] : args[2]
        for filePath in fileList {
            SplitPath(filePath, , , , &fileNameNoExt)
            GlobalData.programData.Push([filePath, filePath, 0, fileNameNoExt, ChineseFirstChar(fileNameNoExt)])
            EditGui.listView.Add(, fileNameNoExt)    ; 添加至列表
        }
        SearchGui.reloadSearchList(false, false)    ;重载列表，但不重置图片列表且不保存
        SearchGui.search(true, false)
        GlobalData.storeProgramData()    ;此处再保存
    }

    ; 选择文件路径
    static choseFile(index) {
        if (this.curItemIndex) {
            oldPath := this.editGroup[index].Value
            if (index == 1) {
                res := FileSelect("35", oldPath, "请选择文件")
            } else {
                res := FileSelect("3", oldPath, "请选择图标路径")
            }
            if (StrLen(res) and oldPath !== res) {
                this.editGroup[index].Value := res
                this.changeFlag := true
                if (index == 2)
                    this.reloadILFlag := true
            }
        }
    }

    ; 删除当前项
    static delCurItem() {
        if (this.curItemIndex > 0 and MsgBox("当前操作不可恢复，是否将当前项删除？", "提示", 0x2044) = "Yes") {
            GlobalData.programData.RemoveAt(this.curItemIndex)
            this.listView.Delete(this.curItemIndex)

            ; 切换到下一项
            if (GlobalData.programData.Length)
                this.itemEdit(Min(this.curItemIndex, GlobalData.programData.Length))
            else {
                this.hideGui()
                MsgBox("启动列表内无可编辑项", "提示", 0x2040)
            }

            ; 刷新搜索界面的列表
            SearchGui.edit.Value := ""
            SearchGui.search(true, false)
        }
    }

    ; 保存当前项
    static saveCurItem() {
        if (this.curItemIndex > 0 and StrLen(this.editGroup[4].Value)) {
            if (this.curItem[4] != this.editGroup[4].Value)
                this.listView.Modify(this.curItemIndex, , this.editGroup[4].Value)
            loop 4
                this.curItem[A_Index] := this.editGroup[A_Index].Value

            GlobalData.programData[this.curItemIndex] := this.curItem
            this.changeFlag := false

            if (this.reloadILFlag) {    ; 需要重载列表
                SearchGui.reloadSearchList(false, false)
                SearchGui.search(true, false)
                this.reloadILFlag := false
            }

            ToolTip("保存成功")
            SetTimer(() => ToolTip(), -1500)
        }
    }

    ; 发送F2到listview开启编辑
    static keywordsSendF2() {
        this.keywordsListView.Focus()
        ControlSend("{F2}", this.keywordsListView, this.gui)
    }

    ; 编辑关键词回调
    static keywordsEdit(rowNum) {
        newKeyword := this.keywordsListView.GetText(rowNum)
        if (this.curItem[4 + rowNum] !== newKeyword) {
            this.curItem[4 + rowNum] := newKeyword
            this.changeFlag := true
        }
    }

    ; 添加新关键词
    static keywordsAdd() {
        this.changeFlag := true
        newKeyword := ChineseFirstChar(this.editGroup[4].Value)
        this.curItem.Push(newKeyword)
        this.keywordsListView.Add(, newKeyword)
    }

    ; 删除关键词
    static keywordsDel(rowNum) {
        this.changeFlag := true
        this.curItem.RemoveAt(4 + rowNum)
        this.keywordsListView.Delete(rowNum)
    }

    ; 编辑项
    static itemEdit(rowNum) {
        if (rowNum > 0) {
            if (rowNum == this.curItemIndex)
                return

            if (this.changeFlag) {
                if (MsgBox("是否将当前项修改内容保存？", "提示", 0x2044) = "Yes")
                    this.saveCurItem()
            }
            this.changeFlag := false
            this.curItemIndex := rowNum
            this.curItem := GlobalData.programData[rowNum].Clone()    ;生成浅拷贝
            this.listView.Modify(rowNum, "Select Focus Vis")

            loop 4
                this.editGroup[A_Index].Value := this.curItem[A_Index]

            keywordsCount := this.curItem.Length - 4
            this.keywordsListView.Opt("-Redraw")    ;禁用重绘
            this.keywordsListView.Delete()
            loop keywordsCount
                this.keywordsListView.Add(, this.curItem[4 + A_Index])
            this.keywordsListView.Opt("Redraw")

            if (!FileExist(this.curItem[1])) {
                MsgBox("文件路径不存在，当前启动项无效", "提示", 0x2040)
            }
        }
    }
}