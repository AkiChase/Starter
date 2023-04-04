/**
 * @Name: WiseGuiHelper
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-03
 * @Description: WiseGui辅助类，便于对象化调用WiseGui
 */

; example
; #SingleInstance Force
; w1 := WiseGuiHelper("a",
;     WiseGuiHelper.textHelper("标题", , "内容", 1, "s14 Underline, 雅痞-简", , 200)
;     , "Warn", , , , , true, 200
;     , "zoom@1000", "RollSouth@1000"  ;roll slide效果较稳定
; )
; F2:: w1.close() ;关闭或者点击窗口进行关闭
; WiseGuiHelper.setOpt(, , "s14 Bold, 雅痞-简", "s12, 雅痞-简", 225, , , , "4,1,1,3", true, , "RollWest@250")
; Tip.show("检测到新版本: 0.2.2", "请自行前往项目主页下载")


class WiseGuiHelper {
    opt := Map()

    /**
     * @param id 窗口id
     */
    __New(id) {
        this.id := id
        this.opt.CaseSensitive := "Off"
    }

    /**
     * @param title 标题
     * @param content 内容
     * @param time 计时消失时间(选填) 若指定则无视opt中theme相关内容
     * @param theme 主题(选填) Info,Warning,Success,Error 若指定则无视opt中theme相关内容
     */
    show(title, content, time?, theme?) {
        opts := ["mainText: " title, "subText: " content]
        for k, v in this.opt
            opts.Push(Format("{}:{}", k, v))
        if (IsSet(time))
            opts.Push("timer: " time)
        if (IsSet(theme))
            opts.Push("theme: " theme)

        WiseGuiHelper.WiseGui(this.id, opts*)
    }

    /**
     * @description: 设置样式
     * @param mainAlign 主文本对齐 -1=Left, 0=Center, 1=Right
     * @param subAlign 副文本对齐 -1=Left, 0=Center, 1=Right
     * @param fontMain 主文本字体 options, fontName
     * @param fontSub 副文本字体 options, fontName
     * @param textWidth 主副文本宽度
     * @param theme 主题 Warning,Info,Success,Error(带有首字母即可)
     *              或者自定义主题: "TextColor, WindowColor, BorderColor, [HICON]" 
     *              HICON=0时取消icon部分，如"0xF0F0F0, 0x778899, 0x556677, 0"
     * @param timer 计时关闭 ms
     * @param move xAxis, yAxis, Monitor (默认右下角:1,1; 左上角:-1,-1,居中: , )
     * @param margins xMargin, yMargin, ySpacing, IconMargin
     * @param shadow 是否添加窗口阴影
     * @param transparency 窗口透明度 64 to 255
     * @param show 出现动画 "type@duration"
     * Valid duration: 25ms to 2500ms
     * Valid types: Fade,Zoom,SlideEast,SlideNorthEast,SlideNorth,
     *              SlideNorthWest,SlideWest,SlideSouthWest,SlideSouth,
     *              SlideSouthEast,RollEast,RollNorthEast,RollNorth,
     *              RollNorthWest,RollWest,RollSouth,RollSouthEast
     * @param hide 消失动画 "type@duration" 同show
     */
    setOpt(mainAlign?, subAlign?, fontMain?, fontSub?, textWidth?, theme?, timer?, move?, margins?, shadow?, transparency?, show?, hide?) {
        for k in ["mainAlign", "subAlign", "fontMain", "fontSub", "textWidth", "timer"
            , "theme", "move", "margins", "shadow", "transparency", "show", "hide"] {
            if (IsSet(%k%))
                this.opt[k] := %k%
        }
    }

    /**
     * @description: 重置样式
     */
    resetOpt() {
        this.opt := Map()
        this.opt.CaseSensitive := "Off"
    }

    /**
     * @description: 删除指定样式
     */
    delOpt(key) {
        if (this.opt.Has(key))
            this.opt.Delete(key)
    }

    /**
     * @description: 设置窗口是否不可普通关闭
     */
    setNoClose(flag := true) {
        if (flag) {
            this.opt["close"].Push(0)
            this.noClose := 1
        } else {
            this.delOpt("close")
            this.noClose := 0
        }
    }

    /**
     * @description: 关闭窗口(包括不可普通关闭的)
     */
    close() {
        if (this.HasOwnProp("noClose") && this.noClose)
            WiseGuiHelper.WiseGui(this.id, "Close: 1")
        else
            WiseGuiHelper.WiseGui(this.id)
    }

    static WiseGui(Name, Options*) ;  v0.96a by SKAN for ah2 on D48F/D491 @ autohotkey.com/r?t=94044   -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  RM145
    {
        If (StrLen(Name) = 0)
            Return

        Static Names := Map()
        Local MyGui

        If (Options.Length = 0 && Names.Has(Name))
            Return GuiClose(Names[Name])

        If (Names.Has(Name))
        {
            MyGui := Names[Name]
            UpdateGui(&MyGui)
        }
        Else CreateGui(&MyGui)


        ParseOptions(&UsrOpts)  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            Local Value
            For Value in Options
            {
                Switch (Type(Value))
                {
                    Case "String":
                        {
                            Value := StrSplit(Value, ["=", ":"], A_Space, 2)
                            If (Value.Length > 1)
                                UsrOpts[SubStr(Value[1], 1, 5)] := Trim(Value[2], "'" . '"')
                        }

                    Case "Func", "BoundFunc":
                        {
                            UsrOpts["Trigger"] := Value
                        }
                }
            }
        }


        UpdateGui(&MyGui) ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            Local UsrOpts, Value, GuiP, Period

            UsrOpts := MyGui.UsrOpts
            If (Options.Length)
                ParseOptions(&UsrOpts)

            If (UsrOpts.Has("Theme"))
            {
                GuiP := GetTheme(UsrOpts["Theme"])
                MyGui.BackColor := GuiP["WindowColor"]
                MyGui["LineL"].Opt("Background" . GuiP["BorderColor"])
                MyGui["LineT"].Opt("Background" . GuiP["BorderColor"])
                MyGui["LineB"].Opt("Background" . GuiP["BorderColor"])
                MyGui["LineR"].Opt("Background" . GuiP["BorderColor"])
                MyGui["MainText"].Opt("c" . GuiP["TextColor"])
                MyGui["SubText"].Opt("c" . GuiP["TextColor"])
                If MyGui["Icon"].Value
                    MyGui["Icon"].Value := "HICON:" . GuiP["HICON"]
                WinRedraw(MyGui.Hwnd)
                MyGui.Show("NA")
            }

            If (MyGui.UsrOpts.Has("MainT"))
            {
                If MyGui["MainText"].Text != UsrOpts["MainT"]
                    MyGui["MainText"].Text := UsrOpts["MainT"]
                MyGui.UsrOpts.Delete("MainT")
            }

            If (MyGui.UsrOpts.Has("SubTe"))
            {
                If MyGui["SubText"].Text != UsrOpts["SubTe"]
                    MyGui["SubText"].Text := UsrOpts["SubTe"]
                MyGui.UsrOpts.Delete("SubTe")
            }

            OnClose(&MyGui)
            ApplySettings(&MyGui)

            If MyGui.UsrOpts.Has("Timer")
            {
                Period := 0 - Min(20000, Max(200, Format("{:d}", MyGui.UsrOpts["Timer"])))
                SetTimer(MyGui.MyTimer, Period)
                MyGui.UsrOpts.Delete("Timer")
            }
        }


        CreateGui(&MyGui) ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            Local Value, Theme, GuiP, TxtP, UsrOpts, Font, Period, DHW, XY
            MyGui := Gui("+DpiScale -Caption +AlwaysOnTop +Owner +E0x08000000", "WiseGui\" . Name)
            Names[Name] := MyGui
            MyGui.Name := Name
            MyGui.MyTimer := GuiClose.Bind(MyGui)
            MyGui.UsrOpts := Map()

            UsrOpts := MyGui.UsrOpts
            UsrOpts.CaseSense := "Off"

            If (Options.Length)
                ParseOptions(&UsrOpts)

            XY := UsrOpts.Has("Margi") ? StrSplit(UsrOpts["Margi"] . ",,,,", ",", A_Space, 5) : [2, 1, 0, 0]
            Loop (4)
                XY[A_Index] := Format("{:d}", XY[A_Index]) * 4

            MyGui.MarginX := 0
            MyGui.MarginY := 0

            GuiP := GetTheme(UsrOpts.Has("Theme") ? UsrOpts["Theme"] : "Info")
            MyGui.BackColor := GuiP["WindowColor"]

            ; Icon
            If GuiP["HICON"]
            {
                MyGui.Add("Text", "x0 y0 w" . (XY[4] * 2) + 32 " h" (XY[4] * 2) + 32 . " vLineL Background" . GuiP["BorderColor"])
                MyGui.Add("Picture", "xp+" . XY[4] . " yp+" . XY[4] . " w32 h32 BackgroundTrans vIcon", "HICON:" . GuiP["HICON"])
                MyGui.Add("Text", "x+" . XY[4] . " w0 h0")
            }
            Else
            {
                MyGui.Add("Text", "x0 y0   w1 h1 vLineL Background" . GuiP["BorderColor"])
                MyGui.Add("Picture", "xp yp w0 h0 vIcon")
            }

            MyGui.Add("Text", "x+0 ym w10 h1 Section vLineT Background" . GuiP["BorderColor"])

            ; MainText
            If (UsrOpts.Has("MainT"))
            {
                Value := UsrOpts["MainT"]
                MyGui.UsrOpts.Delete("MainT")
            }
            Else Value := ["Warning", "Information", "Success", "Error", A_ScriptName][InStr("WISEU", GuiP["T"])]

            MyGui.MarginX := XY[1]
            MyGui.MarginY := XY[2]

            Font := UsrOpts.Has("FontM") ? StrSplit(UsrOpts["FontM"], ",", " ") : ["s10 Bold", "Segoe UI"]
            MyGui.SetFont(Font*)
            TxtP := "xp+" . MyGui.MarginX . " y+m vMainText BackgroundTrans c" . GuiP["TextColor"]
            TxtP .= UsrOpts.Has("TextW") ? (" w" . UsrOpts["TextW"]) : ""
            TxtP .= UsrOpts.Has("MainA") ? (UsrOpts["MainA"] = 0 ? " Center" : UsrOpts["MainA"] = 1 ? " Right" : "") : ""

            If (UsrOpts.Has("Main") && UsrOpts["Main"] = 0)
                MyGui.Add("Text", "vMainText w0 h0 y+0 xp+" . MyGui.MarginX)
            Else MyGui.Add("Text", TxtP, Value)

            ; SubText
            If (UsrOpts.Has("SubTe"))
            {
                Value := UsrOpts["SubTe"]
                MyGui.UsrOpts.Delete("SubTe")
            }
            Else Value := ""

            MyGui.MarginY := XY[3]
            Font := UsrOpts.Has("FontS") ? StrSplit(UsrOpts["FontS"], ",", " ") : ["s10 Norm", "Segoe UI"]
            MyGui.SetFont(Font*)
            TxtP := "xp y+m vSubText BackgroundTrans c" . GuiP["TextColor"]
            TxtP .= UsrOpts.Has("TextW") ? " w" . UsrOpts["TextW"] : ""
            TxtP .= UsrOpts.Has("SubAl") ? (UsrOpts["SubAl"] = 0 ? " Center" : UsrOpts["SubAl"] = 1 ? " Right" : "") : ""
            MyGui.Add("Text", TxtP, Value)

            MyGui.MarginY := XY[2]
            ; Right / Bottom lines
            MyGui.Add("Text", "x+0 yp  w1  hp vLineR Background" . GuiP["BorderColor"])
            MyGui.Add("Text", "xs  y+m w10 h1 vLineB Background" . GuiP["BorderColor"])

            MyGui.MarginX := XY[1]
            MyGui.MarginY := 0
            MyGui.Show("AutoSize Hide")
            Local X, Y, W, H, LX
            MyGui.GetPos(&X, &Y, &W, &H)

            MyGui["LineL"].Move(, , , H)
            MyGui["LineR"].Move(W - 1, 0, , H)
            MyGui["LineT"].GetPos(&LX)
            MyGui["LineT"].Move(, , W - LX)
            MyGui["LineB"].Move(, H - 1, W - LX)

            Local MW, SW
            MyGui["MainText"].GetPos(, , &MW)
            MyGui["SubText"].GetPos(, , &SW)
            If (MW > SW)
                MyGui["SubText"].Move(, , MW)
            Else MyGui["MainText"].Move(, , SW)

            MyGui.Add("Text", "x0 y0 w" . W . " h" . H . " vClick BackgroundTrans")

            If UsrOpts.Has("Shado") && UsrOpts["Shado"]
            {
                dwOldLong := SetClassLong(MyGui.Hwnd, -26)           ; Save GCL_STYLE
                SetClassLong(MyGui.Hwnd, -26, dwOldLong | 0x20000)   ; Apply CS_DROPSHADOW
            }

            OnClose(&MyGui)
            ApplySettings(&MyGui, True)

            If UsrOpts.Has("Show")
                AnimateWindow(MyGui.Hwnd, UsrOpts["Show"])

            MyGui.Show("NA")

            If UsrOpts.Has("Shado") && UsrOpts["Shado"]
                SetClassLong(MyGui.Hwnd, -26, dwOldLong)             ; Restore GCL_STYLE


            If MyGui.UsrOpts.Has("Timer")
            {
                Period := 0 - Min(20000, Max(200, Format("{:d}", MyGui.UsrOpts["Timer"])))
                SetTimer(MyGui.MyTimer, Period)
                MyGui.UsrOpts.Delete("Timer")
            }
        }


        ApplySettings(&MyGui, Create := 0)
        {
            Local UsrOpts := MyGui.UsrOpts
            If UsrOpts.Has("WMP")
            {
                PlaySound(Name, UsrOpts["WMP"])
                Sleep(100)
                MyGui.UsrOpts.Delete("WMP")
            }

            If (UsrOpts.Has("Move"))
            {
                GuiSetPos(MyGui.Hwnd, StrSplit(UsrOpts["Move"], ",", A_Space, 3)*)
                MyGui.UsrOpts.Delete("Move")
            }
            Else
                If (Create = True)
                {
                    GuiSetPos(MyGui.Hwnd, "-10", "-10")
                }

            Local Trans, DHW
            If (MyGui.UsrOpts.Has("Trans"))
            {
                Trans := Min(255, Max(64, Format("{:d}", MyGui.UsrOpts["Trans"])))
                DHW := A_DetectHiddenWindows
                DetectHiddenWindows(True)
                WinSetTransparent(Trans, MyGui.Hwnd)
                DetectHiddenWindows(DHW)
            }
        }


        GetTheme(Theme)   ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            If ( Not InStr(Theme, ","))
            {
                Theme := Format("{:U}", SubStr(Theme, 1, 1))
                Return (Theme = "W" ? Map("T", "W", "TextColor", "856442", "WindowColor", "FFFFF0", "BorderColor", "EBB800", "HICON", GetIcon(Theme))
                    : Theme = "I" ? Map("T", "I", "TextColor", "194499", "WindowColor", "F0F8FF", "BorderColor", "3399FF", "HICON", GetIcon(Theme))
                        : Theme = "S" ? Map("T", "S", "TextColor", "155724", "WindowColor", "F0FFE9", "BorderColor", "429300", "HICON", GetIcon(Theme))
                            : Theme = "E" ? Map("T", "E", "TextColor", "721C24", "WindowColor", "FFF4F4", "BorderColor", "E40000", "HICON", GetIcon(Theme))
                                : Map("T", "I", "TextColor", "194499", "WindowColor", "F0F8FF", "BorderColor", "3399FF", "HICON", GetIcon("I")))
            }

            Local Arr := StrSplit(Theme . ",,,,", ",", A_Space, 5)
            Return Map("T", "U"
                , "TextColor", StrLen(Arr[1]) ? Format("{:06X}", Arr[1]) : GetSysColor(8)
                , "WindowColor", StrLen(Arr[2]) ? Format("{:06X}", Arr[2]) : GetSysColor(15)
                    , "BorderColor", StrLen(Arr[3]) ? Format("{:06X}", Arr[3]) : GetSysColor(6)
                        , "HICON", StrLen(Arr[4]) = 0 ? GetIcon("") : Arr[4])
        }


        GetSysColor(nIndex)  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            Return Format("{5:}{6:}{3:}{4:}{1:}{2:}", StrSplit(Format("{:06X}", DllCall("User32.dll\GetSysColor", "Int", nIndex)))*)
        }


        GetIcon(Theme, W := 0, H := 0)    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        { ; v1.10
            Local B64, B64Len, nBytes, Bin

            B64 := (Theme = "W" ? "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAMAAACdt4HsAAAAXVBMVEXruAD//+KFZEL13HH+/NiPclLsuwr9+c789cH887v46Jj45pP02GbtvhPEt5"
                . "ruwh/67ar67amii22Zf2Dyz0rxz0nb1LfUyq7MwaSzooTuwiD499rx7tHn4sWrl3l1GphJAAABHUlEQVRYw+2WybLCIBBF3wUyCZmMUfMc/v8zLXeaC0IXW86+T9FAD3+FQiH"
                . "Gv7NTa0w7WTfKo3vd4YNO96LwWhvsMLpOjz818NCsqfEaAXTa8Q8IckhJ4zOeDdLzy7M4IcIauYDv+38qpa67t6glCVQkiCTRGxY8dgLT/zwAC+6Se+xYUGFP96P+wIIFRLg2"
                . "nUewgXBBgfUIBhA2KJg8giuIOShoPYIziDYoMB7BA4QRCW4CAadwVBUkKUwsWCC5RMuCIxib/pGeagPj0r/yZbiAGZOLyU8na4iMTm8oZ6WWO7ihJB9hUZ5i0oKmWnkETS1o6"
                . "5viYlolg+U20DPq3NGWPVwzx3vugpG74uQuWWJGZ+f3mje/17xCoRDhBWODDIHAQPWnAAAAAElFTkSuQmCC" : Theme = "I" ? "iVBORw0KGgoAAAANSUhEUgAAAEAAAABAC"
                    . "AMAAACdt4HsAAAAVFBMVEUzmf/w+P8ZRJmSyf/o9P/c5vOks9Pg8P/V6v/P6P/B4f+y2f+u1v+IxP9wuP9Npv9Eof88nv9tg7jH0ue7yOA6nf80VqFKZqmRosrR3O18kL9cdb"
                    . "Au8FSxAAABHElEQVRYw+2WyZaEIAxFO4JhKMSpyp7+/z9bdzYRk2xqxd2/e+AkIXw0Gg2OcUjRW+tjGkZ9ejIBTgQzqeKzsVBgzSzPZwcXuCzNG6hgRPHXA6o8XgLBvzwxKM/"
                    . "f/3bdortFhjNf3c4TzmSmfo4TuFlTANzzm1WUYir7BxH7sqMm+QH03RAkgnAzfyCiPpuDTDBUBQkKfkgVD1JVEKFguxTEqsBDQbfzTQS+KrBXgp4IrFjQHwJQCPyF4BMUV4gy"
                    . "QbwpIxUsVJDEjbQSAdNIo0wwMsPECQIzzqzAMA8KJ7C3S86QKmy67TI70onrE5E8qnUymYWimbJqsSxHfENyAfFq6xFxFa82/XLVr/d3fTD0Xxz9J0v/zWs0Ggx/07kMr8YqP"
                    . "fYAAAAASUVORK5CYII=" : Theme = "S" ? "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAMAAACdt4HsAAAAY1BMVEVCkwDw/+kVVySZyXXo+t/c7dbh9tTS7MHF5K+325yz2"
                        . "ZiQxGl6tktRnBRKmAvG28Jrj24yZzujvaHm9uBaoiDR5MzX78fW78avx62WspWJp4lbg19IdU5IlwlboiG70bd7m3xysmd2AAABTUlEQVRYw+2W226EIBCGOwMqKyqeD6tr+/"
                        . "5PWeO2oSjEsdzyJV5o8v+ZgzDzEQgErlhlKnrOe5HK9r46Zwn8IWH5LXnBOBzgrKDrsxgsxBlVz8ABI8lfD3DyeBEMtN7m4BE/MYsMLsgu+heDFTWVXz+9KP6TwIiIMyWJnIO"
                        . "NqEKsInjD8/sBlIhYk+qYOBMo9Wvi1q9go6kQMQKN+2xKsFEbCWxIp0FqreCmX4wvqdNAgIUnIn4aX4TToHcEUILB4DTgjgAUGHCSQaQDeIIJJ6TQLVh1vy2IwGQgFHFCfDtU"
                        . "5wBAENrYzIg4NzDqClDaKMF0mKDULaD8SOvhBGK9PSMcaWmHSeHOctIn1OM87QY1HGHkC2VBo4f6QqGGoNBWQnbjUu2Uak4DrvC91n0Hi+9o8x6uvuPdf8HwX3H8lyw6rUzFw"
                        . "Pmwr3mBQOCCb5bODse1hzUgAAAAAElFTkSuQmCC" : Theme = "E" ? "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAMAAACdt4HsAAAAS1BMVEXkAAD/7u1yHCTyd3eziovFo"
                            . "6T+5OPlCgqfbW/92dj7y8v6xcT4s7LOr6/2m5rwa2voISHmFRT2oJ/tTU3tTUy8l5ipfH6UXWD2oaDGo2xeAAABGUlEQVRYw+2W3W7DIAyFdyCB8VMIdN32/k+6SZ3SZBSbyr"
                            . "d8d1F0TmxiG79NJhOOLafojfEx5e11ddEBB4IuL8mtNviH0XZcf3V4gvsY1Wt00GPhV3SpI2l8g6AK4h/M4goG5iStA4OzfAKCJMqjfpYLjqzrXlFlKIBFqctRr9Q6EkI4CP4"
                            . "c2sdA9B923pV6fPSmfln2d/3ezHjqsJz1yF2DhNah1SN1DSJah1aP2DXwaB2+Gj1818DgzKe6c8MJM2yARd3TGDXwtAGfQqRT4A8xjR1ioguJ/42ZLmW+kDaymfhSDlQ7t/rW"
                            . "QZMDhW9nU8iRxg8UzQxVbqQ5Kx3r4ouFpYKgii9X4fUuXTCkK45wyRKueZPJhOEHEsMMXLgJ8a8AAAAASUVORK5CYII=" : "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYA"
                            . "AAAfFcSJAAAADUlEQVQImWOor69nBgAEfwGBGWiMoAAAAABJRU5ErkJggg==")

            nBytes := Floor((B64Len := StrLen(B64 := RTrim(B64, "="))) * 3 / 4)
            Bin := Buffer(nBytes)

            DllCall("Crypt32.dll\CryptStringToBinary", "str", B64, "int", B64Len, "int", 1, "ptr", Bin, "uintp", nBytes, "Int", 0, "Int", 0)
            Return DllCall("User32.dll\CreateIconFromResourceEx", "ptr", Bin, "int", nBytes, "int", 1, "int", 0x30000, "Int", W, "Int", H, "Int", 0, "ptr")
        }


        PlaySound(Name, Filename := "")    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {                                ; by SKAN for ah2 on D48J/D48K @ autohotkey.com/r?t=93918
            Static Names := Map()

            If (Filename = "")
            {
                If Names.Has(Name)
                {
                    Names[Name].Controls.Stop
                        , Names.Delete(Name)
                }
                Return
            }

            Names[Name] := ComObject("WMPlayer.OCX")
                , Names[Name].Url := FileName

            While (Names.Has(Name)
                && Names[Name].controls.isAvailable("stop")
                && !Names[Name].controls.currentPosition)
                Sleep 10

            Try SetTimer(CheckSound.Bind(Name), 2000)

            CheckSound(_Name)
            {
                If ( Not Names.Has(_Name))
                    Return SetTimer(, 0)

                If (Names[_Name].playState != 3)
                {
                    SetTimer(, 0)
                        , Names.Delete(_Name)
                }
            }
        }


        SetClassLong(Hwnd, nIndex, dwNewLong := "")
        {
            If !IsInteger(dwNewLong)
                Return A_PtrSize = 8 ? DllCall("User32.dll\GetClassLongPtr", "ptr", Hwnd, "int", nIndex, "uint")
                    : DllCall("User32.dll\GetClassLong", "ptr", Hwnd, "int", nIndex, "uint")
            Else Return A_PtrSize = 8 ? DllCall("User32.dll\SetClassLongPtr", "ptr", Hwnd, "int", nIndex, "ptr", dwNewLong, "uint")
                : DllCall("User32.dll\SetClassLong", "ptr", Hwnd, "int", nIndex, "ptr", dwNewLong, "uint")
        }


        GuiSetPos(Hwnd, X := "", Y := "", M := "")   ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            Local DPI_AWARENESS_CONTEXT_UNAWARE, DPI_AWARENESS_CONTEXT := 0

            Try
            {
                DPI_AWARENESS_CONTEXT := DllCall("User32.dll\GetThreadDpiAwarenessContext", "ptr")
                DPI_AWARENESS_CONTEXT_UNAWARE := DPI_AWARENESS_CONTEXT - 1
                DllCall("User32.dll\SetThreadDpiAwarenessContext", "ptr", DPI_AWARENESS_CONTEXT_UNAWARE, "ptr")
            }

            Local Err, mLeft, mTop, mRight, mBottom
            Try M := MonitorGetWorkArea(M, &mLeft, &mTop, &mRight, &mBottom)
            Catch Error as Err
                M := MonitorGetWorkArea(, &mLeft, &mTop, &mRight, &mBottom)

            Local RECT := Buffer(16, 0)
            DllCall("User32.dll\GetWindowRect", "ptr", Hwnd, "ptr", RECT)
            Local W := NumGet(RECT, 8, "int") - NumGet(RECT, 0, "int")
            Local H := NumGet(RECT, 12, "int") - NumGet(RECT, 4, "int")

            X := mLeft + (StrLen(X) = 0 ? ((mRight - mLeft) // 2) - (W // 2) : X < 0 ? mRight - mLeft - W + 1 + X : X)
            Y := mTop + (StrLen(Y) = 0 ? ((mBottom - mTop) // 2) - (H // 2) : Y < 0 ? mBottom - mTop - H + 1 + Y : Y)

            DllCall("User32.dll\MoveWindow", "ptr", Hwnd, "int", X, "int", Y, "int", W, "int", H, "int", 1)
            If (DPI_AWARENESS_CONTEXT)
                DllCall("User32.dll\SetThreadDpiAwarenessContext", "ptr", DPI_AWARENESS_CONTEXT)
        }


        AnimateWindow(Hwnd, P)  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            Local Flags := Map()
            Flags.CaseSense := "Off"
            Flags.Set("Fade", "0x00080000", "Zoom", "0x00000010"
                , "SlideEast", "0x00040001", "SlideNorthEast", "0x00040009", "SlideNorth", "0x00040008", "SlideNorthWest", "0x0004000A"
                , "SlideWest", "0x00040002", "SlideSouthWest", "0x00040006", "SlideSouth", "0x00040004", "SlideSouthEast", "0x00040005"
                , "RollEast", "0x00000001", "RollNorthEast", "0x00000009", "RollNorth", "0x00000008", "RollNorthWest", "0x0000000A"
                , "RollWest", "0x00000002", "RollSouthWest", "0x00000006", "RollSouth", "0x00000004", "RollSouthEast", "0x00000005")

            P := StrSplit(P, ["@", "ms"], "- ")
            P[1] := Flags.Has(P[1]) ? Flags[P[1]] : Flags["Fade"]
            P[1] |= DllCall("User32.dll\IsWindowVisible", "ptr", Hwnd) ? 0x10000 : 0
            P[2] := Min(2500, Max(25, Format("{:d}", P[2])))


            DllCall("User32.dll\AnimateWindow", "ptr", Hwnd, "int", P[2], "int", P[1])
        }


        OnClose(&MyGui)   ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            Local UsrOpts := MyGui.UsrOpts
            If (UsrOpts.Has("Close"))
            {
                If (UsrOpts["Close"])
                    MyGui["Click"].OnEvent("Click", GuiClose.Bind(MyGui, True))
            }
            Else
            {
                MyGui["Click"].OnEvent("Click", GuiClose.Bind(MyGui, True))
                UsrOpts["Close"] := 1
            }

            MyGui.OnEvent("Close", (*) => GuiClose(MyGui, "*"))
            MyGui.OnEvent("ContextMenu", (*) => GuiClose(MyGui, "-1"))
        }


        GuiClose(thisGui, Clicked := "0", *)  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        {
            SetTimer(thisGui.MyTimer, 0)

            If (!thisGui.UsrOpts["Close"])
            {
                Sleep(0)
                Return 1
            }

            Local err
            Try thisGui.Title := ""
            Catch Error as err
                Return

            Names.Delete(thisGui.Name)

            If thisGui.UsrOpts.Has("Hide")
                AnimateWindow(ThisGui.Hwnd, thisGui.UsrOpts["Hide"])

            SetTimer(PlaySound.Bind(thisGui.Name), -1)

            If thisGui.UsrOpts.Has("Close")
                If thisGui.UsrOpts["Close"] = "Trigger"
                    If thisGui.UsrOpts.Has("Trigger")
                        SetTimer(thisGui.UsrOpts["Trigger"].Bind(Clicked), -1)

            thisGui.Destroy()
        }
    }   ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
}