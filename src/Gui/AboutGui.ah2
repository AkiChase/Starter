/**
 * @Name: 关于界面
 * @Version: 0.0.3
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-02
 * @Description: 关于界面显示版本信息、项目主页、检查更新
 */
class AboutGui {
    static version := "0.2.1"
    ; static gui:=unset

    static init() {
        this.gui := Gui("-Resize", "关于界面")
        this.gui.SetFont("s14 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体

        this.gui.AddPicture("w75 h75", GlobalData.imgDir "\Starter.png")
        this.gui.AddText("x160 yp h50 w200", "Starter").SetFont("bold s30")
        this.gui.AddText("x160 yp+50", "当前版本: " this.version)

        this.gui.AddText("x140 yp+50", "开发者:")
        this.gui.AddText("xp+90 yp w200", "ruchuby").SetFont("bold")
        this.gui.AddLink("x120 yp+35", '项目主页:  <a href="https://github.com/ruchuby/Starter">Github Starter</a>')
        this.gui.AddLink(, '项目主页:  <a href="https://gitee.com/ruchuby/Starter"> Gitee  Starter</a>')

        this.gui.AddButton("x175 yp+50", "检查更新").OnEvent("Click", (*) => this.checkUpdates())

        this.gui.OnEvent("Close", (guiObj) => guiObj.Hide())
        this.checkUpdates(true)
    }

    static showGui() {
        this.gui.Show()
    }

    static versionCompare(v1, v2) {
        v1 := StrSplit(v1, ".")
        v2 := StrSplit(v2, ".")
        loop 3 {
            if (v1[A_Index] == v2[A_Index])
                continue
            return StrCompare(v1[A_Index], v2[A_Index])
        }
        return 0
    }

    ; 检查最新版本
    static checkUpdates(silent := false) {
        this.gui.Title := "正在检查更新..."
        try {
            res := WinHttp().Download("https://gitee.com/api/v5/repos/ruchuby/Starter/tags?access_token=14eff4e12ee77cfd7ea5410727cb1526")
            res_json := Jxon_Load(&res)
            latest := SubStr(res_json[1]["name"], 2)
            if (this.versionCompare(latest, this.version) > 0) {
                WiseGuiHelper.tooltip("检测到新版本: " latest
                    , "请自行前往项目主页下载, 右键右下角托盘图标导出用户数据后可以导入新版本中")
            } else if (!silent)
                WiseGuiHelper.tooltip("更新提示", "无需更新，已更新至最新版本: " latest)
        } catch
            WiseGuiHelper.tooltip("错误", "检查更新失败")
        this.gui.Title := "关于界面"
    }
}