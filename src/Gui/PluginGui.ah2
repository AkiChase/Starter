/**
 * @Name: PluginGui
 * @Version: 0.0.1
 * @Author: AkiChase
 * @LastEditors: AkiChase
 * @LastEditTime: 2023-04-13
 * @Description: 插件界面
 */

class PluginGui {
    ; static gui:=unset
    ; static LV:=unset
    static pluginList := []
    static IL := 0

    static init() {
        if (!IsSet(DEBUG) || !DEBUG)
            this.loadPlugins()
        this.gui := Gui("-Resize", "插件界面")
        this.gui.SetFont("s12 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        this.gui.BackColor := "FFFFFF"

        this.LV := this.gui.Add("ListView", "x0 y0 w500 h320 -E0x200 Grid", ["名称", "启用", "作者", "版本", "介绍"])
        this.LV.OnEvent("DoubleClick", (_LV, rowNum) => this.togglePluginEnabled(rowNum))

        this.gui.AddButton("x120 y330", "刷新列表").OnEvent("Click", (*) => this.refreshPluginsList())
        this.gui.AddButton("x280 y330", "保存重载").OnEvent("Click", (*) => this.storeAndReload())

        this.gui.OnEvent("Close", (guiObj) => guiObj.Hide())
        this.gui.Show("w500 h380 Hide")

        this.refreshPluginsList()
    }

    static loadPlugins() {
        fList := []
        pluginList := []
        for name in GlobalData.config["plugin"] {
            path := GlobalData.pluginDir "\" name
            if (FileExist(path)) ; 仅添加有效的文件
                fList.Push(GlobalData.pluginDir "\" name), pluginList.Push(name)
        }

        ; 如果插件列表出现变动
        if (pluginList.Length != GlobalData.config["plugin"].Length) {
            GlobalData.config["plugin"] := pluginList
            GlobalData.storeConfig()
        }
        Loader.loadFromFiles(fList)
    }

    static storeAndReload() {
        plugin := []
        for info in this.pluginList {
            if (info["enabled"]) {
                plugin.Push(info["name"])
            }
        }
        GlobalData.config["plugin"] := plugin
        Reload()
    }

    static togglePluginEnabled(rowNum) {
        if (rowNum > 0) {
            flag := this.pluginList[rowNum]["enabled"]
            this.pluginList[rowNum]["enabled"] := !flag
            this.LV.Modify(rowNum, , , flag ? "" : "是")
            this.gui.Title := "插件界面 *未保存"
        }
    }

    static refreshPluginsList() {
        this.LV.Opt("-Redraw")
        this.LV.Delete()
        if (this.IL)
            IL_Destroy(this.IL)
        this.IL := IL_Create()
        this.LV.SetImageList(this.IL)


        ; 插件文件后缀判断
        fList := []
        Loop Files, GlobalData.pluginDir "\*.*" {
            if (InStr(A_LoopFileExt, "ahk") || InStr(A_LoopFileExt, "ah2"))
                fList.Push(A_LoopFileFullPath)
        }

        this.pluginList := []

        if (!fList.Length) {
            this.LV.Opt("Redraw")
            return
        }

        s := "===Starter Plugin Info==>", e := "<==Starter Plugin Info===", len := StrLen(s)
        pluginCopy := GlobalData.config["plugin"].Clone()


        for f in fList {
            content := FileRead(f)
            l := InStr(content, s) + len, r := InStr(content, e)
            if (r <= l || l == len) ;未解析到插件信息，跳过
                continue

            content := SubStr(content, l, r - l)
            info := Jxon_Load(&content)

            ; 插件信息格式不正确，跳过
            if (Type(info) != "Map")
                continue

            SplitPath(f, &name)
            info["name"] := name

            ; 默认值
            for name in ["author", "version", "introduction", "icon"] {
                if (!info.Has(name))
                    info[name] := ""
            }

            info["filePath"] := f

            ; 加载图标至图像列表
            base64 := info["icon"]
            info["iconBase64"] := base64
            if (base64) {
                hIcon := LoadIconFromBase64(base64, 32, 32)
                info["icon"] := IL_Add(this.IL, "HICON:*" hIcon)
                info["iconHIcon"] := hIcon
            } else
                info["icon"] := 0

            info["enabled"] := this._isPluginEnabled(pluginCopy, info["name"]) ? 1 : 0
            this.pluginList.Push(info)
        }

        this.LV.SetImageList(this.IL)
        for info in this.pluginList {
            this.LV.Add("Icon" info["icon"], A_Space info["name"],
            info["enabled"] ? "是" : "",
            info["author"], info["version"], info["introduction"])
        }


        this.LV.ModifyCol()
        this.LV.ModifyCol(2, "AutoHdr Center")

        this.LV.Opt("Redraw")

        this.gui.Title := "插件界面"
    }

    static _isPluginEnabled(arr, name) {
        for i, v in arr {
            if (name == v) {
                arr.RemoveAt(i)
                return true
            }
        }
        return false
    }

    static showGui() {
        this.gui.Show()
    }
}