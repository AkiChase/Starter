/**
 * @Name: 网页搜索.ahk
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-04
 * @Description: 网页搜索(带联想词)
 */

/*
===Starter Plugin Info==>
{
    "author": "ruchuby",
    "version": "0.0.1",
    "introduction": "网页搜索(带联想词)，已支持百度、谷歌搜索",
    "icon": "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAABA9JREFUWEfFl2toXFUQx/9z3DUBi/ngWyg+SKV2Q8zeObsBK2g/VBEqotBA0A9+SBRF1A+2IgimHyris6Xiq0YRH4gVnyjoF1vED5u9czeNpLb4QKq1KCn4QAgme0bOujdstnf3btZgLyz33nNmzvxmzrkzs4RTfNEpto8VAzBznzHmLFU928MT0Zxz7oSI/N6NMx0DBEGwxRhzu6re0MLQjwCeNMa8Wy6X/XNHVyqAtXYjgAcSDP+kqseJaAOAMxqs/Q3g+YWFhZ0zMzO/plG0BWDmewDsri8yq6qvAviaiEREjseLM/N6IhpwzuWIaKI+flhVd0ZR9Ho7iJYAzKyxoqruyGazT5VKpT/SPGLmawE8BuCKuuxdIvJcK71EAGb21Ld4Je9VpVI5lGa4eZ6Z7wfweH38OhH5LGmNkwCstder6ifNiroXEyA8DMUmGsf+ToCCINhGRD4a3wC4unHbYv0kgA/rB+49EbnZC+pkzXC8t+toDN92AuBlgiCYIqKC38YoiuI1ltSXAfhPjYg+AnAsk8lwqVT6Zcnzf1VGaAz7OjXu5ay116jq5wB+9q/NUVgGYK2Nvd8mIk/oC8jiNPwA4MJujDd8Je8DuDEpCksAw8PDZy4uLsbZrHZodC/uA+FpAPtpDJtW4nmjLDM/AuBBAPtEZKRxbgmgWCxeUq1Wv/eTmUzm/Fr4X8IrAG6DYozGMdktgLV2VFXfBDArIgOJAPl83hpjygCOishFtcP3MkZRxXk0jl3dGvd6xWLxsmq1esQ/i8iybV96sdYWVbWkquUoior/xWCzbi6XW9Pb2/sngDkROScxAoVC4VLn3HcA/hKRNasJwMxXAfgCwBERWZ8I4MssgN/qk5eLyOHVgrDW3q2qewB8KSIeJjkPMPNRAGuJaGsYhu+sFkAQBHuIyEP44vRQO4B7AexS1YkoinasFgAz+zqwmYiGwzCcaglQKBTWOud8mj0dQMsCshKwIAhuJaLXAEyJyHCz7km1gJl9/fd9wEERGVqJsWbZ/v7+nr6+vnk/TkSjYRi+lQowODh4bjabPQDAn9ZaSu4WgpnfBrAVwKSIjCWtk9gPNIQNqro9iqK4rnfE4r/7np6eT4noSp/9nHMjrXqKdh3RnQCerWVE1bIxZnsYhql9ADP7nO9zv79mAeTaQaT1hL69egbAuvqCHwA4RERfGWNkfn7+WDabHSCinHPO332e31yX3e2ce9EY47ehJURqV8zMF6jqHUQ0Xi/LadtQAvCoiPgSjHw+v6EdRCpAbK0BxLfh/ue9mgNwwt99G6eqH1cqlYPNhM0Q1Wp1y/T0tO8zVv7PKM39VvNNEDfFEeo4At0abtQbGhq62BizMYqiN+Lx/xWg4zywGt52usY/oT63MIvoAk0AAAAASUVORK5CYII="
}
<==Starter Plugin Info===
*/

#Include ..\Utils\PluginHelper.ah2
PluginHelper.addEntryFunc((*) => Plugin_网页搜索.main()) ; 添加入口函数等待执行

class Plugin_网页搜索 {
    static client := PluginHelper.Utils.WinHttp()
    static settings := Map()
    static proxy => this.settings["proxy"]
    static proxyBypassList => this.settings["proxyBypassList"]
    static menu := Menu()

    static main() {
        SplitPath(A_LineFile, &name) ; 获取插件id即文件名
        this.name := name
        FileEncoding("UTF-8-RAW")
        this.loadData()
        this.menu.Add("设置", (*) => this.setting())
        PluginHelper.pluginMenu.Add("网页搜索", this.menu)

        for name in this.settings["enabled"] {
            name := SubStr(name, 1, -2)
            this.%name%.hIcon := PluginHelper.Utils.base64ToHICON(this.%name%.icon)
            this.%name%.addToSearchGui()
        }
    }

    static storeData() {
        SplitPath(A_LineFile, , &dir)
        dataPath := dir "\网页搜索配置.txt"
        f := FileOpen(dataPath, "w")
        f.Write(PluginHelper.Utils.Jxon_Dump(this.settings))
        f.Close()
    }

    static loadData() {
        static default := Map("enabled", ["百度搜索", "谷歌搜索"], "proxy", "", "proxyBypassList", "")
        SplitPath(A_LineFile, , &dir)
        dataPath := dir "\网页搜索配置.txt"
        if (FileExist(dataPath)) {
            content := FileRead(dataPath)
            this.settings := PluginHelper.Utils.Jxon_Load(&content)
        } else
            this.settings := default
    }

    static setting() {
        g := Gui(, "网页搜索设置")
        g.BackColor := "FFFFFF"
        g.SetFont("s14 q5 c333333", "NSimSun")
        g.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        g.AddText(, "代理服务器")
        proxyEdit := g.AddEdit("w300 ", this.proxy)
        g.AddText(, "代理黑名单")
        proxyBLEdit := g.AddEdit("w300 h100", this.proxyBypassList)
        g.AddText(, "启用功能(重启生效)")

        checkboxMap := Map()
        for name in ["谷歌搜索", "必应搜索", "百度搜索"]
            checkboxMap[name] := g.AddCheckbox(, name)

        for name in this.settings["enabled"]
            checkboxMap.Has(name) && checkboxMap[name].Value := 1

        f(*) {
            this.settings["proxy"] := proxyEdit.Value
            , this.settings["proxyBypassList"] := StrReplace(StrReplace(proxyBLEdit.Value, "`r`n"), "`n")
            enabled := []
            for k, c in checkboxMap {
                if (c.Value == 1)
                    enabled.Push(k)
            }
            this.settings["enabled"] := enabled
            this.storeData()
            g.Destroy()
        }

        g.AddButton("x135", "保存").OnEvent("Click", f)
        g.OnEvent("Close", (*) => g.Destroy())
        g.Show()
    }

    ; get请求
    static request(url) {
        try {
            opt := "Method:GET`nTimeout:1"
            if (this.proxy)
                opt .= Format("`nProxy:{}`nProxyBypassList:{}", this.proxy, this.proxyBypassList)
            return this.client.Download(url, opt)
        } catch Error as e {
            if (this.client.Error.Has("Message")) {
                PluginHelper.Utils.tip(this.name, this.client.Error["Message"] "`n请检查网络或使用代理服务器")
                ; PluginHelper.hideSearchGui()
            }
        }
        return 0
    }

    class 谷歌 {
        static title := "谷歌搜索"
        static outer := Plugin_网页搜索
        static icon := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAABCxJREFUWEfFV21sU2UUfs5t71ZKQfdjHZoMCbouYjCbazc1i8AoKiCRsM0MN0yIhj9m8yOI0WHcYpiJJmggMRESdYbIOt1IcDB0bTd0ZrPdwK9A/Ahg1C0tBsK2Amu795hbaM3W23u7usWb9Efve97zPOfcc87zvoRZPCObSszG65INDBsAGzMKCZwDSN8D/EOUo4O3e0//PguXoHSMg057MTPqCFQLIE9rD4HOCuZ+iehorsfXpedfk8BFZ+lGZq4DUKPnSG2dgM8BOqBFJCWBoNOxHYwPMgGeuYeBQ3ke/7YUJJNfX3Q6djLj7bkAT/hg2m31+vbM9JmUgeBaRzeAR+cSnIFn8zz+93QzEKiw7yWiF2YBfoGBIAGFAG5RBWB6MtfrO5zKZyIDwYrSahC364CPgbmVDXBlZ5nO3Hqs/3LcPriurABTU4+AaBeA/Jvv11s9/hPaXQNg4qVlRVdP5R4EYE9lzMzNbJRal3zpO6+XoUCFvUlI6LvNPdSnZxvLQNgtPxdqW745cn7xarUNCnied6hJz1km6zcI9MiDRCgL/5gzEOpauhIgS9zZfIIrGMQnswuiEfFLgn3Y8PeVg4XnxFhWKQEjMAp77hfDo5lEl84emuwxNklEr880vnZ8ae+173K+mq/Ux/Eo3CPvI0K9GtvIoPUB8+6/BrUiWdMy0ZtOpGo2spCeorBbPkSAIjJJj+yM6IqVQoAYqsWrR4yAhynizjoO8PokY8ZP8rrISj0n/4UAmOtTEwDOys7IinklAKnhf/0EAG3QLEJXaHl53eM/f6NXhJnWgJCMBSnb8M3xopNHr+f3DW3t1JyAq98Y1yxASeJlgPShWhDeRgsR92bfFZ0Sv8YNQixf2nZ51blRYbYDNMKysA9XdmY8iCpaQj4wO1QIdHsbLRtibRZxy0qaHzwRzvc3jxXfDSAxisHcrJeFVJ9oTcvVLcSiQ31davA2mvfHCEx55Prnr9xfORC2rlI1zoDE2pbJFYxIOxj3qPlUvn/fK6bfYgT2HCkqOjJ5p6YcK5mQDIZW3xOf6sqxHjjA+72NixpiYhRnV9JWVU1I40ACagUJlylqOtNf+0niQKL4ua+9ukQSYgeJBTsW/vFWvxRdXK4y4C4Jg7FMiX4aAeWP/XDlXhDSPpIxcCGmmDfuCsrv39oBYAo83ZU18dBj00gIbva+tijRWUmz3u6q6gbznB1K5fFy/4LgM9kA3QvCu95XLdMCVBUbh6tqJzPP2bFcCi8ZXzi663Tvy3ckFXlKtXO0VW1n8JxcTMB4Z2hrx4tq3aAptyXtWzaSQB1AmV7Nhhm0b6jms49TzQpdvb9ZnMWgGJFagDUvpzEgogFi/shf03FAT03TIpBo1fc3mSWLyQajsAmwjQQVgmAFEGBCgIBTBiN//W1l5596wPH1fwCsn59FqavjHwAAAABJRU5ErkJggg=="
        static hIcon := 0
        static lxUrl := "https://google.com/complete/search?output=toolbar&q="
        static searchUrl := "https://www.google.com/search?q="

        static addToSearchGui() {
            ;#region 定义插件模式下搜索功能
            searchHandler(that, searchText) {
                if (searchText) {
                    res := this.outer.request(this.lxUrl PluginHelper.Utils.UrlEncode(searchText))
                    that.pluginSearchResult := []
                    if (res && res := PluginHelper.Utils.globalMatch(res, '\<suggestion data="(.*?)"\/\>')) { ; 有请求结果
                        that.pluginSearchResult.Capacity := res.length + 1
                        for item in res
                            that.pluginSearchResult.Push(item[1])
                        (that.pluginSearchResult.Has(1) && that.pluginSearchResult[1] = searchText)
                        ? 0 : that.pluginSearchResult.InsertAt(1, searchText)
                    } else
                        that.pluginSearchResult.Push(searchText)
                } else ; 搜索内容为空时什么都不显示
                    that.pluginSearchResult := []

                ;重置列表
                that.listView.Opt("-Redraw")    ;禁用重绘
                that.listView.Delete()
                ; 添加搜索结果到列表
                for item in that.pluginSearchResult {
                    that.listView.Add(, item)
                }
                that.resizeGui() ;根据搜索结果数量调整gui尺寸 并启用重绘
            }

            runHandler(that, rowNum) {
                kw := rowNum ? that.pluginSearchResult[rowNum] : PluginHelper.SearchText
                Run(this.searchUrl kw)
                PluginHelper.hideSearchGui()
            }

            ; 添加插件项到启动模式搜索界面
            PluginHelper.addPluginToStartupMode(
                this.outer.name,
                this.title,
                ["GGSS", "google"],
                (that, searchText) => (
                    PluginMode.showPluginMode( ; 启动插件模式
                        [], ;数据靠search获取，不需要传入
                        searchHandler,
                        runHandler, , , , ,
                        "Search on Google",
                        this.hIcon
                    )
                ), , , this.hIcon
            )

            ; 添加插件项到智能模式搜索界面
            PluginHelper.addPluginToIntelligentMode(
                this.outer.name,
                this.title,
                [["(gg|google|谷歌)\s+(?<query>.*)", "${query}"], [".+", "$0"]],
                (that, content) => (
                    PluginMode.showPluginMode( ; 启动插件模式
                        [], ;数据靠search获取，不需要传入
                        searchHandler,
                        runHandler, , , ,
                        content, ; 搜索词替换为传入的内容
                        "Search on Google",
                        this.hIcon
                    )
                ), ,
                this.hIcon
            )
        }

    }

    class 必应 {
        static title := "必应搜索"
        static outer := Plugin_网页搜索
        static icon := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAp9JREFUWEftlk1IFGEYx3/PikaIh4iiSxZEH8foFgWOW4gQ3UIlhJq1CEuKEA/RQZEIjCgKCg+7Y+UhyEvUbpJRO2skHTqUZV4693HIQ0iEH/PETG6suurs6xodfGFgmHme///Hf96PEXKG5WgaYUQ8BjTCgGvLr9z3K3Ev8wDAyj5TeCDQt7aMgf5G+fHPAeYYum5MqosNsWgCqwCrCfyXCXR0aMSt5DPQK5BMxySznJVhtAosRy8Cl2aMvymkVEh9Lyc5UicThQAZAexLaEWp8AUon2M2iZJCgivp2vJ1KRgjAF+02tHLChcWM1BlMCKkIpB8HpOP+WqNAawe3YQGKYQdHyBI5rVry8NskzGAL1Dl6A2Bs2EJgHco426T7C8KQPSObvM8PoUAeAvsnqmbdaYsK4FgLiS0U4XjwOa5ICoMo+wSKMt5V1yArLDlaD0+iFKLMoqwEVifJ52VAfCNogmt8YSbwM5FPkvxAaKO7vGUKwgHQsyH4gFE47rFi9AF1IcwzpYUDiAw5pXQmDkm/b5KzT0tn5ikC+FMAcaGAMrotEfDy5My7CtYCe1AaDcw9lvGEdpcW7rD7gPpNR5Hnp6QMcvRFqATWGdkrnRXTNH6+JT8zO1fcB8QuJ+OyVErrg1EAuPtJsYKQyXQ9iImQ6HPAoHrCk9QOhH2mhjnizsUgMIjAf/3+7ChMSjdGypo6auT6aU0/n4Cq0e3Au1osK0aDT9uUc65TfImrMCsORDMckev8ueEKw0rEsQN592YxAvoCUrnAfgPq+N6yBOuibBjSUHhlmuLv0KMRl6ArJKV0H6E2rzKwisPmgdteW/kPNO0KIBfU+Vos8DtHJNxFU5nbOldjnHejWghwYN3tXJqmqQKzzK2tBbDOKvxGxgIQTAtrSi/AAAAAElFTkSuQmCC"
        static hIcon := 0
        static lxUrl := "https://api.bing.com/qsonhs.aspx?q="
        static searchUrl := "https://www.bing.com/search?q="

        static addToSearchGui() {
            ;#region 定义插件模式下搜索功能
            searchHandler(that, searchText) {
                if (searchText) {
                    res := this.outer.request(this.lxUrl PluginHelper.Utils.UrlEncode(searchText))
                    that.pluginSearchResult := []
                    if (res) { ; 有搜索结果
                        res := PluginHelper.Utils.Jxon_Load(&res)["AS"]
                        if (res.Has("Results")) {
                            for group in res["Results"] {
                                for item in group["Suggests"]
                                    that.pluginSearchResult.Push(item["Txt"])
                            }
                        }
                        (that.pluginSearchResult.Has(1) && that.pluginSearchResult[1] = searchText) ?
                        0 : that.pluginSearchResult.InsertAt(1, searchText)
                    } else
                        that.pluginSearchResult.Push(searchText)

                } else ; 搜索内容为空时什么都不显示
                    that.pluginSearchResult := []

                ;重置列表
                that.listView.Opt("-Redraw")    ;禁用重绘
                that.listView.Delete()
                ; 添加搜索结果到列表
                for item in that.pluginSearchResult {
                    that.listView.Add(, item)
                }
                that.resizeGui() ;根据搜索结果数量调整gui尺寸 并启用重绘
            }

            runHandler(that, rowNum) {
                kw := rowNum ? that.pluginSearchResult[rowNum] : PluginHelper.SearchText
                Run(this.searchUrl kw)
                PluginHelper.hideSearchGui()
            }

            ; 添加插件项到启动模式搜索界面
            PluginHelper.addPluginToStartupMode(
                this.outer.name,
                this.title,
                ["BYSS", "bing"],
                (that, searchText) => (
                    PluginMode.showPluginMode( ; 启动插件模式
                        [], ;数据靠search获取，不需要传入
                        searchHandler,
                        runHandler, , , , ,
                        "Search on Bing",
                        this.hIcon
                    )
                ), , , this.hIcon
            )

            ; 添加插件项到智能模式搜索界面
            PluginHelper.addPluginToIntelligentMode(
                this.outer.name,
                this.title,
                [["(by|bing|必应)\s+(?<query>.*)", "${query}"], [".+", "$0"]],
                (that, content) => (
                    PluginMode.showPluginMode( ; 启动插件模式
                        [], ;数据靠search获取，不需要传入
                        searchHandler,
                        runHandler, , , ,
                        content, ; 搜索词替换为传入的内容
                        "Search on Bing",
                        this.hIcon
                    )
                ), ,
                this.hIcon
            )
        }

    }

    class 百度 {
        static title := "百度搜索"
        static outer := Plugin_网页搜索
        static icon := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAABOFJREFUWEe9l3toW1Ucx7+/pFnbdbI5ujU3bV2Xe9KKinNMqfWB28CBgypuOoZDx7A4VDbdS+c/rkNEFArblIGOYREKe7Qi0yHqHw7BrhVFp/iguSfrbM1N17oNrOs60/uTc5sbb5KbRyd6IJCc+3t8zu91cgklrnAw2k5EG21xQreMi11eqnrIqE9eLUueG2swSzFNpQjpmvEUgLfdskx8MBaPPOvs6TXGQhD2g7Be7THz3lgi0l7MfqkAXwNYlmVsVJpiobMXDsoTRNyaAVkCRFEAURutY4uGvE4ylfRrg6OLE+GgXE3EJ3Nl6PKkf1b18HD9RL5IlALQwhb1ehkgi1uMkUifrhmHALR5yjCvMBKRU9cMEK6TEZriAU8DfkTksDB0zfgcwPL/BECIaDmPUwyEULYDaQo7ggUABqQpmgoVYkYKwiG5iZh32wqMT2VCbFFfUy24J8MQoVPGxaZpALkP4OeyHZXSCWkAz0IiOi7j+jrbSUgeA/OjqTlwkpmeiZn6r+q3qIneyT76DMAcF8QH0hQPl9yG4ZDsI+ZmD4XN0hTv2I6CURvASESOZ8ulDqAczmfmH5wZoIeM9WA8CMYQk/VVzGzscevaEWgI/tzgp8DZPLSnpClWFDuJ1/NwUO4h4oxhxEztsYS+15G3AUQwupyJVCXnLsZRmRD2dJvJqqsbqqyYujrK4KpsPYusVWfjjSplKA4AHJCmyCiwW2sSVX/6x+9ni28D4RIT/+gYdJzlH06ZYzpdhLpmqBQ05JySrU0y0dj5j2H7UlJA89yy2RWvB41dILzhGVTXiHZ1gW04s9WAQariGw0jMqkMebajywMxr3MKVGjRxxn0Xp607pQJ0ZFOQcbpfLQGjBsA9BEHthuJRT9NO5dPE/HBYnXAsNbGzMb3G2oGmv0+X59nBCxqjY3oH+UA5DO+qHpQKwsk48Wcp55fhoXWyUD5d+VTk7976HwjTXF7RhcUM6xrxjnAjgqaWyqxdcf16D99BQc6LuRR5bGp8rKIb9K6hYDXwBwGYQ6IPnEGW0kAojaqbsJ3AaTnuQLo6gnhQMfFAgB2cM9JU88t6izkvNexCEXbmEldsxmrdABbrVea4u5CEfYE0EPGC2C8rhSX3VGBxzbOxUNr3GMedgT6eyfsdKi14ZHpEtm6Yz6aWyrcKYpJU+j5IHIAwppcS+BupbBkaQV6TtbausNDSfw29Jf9vfmuyjSASocCcQMoqOwUOVd3NkgOgK4ZXwC4Vwl2vFVjn/zjD8exZfNI+oSOA+W4VABlTppiZ0EAddsx0TFHqKs7ZJ/2pe3ncfzIH/8WAMSBm5254tkF2ZPOAdiwNo7+09P/K1WOrzECIPK1GfHwYXcUMlKQHYGXX6nGE0/ORXTgKnZvG8WZb694Aqj6ePH58+n68KqBlNP0fwvPCKi3GjDOALBLe948Pw53aViytDyniFWRdR66hKMnahFpnOX5PGdQEe6RcfFl3gioB7pm7FeRdgupbrhv5WwPJxdsyJWrZqOuPuD53L3pp6kFA/GmsYIAi0OxJh9bKk8FB0i+vs63z+BtMTOyr2gbKoGm6l+uS5aVvQrgARBESukiAOczCtAgszXdmz4sIKabPN4NxgF8D8KbMi6OeMEVfTOa6UlTN2eIODCR3XL/C8BMgf8GNVpRPxjhCH0AAAAASUVORK5CYII="
        static hIcon := 0
        static lxUrl := "https://suggestion.baidu.com/su?wd="
        static searchUrl := "https://www.baidu.com/s?word="

        static addToSearchGui() {
            ;#region 定义插件模式下搜索功能
            searchHandler(that, searchText) {
                if (searchText) {
                    res := this.outer.request(this.lxUrl PluginHelper.Utils.UrlEncode(searchText))
                    if (res && RegExMatch(res, "s:(\[.*\])", &res)) { ; 请求成功
                        res := res[1]
                        that.pluginSearchResult := PluginHelper.Utils.Jxon_Load(&res)
                        (that.pluginSearchResult.Has(1) && that.pluginSearchResult[1] = searchText) ?
                        0 : that.pluginSearchResult.InsertAt(1, searchText)
                    } else
                        that.pluginSearchResult.Push(searchText)


                } else ; 搜索内容为空时什么都不显示
                    that.pluginSearchResult := []

                ;重置列表
                that.listView.Opt("-Redraw")    ;禁用重绘
                that.listView.Delete()
                ; 添加搜索结果到列表
                for item in that.pluginSearchResult {
                    that.listView.Add(, item)
                }
                that.resizeGui() ;根据搜索结果数量调整gui尺寸 并启用重绘
            }

            runHandler(that, rowNum) {
                kw := rowNum ? that.pluginSearchResult[rowNum] : PluginHelper.SearchText
                Run(this.searchUrl kw)
                PluginHelper.hideSearchGui()
            }

            ; 添加插件项到启动模式搜索界面
            PluginHelper.addPluginToStartupMode(
                this.outer.name,
                this.title,
                ["BDSS", "baidu"],
                (that, searchText) => (
                    PluginMode.showPluginMode( ; 启动插件模式
                        [], ;数据靠search获取，不需要传入
                        searchHandler,
                        runHandler, , , , ,
                        "百度一下，你就知道",
                        this.hIcon
                    )
                ), , , this.hIcon
            )

            ; 添加插件项到智能模式搜索界面
            PluginHelper.addPluginToIntelligentMode(
                this.outer.name,
                this.title,
                [["(bd|baidu|百度)\s+(?<query>.*)", "${query}"], [".+", "$0"]],
                (that, content) => (
                    PluginMode.showPluginMode( ; 启动插件模式
                        [], ;数据靠search获取，不需要传入
                        searchHandler,
                        runHandler, , , ,
                        content, ; 搜索词替换为传入的内容
                        "百度一下，你就知道",
                        this.hIcon
                    )
                ), ,
                this.hIcon
            )
        }

    }
}