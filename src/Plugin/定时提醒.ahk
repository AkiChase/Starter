/**
 * @Name: 定时提醒.ahk
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-02
 * @Description: 定时提醒 可设置定时时间和提示语
 */

/*
===Starter Plugin Info==>
{
    "author": "ruchuby",
    "version": "0.0.1",
    "introduction": "定时提醒, 可设置定时时间和提示语",
    "icon": "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAABXJJREFUWEfNVwtsU2UU/s7fhQUYEGAbDw0D5CGi8wEhPBKdQduuBcNYr0YUAoqIkJigYAQlYJwQohgjykvi2FQI3tuBQm97K2QEGApmTkMcTweyBcSMgYypY9x7zN+u2K3tVh4J3KRJe//zn/Od7//+c04Jt/mh2xwfdx6A3FzlPousBQByQNTAjKAl6KOdO9TT18PW+Ly8nimNKevA1igmSifgOIj3COvv+X6/vzHiqwUDdrdnLDHKWgciUC2I5wR8mpoMCIdD6QEb7wTwcBz7ckPXRsYAyMlR0lI74ygsToXgzWSS17JRvbCsWUwkPy/TVWgsOJeAmSDuC1CfsCM+C6YzIHzFNtolmpqYha2UiGQyJWTRXhassAUFhBzpK+hT18ud1xhwupUXmXkDwBsN3TsjGrnTmZ8NoqlMmAqgV3ssEPN6S4j1QZ9aHm3ryFUKQPwWQNsMXc1rAcDh8nwNQAHYY+heb2Sj0+VZyMCyKEclTPSTMK0KZq64mppqiaamB0kgm5gl0Dww0pqdLwro2vJrvpyT+rNIOQngoqFr3VsByC8EaDoxVgX82qty0e7yLCVgSbODI8y0OOhXtbYYaNbR+wDGhg4HeCeoa0vld6dr8nSGKARzteH39msBIDqYoWvknKCMYYv3x8skBM5u70y2rrPJxocDO7x6a1BOl/Iag1eG9hOelgK2uxUfMbsA8hq66mkBQP5w5HpKIZDR2IlGpzbwHqliJpoT9KlrYgI4PTksUArGbsOvPR6PlYJZj32+tyYjpCcmGklsrQEo5Wqq+eSurVvPxwCQL2QdMImfJ2BhNNIbAcBFmdkFZcN+2VeTASlMQSkrTdOqNQy1LuYaRl64XM8MMWEeBeiCSWLcTt+Ww/GycybBAG/K7HX6fMc/5u16xGq4YhM22Ibq+pZj0f5iSrEj1/M6CB8AvMnQvc8lElwyAELUF2Xwih+GofT3TKnI+YZfC+kiIQMhHRByCFgc0LWCmwHAhRkPQaBiU2UWig/1lwBi9BLLgCtf0j+EgYlBXdtxkwCmQ6DwwJmeWLL3fsnHMUP3Dm2bAZfnEoAuMK2+hlFyNhkArW0IOCRrCRenrwDTG3X/dMCUb8dIs3pD17reEgDhrsm/JgIoEwg8u28tiJ+q+7cDpnyTNIDwEZDF7kAgtsBEB7S7lRHC5C6tQXAHqgnkl94L0Ha59uPZHli854Ekj6BZhEz0dtCnvpcwwzYW+ONBqej2Vw2AdGm2ubIfig4NSFaEnpkAPpNt1NC1/BsCUJQhm9nkyN53y4ajrCaE5SVD1za0qQH7RGUAmVwVLpPWjIBesvF6QHBRejFAsm2Hnu9O9sbKg2Hhs40GBrershsmrgNyxe7yLJOl2Ea4pPu0bskA4OKMuWDI1ttCE8rWcai/kiK74vKgri2Kc2Ni3ecoSlqkGWV1baheZz8wjl6oq44R25c97oZlk/KeAMa01utv7s7Gz+dCbb+isTM9ultVLycFQBo5ncoYFrwNQOb4rHPmgtFHjoNwCowTYHQE8WiAhidiZ1X5YPhO9JXLf5JFkwIB9ft4tm2O5U63R2GGnJSQ3rER80Ydw4je1xpZ3NhVF9PwSflgVNaG601kFkgENCEAhyt/NkDhOUBmTRgkv469qxZZ3RowqPtlDO1ZDwHG8Qtd8NvFNFRf6oT9NelmoylsDFQRMDAcmF8xdO/apBloOYrRNENXv7C7PBMImCNHhnZEeZDZ+jDoL9nicClTAS4O5/D/aJbMLfhUBotHn8Od/wRbGEyC7pEZMhOB+BQxn7RAVa0bWOQYGVgd1LW5SYnQ4ZjcRwhbd79frUzmCrZnE+oblnkhXnO78/4btpfNrV7/D4b1gz/RPr0sAAAAAElFTkSuQmCC"
}
<==Starter Plugin Info===
*/

PluginHelper.addEntryFunc((*) => Plugin_定时提醒.main()) ; 添加入口函数等待执行

class Plugin_定时提醒 {
    static time := 30
    static words := "起来走走, 休息一下眼睛！`n记得要喝水, 保持身体 hydrated!"
    static state := false
    static menu := Menu()


    static toggleState() {
        if (this.state) {
            SetTimer(this.f, 0) ;关闭计时器
            this.menu.Uncheck("开启")
        } else {
            SetTimer(this.f, this.time * 60 * 1000) ;开启计时器
            PluginHelper.tooltip("定时提醒已开启", "提醒间隔时间: " this.time "分钟", 2500)
            this.menu.check("开启")
        }
        this.state := !this.state
    }

    static setting() {
        g := Gui(, "定时提醒设置")
        g.BackColor := "FFFFFF"
        g.SetFont("s14 q5 c333333", "NSimSun")
        g.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        g.AddText(, "提醒间隔时间(min)")
        timeEdit := g.AddEdit("w300 ", this.time)
        g.AddText(, "提醒内容")
        wordsEdit := g.AddEdit("w300 h100", this.words)
        f(*) {
            this.time := timeEdit.Value, this.words := wordsEdit.Value, this.state := false
            this.storeData()
            g.Destroy()
            this.toggleState()
        }
        g.AddButton("x135", "保存").OnEvent("Click", f)
        g.OnEvent("Close", (*) => g.Destroy())
        g.Show()
    }

    static storeData() {
        SplitPath(A_LineFile, , &dir)
        dataPath := dir "\定时提醒配置.txt"
        f := FileOpen(dataPath, "w")
        f.Write(this.time "`r`n" this.words)
        f.Close()
    }

    static loadDataAndStart() {
        SplitPath(A_LineFile, , &dir)
        dataPath := dir "\定时提醒配置.txt"
        if (FileExist(dataPath)) {
            content := FileRead(dataPath)
            sep := "`r`n"
            i := InStr(content, sep)
            this.time := Float(SubStr(content, 1, i - 1))
            this.words := SubStr(content, i + StrLen(sep))
            this.toggleState()
        } else {
            this.setting()
        }
    }

    static main() {
        FileEncoding("UTF-8-RAW")
        this.menu.Add("开启", (*) => this.toggleState())
        this.menu.Add("设置", (*) => this.setting())
        PluginHelper.pluginMenu.Add("定时提醒", this.menu)
        this.f := (*) => PluginHelper.tooltip(Format("定时提醒: {}min", this.time), this.words)
        this.loadDataAndStart()
    }
}