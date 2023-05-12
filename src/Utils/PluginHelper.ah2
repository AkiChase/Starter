/**
 * @Name: PluginHelper
 * @Version: 0.0.3
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-05-12
 * @Description: 插件API封装
 */

class PluginHelper {
    static funcList := []
    static init() {
        TrayMenu.menu.Insert("用户数据`t(&D)", "插件功能`t(&F)", this.pluginMenu) ; 插件托盘菜单
        for f in this.funcList ; 执行入口函数
            f()
        ;加载插件的图标
        StartupMode.pluginLoadImgs()
        IntelligentMode.pluginLoadImgs()
    }

    /**
     * @description 返回搜索界面hwnd
     * @link [searchGuiHwnd | Starter文档](https://ruchuby.github.io/Starter/api/searchGuiHwnd)
     * @type {Int}
     */
    static searchGuiHwnd => SearchGui.gui.Hwnd

    /**
     * @description 插件菜单对象，菜单位于：托盘菜单 > 插件功能
     * @link [pluginMenu | Starter文档](https://ruchuby.github.io/Starter/api/pluginMenu)
     * @type {Menu}
     */
    static pluginMenu := Menu()

    /**
     * @description 添加插件入口函数到执行队列，等待基本功能初始化后，函数将被执行
     * @link [addEntryFunc | Starter文档](https://ruchuby.github.io/Starter/api/addEntryFunc)
     * @param {(*)=>any} f 插件入口函数，也可以称为插件的初始化函数
     * @returns {void}
     */
    static addEntryFunc(f) {
        this.funcList.Push(f)
    }

    /**
     * @description 添加插件智能项，应用方式见[插件智能项](https://ruchuby.github.io/Starter/dev/intelligent/)
     * @link [addPluginToIntelligentMode | Starter文档](https://ruchuby.github.io/Starter/api/addPluginToIntelligentMode)
     * @param {String} name 插件id，即插件文件名
     * @param {String} title 插件智能项显示标题
     * @param {(obj, searchText, pastedContentType, pastedContent, workWinInfo, winInfoMatchFlag)=>number} matchHandler 智能插件项的自定义匹配函数，返回值决定当前插件项是否显示
     * @param {(obj, searchText)=>any} runHandler 运行（鼠标双击或回车）该插件智能项时执行的函数。
     * @param {(obj)=>any} [contextHandler] 右键该插件智能项时执行的函数。
     * @param {Int} [hIcon] 插件智能项显示的图标hIcon，忽略则使用插件的图标。
     * @returns {void}
     */
    static addPluginToIntelligentMode(name, title, matchHandler, runHandler, contextHandler?, hIcon?) {
        plugin := { name: name, title: title, matchHandler: matchHandler, runHandler: runHandler }
        for n in ["contextHandler", "hIcon"] {
            if (IsSet(%n%))
                plugin.%n% := %n%
        }
        IntelligentMode.pluginData.Push(plugin)
    }

    /**
     * @description 添加插件启动项，应用方式见[插件启动项](https://ruchuby.github.io/Starter/dev/startup)
     * @link [addPluginToStartupMode | Starter文档](https://ruchuby.github.io/Starter/api/addPluginToStartupMode)
     * @param {String} name 插件id，即插件文件名
     * @param {String} title 插件启动项显示标题
     * @param {Array} keywords 插件启动项其他关键字，比如 `["其他","QTGJZ"]`
     * @param {(obj, searchText)=>any} startHandler 运行（鼠标双击或回车）该插件启动项时执行的函数。
     * @param {(obj, searchText)=>any} [doubleRightHandler] 选中该插件启动项后，双击 `Right` 按键时执行的函数。
     * @param {(obj)=>any} [contextHandler] 右键该插件启动项时的处理函数。
     * @param {Int} [hIcon] 插件启动项显示的图标hIcon，忽略则使用插件的图标。
     * @returns {void}
     */
    static addPluginToStartupMode(name, title, keywords, startHandler, doubleRightHandler?, contextHandler?, hIcon?) {
        plugin := { name: name, title: title, keywords: keywords, startHandler: startHandler }
        for n in ["doubleRightHandler", "contextHandler", "hIcon"] {
            if (IsSet(%n%))
                plugin.%n% := %n%
        }
        StartupMode.pluginData.Push(plugin)
    }

    /**
     * @description 获取指定插件的图标 hIcon
     * @link [getPluginHIcon | Starter文档](https://ruchuby.github.io/Starter/api/getPluginHIcon)
     * @param {String} pluginName 插件名称，即插件文件名(插件id)
     * @returns {Int} 如果插件有图标，则返回hIcon，否则返回0
     */
    static getPluginHIcon(pluginName) {
        for info in PluginGui.pluginList {
            if (pluginName == info["name"])
                return info["iconHIcon"]
        }
        return 0
    }

    /**
     * @description 获取指定插件的图标的 Base64
     * @link [getPluginIconBase64 | Starter文档](https://ruchuby.github.io/Starter/api/getPluginIconBase64)
     * @param {String} pluginName 插件名称，即插件文件名、插件id
     * @returns {String|Int} 如果插件有图标，返回无头部Base64，否则返回0
     */
    static getPluginIconBase64(pluginName) {
        for info in PluginGui.pluginList {
            if (pluginName == info["name"])
                return info["iconBase64"]
        }
        return 0
    }

    /**
     * @description 隐藏搜索框
     * @link [hideSearchGui | Starter文档](https://ruchuby.github.io/Starter/api/hideSearchGui)
     * @param {Bool} [recordHideTime=false] 默认为 `false`。如果设置为 `true`，则会记录隐藏时间，15s内按**呼出搜索框**快捷键可恢复搜索框内容。
     * @return {Void}
     */
    static hideSearchGui(recordHideTime := false) {
        SearchGui.hideGui(recordHideTime)
    }

    /**
     * @description 返回当前搜索框粘贴的内容的类型，或者按下智能搜索框时选中的内容的类型。可返回 "file", "bitmap", "text"
     * @link [pastedContentType | Starter文档](https://ruchuby.github.io/Starter/api/pastedContentType)
     * @type {String}
     */
    static pastedContentType => SearchGui._pastedContentType

    /**
     * @description 返回当前搜索框粘贴的内容，或者按下智能搜索框时选中的内容
     * @link [pastedContent | Starter文档](https://ruchuby.github.io/Starter/api/pastedContent)
     * @type {(Array|ImagePutBuffer|String)}
     */
    static pastedContent => SearchGui._pastedContent

    /**
     * @description 返回当前活动窗口的相关信息
     * @link [workWinInfo | Starter文档](https://ruchuby.github.io/Starter/api/workWinInfo)
     * @type {Object}
     * @property {Int} hwnd 窗口句柄
     * @property {String} title 窗口标题
     * @property {String} class 窗口类名
     * @property {String} processPath 程序路径
     * @property {String} processName 程序名称
     */
    static workWinInfo => SearchGui.workWinInfo

    /**
     * @description 判断当前是否处于工作窗口模式
     * @link [winInfoMatchFlag | Starter文档](https://ruchuby.github.io/Starter/api/winInfoMatchFlag)
     * @type {Bool}
     */
    static winInfoMatchFlag => SearchGui.winInfoMatchFlag

    /**
     * @description 获取或设置搜索框的占位符
     * @link [placeholder | Starter文档](https://ruchuby.github.io/Starter/api/placeholder)
     * @type {String}
     * @example
     * Tooltip(PluginHelper.placeholder) ; 获取占位符内容
     * PluginHelper.placeholder:="new placeholder!" ; 修改占位符内容
     */
    static placeholder {
        get => SearchGui.placeholder
        set => SearchGui.placeholder := Value
    }

    /**
     * @description 获取或设置搜索框的文本内容
     * @link [SearchText | Starter文档](https://ruchuby.github.io/Starter/api/searchText)
     * @type {String}
     * @example
     * Tooltip(PluginHelper.searchText) ; 获取搜索框文本内容
     * PluginHelper.searchText:="new searchText!" ; 修改搜索框文本内容
     */
    static searchText {
        get => SearchGui.searchText
        set => SearchGui.edit.Value := SearchGui.searchText := value
    }

    /**
     * @description 设置搜索框的选中文本区域
     * @link [setSearchTextSel | Starter文档](https://ruchuby.github.io/Starter/api/setSearchTextSel)
     * @param {Int} [start=0] 选中文本区域的开始位置，默认值为 `0`
     * @param {Int} [end=-1] 选中文本区域的结束位置，默认值为 `-1`
     * @return {Void}
     * @example
     * setSearchTextSel(StrLen(searchText), -1) ; 将游标移动到最后
     */
    static setSearchTextSel(start := 0, end := -1) {
        EditCtrlFunc.editSelect(SearchGui.edit, start, end)
    }

    /**
     * @description 获取Starter的图片资源目录路径
     * @link [imgDir | Starter文档](https://ruchuby.github.io/Starter/api/imgDir)
     * @type {String}
     */
    static imgDir => GlobalData.imgDir

    /**
     * @description 获取PluginMode类。特定情况下需要提前获取到PluginMode，即所谓的 `that`
     * @link [getPluginMode | Starter文档](https://ruchuby.github.io/Starter/api/getPluginMode)
     * @return {PluginMode}
     */
    static getPluginMode(*) {
        return PluginMode
    }

    /**
     * @description: 启动插件模式
     * @param pluginSearchData 用于插件模式搜索的数据
     * 
     * 将被存放至 that.pluginSearchData
     * 
     * @param searchHandler 插件模式搜索处理函数 (that, searchText) => void
     * 
     * 规范使用，请将搜索结果存放至 that.pluginSearchResult 然后对其进行渲染(添加到listview)
     * 
     * @param runHandler 插件模式回车、双击任意项时的处理函数 (that, rowNum) => void
     * @param options 可选参数对象 {...} 
     * 
     * options.doubleRightHandler (可选)插件模式双击Right时的处理函数 (that, rowNum) => void
     * 
     * options.loadImgsHandler (可选)加载插件模式图片的处理函数, 若需要显示图标一定要带有此参数 (that) => void
     * 
     * options.toBottomHandler (可选)列表最后一行可见(触底)处理函数 (that) => void
     * 
     * options.pasteContentHandler (可选)Ctrl+V粘贴内容时的处理函数(that, typeName, content?) => bool
     * 
     * 在粘贴**bitmap/file**内容前会触发一次 (that, typeName) => bool 返回true则允许粘贴
     * 
     * 在粘贴**bitmap/file**内容后还会触发一次 (that, typeName, content) => any
     * 
     * file: content为文件路径数组; bitmap: content为位图句柄;
     * 
     * options.dropFilesHandler (可选)拖入文件到搜索框的处理函数(that, fileList, pre) => bool
     * 
     * 在拖入文件后会触发一次 (that, fileList, true) => bool 返回true则允许拖入生效
     * 
     * 拖入生效后还会触发一次 (that, fileList, false) => any
     * 
     * options.initHandler (可选)初始化处理函数 (that) => void
     * 
     * options.searchText (可选)启动时设置搜索框文本
     * 
     * options.placeholder (可选)设置搜索框占位符
     * 
     * options.thumb (可选)hICON 设置插件模式搜索框图标
     */


    /**
     * @description 启动插件模式
     * @link [showPluginMode | Starter文档](https://ruchuby.github.io/Starter/api/showPluginMode)
     * @param {Array} pluginSearchData 插件模式搜索数据
     * @param {(that, typeName, content?) => bool} searchHandler 搜索结果处理函数，参考
     * @param {Function} runHandler 回车/双击任意项时的处理函数
     * @param {Object} [options={}] 可选参数
     * @type {Void}
     */


    /**
     * @description: 启动插件模式
     * @link [showPluginMode | Starter文档](https://ruchuby.github.io/Starter/api/showPluginMode)
     * @param {Array} pluginSearchData 用于插件模式搜索的数据
     * @param {(that, searchText) => void} searchHandler 插件模式搜索处理函数
     * @param {(that, rowNum) => void} runHandler 插件模式回车、双击任意项时的处理函数
     * @param {Object} [options] 可选参数对象
     * 
     * options.doubleRightHandler {(that, rowNum) => void}  插件模式双击Right时的处理函数
     * 
     * options.loadImgsHandler {(that) => void}  加载插件模式图片的处理函数
     * 
     * options.toBottomHandler {(that) => void}  列表最后一行可见(触底)处理函数
     * 
     * options.pasteContentHandler {(that, typeName, content?) => bool}  Ctrl+V粘贴内容时的处理函数，参考[pasteContentHandler](https://ruchuby.github.io/Starter/api/showPluginMode.html#pastecontenthandler)
     * 
     * options.dropFilesHandler {(that, fileList, pre) => bool}  拖入文件到搜索框的处理函数，参考[dropFilesHandler](https://ruchuby.github.io/Starter/api/showPluginMode.html#dropFilesHandler)
     * 
     * options.initHandler {(that) => void}  初始化处理函数
     * 
     * options.searchText {string}  启动时设置搜索框文本
     * 
     * options.placeholder {string}  设置搜索框占位符
     * 
     * options.thumb {Object}  hICON 设置插件模式搜索框图标
     */
    static showPluginMode(pluginSearchData, searchHandler, runHandler, options := {}) {
        PluginMode.showPluginMode(pluginSearchData, searchHandler, runHandler, options)
    }

    class Utils {
        /**
         * @description 将文本的中文部分转换为拼音首字母，多音字转换不准确
         * @link [chineseFirstChar | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#chineseFirstChar)
         * @param {String} str 要转换的文本
         * @returns {String} 将中文部分转为拼音首字母后的字符串
         */
        static chineseFirstChar(str) {
            return ChineseFirstChar(str)
        }

        /**
         * @description 判断文本是否以指定子串开头
         * @link [strStartWith | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#strStartWith)
         * @param {String} ori 进行判断的文本
         * @param {String} sub 开头的文本
         * @param {Bool} [caseSense=false] 是否大小写敏感，默认为false
         * @returns {Bool} 如果文本以指定子串开头，则返回true
         */
        static strStartWith(ori, sub, caseSense := false) {
            return !sub ? false : (
                caseSense ? SubStr(ori, 1, StrLen(sub)) == sub :
                    SubStr(ori, 1, StrLen(sub)) = sub
                )
        }

        /**
         * @description 压缩文件路径文本，使其不超过最大字符数
         * @link [pathStrCompact | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#pathStrCompact)
         * @param {String} fullPath 文件完整路径
         * @param {Number} maxChars 压缩后最大字符数
         * @returns {String} 压缩后的文件路径文本
         */
        static pathStrCompact(fullPath, maxChars) {
            out := Buffer(255)
            DllCall("shlwapi.dll\PathCompactPathExW"
                , "UPtr", out.Ptr
                , "WStr", fullPath
                , "UInt", maxChars
            )
            return StrGet(out)
        }

        /**
         * @description 复制指向文件的路径到剪切板，可选择进行剪切而不是复制
         * @link [copyToClipboard | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#copyToClipboard)
         * @param {String} filePath 指向文件的路径
         * @param {Bool} [cut=false] 是否剪切，默认为false
         * @returns {Void} 
         */
        static copyToClipboard(filePath, cut := false) {
            CopyToClipboard(filePath, cut)
        }

        /**
         * @description 运行指定路径的文件
         * @link [startFile | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#startFile)
         * @param {String} path 文件路径
         * @param {String} [workingDir=""] 工作目录，见[Run / RunWait - 语法 & 使用 | AutoHotkey v2](https://orz707.gitee.io/v2/docs/commands/Run.htm)
         * @param {String} [options=""] 见[Run / RunWait - 语法 & 使用 | AutoHotkey v2](https://orz707.gitee.io/v2/docs/commands/Run.htm)
         * @param {Closure} [beforeRun] 运行文件前执行的处理函数
         * @returns {String} 如果无法确定 PID, 返回空字符串
         */
        static startFile(path, workingDir := "", options := "", beforeRun?) {
            return Start.startFile(path, workingDir, options, beforeRun?)
        }

        /**
         * @description 在资源管理器中显示指定路径的文件
         * @link [openFileInFolder | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#openFileInFolder)
         * @param {String} path 文件路径
         * @returns {Void} 
         */
        static openFileInFolder(path) {
            Start.openFileInFolder(path)
        }

        /**
         * @description 对给定字符串进行 URL 编码
         * @link [UrlEncode | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#UrlEncode)
         * @param {String} str 需要编码的字符串
         * @returns {String} URL 编码后的字符串
         */
        static UrlEncode(str) {
            return UrlEncode(str)
        }

        /**
         * @description 对给定字符串进行 URL 解码
         * @link [UrlDecode | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#UrlDecode)
         * @param {String} str 需要解码的字符串
         * @returns {String} URL 解码后的字符串
         */
        static UrlDecode(str) {
            return UrlDecode(str)
        }

        /**
         * @description 从给定字符串的指定起始位置处查找符合正则表达式的所有子字符串，即正则全局模式
         * @link [globalMatch | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#globalMatch)
         * @param {String} Haystack 给定字符串
         * @param {RegExp} NeedleRegEx 正则表达式对象
         * @param {Number} [StartingPos=1] 起始位置，默认为 1
         * @returns {Array} 匹配对象数组，参考[匹配对象 - MatchObject](https://orz707.gitee.io/v2/docs/commands/RegExMatch.htm#MatchObject)
         */
        static globalMatch(Haystack, NeedleRegEx, StartingPos := 1) {
            return WinHttp.RegEx.GlobalMatch(Haystack, NeedleRegEx, StartingPos := 1)
        }

        /**
         * @description 将给定 JSON 文本数据加载成为 AutoHotkey 变量
         * @link [Jxon_Load | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#Jxon_Load)
         * @param {String} src JSON 文本的引用
         * @param {*} [args] 可选参数，参考源码JXON.ah2
         * @returns {*} AutoHotkey 变量
         */
        static Jxon_Load(&src, args*) {
            return Jxon_Load(&src, args*)
        }

        /**
         * @description 将给定的 AutoHotkey 变量转换为 JSON 文本
         * @link [Jxon_Dump | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#Jxon_Dump)
         * @param {*} obj 需要转换的 AutoHotkey 变量
         * @param {String} [indent=""] 缩进用的字符串，默认为空字符串
         * @param {Number} [lvl=1] 当前递归的深度，默认为 1
         * @returns {String} 转换后的 JSON 文本
         */
        static Jxon_Dump(obj, indent := "", lvl := 1) {
            return Jxon_Dump(obj, indent := "", lvl := 1)
        }

        /**
         * @description 参考 WinHttp 库函数源码，`src\Utils\WinHttp.ah2`
         * @link [WinHttp | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#WinHttp)
         * @returns {WinHttp} WinHttp 对象
         */
        static WinHttp(args*) {
            return WinHttp(args*)
        }

        /**
         * @description 获取 Windows 中与指定文件关联的图标，并返回一个 hICON 句柄
         * @link [associatedHIcon | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#associatedHIcon)
         * @param {String} filePath 需要获取关联图标的文件路径
         * @returns {Int} 获取到的关联图标的 HICON 句柄
         */
        static associatedHIcon(filePath) {
            return DllCall("Shell32\ExtractAssociatedIcon", "Ptr", 0, "Str", filePath, "ShortP", 1, "Ptr")
        }

        /**
         * @description 载入无头部的图片base64文本，返回 hIcon 句柄
         * @link [base64ToHICON | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#base64ToHICON)
         * @param {String} base64 无头部的图片base64文本
         * @returns {Int} 载入后图标的 HICON 句柄
         */
        static base64ToHICON(base64)
        {
            nBytes := Floor((B64Len := StrLen(base64 := RTrim(base64, "="))) * 3 / 4)
            buf := Buffer(nBytes)

            DllCall("Crypt32.dll\CryptStringToBinary", "str", base64, "int", B64Len, "int", 1, "ptr", buf, "uintp", nBytes, "Int", 0, "Int", 0)
            Return DllCall("User32.dll\CreateIconFromResourceEx", "ptr", buf, "int", nBytes, "int", 1, "int", 0x30000, "Int", 0, "Int", 0, "Int", 0, "ptr")
        }

        /**
         * @description 在右下角弹出一条 `WiseGui` 通知，可设置标题、内容、计时消失时间、是否唯一，返回该通知的 id
         * @link [tip | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#tip)
         * @param {String} title 通知标题
         * @param {String} content 通知内容
         * @param {Number} [time=0] 计时消失时间（单位为毫秒），选填，默认为 0，表示不消失
         * @param {Boolean} [unique=false] 是否保证唯一（不会被覆盖），选填，默认为 false
         * @returns {String} 该通知窗口的 id（如果 `unique` 为 true，则返回 A_TickCount 值作为 id）
         */
        static tip(title, content, time?, unique := false) {
            return Tip.show(title, content, time?, , unique)
        }

        /**
         * @description 对给定的数组进行**快速排序**（不生成副本），并返回排序后的数组
         * @link [quickSort | Starter文档](https://ruchuby.github.io/Starter/api/utils/other.html#quickSort)
         * @param {Array} arr 待排序数组
         * @param {Function} fn 比较函数，接受两个参数 itemA 和 itemB，返回值为数字类型，表示 itemA 和 itemB 的大小关系。如果 itemA 大于 itemB，返回正数；如果 itemA 小于 itemB，返回负数；如果 itemA 等于 itemB，返回 0。
         * @returns {Array} 排序后的数组
         * @example 
         * ; 升序排序示例
         * arr:=[1,9,2,8,3,7]
         * QuickSort(arr, (a,b)=>a-b)
         */
        static quickSort(arr, fn) {
            return QuickSort(arr, fn)
        }

        /**
         * @description: 简单、高效、实用的图片操作库
         * @link [ImagePutHelper | Starter文档](https://ruchuby.github.io/Starter/api/utils/ImagePutHelper.html)
         */
        class ImagePutHelper {
            ; Puts the image into a file format and returns a base64 encoded string.
            ;   extension  -  File Encoding           |  string   ->   bmp, gif, jpg, png, tiff
            ;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
            static ImagePutBase64(image, extension := "", quality := "") {
                return ImagePut("base64", image, extension, quality)
            }

            ; Puts the image into a GDI+ Bitmap and returns a pointer.
            static ImagePutBitmap(image) {
                return ImagePut("bitmap", image)
            }

            ; Puts the image into a GDI+ Bitmap and returns a buffer object with GDI+ scope.
            static ImagePutBuffer(image) {
                return ImagePut("buffer", image)
            }

            ; Puts the image onto the clipboard and returns ClipboardAll().
            static ImagePutClipboard(image) {
                return ImagePut("clipboard", image)
            }

            ; Puts the image as the cursor and returns the variable A_Cursor.
            ;   xHotspot   -  X Click Point           |  pixel    ->   0 - width
            ;   yHotspot   -  Y Click Point           |  pixel    ->   0 - height
            static ImagePutCursor(image, xHotspot := "", yHotspot := "") {
                return ImagePut("cursor", image, xHotspot, yHotspot)
            }

            ; Puts the image onto a device context and returns the handle.
            ;   alpha      -  Alpha Replacement Color |  RGB      ->   0xFFFFFF
            static ImagePutDC(image, alpha := "") {
                return ImagePut("dc", image, alpha)
            }

            ; Puts the image behind the desktop icons and returns the string "desktop".
            static ImagePutDesktop(image) {
                return ImagePut("desktop", image)
            }

            ; Puts the image into the most recently active explorer window.
            static ImagePutExplorer(image, default := "") {
                return ImagePut("explorer", image, default)
            }

            ; Puts the image into a file and returns its filepath.
            ;   filepath   -  Filepath + Extension    |  string   ->   *.bmp, *.gif, *.jpg, *.png, *.tiff
            ;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
            static ImagePutFile(image, filepath := "", quality := "") {
                return ImagePut("file", image, filepath, quality)
            }

            ; Puts the image into a multipart/form-data in binary and returns a SafeArray COM Object.
            ;   boundary   -  Content-Type            |  string   ->   multipart/form-data; boundary=something
            static ImagePutFormData(image, boundary := "ImagePut-abcdef") {
                return ImagePut("formdata", image, boundary)
            }

            ; Puts the image into a device independent bitmap and returns the handle.
            ;   alpha      -  Alpha Replacement Color |  RGB      ->   0xFFFFFF
            static ImagePutHBitmap(image, alpha := "") {
                return ImagePut("hBitmap", image, alpha)
            }

            ; Puts the image into a file format and returns a hexadecimal encoded string.
            ;   extension  -  File Encoding           |  string   ->   bmp, gif, jpg, png, tiff
            ;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
            static ImagePutHex(image, extension := "", quality := "") {
                return ImagePut("hex", image, extension, quality)
            }

            ; Puts the image into an icon and returns the handle.
            static ImagePutHIcon(image) {
                return ImagePut("hIcon", image)
            }

            ; Puts the image into a file format and returns a pointer to a RandomAccessStream.
            ;   extension  -  File Encoding           |  string   ->   bmp, gif, jpg, png, tiff
            ;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
            static ImagePutRandomAccessStream(image, extension := "", quality := "") {
                return ImagePut("RandomAccessStream", image, extension, quality)
            }

            ; Puts the image into a file format and returns a SafeArray COM Object.
            ;   extension  -  File Encoding           |  string   ->   bmp, gif, jpg, png, tiff
            ;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
            static ImagePutSafeArray(image, extension := "", quality := "") {
                return ImagePut("safeArray", image, extension, quality)
            }

            ; Puts the image on the shared screen device context and returns an array of coordinates.
            ;   screenshot -  Screen Coordinates      |  array    ->   [x,y,w,h] or [0,0]
            ;   alpha      -  Alpha Replacement Color |  RGB      ->   0xFFFFFF
            static ImagePutScreenshot(image, screenshot := "", alpha := "") {
                return ImagePut("screenshot", image, screenshot, alpha)
            }

            ; Puts the image into a file format and returns a pointer to a stream.
            ;   extension  -  File Encoding           |  string   ->   bmp, gif, jpg, png, tiff
            ;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
            static ImagePutStream(image, extension := "", quality := "") {
                return ImagePut("stream", image, extension, quality)
            }

            ; Puts the image into a file format and returns a URI string.
            ;   extension  -  File Encoding           |  string   ->   bmp, gif, jpg, png, tiff
            ;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
            static ImagePutURI(image, extension := "", quality := "") {
                return ImagePut("uri", image, extension, quality)
            }

            ; Puts the image as the desktop wallpaper and returns the string "wallpaper".
            static ImagePutWallpaper(image) {
                return ImagePut("wallpaper", image)
            }

            ; Puts the image into a WICBitmap and returns the pointer to the interface.
            static ImagePutWICBitmap(image) {
                return ImagePut("wicBitmap", image)
            }

            ; Puts the image in a window and returns a handle to a window.
            ;   title      -  Window Title            |  string   ->   MyTitle
            ;   pos        -  Window Coordinates      |  array    ->   [x,y,w,h] or [0,0]
            ;   style      -  Window Style            |  uint     ->   WS_VISIBLE
            ;   styleEx    -  Window Extended Style   |  uint     ->   WS_EX_LAYERED
            ;   parent     -  Window Parent           |  ptr      ->   hwnd
            static ImagePutWindow(image, title := "", pos := "", style := 0x82C80000, styleEx := 0x9, parent := "") {
                return ImagePut("window", image, title, pos, style, styleEx, parent)
            }


            ;   title      -  Window Title            |  string   ->   MyTitle
            ;   pos        -  Window Coordinates      |  array    ->   [x,y,w,h] or [0,0]
            ;   style      -  Window Style            |  uint     ->   WS_VISIBLE
            ;   styleEx    -  Window Extended Style   |  uint     ->   WS_EX_LAYERED
            ;   parent     -  Window Parent           |  ptr      ->   hwnd
            static ImageShow(image, title := "", pos := "", style := 0x90000000, styleEx := 0x80088, parent := "") {
                return ImagePut("show", image, title, pos, style, styleEx, parent)
            }

            static ImageDestroy(image) {
                return ImagePut.Destroy(image)
            }

            static ImageWidth(image) {
                return ImagePut.Dimensions(image)[1]
            }

            static ImageHeight(image) {
                return ImagePut.Dimensions(image)[2]
            }
        }
    }
}