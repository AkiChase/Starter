class SettingGui {
    static hkTextCtrlList := []
    static hotkeyMap := Map()
    static ctrlMap := Map()
    static keywordsHotkeyMap := Map()

    static init() {
        this.gui := g := Gui("-Resize", "设置界面")
        g.SetFont("s12 q5", "NSimSun")
        g.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        g.OnEvent("Close", (guiObj) => this.hideGui())

        tab := g.Add("Tab3", "x0 y0 w452 h352 -Wrap BackgroundFFFFFF", ["常规", "控制"])
        tab.OnEvent("Change", (ctrl, *) => this.onSwitchTab(ctrl.Value))

        ; tab 1
        ; 初始化热键编辑类
        this.hotkey.init()
        this.ctrlMap["startupCheckBox"] := g.AddCheckbox("x30 y55", "开机启动")

        this.ctrlMap["startupCheckBox"].OnEvent("Click", (ctrl, *) =>
            (TrayMenu.toggleStartupState(), ctrl.Value := TrayMenu.getStartupState()))
        for index, text in ["呼出搜索框", "智能搜索框"] {
            this.addHotkeyCtrl(60 + 35 * A_Index, A_Index, text)
            GlobalData.hotkeyList[index].title := text
        }

        ; tab 2
        tab.UseTab(2)
        g.AddText("x10 y40", "关键字快捷键")
        g.AddButton("x385 yp-5 h26", "删除").OnEvent("Click", (*) => this.deleteSearchHotkey())
        g.AddButton("x315 yp h26", "新增").OnEvent("Click", (*) => this.addSearchHotkey())
        this.keywordsHotkey.init()
        this.keywordsHotkeyLV := g.Add("ListView", "x10 yp+30 w430 h280", ["快捷键", "关键字"])
        this.keywordsHotkeyLV.OnEvent("doubleClick", (ctrl, index) => this.editSearchHotkey(index))
        this.keywordsHotkeyLV.ModifyCol(1, "210 Center")
        this.keywordsHotkeyLV.ModifyCol(2, "210 Center")

        this.hotkeyInit()

        ;......
        this.onSwitchTab(1) ;主动触发切换回调

        g.Show("w450 h350 Hide")
    }

    ; 切换tab回调
    static onSwitchTab(index) {
        switch index {
            case 1:
                this.ctrlMap["startupCheckBox"].Value := TrayMenu.getStartupState()
        }
    }

    static editSearchHotkey(index) {
        if (index) {
            ; 确定添加的回调
            callback(obj) {
                ; 添加到config
                GlobalData.config["keywordsHK"][index] := obj
                this.refreshHotkey() ; 重新加载热键
                this.gui.Opt("-Disabled")
            }
            this.gui.Opt("Disabled")

            this.keywordsHotkey.showGui(
                callback,
                GlobalData.hotkeyList[index + GlobalData.config["hotkey"].Length].obj,
            )
        }
    }

    static deleteSearchHotkey() {
        curRow := this.keywordsHotkeyLV.GetNext()
        if (curRow) {
            GlobalData.config["keywordsHK"].RemoveAt(curRow)
            GlobalData.hotkeyList.RemoveAt(GlobalData.config["hotkey"].Length + curRow)
            this.refreshHotkey()
        } else {
            ToolTip("请选中要删除的关键字快捷键")
            SetTimer((*) => ToolTip(), -2500)
        }
    }

    ; 添加搜索指定关键词热键
    static addSearchHotkey() {
        ; 确定添加的回调
        callback(obj) {
            ; 添加到config
            GlobalData.config["keywordsHK"].Push(obj)
            this.refreshHotkey() ; 重新加载热键
            this.gui.Opt("-Disabled")
        }
        this.gui.Opt("Disabled")

        this.keywordsHotkey.showGui(
            callback,
            Map("block", 1, "index", 1, "key", "", "keywords", "", "mode", 0, "play", 0),
        )
    }

    ; 固有热键定义
    static hotkeyInit() {
        ; this.hotkeyMap[原始按键][按键方式]:=属于的热键序号
        for index, obj in GlobalData.config["hotkey"] {
            GlobalData.hotkeyList[index].obj := obj
            rawKey := Trim(obj["key"], "~$")
            if (rawKey) {
                ; 标记按键占用的方式
                if (this.hotkeyMap.Has(rawKey)) {
                    this.hotkeyMap[rawKey][obj["index"]] := index
                } else {
                    this.hotkeyMap[rawKey] := Map(obj["index"], index)
                }
            }
        }

        ; 关键字快捷键的回调
        searchOnKeywords(kw, mode, play, *) {
            c := mode == 0 ? StartupMode : IntelligentMode
            c.showGui(kw)
            if (play) {
                searchResult := mode == 0 ? GlobalData.startupSearchResult : GlobalData.intelligentSearchResult
                pluginSearchResut := mode == 0 ? StartupMode.pluginSearchResult : IntelligentMode.pluginSearchResult
                ; 启动第一个结果
                if (searchResult.Length || pluginSearchResut.Length)
                    (mode == 0) ? StartupMode.startupRun(1) : IntelligentMode.intelligentRun(1)
            }
        }

        len := GlobalData.config["hotkey"].Length
        for index, obj in GlobalData.config["keywordsHK"] {
            tmp := {
                cb: searchOnKeywords.Bind(obj["keywords"], obj["mode"], obj["play"]),
                obj: obj
            }
            GlobalData.hotkeyList.Has(index + len) ?
                (GlobalData.hotkeyList[index + len] := tmp) :
                GlobalData.hotkeyList.Push(tmp)

            rawKey := Trim(obj["key"], "~$")
            if (rawKey) {
                ; 标记按键占用的方式
                if (this.hotkeyMap.Has(rawKey)) {
                    this.hotkeyMap[rawKey][obj["index"]] := index + len ; 序号从len+1开始
                } else {
                    this.hotkeyMap[rawKey] := Map(obj["index"], index + len)
                }
            }
        }

        ; 对标记结果按优先级进行占用
        for key, item in this.hotkeyMap {
            if (item.Has(3) || item.Has(4)) { ; 3,4优先于1,2
                loop 2 {
                    if (item.Has(A_Index))
                        item.Delete(A_Index)
                }
            } else if (item.Has(2) && item.Has(1)) { ;2 优先于1
                item.Delete(1)
            }
        }

        ; 填充设置界面"固有热键"的文本
        for index, obj in GlobalData.config["hotkey"] {
            rawKey := Trim(obj["key"], "~$")
            if (rawKey) {
                this.hkTextCtrlList[index].Text := this.hotkeyMap[rawKey].Has(obj["index"]) ?
                (this.hotkeyMap[rawKey][obj["index"]] = index ? this.keyObjToString(obj) : "无效") : "无效"
            } else
                this.hkTextCtrlList[index].Text := "无效"
        }

        ; 重新加载设置界面 "控制" 中关键字热键列表
        this.keywordsHotkeyLV.Opt("-Redraw")
        this.keywordsHotkeyLV.Delete()
        for index, obj in GlobalData.config["keywordsHK"] {
            rawKey := Trim(obj["key"], "~$")
            if (rawKey) {
                hkWords := this.hotkeyMap[rawKey].Has(obj["index"]) ?
                (this.hotkeyMap[rawKey][obj["index"]] = index + len ? this.keyObjToString(obj) : "无效") : "无效"
            } else
                hkWords := "无效"

            this.keywordsHotkeyLV.Add(, hkWords, obj["keywords"])
        }
        this.keywordsHotkeyLV.Opt("Redraw")

        ; 启用热键
        for key, item in this.hotkeyMap {
            if (item.Has(3) && item.Has(4)) {
                ; 同时存在时组合
                HotkeyHelper.doubleAndLongHotkey(key, 0.5, 0.5,
                    GlobalData.hotkeyList[item[4]].cb, ; 长按
                    GlobalData.hotkeyList[item[3]].cb) ; 双击
            } else { ; 否则仅有1个按键方式
                keyWay := 1
                for k in item
                    keyWay := k
                gItem := GlobalData.hotkeyList[item[keyWay]]
                switch keyWay {
                    case 1: ; 普通
                        Hotkey((gItem.obj["block"] ? "" : "~") gItem.obj["key"], gItem.cb, "On") ;需要判断是否加~
                    case 2: ;自定义
                        Hotkey(gItem.obj["key"], gItem.cb, "On") ; 不需要加~判断直接使用obj["key"]
                    case 3: ; 双击
                        HotkeyHelper.doubleAndSingleHotKey(gItem.obj["key"], 0.5, gItem.cb, , gItem.obj["block"])
                    case 4: ; 长按
                        HotkeyHelper.longPressHotKey(gItem.obj["key"], 0.5, gItem.cb)
                }
            }

        }
    }

    ; 刷新热键定义
    static refreshHotkey() {
        ; 禁用所有按键
        for key in this.hotkeyMap
            Hotkey(key, "Off")
        this.hotkeyMap := Map() ; 重置map
        ; 重新执行init
        this.hotkeyInit()
    }

    ; 添加热键组件
    static addHotkeyCtrl(y, index, text) {
        editHotkey(index) {
            callback(obj) {
                GlobalData.config["hotkey"][index] := obj
                this.refreshHotkey() ; 重新加载热键
                this.gui.Opt("-Disabled")
            }
            this.gui.Opt("Disabled")
            this.hotkey.showGui(callback, GlobalData.hotkeyList[index].obj, "修改热键 - " GlobalData.hotkeyList[index].title)
        }
        this.gui.AddText("x30 y" y, text)
        this.hkTextCtrlList.Push(this.gui.AddText("xp+100 yp-2 w200 +Border"))
        this.gui.AddButton("xp+210 yp-3 h27", "修改").OnEvent("Click", (*) => editHotkey(index))
    }

    ; 热键对象转文本
    static keyObjToString(obj) {
        out := []

        if (obj.Has("block") && obj["block"])
            out.Push("Block")

        switch obj["index"] {
            case 1:
                tmp := obj["key"]
                names := ["Shift", "Ctrl", "Alt"]
                for k in ["+", "^", "!"] {
                    if (InStr(tmp, k)) {
                        tmp := StrReplace(tmp, k)
                        out.Push(names[A_Index])
                    }
                }
                out.Push(tmp)
            default:
                out.Push(["自定义", "双击", "长按"][obj["index"] - 1])
                out.Push(obj["key"])
        }
        res := ""
        for v in out
            res .= v " + "
        return SubStr(res, 1, -3)
    }

    ; 隐藏设置界面
    static hideGui() {
        this.gui.Hide()
    }

    ; 显示设置界面
    static showGui() {
        this.gui.Show()
    }

    ; 关键词快捷键编辑类
    class keywordsHotkey {
        static outer := SettingGui
        static _khDDLChoice := 0
        static callBack := (*) => 0
        static khDDLChoice {
            get => this._khDDLChoice
            set {
                if (this._khDDLChoice != Value) {
                    this._khDDLChoice := Value
                    this.hkDDL.Value := Value
                    if (Value == 1) {
                        this.sinHotkeyEdit.Visible := false
                        this.ordHotkey.Visible := true
                    } else {
                        this.ordHotkey.Visible := false
                        this.sinHotkeyEdit.Visible := true
                    }
                    if (Value == 2)
                        this.checkBoxBlock.Value := 0
                    this.checkBoxBlock.Enabled := Value != 2
                }
            }
        }

        static init() {
            this.gui := g := Gui(, "关键词快捷键设置")
            g.Opt("Owner" SettingGui.gui.Hwnd)
            g.BackColor := "FFFFFF"
            g.SetFont("s12 q5 c333333", "NSimSun")
            g.SetFont(, "雅痞-简")    ;优先使用更好看的字体

            g.AddText("x10 y10", "按键类型")
            this.hkDDL := g.AddDropDownList("xp+80 yp-3 w150", ["普通", "自定义", "双击", "长按"])
            this.hkDDL.OnEvent("change", (ctrl, *) => this.khDDLChoice := ctrl.Value)

            g.AddText("x10 yp+50", "按键内容")
            this.ordHotkey := g.Add("Hotkey", "xp+80 yp-3 w150")
            this.sinHotkeyEdit := g.Add("Edit", "xp yp w150")
            this.checkBoxBlock := g.AddCheckbox("x10 yp+50", "屏蔽原按键功能")
            this.khDDLChoice := 1

            ; 关键词相关内容
            g.AddText("x260 y10", "搜索模式")
            this.modeDDL := g.AddDropDownList("xp+80 yp-3 w150 Choose1", ["启动模式", "智能模式"])
            g.AddText("x260 yp+50", "关键词")
            this.keywordsEdit := g.Add("Edit", "xp+80 yp-3 w150")
            this.checkBoxPlay := g.AddCheckbox("x260 yp+50", "是否启动搜索结果")


            cb(*) {
                if (res := this.submit()) {
                    this.callBack.Call(res)
                    g.Hide()
                }
            }
            g.AddButton("x135 yp+40 h27 w230", "确定").OnEvent("Click", cb)

            g.OnEvent("Close", (*) => SettingGui.gui.Opt("-Disabled"))
            g.Show("w500 Hide")
        }

        static submit() {
            if !(keywords := this.keywordsEdit.Value) {
                ToolTip("关键词不能为空")
                SetTimer((*) => ToolTip(), -2500)
                return
            }
            index := this.khDDLChoice
            key := index = 1 ? this.ordHotkey.Value : this.sinHotkeyEdit.Value
            block := this.checkBoxBlock.Value
            mode := this.modeDDL.Value - 1
            play := this.checkBoxPlay.Value

            switch index {
                case 1: ; 普通
                    if (InStr(key, "vk")) {
                        ToolTip("非法按键，请重新设置")
                        SetTimer((*) => ToolTip(), -2500)
                    } else {
                        return Map(
                            "index", index,
                            "key", key,
                            "block", block,
                            "mode", mode,
                            "keywords", keywords,
                            "play", play
                        )
                    }
                case 2: ; 自定义
                    return Map(
                        "index", index,
                        "key", key,
                        "mode", mode,
                        "keywords", keywords,
                        "play", play
                    )
                default: ; 双击、长按
                    name := GetKeyName(key)
                    if (name && name = key) {
                        return Map(
                            "index", index,
                            "key", key,
                            "block", block,
                            "mode", mode,
                            "keywords", keywords,
                            "play", play
                        )
                    } else {
                        ToolTip("非法按键，请使用按键列表中的某一个按键名称")
                        SetTimer((*) => ToolTip(), -2500)
                    }
            }
        }

        ; 显示编辑gui
        static showGui(cb, obj) {
            this.callBack := cb
            this.khDDLChoice := obj["index"]
            if (obj.Has("block"))
                this.checkBoxBlock.Value := obj["block"]
            (obj["index"] = 1 ? this.ordHotkey : this.sinHotkeyEdit).Value := obj["key"]

            this.keywordsEdit.Value := obj["keywords"]
            this.modeDDL.Value := obj["mode"] + 1
            this.checkBoxPlay.Value := obj["play"]
            this.gui.Show()
        }
    }

    ; 热键编辑类
    class hotkey {
        static outer := SettingGui
        static _khDDLChoice := 0
        static callBack := (*) => 0
        static khDDLChoice {
            get => this._khDDLChoice
            set {
                if (this._khDDLChoice != Value) {
                    this._khDDLChoice := Value
                    this.hkDDL.Value := Value
                    if (Value == 1) {
                        this.sinHotkeyEdit.Visible := false
                        this.ordHotkey.Visible := true
                    } else {
                        this.ordHotkey.Visible := false
                        this.sinHotkeyEdit.Visible := true
                    }
                    if (Value == 2)
                        this.checkBox.Value := 0
                    this.checkBox.Enabled := Value != 2
                }
            }
        }

        static init() {
            this.gui := g := Gui(, "按键设置")
            g.Opt("Owner" SettingGui.gui.Hwnd)
            g.BackColor := "FFFFFF"
            g.SetFont("s12 q5 c333333", "NSimSun")
            g.SetFont(, "雅痞-简")    ;优先使用更好看的字体

            this.title := g.AddText("x10 y10 w230")
            g.AddText("x10 yp+40", "按键类型")
            this.hkDDL := g.AddDropDownList("xp+80 yp-3 w150", ["普通", "自定义", "双击", "长按"])
            this.hkDDL.OnEvent("change", (ctrl, *) => this.khDDLChoice := ctrl.Value)

            g.AddText("x10 yp+50", "按键内容")
            this.ordHotkey := g.Add("Hotkey", "xp+80 yp-3 w150")
            this.sinHotkeyEdit := g.Add("Edit", "xp yp w150")
            this.checkBox := g.AddCheckbox("x10 yp+50", "屏蔽原按键功能")
            this.khDDLChoice := 1

            cb(*) {
                if (res := this.submit()) {
                    this.callBack.Call(res)
                    g.Hide()
                }
            }
            g.AddButton("x10 yp+40 h27 w230", "确定").OnEvent("Click", cb)

            g.OnEvent("Close", (*) => SettingGui.gui.Opt("-Disabled"))
            g.Show("w250 Hide")
        }

        static submit() {
            index := this.khDDLChoice
            key := index = 1 ? this.ordHotkey.Value : this.sinHotkeyEdit.Value
            block := this.checkBox.Value
            switch index {
                case 1:
                    if (InStr(key, "vk")) {
                        ToolTip("非法按键，请重新设置")
                        SetTimer((*) => ToolTip(), -2500)
                    } else {
                        return Map(
                            "index", index,
                            "key", key,
                            "block", block
                        )
                    }
                case 2:
                    return Map(
                        "index", index,
                        "key", key
                    )
                default:
                    name := GetKeyName(key)
                    if (name && name = key) {
                        return Map(
                            "index", index,
                            "key", key,
                            "block", block
                        )
                    } else {
                        ToolTip("非法按键，请使用按键列表中的某一个按键名称")
                        SetTimer((*) => ToolTip(), -2500)
                    }
            }
        }

        ; 显示编辑gui
        static showGui(cb, obj, title) {
            this.title.Text := title
            this.callBack := cb
            this.khDDLChoice := obj["index"]
            if (obj.Has("block"))
                this.checkBox.Value := obj["block"]
            (obj["index"] = 1 ? this.ordHotkey : this.sinHotkeyEdit).Value := obj["key"]
            this.gui.Show()
        }
    }
}