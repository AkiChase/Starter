class IntelligentEditGui {
    ; static gui:=unset
    ; static treeView := unset
    ; static delBtn := unset
    ; static saveBtn := unset
    ; static enableBtn := unset

    static baseInfo := Map()
    static matchInfo := Map()
    static scriptInfo := Map()

    ; static curItem := unset
    static curID := 0
    static id2Pos := Map()
    static pos2ID := Map()

    static _changeFlag := false
    static changeFlag {
        get => this._changeFlag
        set => this._changeFlag := this.saveBtn.Enabled := value
    }

    static enableState {
        get => this.curItem["enabled"]
        set {
            this.curItem["enabled"] := value
            this.enableBtn.Text := value ? "禁用" : "启用"
            this.changeFlag := true
        }
    }

    static reloadILFlag := false

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
        this.treeView.OnEvent("Click", (_tv, id) => id > 0 and this.id2Pos.Has(id) ? this.itemEdit(this.id2Pos[id][1], this.id2Pos[id][2]) : 0)
        ;#endregion

        ;#region 基本信息
        for index, name in ["显示名称", "备注"]
            this.baseInfo[name] := this.addEditGroup(name, 280, index * 50 - 25)
        this.baseInfo["图标文件"] := this.addEditGroup("图标文件", 280, 125, 200)
        this.baseInfo["图标文件"].Opt("+ReadOnly")
        this.baseInfo["选择按钮"] := this.gui.AddButton("xp+218 yp h30", "选择")
        this.baseInfo["选择按钮"].OnEvent("Click", (*) => this.selectIcon())
        this.baseInfo["获取按钮"] := this.gui.AddButton("xp+75 yp h30", "获取")
        this.baseInfo["获取按钮"].OnEvent("Click", (*) => this.fetchFavicon())
        ;#endregion

        ;#region 匹配模式
        this.gui.AddText("w80 x280 yp+50", "匹配模式")
        this.matchInfo["DDLKeys"] := ["str", "reg"]
        this.matchInfo["DDL"] := this.gui.AddDropDownList("xp+90 yp-5 w100 R5", this.matchInfo["DDLKeys"])
        this.matchInfo["DDL"].OnEvent("Change", (*) => this.matchDDLChange())
        this.matchInfo["boxTitle"] := Map("str", "字符串模式", "reg", "正则匹配模式")
        this.matchInfo["box"] := this.gui.AddGroupBox("x280 y200 w442 h130")
        this.matchInfo["box"].SetFont("s12")

        this.matchInfo["modeInfo"] := Map("str", "匹配条件: 输入内容为字符串", "reg", "匹配条件: 输入内容满足下方任一正则表达式")
        this.matchInfo["modeText"] := this.gui.AddText("x300 y260 w402")
        this.matchInfo["regLV"] := this.gui.Add("ListView", "x300 y220 w402 h100 -Multi -hdr -ReadOnly -E0x200 Grid Count3", [""])
        this.matchInfo["regLV"].ModifyCol(1, "Center")
        this.matchInfo["regLV"].OnEvent("ItemEdit", (LV, rowNum) => this.regLVEdit(rowNum))

        this.matchInfo["regLV"].OnEvent("ContextMenu", (_lv, rowNum, *) => this.showRegLVMenu(rowNum))
        this.regMenuInit()
        ;#endregion

        ;#region 脚本模式
        this.gui.AddText("w80 x280 y350", "脚本模式")
        this.scriptInfo["DDLKeys"] := ["none", "arg", "args"]
        this.scriptInfo["DDL"] := this.gui.AddDropDownList("xp+90 yp-5 w100 R5", this.scriptInfo["DDLKeys"])
        this.scriptInfo["DDL"].OnEvent("Change", (*) => this.scriptDDLChange())
        this.scriptInfo["programEdit"] := this.addEditGroup("程序路径", 280, 390, , &textObj)
        this.scriptInfo["programText"] := textObj
        ; this.scriptInfo["urlEdit"] := this.addEditGroup("搜索链接", 280, 390)

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
        this.enableBtn.OnEvent("Click", (*) => this.enableState := !this.enableState)

        this.gui.Show("Hide w800 h480")
    }

    ; 创建新项目
    static createItem() {
        group := this.curItem["group"]
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
        res := FileSelect("3", GlobalData.customImgDir "\" this.baseInfo["图标文件"].Value, "请选择图标路径")
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
            this.baseInfo["图标文件"].Value := Format("{}.{}", name, ext)

            this.changeFlag := true
            this.reloadILFlag := true
        }
    }

    ; 匹配模式切换事件
    static matchDDLChange() {
        newMode := this.matchInfo["DDLKeys"][this.matchInfo["DDL"].Value]
        this.matchInfo["box"].Text := this.matchInfo["boxTitle"][newMode]

        if (newMode == "reg") {
            if (this.curItem["match"].Has("exp")) {
                this.matchInfo["regLV"].Opt("-Redraw")    ;禁用重绘
                this.matchInfo["regLV"].Delete()
                for exp in this.curItem["match"]["exp"]
                    this.matchInfo["regLV"].Add(, exp)
                this.matchInfo["regLV"].Opt("Redraw")
            } else {    ; 不存在时添加默认项
                this.curItem["match"]["exp"] := [".+"]
                this.matchInfo["regLV"].Add(, ".+")
            }

            this.matchInfo["regLV"].Visible := true
        } else {
            this.matchInfo["regLV"].Visible := false
            this.matchInfo["modeText"].Text := this.matchInfo["modeInfo"][newMode]    ; 显示模式信息
            this.matchInfo["modeText"].Visible := true
        }
    }

    ; 脚本模式切换事件
    static scriptDDLChange() {
        newMode := this.scriptInfo["DDLKeys"][this.scriptInfo["DDL"].Value]
        this.scriptInfo["DDL"].Enabled := true
        this.scriptInfo["programEdit"].Enabled := newMode !== "none"
    }

    ; 添加编辑框ui组件
    static addEditGroup(txt, xPos, yPos, w := 350, &txtObj := unset) {
        txtObj := this.gui.AddText("w80 x" xPos " y" yPos, txt)
        editObj := this.gui.AddEdit("w" w " yp-5 xp+90")
        editObj.OnEvent("Change", this._eventChangeFlag)
        return editObj
    }

    ; 正则列表菜单初始化
    static regMenuInit() {
        m := Menu()
        m.Add("添加正则表达式`t(&A)", (*) => this.regLVAdd())
        m.Add("修改正则表达式`t(&E)", (*) => this.regLVSendF2())
        m.Add("删除正则表达式`t(&X)", (*) => this.regLVDel(this.matchInfo["regLVMenuRow"]))

        m.SetIcon("1&", GlobalData.imgDir "\grey-run.png")
        m.SetIcon("2&", GlobalData.imgDir "\grey-edit.png")
        m.SetIcon("3&", GlobalData.imgDir "\grey-delete.png")
        this.matchInfo["regLVMenu"] := m
        this.matchInfo["regLVMenuRow"] := 0
    }

    ; 发送F2到listview开启编辑
    static regLVSendF2() {
        this.matchInfo["regLV"].Focus()
        ControlSend("{F2}", this.matchInfo["regLV"], this.gui)
    }

    ; 编辑关键词回调
    static regLVEdit(rowNum) {
        newKeyword := this.matchInfo["regLV"].GetText(rowNum)
        if (this.curItem["match"]["exp"][rowNum] !== newKeyword) {
            this.curItem["match"]["exp"][rowNum] := newKeyword
            this.changeFlag := true
        }
    }

    ; 添加新关键词
    static regLVAdd() {
        this.changeFlag := true
        this.curItem["match"]["exp"].Push(".+")
        this.matchInfo["regLV"].Add(, ".+")
    }

    ; 删除关键词
    static regLVDel(rowNum) {
        this.changeFlag := true
        this.curItem["match"]["exp"].RemoveAt(rowNum)
        this.matchInfo["regLV"].Delete(rowNum)
    }

    ; 显示菜单
    static showRegLVMenu(rowNum) {
        this.matchInfo["regLVMenuRow"] := rowNum
        if (rowNum)
            this.matchInfo["regLVMenu"].Enable("2&"), this.matchInfo["regLVMenu"].Enable("3&")
        else
            this.matchInfo["regLVMenu"].Disable("2&"), this.matchInfo["regLVMenu"].Disable("3&")
        this.matchInfo["regLVMenu"].Show()
    }

    ; 事件回调修改changeFlag
    static _eventChangeFlag(*) {
        IntelligentEditGui.changeFlag := true
    }

    ; 重新加载树状图
    static reloadTV(reloadIL := false) {
        if (this.curID)    ; 若此时已开始编辑某项，需要更新curID避免丢失
            pos := this.id2Pos[this.curID]

        this.pos2ID := Map()
        this.id2Pos := Map()
        if (reloadIL) {
            IntelligentMode.reloadSearchList()    ;通过IntelligentMode内重新加载图片列表
            this.treeView.SetImageList(IntelligentMode.imgListID)
        }

        this.treeView.Opt("-Redraw")
        this.treeView.Delete()
        for name, group in GlobalData.intelligentData {
            pID := this.treeView.Add(name, , "Expand Icon" IntelligentMode.imgPathToImgListIndex[GlobalData.imgDir "\folder.png"])
            for index, item in group {
                iconIndex := IntelligentMode.imgPathToImgListIndex.Has(item["thumb"]) ? IntelligentMode.imgPathToImgListIndex[item["thumb"]] : IntelligentMode.imgPathToImgListIndex[GlobalData.imgDir "\noImg.png"]
                id := this.treeView.Add(item["title"], pID, "Icon" iconIndex)
                this.pos2ID[name "." index] := id
                this.id2Pos[id] := [name, index]
            }
        }
        this.treeView.Opt("Redraw")

        if (this.curID)
            this.curID := this.pos2ID[pos[1] "." pos[2]]
    }

    ; 删除当前项（若允许删除）
    static delCurItem() {
        pos := this.id2Pos[this.curID]
        if (GlobalData.intelligentData[pos[1]].Length > 1 and this.curItem["removable"] and MsgBox("当前操作不可恢复，是否将当前项删除？", "提示", 0x2044) = "Yes") {
            GlobalData.intelligentData[pos[1]].RemoveAt(pos[2])
            this.treeView.Delete(this.curID)

            ; 切换到下一项
            this.itemEdit(pos[1], pos[2] <= GlobalData.intelligentData[pos[1]].Length ? pos[2] : pos[2] - 1)
            ; 无需重载列表和图标资源
        }

    }

    ; 保存当前项
    static saveCurItem() {
        pos := this.id2Pos[this.curID]

        ; 基本信息
        this.curItem["title"] := this.baseInfo["显示名称"].Value
        this.curItem["notes"] := this.baseInfo["备注"].Value
        this.curItem["thumb"] := this.baseInfo["图标文件"].Value

        ; 匹配模式
        newMatchMode := this.matchInfo["DDLKeys"][this.matchInfo["DDL"].Value]
        if (newMatchMode !== "reg")    ; reg模式下match值与列表内容是同步的
            this.curItem["match"] := Map("mode", newMatchMode)    ; 其他模式则需要重置match值

        ; 脚本模式
        if (this.curItem["group"] == "search") {
            url := this.scriptInfo["programEdit"].Value
            if (!StrLen(url)) {
                MsgBox("搜索url不可为空", "提示", 0x2040)
                return
            }
            this.curItem["url"] := url
        } else {
            newScriptMode := this.scriptInfo["DDLKeys"][this.scriptInfo["DDL"].Value]
            if (newScriptMode !== "none") {
                newProgram := this.scriptInfo["programEdit"].Value
                if (!StrLen(newProgram)) {
                    MsgBox("程序路径不可为空", "提示", 0x2040)
                    return
                }
                this.curItem["script"] := Map("mode", newScriptMode, "program", newProgram)
            } else
                this.curItem["script"] := Map("mode", newScriptMode)
        }


        GlobalData.intelligentData[pos[1]][pos[2]] := this.curItem
        this.changeFlag := false

        this.treeView.Modify(this.curID, "Select", this.curItem["title"])

        if (this.reloadILFlag) {
            this.reloadILFlag := false
            this.reloadTV(true)
        }

        ToolTip("保存成功")
        SetTimer(() => ToolTip(), -1500)
    }

    ; 编辑指定项目
    static itemEdit(group, index) {
        if (this.pos2ID[group "." index] == this.curID)
            return

        if (this.changeFlag) {
            if (MsgBox("是否将当前项修改内容保存？", "提示", 0x2044) = "Yes")
                this.saveCurItem()
            this.changeFlag := false
        }

        this.curItem := MapArrClone(GlobalData.intelligentData[group][index])    ; 对于Map嵌套类型，需要生成深拷贝
        this.curID := this.pos2ID[group "." index]

        this.treeView.Modify(this.curID, "Select")

        ;#region 基本信息
        this.baseInfo["显示名称"].Value := this.curItem["title"]
        this.baseInfo["备注"].Value := this.curItem["notes"]
        this.baseInfo["图标文件"].Value := this.curItem["thumb"]
        this.baseInfo["获取按钮"].Enabled := this.curItem["group"] == "search"    ;仅search组可用获取
        ;#endregion

        ;#region 匹配模式
        for i, mode in this.matchInfo["DDLKeys"] {
            if (this.curItem["match"]["mode"] == mode) {
                this.matchInfo["DDL"].Value := i
                break
            }
        }
        this.matchInfo["box"].Text := this.matchInfo["boxTitle"][this.curItem["match"]["mode"]]
        ; TODO 增加regR 正则替换模式
        if (this.curItem["match"]["mode"] == "reg") {
            this.matchInfo["regLV"].Opt("-Redraw")    ;禁用重绘
            this.matchInfo["regLV"].Delete()
            for exp in this.curItem["match"]["exp"]
                this.matchInfo["regLV"].Add(, exp)
            this.matchInfo["regLV"].Opt("Redraw")
            this.matchInfo["regLV"].Visible := true
        } else {
            this.matchInfo["regLV"].Visible := false
            this.matchInfo["modeText"].Text := this.matchInfo["modeInfo"][this.curItem["match"]["mode"]]
            this.matchInfo["modeText"].Visible := true
        }
        ;#endregion

        ;#region 脚本模式
        if (this.curItem["group"] == "run-with") {
            this.scriptInfo["DDL"].Enabled := true
            this.scriptInfo["programText"].Value := "程序路径"

            if (this.curItem["script"]["mode"] !== "none") {
                this.scriptInfo["programEdit"].Enabled := true
                this.scriptInfo["programEdit"].Value := this.curItem["script"]["program"]
            } else {
                this.scriptInfo["programEdit"].Enabled := false
                this.scriptInfo["programEdit"].Value := ""
            }

            for index, mode in this.scriptInfo["DDLKeys"] {
                if (this.curItem["script"]["mode"] == mode) {
                    this.scriptInfo["DDL"].Value := index
                    break
                }
            }

        } else if (this.curItem["group"] == "search") {
            this.scriptInfo["programText"].Value := "搜索URL"
            this.scriptInfo["programEdit"].Value := this.curItem["url"]
            this.scriptInfo["programEdit"].Enabled := true
            this.scriptInfo["DDL"].Enabled := false
            this.scriptInfo["DDL"].Value := 0
        }
        ;#endregion

        ; 删除按钮
        this.delBtn.Enabled := GlobalData.intelligentData[this.curItem["group"]].Length > 1 and this.curItem["removable"]

        ; 是否禁用
        this.enableBtn.Text := this.curItem["enabled"] ? "禁用" : "启用"
    }

    ; 显示智能模式编辑界面，并编辑某项
    static showGui(editPos := unset) {
        Critical('On')    ;防止线程被中断
        Hotkey("~CapsLock Up", "Off")    ; 关闭热键，防止数据冲突
        SearchGui.hideGui()

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
        Hotkey("~CapsLock Up", "On")    ; 恢复热键
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

        if (icoURL := this.getFaviconUrl(this.curItem["url"])) {
            ext := SubStr(icoURL, 1 + InStr(icoURL, ".", , , -1))
            newTitle := oriTitle := RegExReplace(this.curItem["title"], '[\s\/\\":|*?<>]')    ;过滤非法字符

            while (FileExist(Format("{}\{}.{}", GlobalData.customImgDir, newTitle, ext)))    ;避免文件名重复
                newTitle := Format("{}{}", oriTitle, A_Index)

            filePath := Format("{}\{}.{}", GlobalData.customImgDir, newTitle, ext)
            try {
                WinHttp().Download(icoURL, "Timeout:10", , , filePath)
                this.baseInfo["图标文件"].Value := Format("{}.{}", newTitle, ext)
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

    ; 获取图标
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
            if (item.Has("type") and item["type"] = "image/x-icon")    ; 只要image/x-icon类型的
                return item["src"]
        return false
    }
}