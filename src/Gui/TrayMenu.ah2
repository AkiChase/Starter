/**
 * @Name: TrayMenu
 * @Version: 0.0.2
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-02
 * @Description: 菜单栏
 */

class TrayMenu {
    ; static menu := unset
    ; static 7z:=unset
    ; static gui:=unset

    static init() {
        A_IconTip := "Starter"

        this.menu := A_TrayMenu
        this.menu.Delete()

        this.menu.Add("搜索界面`t双击CapsLock", (*) => StartupMode.showGui())
        this.menu.Add("编辑启动模式`t(&S)", (*) => StartupEditGui.showGui())
        this.menu.Add("编辑智能模式`t(&I)", (*) => IntelligentEditGui.showGui())
        this.menu.Add("自启界面`t(&B)", (*) => BootGui.showGui())
        this.menu.Add("插件界面`t(&P)", (*) => PluginGui.showGui())
        this.menu.Add("关于界面`t(&A)", (*) => AboutGui.showGui())
        this.menu.Add()
        this.menu.Add("开机启动", (*) => this.toggleStartupState())

        userDataMenu := Menu()
        userDataMenu.Add("打开数据目录`t(&D)", (*) => Start.startFile(GlobalData.dataDir))
        userDataMenu.Add("导出用户数据`t(&B)", (*) => this.guideGui(0))
        userDataMenu.Add("导入用户数据`t(&I)", (*) => this.guideGui(1))
        this.menu.Add("用户数据`t(&D)", userDataMenu)

        this.menu.Add("退出`t(&X)", (*) => ExitApp())

        this.menu.SetIcon("1&", GlobalData.imgDir "\Starter.png")
        this.menu.SetIcon("2&", GlobalData.imgDir "\edit.ico")
        this.menu.SetIcon("3&", GlobalData.imgDir "\edit.ico")
        this.menu.SetIcon("4&", GlobalData.imgDir "\run.ico")
        this.menu.SetIcon("5&", GlobalData.imgDir "\plugin.ico")
        this.menu.SetIcon("6&", GlobalData.imgDir "\info.ico")

        if (this.getStartupState())
            this.menu.Check("开机启动")

        this.menu.Default := "1&"

        A_IconHidden := false ; 重载结束后显示图标
    }

    /**
     * @param mode 0: 导出用户数据; 1: 导入用户数据
     */
    static guideGui(mode := 0) {
        g := Gui(, mode ? "导入用户数据" : "导出用户数据")
        g.BackColor := "FFFFFF"
        g.SetFont("s12 q5 c333333", "NSimSun")
        g.SetFont(, "雅痞-简")    ;优先使用更好看的字体

        g.AddText("x10 y15", mode ? "数据路径" : "保存目录")
        pathEdit := g.AddEdit("xp+80 yp-5 w200 ReadOnly")

        g.AddButton("xp+220 yp-5", "选择").OnEvent("Click",
            (*) => mode ?
                pathEdit.Value := FileSelect(3, A_Desktop, "请选择用户数据文件", "zip (*.zip)") :
                pathEdit.Value := DirSelect("*" A_Desktop, , "请选择保存目录")
        )

        g.AddText("x10 yp+50", mode ? "导入内容选项:" : "导出内容选项:")

        checkboxList := [
            g.AddCheckbox("x75 yp+30 Checked", "用户数据"),
            g.AddCheckbox("xp+150 yp Checked", "插件"),
        ]

        options() {
            out := []
            for c in checkboxList
                out.Push(c.Value)
            return out
        }

        g.AddButton("x130 yp+40 h27 w100", mode ? "导 入" : "导 出").OnEvent("Click",
            (*) => mode ? this.importUserData(pathEdit.Value, options()) : this.backupUserData(pathEdit.Value, options(), g)
        )

        g.OnEvent("Close", (*) => g.Destroy())
        g.Show()
    }

    ; 导出用户数据
    static backupUserData(path, options, g) {
        if (!this.HasOwnProp("7z"))
            this.zipper := SevenZip()
        fList := []
        if (options[1])
            fList.Push(GlobalData.dataDir)
        if (options[2])
            fList.Push(GlobalData.pluginDir)

        if (!fList.Length) {
            WiseGuiHelper.tooltip("提示", "至少选择一项内容", 1500)
            return
        }
        if (!StrLen(path)) {
            WiseGuiHelper.tooltip("提示", "请选择保存目录", 1500)
            return
        }

        newPath := path "\Starter_Data_" A_Now ".zip"

        _files := ""
        for v in fList
            _files .= v "`n"
        this.zipper.Add(newPath, _files, "-tzip -r -mx5 -mmt=2")
        g.Destroy()
        WiseGuiHelper.tooltip("提示", "用户数据已导出: " newPath, 2500)
    }

    ; 导入用户数据
    static importUserData(path, options) {
        if (!this.HasOwnProp("7z"))
            this.zipper := SevenZip()
        if !(options[1] || options[2]) {
            WiseGuiHelper.tooltip("提示", "至少选择一项内容", 1500)
            return
        }
        if (!StrLen(path)) {
            WiseGuiHelper.tooltip("提示", "请选择保存目录", 1500)
            return
        }

        tmpDir := A_Temp "\" A_TickCount "_starter"
        this.zipper.Extract(path, tmpDir, , "-aoa")

        res := ""
        if (options[1]) {
            if (FileExist(dir := tmpDir "\data"))
                DirCopy(dir, GlobalData.dataDir, true), res .= "用户数据导入成功`n"
        }
        if (options[2]) {
            if (FileExist(dir := tmpDir "\Plugin"))
                DirCopy(dir, GlobalData.pluginDir, true), res .= "插件导入成功`n"
        }
        if (StrLen(res)) {
            GlobalData.onExitHandler := (*) => 0
            WiseGuiHelper.tooltip("提示", res "1s后软件重启")
            Sleep(1000)
            Reload()
            ;清除退出保存重启
        } else {
            WiseGuiHelper.tooltip("提示", "导入失败")
        }
    }

    ; 获取加入注册表状态
    static getStartupState() {
        try
            return RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Starter")
        catch
            return false
    }

    ; 切换开机启动
    static toggleStartupState() {
        if (this.getStartupState()) {
            RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Starter")
            this.menu.Uncheck("开机启动")
        } else {
            cmd := Format('"{}" "{}" "the_Startup"', GlobalData.rootDir "\src\AutoHotkey64.exe", GlobalData.rootDir "\src\Starter.ah2")
            RegWrite(cmd, "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Starter")
            this.menu.check("开机启动")
        }
    }
}