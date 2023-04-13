class SettingGui {
    static hkTextCtrlList := []
    static hotkeyMap := Map()
    static ctrlMap := Map()

    static init() {
        ; 初始化热键编辑类
        this.hotkey.init()

        this.gui := g := Gui("-Resize", "设置界面")
        g.SetFont("s12 q5", "NSimSun")
        g.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        g.OnEvent("Close", (guiObj) => this.hideGui())

        tab := g.Add("Tab3", "x10 y10 w430 h330 BackgroundFFFFFF", ["常规", "控制"])
        tab.OnEvent("Change", (ctrl, *) => this.onSwitchTab(ctrl.Value))
        ; tab 1
        this.ctrlMap["startupCheckBox"] := g.AddCheckbox("x30 y55", "开机启动")

        this.ctrlMap["startupCheckBox"].OnEvent("Click", (ctrl, *) =>
            (TrayMenu.toggleStartupState(), ctrl.Value := TrayMenu.getStartupState()))
        ; tab 2
        tab.UseTab(2)
        for index, text in ["呼出搜索框", "智能搜索框"] {
            this.addHotkeyCtrl(20 + 35 * A_Index, A_Index, text)
            GlobalData.hotkeyList[index].title := text
        }
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

    ; 热键定义
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

        ; 填充设置界面热键文本
        for index, obj in GlobalData.config["hotkey"] {
            rawKey := Trim(obj["key"], "~$")
            if (rawKey) {
                this.hkTextCtrlList[index].Text := this.hotkeyMap[rawKey].Has(obj["index"]) ?
                (this.hotkeyMap[rawKey][obj["index"]] = index ? this.keyObjToString(obj) : "无效") : "无效"
            } else
                this.hkTextCtrlList[index].Text := "无效"
        }

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
            }
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
        this
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