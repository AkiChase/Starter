class IntelligentEditGui {
    ; static gui:=unset
    ; static treeView := unset
    ; static delBtn := unset
    ; static saveBtn := unset
    ; static enableBtn := unset

    static reloadILFlag := false

    static baseInfo := Map()
    static matchInfo := Map()
    static scriptInfo := Map()

    ;#region 当前编辑项
    static _curItem := Map()
    class curItem {
        static outer := IntelligentEditGui

        static id := 0
        static id2Pos := Map()
        static pos2ID := Map()

        static __Item[key] {
            get => this.%key%
            set => this.%key% := Value
        }

        static group => this.outer._curItem["group"]

        static title {
            get => this.outer._curItem["title"]
            set {
                this.outer._curItem["title"] := Value
                this.outer.changeFlag := true
                if (this.outer.baseInfo["titleEdit"].Value == Value)
                    return
                this.outer.baseInfo["titleEdit"].Value := Value
            }
        }

        static notes {
            get => this.outer._curItem["notes"]
            set {
                this.outer._curItem["notes"] := Value
                this.outer.changeFlag := true
                if (this.outer.baseInfo["notesEdit"].Value == Value)
                    return
                this.outer.baseInfo["notesEdit"].Value := Value
            }
        }

        static thumb {
            get => this.outer._curItem["thumb"]
            set {
                this.outer._curItem["thumb"] := Value
                this.outer.changeFlag := true
                if (this.outer.baseInfo["thumbEdit"].Value == Value)
                    return
                this.outer.baseInfo["thumbEdit"].Value := Value
            }
        }

        class match {
            static outer := IntelligentEditGui

            static mode2Help := Map("str", "输入内容为任意字符串可匹配"
                , "reg", "输入内容满足左侧列表任一正则表达式可匹配，`n而输入内容经右侧列表相应行正则替换后传递给启动处理程序")
            static mode2BoxTitle := Map("str", "字符串模式", "reg", "正则匹配替换模式")
            static modeKeys := ["str", "reg"]

            static reloadLV(LV, list) {
                LV.Opt("-Redraw")    ;禁用重绘
                Lv.Delete()
                for exp in list    ; 不调用exp属性、更快捷
                    LV.Add(, exp)
                LV.Opt("Redraw")
            }

            static mode {
                get => this.outer._curItem["match"]["mode"]
                set {
                    this.outer._curItem["match"]["mode"] := Value
                    ; 选择DDL选项
                    for i, mode in this.modeKeys {
                        if (this.outer._curItem["match"]["mode"] == mode) {
                            this.outer.matchInfo["DDL"].Value := i
                            break
                        }
                    }
                    ; 设置box标题
                    this.outer.matchInfo["box"].Text := this.mode2BoxTitle[Value]
                    ; 视模式调整其他控件
                    if (Value == "reg") {
                        ; 保证每个都至少1条，数量匹配在保存时验证
                        if (this.outer._curItem["match"].Has("exp"))
                            this.reloadLV(this.outer.matchInfo["expLV"], this.outer._curItem["match"]["exp"])
                        else {
                            this.outer.matchInfo["expLV"].Delete()
                            this.exp.Push(".+")
                        }

                        if (this.outer._curItem["match"].Has("replace"))
                            this.reloadLV(this.outer.matchInfo["replaceLV"], this.outer._curItem["match"]["replace"])
                        else {
                            this.outer.matchInfo["replaceLV"].Delete()
                            this.replace.Push("$0")
                        }

                        this.outer.matchInfo["expLV"].Visible := this.outer.matchInfo["replaceLV"].Visible := true
                    } else
                        this.outer.matchInfo["expLV"].Visible := this.outer.matchInfo["replaceLV"].Visible := false
                    this.outer.changeFlag := true
                }
            }

            class exp {
                static outer := IntelligentEditGui
                static __Item[index] {
                    get => this.outer._curItem["match"]["exp"][index]
                    set {
                        this.outer._curItem["match"]["exp"][index] := Value
                        this.outer.changeFlag := true
                    }
                }
                static Push(v) {
                    if (!this.outer._curItem["match"].Has("exp"))
                        this.outer._curItem["match"]["exp"] := []

                    this.outer._curItem["match"]["exp"].Push(v)
                    this.outer.matchInfo["expLV"].Add(, v)
                    this.outer.changeFlag := true
                }
                static RemoveAt(index) {
                    this.outer._curItem["match"]["exp"].RemoveAt(index)
                    this.outer.matchInfo["expLV"].Delete(index)
                    this.outer.changeFlag := true
                }
            }

            class replace {
                static outer := IntelligentEditGui
                static __Item[index] {
                    get => this.outer._curItem["match"]["replace"][index]
                    set {
                        this.outer._curItem["match"]["replace"][index] := Value
                        this.outer.changeFlag := true
                    }
                }
                static Push(v) {
                    if (!this.outer._curItem["match"].Has("replace"))
                        this.outer._curItem["match"]["replace"] := []
                    this.outer._curItem["match"]["replace"].Push(v)
                    this.outer.matchInfo["replaceLV"].Add(, v)
                    this.outer.changeFlag := true
                }
                static RemoveAt(index) {
                    this.outer._curItem["match"]["replace"].RemoveAt(index)
                    this.outer.matchInfo["replaceLV"].Delete(index)
                    this.outer.changeFlag := true
                }
            }
        }

        class script {
            static outer := IntelligentEditGui

            static modeKeys := ["none", "arg", "args"]
            static mode2Help := Map("none", "启动处理程序直接执行收到的内容"
                , "arg", '启动处理程序将收到的内容视为一个命令行参数(即添加双引号)`n启动下方程序路径',
                "args", '启动处理程序将收到的内容视为完整命令行参数(不做任何处理)启动下方程序路径')
            static mode2BoxTitle := Map("str", "字符串模式", "reg", "正则匹配替换模式")
            static mode {
                get => this.outer._curItem["script"]["mode"]
                set {
                    this.outer._curItem["script"]["mode"] := Value
                    for index, mode in this.modeKeys {
                        if (this.mode == mode) {
                            this.outer.scriptInfo["DDL"].Value := index
                            break
                        }
                    }

                    if (Value !== "none") {
                        this.outer.scriptInfo["programEdit"].Enabled := true
                        if (!this.outer._curItem["script"].Has("program"))
                            this.program := ""
                        else
                            this.program := this.program
                    } else {
                        this.outer.scriptInfo["programEdit"].Enabled := false
                        this.outer.scriptInfo["programEdit"].Value := ""    ;防止清除program值
                    }

                    this.outer.scriptInfo["programEdit"].Enabled := Value !== "none"
                    this.outer.changeFlag := true
                }
            }

            static program {
                get => this.outer._curItem["script"]["program"]
                set {
                    if (this.outer.scriptInfo["programEdit"].Value == Value)
                        return
                    this.outer.scriptInfo["programEdit"].Value := Value
                    this.outer._curItem["script"]["program"] := Value
                    this.outer.changeFlag := true
                }
            }
        }

        static url {
            get => this.outer._curItem.Has("url") ? this.outer._curItem["url"] : false
            set {
                this.outer._curItem["url"] := Value
                this.outer.changeFlag := true
                if (this.outer.scriptInfo["programEdit"].Value == Value)
                    return
                this.outer.scriptInfo["programEdit"].Value := Value
            }
        }

        static enabled {
            get => this.outer._curItem["enabled"]
            set {
                this.outer._curItem["enabled"] := Value
                this.outer.enableBtn.Text := Value ? "禁用" : "启用"
                this.outer.changeFlag := true
            }
        }

        static removable => this.outer._curItem["removable"]
    }
    ;#endregion

    ;#region 修改标识
    static _changeFlag := false
    static changeFlag {
        get => this._changeFlag
        set => this._changeFlag := this.saveBtn.Enabled := Value
    }
    ;#endregion


    static init() {
        this.gui := Gui("-Resize", "智能模式编辑界面")
        this.gui.BackColor := "FFFFFF"
        this.gui.SetFont("s14 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        this.gui.OnEvent("Close", (guiObj) => this.hideGui())

        ;#region 树状图
        this.treeView := this.gui.AddTreeView("x10 y10 w225 h460 -HScroll")
        this.treeView.SetFont("s10")
        this.treeView.SetImageList(IntelligentMode.imgListID)
        this.treeView.OnEvent("Click", (_tv, id) => id > 0 and this.curItem.id2Pos.Has(id) ? this.itemEdit(this.curItem.id2Pos[id][1], this.curItem.id2Pos[id][2]) : 0)
        ;#endregion

        ;#region 基本信息
        for index, nameArr in [["显示名称", "title"], ["备注", "notes"]]
            this.baseInfo[nameArr[2] "Edit"] := this.addEditGroup(nameArr[1], 280, index * 50 - 25, nameArr[2])
        this.baseInfo["thumbEdit"] := this.addEditGroup("图标文件", 280, 125, "thumb", 200)
        this.baseInfo["thumbEdit"].Opt("+ReadOnly")
        this.gui.AddButton("xp+218 yp h30", "选择").OnEvent("Click", (*) => this.selectIcon())
        this.baseInfo["fetchBtn"] := this.gui.AddButton("xp+75 yp h30", "获取")
        this.baseInfo["fetchBtn"].OnEvent("Click", (*) => this.fetchFavicon())
        ;#endregion

        ;#region 匹配模式
        this.gui.AddText("w80 x280 yp+50", "匹配模式")

        this.matchInfo["DDL"] := this.gui.AddDropDownList("xp+90 yp-5 w100 R5", this.curItem.match.modeKeys)
        this.matchInfo["DDL"].OnEvent("Change", (*) => this.curItem.match.mode := this.curItem.match.modeKeys[this.matchInfo["DDL"].Value])

        this.gui.AddPicture("xp+110 yp-2 w32 h32 AltSubmit", GlobalData.imgDir "\help.png").OnEvent("Click", (*) => this.showMatchHelp())

        this.matchInfo["box"] := this.gui.AddGroupBox("x280 y200 w442 h130")
        this.matchInfo["box"].SetFont("s12")

        this.matchInfo["expLV"] := this.gui.Add("ListView", "x285 y220 w215 h105 -Multi -hdr -ReadOnly -E0x200 Grid Count3", [""])
        this.matchInfo["expLV"].ModifyCol(1, "195 Center")
        this.matchInfo["expLV"].OnEvent("ItemEdit", (LV, rowNum) => this.LVEdit(LV, rowNum))
        this.matchInfo["expLV"].OnEvent("ContextMenu", (LV, rowNum, *) => this.regLVSyncSelected(rowNum) or this.showLVMenu(LV, rowNum))
        this.matchInfo["expLV"].OnEvent("Click", (LV, rowNum) => this.regLVSyncSelected(rowNum))


        this.matchInfo["replaceLV"] := this.gui.Add("ListView", "x500 y220 w215 h105 -Multi -hdr -ReadOnly -E0x200 Grid Count3", [""])
        this.matchInfo["replaceLV"].ModifyCol(1, "195 Center")
        this.matchInfo["replaceLV"].OnEvent("ItemEdit", (LV, rowNum) => this.LVEdit(LV, rowNum))
        this.matchInfo["replaceLV"].OnEvent("ContextMenu", (LV, rowNum, *) => this.regLVSyncSelected(rowNum) or this.showLVMenu(LV, rowNum))
        this.matchInfo["replaceLV"].OnEvent("Click", (LV, rowNum) => this.regLVSyncSelected(rowNum))


        this.regMenuInit()
        ;#endregion

        ;#region 脚本模式
        this.gui.AddText("w80 x280 y350", "脚本模式")
        this.scriptInfo["DDL"] := this.gui.AddDropDownList("xp+90 yp-5 w100 R5", this.curItem.script.modeKeys)
        this.scriptInfo["DDL"].OnEvent("Change", (ddl, *) => this.curItem.script.mode := this.curItem.script.modeKeys[ddl.Value])
        this.gui.AddPicture("xp+110 yp-2 w32 h32 AltSubmit", GlobalData.imgDir "\help.png").OnEvent("Click", (*) => this.showScripHelp())

        this.scriptInfo["programText"] := this.gui.AddText("w80 x280 y390", "程序路径")
        this.scriptInfo["programEdit"] := this.gui.AddEdit("w350 yp-5 xp+90")
        this.scriptInfo["programEdit"].OnEvent("Change", (edit, *) => this.curItem.url ? this.curItem.url := edit.Value : this.curItem.script.program := edit.Value)

        ;#endregion

        ; 创建按钮
        this.gui.AddButton("x280 y430 h32 w100", "创建").OnEvent("Click", (*) => this.createItem())
        ; 删除按钮
        this.delBtn := this.gui.AddButton("xp+120 yp h32 w100", "删除")
        this.delBtn.OnEvent("Click", (*) => this.delCurItem())
        ; 保存按钮
        this.saveBtn := this.gui.AddButton("xp+120 yp h32 w100 Disabled", "保存")
        this.saveBtn.OnEvent("Click", (*) => this.saveCurItem())
        ; 禁用\启用按钮
        this.enableBtn := this.gui.AddButton("xp+120 yp h32 w100", "禁用")
        this.enableBtn.OnEvent("Click", (*) => this.curItem.enabled := !this.curItem.enabled)

        this.gui.Show("Hide w800 h480")
    }

    ; 显示匹配模式帮助
    static showMatchHelp() {
        ToolTip(this.curItem.match.mode2Help[this.curItem.match.mode])
        SetTimer(() => ToolTip(), -1500)
    }


    ; 显示脚本模式帮助
    static showScripHelp() {
        if (this.curItem.group == "search")
            help := '启动处理程序将收到的内容填充至搜索URL中"{}"所在位置, 打开填充后的URL'
        else
            help := this.curItem.script.mode2Help[this.curItem.script.mode]
        ToolTip(help)
        SetTimer(() => ToolTip(), -1500)
    }

    ; 创建新项目
    static createItem() {
        group := this.curItem.group
        newItem := Map("title", "新项目", "group", group, "notes", "项目介绍、注释", "thumb", "请选择图标文件.png", "removable", 1, "enabled", 1)
        newItem["match"] := Map("mode", "str")
        if (group == "run-with")
            newItem["script"] := Map("mode", "none")
        else if (group == "search")
            newItem["url"] := "https://www.baidu.com/s?word={}"

        GlobalData.intelligentData[group].Push(newItem)
        this.reloadTV()
        this.itemEdit(group, GlobalData.intelligentData[group].Length)
    }

    ; 选择图标文件
    static selectIcon() {
        res := FileSelect("3", GlobalData.customImgDir "\" this.curItem.thumb, "请选择图标路径")
        if (StrLen(res)) {
            SplitPath(res, , &dir, &ext, &oriName)
            name := oriName
            if (dir != GlobalData.customImgDir) {
                if (MsgBox(Format("是否使用该文件作为图标: `n{}`n该文件将拷贝至用户数据目录内", res), "提示", 0x2044) = "Yes") {
                    while (FileExist(Format("{}\{}.{}", GlobalData.customImgDir, name, ext)))
                        name := Format("{}{}", oriName, A_Index)
                    FileCopy(res, Format("{}\{}.{}", GlobalData.customImgDir, name, ext), true)
                }
            }
            this.curItem.thumb := Format("{}.{}", name, ext)
            this.reloadILFlag := true
        }
    }

    ; 添加编辑框ui组件
    static addEditGroup(txt, xPos, yPos, propName, w := 350) {
        txtObj := this.gui.AddText("w80 x" xPos " y" yPos, txt)
        editObj := this.gui.AddEdit("w" w " yp-5 xp+90")
        editObj.OnEvent("Change", this._eventEditChange.Bind(this, propName))
        return editObj
    }

    ; 事件回调修改changeFlag
    static _eventEditChange(propName, editCtrl, *) {
        this.curItem[propName] := editCtrl.Value
    }

    ; 同步选中俩个列表同一行的项目
    static regLVSyncSelected(rowNum) {
        for LV in [this.matchInfo["expLV"], this.matchInfo["replaceLV"]]
            LV.Modify(rowNum, "Select Focus Vis")
    }

    ; 正则列表菜单初始化
    static regMenuInit() {
        m := Menu()

        m.Add("添加`t(&A)", (*) => this.curItem.match.exp.Push(".+") or this.curItem.match.replace.Push("$0"))
        m.Add("修改`t(&E)", (*) => this.matchLVSendF2())
        m.Add("删除`t(&X)", (*) => this.curItem.match.exp.RemoveAt(this.matchInfo["LVMenuRow"]) or this.curItem.match.replace.RemoveAt(this.matchInfo["LVMenuRow"]))

        m.SetIcon("1&", GlobalData.imgDir "\add.ico")
        m.SetIcon("2&", GlobalData.imgDir "\edit.ico")
        m.SetIcon("3&", GlobalData.imgDir "\delete.ico")
        this.matchInfo["matchLVMenu"] := m
        this.matchInfo["LVMenuRow"] := 0
    }

    ; 发送F2到listview开启编辑
    static matchLVSendF2() {
        LV := this.matchInfo[this.matchInfo["curLVName"]]
        LV.Focus()
        ControlSend("{F2}", this.matchInfo[this.matchInfo["curLVName"]], this.gui)
    }

    ; 编辑关键词回调
    static LVEdit(LV, rowNum) {
        newKeyword := LV.GetText(rowNum)
        tmp := LV == this.matchInfo["expLV"] ? this.curItem.match.exp : this.curItem.match.replace
        if (tmp[rowNum] !== newKeyword)
            tmp[rowNum] := newKeyword
    }

    ; 显示菜单
    static showLVMenu(LV, rowNum) {
        (LV == this.matchInfo["expLV"]) ? this.matchInfo["curLVName"] := "expLV" : this.matchInfo["curLVName"] := "replaceLV"
        this.matchInfo["LVMenuRow"] := rowNum
        if (rowNum)
            this.matchInfo["matchLVMenu"].Enable("2&"), this.matchInfo["matchLVMenu"].Enable("3&")
        else
            this.matchInfo["matchLVMenu"].Disable("2&"), this.matchInfo["matchLVMenu"].Disable("3&")
        this.matchInfo["matchLVMenu"].Show()
    }

    ; 重新加载树状图
    static reloadTV(reloadIL := false) {
        if (this.curItem.id)    ; 若此时已开始编辑某项，需要更新curItem.id避免丢失
            pos := this.curItem.id2Pos[this.curItem.id]

        this.curItem.pos2ID := Map()
        this.curItem.id2Pos := Map()
        if (reloadIL) {
            IntelligentMode.loadImgs()    ;通过IntelligentMode内重新加载图片列表
            this.treeView.SetImageList(IntelligentMode.imgListID)
        }

        this.treeView.Opt("-Redraw")
        this.treeView.Delete()
        for name, group in GlobalData.intelligentData {
            pID := this.treeView.Add(name, , "Expand Icon" IntelligentMode.imgPathToImgListIndex[GlobalData.imgDir "\folder.png"])
            for index, item in group {
                iconIndex := IntelligentMode.imgPathToImgListIndex.Has(item["thumb"]) ? IntelligentMode.imgPathToImgListIndex[item["thumb"]] : IntelligentMode.imgPathToImgListIndex[GlobalData.imgDir "\noImg.png"]
                id := this.treeView.Add(item["title"], pID, "Icon" iconIndex)
                this.curItem.pos2ID[name "." index] := id
                this.curItem.id2Pos[id] := [name, index]
            }
        }
        this.treeView.Opt("Redraw")

        if (this.curItem.id)
            this.curItem.id := this.curItem.pos2ID[pos[1] "." pos[2]]
    }

    ; 删除当前项（若允许删除）
    static delCurItem() {
        pos := this.curItem.id2Pos[this.curItem.id]
        if (GlobalData.intelligentData[pos[1]].Length > 1 and this.curItem.removable and MsgBox("当前操作不可恢复，是否将当前项删除？", "提示", 0x2044) = "Yes") {
            GlobalData.intelligentData[pos[1]].RemoveAt(pos[2])
            this.treeView.Delete(this.curItem.id)

            ; 切换到下一项
            this.itemEdit(pos[1], pos[2] <= GlobalData.intelligentData[pos[1]].Length ? pos[2] : pos[2] - 1)
            ; 无需重载列表和图标资源
        } else {
            MsgBox("当前项目不可删除", "提示", 0x2040)
            this.delBtn.Enabled := false
        }
    }

    ; 保存当前项
    static saveCurItem() {
        for name in ["title", "notes", "thumb"] {
            if (!StrLen(this.curItem[name])) {
                MsgBox("请完整输入参数", "提示", 0x2040)
                return
            }
        }

        if (this.curItem.match.mode !== "reg")    ; reg模式下match值与列表内容是同步的
            this._curItem["match"] := Map("mode", this.curItem.match.mode)    ; 其他模式则需要重置match值

        ; 脚本模式
        if (this.curItem.group == "search") {
            if (!StrLen(this.curItem.url)) {
                MsgBox("搜索url不可为空", "提示", 0x2040)
                return
            }
        } else {
            if (this.curItem.script.mode !== "none") {
                if (!StrLen(this.curItem.script.program)) {
                    MsgBox("程序路径不可为空", "提示", 0x2040)
                    return
                }
            } else
                this._curItem["script"] := Map("mode", this.curItem.script.mode)    ; 其他模式则需要重置script值
        }

        pos := this.curItem.id2Pos[this.curItem.id]
        GlobalData.intelligentData[pos[1]][pos[2]] := this._curItem

        this.treeView.Modify(this.curItem.id, "Select", this.curItem.title)

        this.changeFlag := false

        if (this.reloadILFlag) {
            this.reloadILFlag := false
            this.reloadTV(true)
        }

        ToolTip("保存成功")
        SetTimer(() => ToolTip(), -1500)
    }

    ; 编辑指定项目
    static itemEdit(group, index) {
        if (this.curItem.pos2ID[group "." index] == this.curItem.id)
            return

        if (this.changeFlag) {
            if (MsgBox("是否将当前项修改内容保存？", "提示", 0x2044) = "Yes")
                this.saveCurItem()
            this.changeFlag := false
        }

        this._curItem := MapArrClone(GlobalData.intelligentData[group][index])    ; 对于Map嵌套类型，需要生成深拷贝
        this.curItem.id := this.curItem.pos2ID[group "." index]

        this.treeView.Modify(this.curItem.id, "Select")

        ; 通过赋值触发setter
        for name in ["title", "notes", "thumb"]
            this.curItem[name] := this.curItem[name]

        this.baseInfo["fetchBtn"].Enabled := this.curItem.group == "search"    ;仅search组可用获取

        this.curItem.match.mode := this.curItem.match.mode

        if (this.curItem.group == "run-with") {
            this.scriptInfo["DDL"].Enabled := true
            this.scriptInfo["programText"].Value := "程序路径"
            this.curItem.script.mode := this.curItem.script.mode
        } else if (this.curItem.group == "search") {
            this.scriptInfo["DDL"].Enabled := false
            this.scriptInfo["programText"].Value := "搜索URL"
            this.curItem.url := this.curItem.url
            this.scriptInfo["programEdit"].Enabled := true
            this.scriptInfo["DDL"].Value := 0
        }

        ; 删除按钮
        this.delBtn.Enabled := GlobalData.intelligentData[this.curItem.group].Length > 1 and this.curItem.removable

        ; 是否禁用
        this.enableBtn.Text := this.curItem.enabled ? "禁用" : "启用"

        this.changeFlag := false
    }

    ; 显示智能模式编辑界面，并编辑某项
    static showGui(editPos := unset) {
        Critical('On')    ;防止线程被中断
        for c in [SearchGui, StartupEditGui]
            if (WinExist(c.gui))
                c.hideGui()
        Hotkey("~CapsLock", "Off")    ; 关闭热键，防止数据冲突

        ; 重新加载树状图
        this.reloadTV()

        if (!IsSet(editPos)) {
            for k, v in GlobalData.intelligentData {
                this.itemEdit(k, 1)    ; 第一组第一项
                break
            }
        } else
            this.itemEdit(editPos[1], editPos[2])

        this.gui.Show()
        Critical('Off')
    }

    ; 隐藏编辑界面
    static hideGui() {
        Hotkey("~CapsLock", "On")    ; 恢复热键
        if (this.changeFlag) {
            if (MsgBox("是否将当前项修改内容保存？", "提示", 0x2044) = "Yes")
                this.saveCurItem()
        }
        this.gui.Hide()
    }

    ; 下载图标
    static fetchFavicon() {
        oriGuiTitle := this.gui.Title
        this.gui.Opt("+Disabled")
        WinSetTransparent(240, this.gui)
        this.gui.Title := "正在获取网站图标...请耐心等待"

        if (icoURL := this.getFaviconUrl(this.curItem.url)) {
            ext := SubStr(icoURL, 1 + InStr(icoURL, ".", , , -1))
            newTitle := oriTitle := RegExReplace(this.curItem.title, '[\s\/\\":|*?<>]')    ;过滤非法字符

            while (FileExist(Format("{}\{}.{}", GlobalData.customImgDir, newTitle, ext)))    ;避免文件名重复
                newTitle := Format("{}{}", oriTitle, A_Index)

            filePath := Format("{}\{}.{}", GlobalData.customImgDir, newTitle, ext)
            try {
                WinHttp().Download(icoURL, "Timeout:10", , , filePath)
                this.curItem.thumb := Format("{}.{}", newTitle, ext)
                this.changeFlag := true
                this.reloadILFlag := true
                MsgBox("图标下载成功！保存至数据目录下:`n" filePath, "提示", 0x2040)
            }
            catch {
                MsgBox("图标下载失败, 请尝试手动下载后选用:`n" icoURL, "提示", 0x2040)
            }
        } else
            MsgBox("无法获取网站图标，请自行设置其他图标", "提示", 0x2040)

        this.gui.Title := oriGuiTitle
        WinSetTransparent("Off", this.gui)
        this.gui.Opt("-Disabled")
        WinActivate(this.gui)
    }

    ; 获取图标链接
    static getFaviconUrl(url) {
        if (!RegExMatch(url, "^(https?:\/{2})?([.a-z]*)", &out))    ; 正则提取domain
            return false

        s := WinHttp()
        res := s.Download(Format("https://favicongrabber.com/api/grab/{}", out[2]))
        if (s.StatusCode != 200)
            return false
        res_json := Jxon_Load(&res)

        if (!res_json["icons"].Length)
            return false

        for item in res_json["icons"]
            if (item.Has("type") and item["type"] = "image/x-icon")    ; 如果有image/x-icon类型的就只用image/x-icon
                return item["src"]
        return res_json["icons"][1]["src"]    ;否则用第一个
    }
}