class TrayMenu {
    ; static menu := unset

    static init() {
        TraySetIcon(GlobalData.imgDir "\Starter.png", , true)
        A_IconTip := "Starter"

        this.menu := A_TrayMenu
        this.menu.Delete()

        this.menu.Add("搜索界面`t双击CapsLock", (*) => StartupMode.showGui())
        this.menu.Add("编辑启动模式`t(&S)", (*) => StartupEditGui.showGui())
        this.menu.Add("编辑智能模式`t(&I)", (*) => IntelligentEditGui.showGui())
        this.menu.Add("自启界面`t(&B)", (*) => BootGui.showGui())
        this.menu.Add("关于界面`t(&A)", (*) => AboutGui.showGui())
        this.menu.Add()
        this.menu.Add("开机启动", (*) => this.toggleStartupState())

        userDataMenu := Menu()
        userDataMenu.Add("打开数据目录`t(&D)", (*) => Start.startFile(GlobalData.dataDir))
        userDataMenu.Add("导出用户数据`t(&B)", (*) => this.backupUserData())
        userDataMenu.Add("导入用户数据`t(&I)", (*) => this.importUserData())
        this.menu.Add("用户数据`t(&D)", userDataMenu)

        this.menu.Add("退出`t(&X)", (*) => ExitApp())

        this.menu.SetIcon("1&", GlobalData.imgDir "\Starter.png")
        this.menu.SetIcon("2&", GlobalData.imgDir "\edit.ico")
        this.menu.SetIcon("3&", GlobalData.imgDir "\edit.ico")
        this.menu.SetIcon("4&", GlobalData.imgDir "\run.ico")
        this.menu.SetIcon("5&", GlobalData.imgDir "\info.ico")

        if (this.getStartupState())
            this.menu.Check("开机启动")

        this.menu.Default := "1&"
    }

    ; 导出用户数据
    static backupUserData() {
        folder := DirSelect("*" A_Desktop, , "请选择保存目录")
        if (StrLen(folder)) {
            newPath := folder "\Starter_Data_" A_Now
            DirCopy(GlobalData.dataDir, newPath)
            Start.openFileInFolder(newPath)
            MsgBox("用户数据已导出: " newPath, "提示", 0x2040)
        }
    }

    ; 导入用户数据
    static importUserData() {
        folder := DirSelect("*" A_Desktop, , "请选择导出数据文件夹")
        if (StrLen(folder)) {
            DirCopy(folder, GlobalData.dataDir, true)
            GlobalData.onExitHandler := (*) => MsgBox("用户数据已导入，即将重启", "提示", 0x2040)
            Reload()
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
            cmd := A_IsCompiled ? Format('"{}" "the_Startup"', A_ScriptFullPath) : Format('"{}" "{}" "the_Startup"', A_AhkPath, A_ScriptFullPath)
            RegWrite(cmd, "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Starter")
            this.menu.check("开机启动")
        }
    }
}