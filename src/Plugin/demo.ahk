/**
 * @Name: demo.ahk
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-03-29
 * @Description: 插件示例
 */

/*
===============================================
Starter通过解析 Starter Plugin Info 和
Starter Plugin Info 之间的内容来加载插件
信息，无此内容的文件将被忽略，格式见下方。

icon: 插件列表中的图标，请填入无头部的base64图片
===============================================

===Starter Plugin Info==>
{
    "author": "ruchuby",
    "version": "0.0.1",
    "introduction": "An example of Starter Plugin",
    "icon": "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAnBJREFUWEfVlj9oFEEUxt+bLa6wF0whQcRCENOo2EUQYy/xZmb3sDKCoK0RhURQSFoFwdhcuNuZPY+AXKU22gmKiI2FAREbwUrwrI6dJxN2wv3Z21vZDWe2291vv/fbNx9vBmHKF065Pvy/AEKI60R0EhGPFekSEX1BxE9a68dpPqkdEEI0AcAvUjjl21BrHQw/HwGoVqsXGGMvE+E3ItosAoKIVwBg1noYYxZardarfr8RACHEDQB4aEWe5800m80fRQCCIDgax/F24nFTa/0oE4BzvoqIK1aktS4lpEIIsn5EdC+KotX9CyClXDLGzGQtCWNs2/O8541G44/TldIBKeUcEX3MkwfG2OkwDN+XCsA5n0XECADOTID4UKlUztfr9V+lAuT583GaUpZg6gC1Wu1Ar9dbdENlHJANYbfb7XQ6nd+lLoHv+6eMMe/ydIKIzkVR9KZUgCAIDsVxfBsATmRB2M0niqJr/Zr9mwHbymRP+BmG4ec87Xca3/ePx3F80N4j4uuJo1hKeYSI1gDABm3kQsR1pdRyHggp5RoR3RqjbSPislLq6w6cE3HOnyDi0oQCT7XWmRohxAYAXJ2Qkw2Xk12A/qAAwG6Ckxbav7mYmA68Syk0nzx7QUTrQ+/nh3faVIDhLdOaCCHuA8CdPEsAAA+01neHtWlbfW4AayalXDDGnM2CYIy9VUq5E9WAtDBAzr8fK+OcryDizoHEHXb+qQMlAIyctnKFsGjhvu8zQ/hs3AwoEcBZtbXWlwfmgJRykYiqAHBpDwr2W24hYksp1R4AcAo7EY0xh/cCgjH23U1A51/KsbsI7NQB/gIoe4UwRdVGRAAAAABJRU5ErkJggg=="
}
<==Starter Plugin Info===
*/

PluginHelper.addEntryFunc((*) => Plugin_Demo.main()) ; 添加入口函数等待执行

; 使用类，避免变量名、函数名污染
class Plugin_Demo {
    static menu := Menu()
    ; static gui:=unset
    ; static edit:=unset

    static guiInit() {
        g := Gui(, "插件基本示例1")
        g.BackColor:="FFFFFF"
        g.AddText(, "一个简单的Gui示例")

        SplitPath(A_LineFile, &pluginName)
        ; MsgBox(PluginHelper.getPluginIcon(pluginName))
        g.AddPicture("w50 h50", "hbitmap:" PluginHelper.getPluginIcon(pluginName))
        this.edit := g.AddEdit("w200 h100", "输入文本~")
        g.Show("Hide")
        this.gui := g
    }

    static showGui() {
        this.gui.Show()
    }

    static main() {
        this.guiInit()

        this.menu.Add("显示面板", (*) => this.showGui())
        this.menu.Add("弹出编辑框文本", (*) => MsgBox(this.edit.Value))
        this.menu.Add("其他", (*) => MsgBox("自定义其他的功能吧！"))

        ; PluginHelper是方便插件规范调用Starter API的静态类
        PluginHelper.pluginMenu.Add("demo.ahk", this.menu)
        ; MsgBox("插件已加载 demo.ahk")
    }
}