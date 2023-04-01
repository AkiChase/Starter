/**
 * @Name: win10任务栏透明.ahk
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-03-29
 * @Description: win10任务栏透明功能
 */

/*
===Starter Plugin Info==>
{
    "author": "ruchuby",
    "version": "0.0.1",
    "introduction": "任务栏透明化，仅支持win10，打开开始菜单透明化会消失",
    "icon": "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAKtJREFUWEdjZBhgwDjA9jMMOgfMxBEiZxkYGGbhkPPBIf6cgYEBpA8vQA8BkAOMsegAWY7LAWl4HD3qgNEQIDkEcCUoPQYGhh14Ujs2KREGBoZLhPQQWw6AspovDsPScYhLMjAwSGGR+8zAwHALJj7qgNEQGHQhMFoXjIbAaAiMVka4GpCjteFoCIBCQB1HAunF0yLixSFHcouIUAeHbHliq2OyLSCkccAdAADLclshWioLowAAAABJRU5ErkJggg=="
}
<==Starter Plugin Info===
*/

PluginHelper.addEntryFunc((*) => Plugin_win10任务栏透明.main()) ; 添加入口函数等待执行

class Plugin_win10任务栏透明 {
    static menu := Menu()
    static state := false
    ; static f:=unset

    static TaskBar_SetAttr(accent_state := 0, gradient_color := "0x01000000")
    {
        static init := 0
        static hTrayWnd := 0
        static ver := DllCall("GetVersion") & 0xff < 10
        static pad := A_PtrSize = 8 ? 4 : 0, WCA_ACCENT_POLICY := 19

        if !(init) {
            if (ver)
                throw Error("Minimum support client: Windows 10", -1)
            if !(hTrayWnd := DllCall("user32\FindWindow", "str", "Shell_TrayWnd", "ptr", 0, "ptr"))
                throw Error("Failed to get the handle", -1)
            init := 1
        }

        ACCENT_POLICY := Buffer(16, 0)
        accent_size := ACCENT_POLICY.Size
        NumPut("int", (accent_state > 0 && accent_state < 4) ? accent_state : 0, ACCENT_POLICY, 0)

        if (accent_state >= 1) && (accent_state <= 2) && (RegExMatch(gradient_color, "0x[[:xdigit:]]{8}"))
            NumPut("int", gradient_color, ACCENT_POLICY, 8)

        WINCOMPATTRDATA := Buffer(4 + pad + A_PtrSize + 4 + pad, 0)
        NumPut("int", WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0,)
        NumPut("ptr", ACCENT_POLICY.Ptr, WINCOMPATTRDATA, 4 + pad)
        NumPut("uint", accent_size, WINCOMPATTRDATA, 4 + pad + A_PtrSize)
        if !(DllCall("user32\SetWindowCompositionAttribute", "ptr", hTrayWnd, "ptr", WINCOMPATTRDATA.Ptr))
            throw Error("Failed to set transparency / blur", -1)
        return 0
    }

    static toggleState() {
        if (this.state) {
            SetTimer(this.f, 0) ;关闭计时器
            this.menu.Uncheck("开启")
        } else {
            SetTimer(this.f, 8000) ;开启计时器
            this.TaskBar_SetAttr(2) ; 透明化
            this.menu.check("开启")
        }
        this.state := !this.state
    }

    static main() {
        this.f := this.TaskBar_SetAttr.Bind(this, 2)
        this.menu.Add("开启", (*) => this.toggleState())
        PluginHelper.pluginMenu.Add("win10任务栏透明", this.menu)
        this.toggleState()
    }
}