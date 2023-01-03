class TrayMenu {
    static menu := unset

    static init() {
        TraySetIcon(GlobalData.imgDir "\Starter.png", , true)
        A_IconTip := "Starter"

        this.menu := A_TrayMenu
        this.menu.Delete()

        this.menu.Add("搜索界面`t双击CapsLock", (*) => SearchGui.showGui())
        this.menu.Add("编辑界面`t(&E)", (*) => EditGui.showGui())
        this.menu.Add("自启界面`t(&B)", (*) => BootGui.showGui())
        this.menu.Add()
        this.menu.Add("开机启动", (*) => this.toggleStartupState())
        this.menu.Add("退出`t(&X)", (*) => ExitApp())

        this.menu.SetIcon("1&", GlobalData.imgDir "\Starter.png")
        this.menu.SetIcon("2&", GlobalData.imgDir "\grey-edit.png")
        this.menu.SetIcon("3&", GlobalData.imgDir "\grey-run.png")

        if (this.getStartupState())
            this.menu.Check("5&")

        this.menu.Default := "1&"
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
            this.menu.Uncheck("5&")
        } else {
            cmd := A_IsCompiled ? Format('"{}" "the_Startup"', A_ScriptFullPath) : Format('"{}" "{}" "the_Startup"', A_AhkPath, A_ScriptFullPath)
            RegWrite(cmd, "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Starter")
            this.menu.check("5&")
        }
    }
}