/**
 * @Name: PluginHelper
 * @Version: 0.0.3
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-12
 * @Description: 插件API封装
 */

class PluginHelper {
    static funcList := []
    static pluginMenu := Menu()

    static init() {
        TrayMenu.menu.Insert("用户数据`t(&D)", "插件功能`t(&F)", this.pluginMenu) ; 插件托盘菜单
        for f in this.funcList ; 执行入口函数
            f()
        ;加载插件的图标
        StartupMode.pluginLoadImgs()
        IntelligentMode.pluginLoadImgs()

        Hotkey("~CapsLock", "On") ;加载完毕，恢复热键
    }

    /**
     * @description: 添加插件入口函数到执行队列，基本功能初始化后执行
     * @param f 插件入口函数
     */
    static addEntryFunc(f) {
        this.funcList.Push(f)
    }

    /**
     * @description: 添加插件项到智能模式列表
     * @param name 插件id, 即文件名
     * @param title 插件项显示标题
     * @param matchHandler 插件项匹配函数 (obj, searchText, pastedContentType, pastedContent, workWinInfo, winInfoMatchFlag)=>bool
     * 
     * obj指向添加的插件项对象; searchText为当前搜索内容;
     * 
     * pastedContentType为粘贴内容类型; pastedContentType为粘贴内容
     * 
     * workWinInfo为工作窗口信息; winInfoMatchFlag为是否开启工作窗口模式（即没有选中任何内容）
     * 
     * @param runHandler 鼠标双击、回车该插件项时执行的函数
     * (obj, searchText)=>any obj指向添加的插件项对象, searchText为搜索框文本内容
     * @param contextHandler 选填, 右键该插件项显示的菜单
     * @param hIcon 选填, 插件项显示的图标HICON, 默认使用插件的图标
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
     * @description: 添加插件项到启动模式列表
     * @param name 插件id, 即文件名
     * @param title 插件项显示标题
     * @param keywords 插件项关键字
     * @param startHandler 鼠标双击、回车该插件项时执行的函数 (obj, searchText)=>any obj指向添加的插件项对象
     * @param doubleLeftHandler 选填, 双击Left该插件项时执行的函数 (obj, searchText)=>any obj指向添加的插件项对象
     * @param contextHandler 选填, 右键该插件项时的处理函数 (obj)=>any obj指向添加的插件项对象
     * @param hIcon 选填, 插件项显示的图标HICON, 默认使用插件的图标
     */
    static addPluginToStartupMode(name, title, keywords, startHandler, doubleLeftHandler?, contextHandler?, hIcon?) {
        plugin := { name: name, title: title, keywords: keywords, startHandler: startHandler }
        for n in ["doubleLeftHandler", "contextHandler", "hIcon"] {
            if (IsSet(%n%))
                plugin.%n% := %n%
        }
        StartupMode.pluginData.Push(plugin)
    }

    /**
     * @description: 获取插件图标hIcon，使用HICON时请加*以使用副本，避免句柄用后销毁
     * @param pluginName 插件名称, 即文件名
     * @return 有图标返回hIcon, 无图标则返回0
     */
    static getPluginHIcon(pluginName) {
        for info in PluginGui.pluginList {
            if (pluginName == info["name"])
                return info["iconHIcon"]
        }
        return 0
    }

    /**
     * @description: 获取插件图标base64
     * @param pluginName 插件名称, 即文件名
     * @return 有图标返回base64, 无图标则返回0
     */
    static getPluginIconBase64(pluginName) {
        for info in PluginGui.pluginList {
            if (pluginName == info["name"])
                return info["iconBase64"]
        }
        return 0
    }

    /**
     * @description: 隐藏搜索框
     * @param recordHideTime 默认false true则记录关闭时间，15s内可恢复窗口
     */
    static hideSearchGui(recordHideTime := false) {
        SearchGui.hideGui(recordHideTime)
    }

    /**
     * @description: 粘贴内容类型 file bitmap text
     */
    static pastedContentType => SearchGui._pastedContentType
    /**
     * @description: 粘贴内容 fileList hbitmap str
     */
    static pastedContent => SearchGui._pastedContent

    /**
     * @description: 工作窗口信息
     * 
     * workWinInfo.hwnd   hwnd
     * 
     * workWinInfo.title    窗口标题
     * 
     * workWinInfo.class    窗口类名
     * 
     * workWinInfo.processPath  程序路径
     * 
     * workWinInfo.processName  程序名称
     */
    static workWinInfo => SearchGui.workWinInfo
    ; 是否处于窗口匹配状态
    static winInfoMatchFlag => SearchGui.winInfoMatchFlag

    /**
     * @description: 搜索框占位符
     */
    static placeholder {
        get => SearchGui.placeholder
        set => SearchGui.placeholder := Value
    }

    /**
     * @description: 搜索框内容
     */
    static SearchText {
        get => SearchGui.searchText
        set => SearchGui.edit.Value := SearchGui.searchText := value
    }

    /**
     * @description: 设置搜索框选中文本
     * 
     * start=end=StrLen(searchText)可将游标移动到最后
     * @param start 0代表第一个文本之前
     * @param end -1代表最后一个文本
     */
    static setSearchTextSel(start := 0, end := -1) {
        EditCtrlFunc.editSelect(SearchGui.edit, start, end)
    }

    /**
     * @description: 图片资源目录
     */
    static imgDir => GlobalData.imgDir

    /**
     * @description: 特定情况下需要提前获取到PluginMode，即所谓的that
     */
    static getPluginMode := (*) => PluginMode

    /**
     * @description: 启动插件模式
     * @param pluginSearchData 用于插件模式搜索的数据
     * @param searchHandler 插件模式搜索处理函数 (that, searchText) => void
     * @param runHandler 插件模式回车、双击任意项时的处理函数 (that, rowNum) => void
     * @param options 可选参数对象 {...} 
     * 
     * options.doubleLeftHandler (可选)插件模式双击Left时的处理函数 (that, rowNum) => void
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
    static showPluginMode(pluginSearchData, searchHandler, runHandler, options := {}) {
        PluginMode.showPluginMode(pluginSearchData, searchHandler, runHandler, options)
    }

    class Utils {
        /**
         * @description: 将文本的中文部分转换为拼音首字母(多音字不正确)
         */
        static chineseFirstChar(str) {
            return ChineseFirstChar(str)
        }

        /**
         * @description: ori是否以sub开头
         * @param caseSense 默认false 是否区分大小写
         * @return bool
         */
        static strStartWith(ori, sub, caseSense := false) {
            return !sub ? false : (
                caseSense ? SubStr(ori, 1, StrLen(sub)) == sub :
                    SubStr(ori, 1, StrLen(sub)) = sub
                )
        }

        /**
         * @description: 压缩文件路径文本
         * @param fullPath 文件完整路径
         * @param maxChars 压缩后最大字符数
         * @return 压缩后路径文本
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
         * @description: 复制路径指向文件到剪切板
         */
        static copyToClipboard := (this, filePath, cut := false) => CopyToClipboard(filePath, cut)

        /**
         * @description: 运行文件
         */
        static startFile := (this, path, workingDir := "", options := "", beforeRun?) => Start.startFile(path, workingDir, options, beforeRun?)

        /**
         * @description: 在文件夹中打开
         */
        static openFileInFolder := (this, path) => Start.openFileInFolder(path)

        /**
         * @description: UrlEncode编码
         */
        static UrlEncode := (this, str) => UrlEncode(str)
        /**
         * @description: UrlEncode解码
         */
        static UrlDecode := (this, str) => UrlDecode(str)


        /**
         * @description: 正则全局模式
         */
        static globalMatch := (this, Haystack, NeedleRegEx, StartingPos := 1) => WinHttp.RegEx.GlobalMatch(Haystack, NeedleRegEx, StartingPos := 1)

        /**
         * @description: json转ahk数据
         * @param src json文本的引用
         */
        static Jxon_Load := (this, &src, args*) => Jxon_Load(&src, args*)

        /**
         * @description: ahk数据转json文本
         */
        static Jxon_Dump := (this, obj, indent := "", lvl := 1) => Jxon_Dump(obj, indent := "", lvl := 1)

        /**
         * @description: WinHttp请求库
         */
        static WinHttp := (this, args*) => WinHttp(args*)

        /**
         * @description: 载入文件路径对应的图标为HICON 可以直接关联到图标源头
         */
        static associatedHIcon(filePath) {
            return DllCall("Shell32\ExtractAssociatedIcon", "Ptr", 0, "Str", filePath, "ShortP", 1, "Ptr")
        }

        /**
         * @description: 载入base64图片为HICON
         */
        static base64ToHICON(base64)
        {
            nBytes := Floor((B64Len := StrLen(base64 := RTrim(base64, "="))) * 3 / 4)
            buf := Buffer(nBytes)

            DllCall("Crypt32.dll\CryptStringToBinary", "str", base64, "int", B64Len, "int", 1, "ptr", buf, "uintp", nBytes, "Int", 0, "Int", 0)
            Return DllCall("User32.dll\CreateIconFromResourceEx", "ptr", buf, "int", nBytes, "int", 1, "int", 0x30000, "Int", 0, "Int", 0, "Int", 0, "ptr")
        }

        /**
         * @description: 右下角通知
         * @param title 标题
         * @param content 内容
         * @param time 计时消失时间(选填)
         * @param unique 默认为false, true则使用A_TickCount作为id, 以保证不会被同id覆盖(用WiseGuiHelper.WiseGui(id)可关闭指定id的窗口)
         * @return id
         */
        static tip(title, content, time?, unique := false) {
            return Tip.show(title, content, time?, , unique)
        }

        /**
         * @description: 数组快速排序(不生成副本)
         * @param arr 待排序数组
         * @param fn (itemA, itemB)=> number 比较函数
         * @example 
         * ; 升序排序示例
         * arr:=[1,9,2,8,3,7]
         * QuickSort(arr, (a,b)=>a-b)
         */
        static quickSort(arr, fn) {
            return QuickSort(arr, fn)
        }

        ; modified from iseahound's ImagePut
        ; Wiki:https://github.com/iseahound/ImagePut/wiki/Input-Types-&-Output-Functions
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

            static IImageDestroy(image) {
                return ImagePut.Destroy(image)
            }

            static IImageWidth(image) {
                return ImagePut.Dimensions(image)[1]
            }

            static IImageHeight(image) {
                return ImagePut.Dimensions(image)[2]
            }
        }
    }


}