class BootGui {
    static gui := unset
    static listView := unset
    static menu := unset
    static menuRow := 0

    static init() {
        this.gui := Gui("-Resize", "自启界面")
        this.gui.BackColor := "FFFFFF"
        this.gui.SetFont("s14 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体

        this.gui.OnEvent("Close", (guiObj) => this.gui.Hide())
        this.gui.OnEvent("DropFiles", this.addItem)

        this.listView := this.gui.Add("ListView", "x0 y0 w300 h300 -Multi -hdr Grid", [""])
        this.listView.SetFont("s12")
        this.listView.OnEvent("ContextMenu", (_lv, rowNum, *) => this.showMenu(rowNum))

        this.gui.Show("Hide w300 h300")
        this.menuInit()

        ; 判断是否刚开机
        for arg in A_Args {
            if (arg = "the_Startup") {
                this.boot()
                break
            }
        }
    }

    static menuInit() {
        this.menu := Menu()
        this.menu.Add("添加`t(&A)", (*) => this.choseAddItem())
        this.menu.Add("刷新`t(&R)", (*) => this.loadItems())
        this.menu.Add("删除`t(&X)", (*) => this.delItem(this.menuRow))

        this.menu.SetIcon("1&", GlobalData.imgDir "\grey-run.png")
        this.menu.SetIcon("2&", GlobalData.imgDir "\grey-refresh.png")
        this.menu.SetIcon("3&", GlobalData.imgDir "\grey-delete.png")
    }

    static showGui() {
        this.loadItems()
        this.gui.Show()
    }

    ; 显示菜单
    static showMenu(rowNum) {
        if (rowNum) {
            this.menuRow := rowNum
            this.menu.Enable("3&")
        } else {
            this.menu.Disable("3&")
        }
        this.menu.Show()
    }

    ; 加载boot项
    static loadItems() {
        this.listView.Delete()
        loop files GlobalData.bootDir "\*.*"
            this.listView.Add(, A_LoopFileName)
    }

    ; 选择文件路径
    static choseAddItem() {
        res := FileSelect("M35", , "请选择文件")
        if (res.Length) {
            this.addItem(res)
        }
    }

    ; 添加回调
    static addItem(args*) {
        fileList := args.Length == 1 ? args[1] : args[2]
        if (fileList.Length) {
            for filePath in fileList {
                if (SubStr(filePath, -4) == ".lnk")    ; 快捷方式直接复制
                    FileCopy(filePath, GlobalData.bootDir)
                else {    ; 创建快捷方式到boot文件夹
                    SplitPath(filePath, , &outDir, , &fileNameNoExt)
                    FileCreateShortcut(filePath, GlobalData.bootDir "\" fileNameNoExt ".lnk", outDir)
                }
            }
            BootGui.loadItems()    ; 此处this不是BootGui
        }
    }

    ; 删除
    static delItem(rowNum) {
        fileName := this.listView.GetText(rowNum)
        if (MsgBox("当前操作不可恢复，是否将当前项删除？", "提示", 0x2044) = "Yes") {
            FileDelete(GlobalData.bootDir "\" fileName)
            this.listView.Delete(rowNum)
        }
    }

    ; 启动
    static boot() {
        loop files GlobalData.bootDir "\*.*"
            Run(A_LoopFileFullPath)
    }
}