/*
WinHttp 3.9 for ahk v2
updated by ruchuby on 2023/2/15

example:
  url := "https://httpbin.org/post?a=1&b=2"
  header := "Accept: application/json"
  data := '{"c":3, "d":4}'
  res:= WinHttp().Download(url, , header, data)
  MsgBox(res)
*/

/*
  ; 使用工具 “AHK 爬虫终结者” 可以用 GUI 的形式使用本库，并自动生成代码。
  ; 注: v2版本库不同，但用法一致

  ; 简单示例
  MsgBox(WinHttp.Download("https://www.example.com/"))  ; 网页内容
  MsgBox(WinHttp.ResponseHeaders["Content-type"])       ; 响应头 Content-type 段
  MsgBox(WinHttp.StatusCode)                            ; 状态码
  MsgBox(WinHttp.Cookie)                                ; Cookie

  ; CreateFormData 示例
  objParam := {"file": ["截图.png"]}
  WinHttp.CreateFormData(out_postData, out_ContentType, objParam,,,"image/jpg")
  RequestHeaders := "Content-Type: " out_ContentType
  MsgBox(WinHttp.Download("http://snap.ie.sogou.com/recognition",, RequestHeaders, out_postData))
*/


class WinHttp {
  ResponseHeaders := Map(), StatusCode := "", StatusText := "", Cookie := "", Error := Map()

  /*
  ; *****************参数*****************
  ; URL                  网址，必须包含类似 http:// 这样的开头。
  ;                      www. 最好也带上，有些网站需要。
  
  ; Options              设置，是 Method:GET
  ;                               Timeout:30
  ;                               EnableRedirects:1 这样使用换行分隔的字符。
  ;                      具体支持的值看下方 ***************Options*************** 。
  
  ; RequestHeaders       请求头，格式同 Options 。
  ;                      具体支持的值看下方 ************RequestHeaders************ 。
  
  ; Data                 提交数据，支持 Request Payload 与 Form Data 两种格式。
  ;                      默认格式是文本，即 Request Payload 。
  ;                      Form Data 格式需要使用 WinHttp.CreateFormData() 进行构造。
  ;                      此参数无值时，默认使用 GET 请求。有值时，默认使用 POST 请求。
  
  ; FilePath             此参数非空，则下载到此路径，否则下载到变量。
  
  ; ***************Options***************
  ; 支持以下11种设置，输入其它值无任何效果，不区分大小写。
  
  ; Method               请求方法，支持 GET, HEAD, POST, PUT, PATCH, DELETE, CONNECT, OPTIONS, TRACE 共9种。
  ;                      此参数可以小写，但在程序内部，依然会被转换为全大写。
  ;                      留空表示自动选择 GET 或 POST 。
  
  ; EnableRedirects      重定向，1为获取跳转后的页面信息，0为不跳转。
  ;                      留空表示1。
  
  ; Charset              网页字符集，也就是网页的编码。
  ;                      是 UTF-8、gb2312 这样的字符。
  ;                      留空表示自动选择。
  
  ; URLCodePage          URL 代码页，也就是网址的编码。
  ;                      是 65001、936 这样的数字。
  ;                      留空表示65001。
  
  ; Timeout              超时，单位为秒，0为无限。
  ;                      当设置此参数，会同时覆盖 “连接超时” 与 “下载超时” 两项参数。
  ;                      留空表示不使用此参数。
  
  ; ConnectTimeout       连接超时，单位为秒，0为无限。
  ;                      当设置此参数，会在设置时间内尝试连接。
  ;                      连接失败，超时返回。连接成功，则继续尝试下载。
  ;                      留空表示30。
  
  ; DownloadTimeout      下载超时，单位为秒，0为无限。
  ;                      此参数与 “连接超时” 共享设置的时间。
  ;                      例如此参数设为30，尝试连接时花费10秒，则 “下载超时” 将只剩20秒。
  ;                      留空表示0。
  
  ; ExpectedStatusCode   期望的状态码，重复访问直到服务器返回的状态码与此参数相同时才停止。
  ;                      通常服务器返回的状态码为200表示网页正常，404表示网页找不到了。
  ;                      参数 “重试次数” 可设置重复访问的最大次数。
  ;                      留空表示不使用此参数。
  
  ; NumberOfRetries      重试次数，重复访问的最大次数。
  ;                      与 “期望的状态码” 配对使用。
  ;                      留空表示1。
  
  ; Proxy                代理服务器，是 http://www.tuzi.com:80 这样的字符。
  ;                      有些抓包程序，例如 Fiddler 需要在这里填入 127.0.0.1:8888 才能抓到数据。
  ;                      留空表示不使用此参数。
  
  ; ProxyBypassList      代理服务器白名单，是 *.microsoft.com 这样的域名。
  ;                      符合域名的网址，将不通过代理服务器访问。
  ;                      留空表示不使用此参数。
  
  ; ************RequestHeaders************
  ; 支持所有 RequestHeader ，可能区分大小写。常见的有以下这些。
  
  ; Cookie               常用于登录验证。
  
  ; Referer              引用网址，常用于防盗链。
  
  ; User-Agent           浏览器标识，常用于防盗链。
  
  */
  Download(URL, Options := "", RequestHeaders := "", Data := "", FilePath := "")
  {
    oOptions := this.解析信息为对象(Options)
    oRequestHeaders := this.解析信息为对象(RequestHeaders)
    oRequestHeaders := this.解析SetCookie为Cookie(oRequestHeaders)

    this.Error := Map()

    wr := ComObject("WinHttp.WinHttpRequest.5.1")

    /* Options
    https://docs.microsoft.com/en-us/windows/win32/winhttp/winhttprequestoption
    
    UserAgentString                  := 0
    URL                              := 1
    URLCodePage                      := 2
    EscapePercentInURL               := 3
    SslErrorIgnoreFlags              := 4
    SelectCertificate                := 5
    EnableRedirects                  := 6
    UrlEscapeDisable                 := 7
    UrlEscapeDisableQuery            := 8
    SecureProtocols                  := 9
    EnableTracing                    := 10
    RevertImpersonationOverSsl       := 11
    EnableHttpsToHttpRedirects       := 12
    EnablePassportAuthentication     := 13
    MaxAutomaticRedirects            := 14
    MaxResponseHeaderSize            := 15
    MaxResponseDrainSize             := 16
    EnableHttp1_1                    := 17
    EnableCertificateRevocationCheck := 18
    */
    if (oOptions.Has("URLCodePage") and oOptions["URLCodePage"] != "")  ; 设置 URL 的编码。
      wr.Option[2] := oOptions["URLCodePage"]

    if (oOptions.Has("EnableRedirects") and oOptions["EnableRedirects"] != "")  ; 设置是否获取重定向跳转后的页面信息。
      wr.Option[6] := oOptions["EnableRedirects"]

    if (oOptions.Has("Proxy") and oOptions["Proxy"] != "")
      wr.SetProxy(2, oOptions["Proxy"] ; 首个参数为0表示遵循 Proxycfg.exe 的设置。1表示忽略代理直连。2表示使用代理。
      , oOptions.Has("ProxyBypassList") ? oOptions["ProxyBypassList"] : "")
    Timeout := this.ValidateTimeout(oOptions.Has("Timeout") ? oOptions["Timeout"] : 0
      , oOptions.Has("ConnectTimeout") ? oOptions["ConnectTimeout"] : 0
        , oOptions.Has("DownloadTimeout") ? oOptions["DownloadTimeout"] : 0)
    ValidatedConnectTimeout := Timeout[1] * 1000
    ; 第一个超时参数必须为0，否则会发生内存泄露。
    ; https://docs.microsoft.com/en-us/windows/win32/winhttp/what-s-new-in-winhttp-5-1
    wr.SetTimeouts(0
      , ValidatedConnectTimeout
      , ValidatedConnectTimeout
      , ValidatedConnectTimeout)
    ; HTTP/1.1 支持以下9种请求方法。
    Methods := ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "CONNECT", "OPTIONS", "TRACE"]
    flag := true
    if oOptions.Has("Method") {
      oOptions["Method"] := Format("{:U}", oOptions["Method"])  ; 转换为大写，小写在很多网站会出错。
      for v in Methods
        if (oOptions["Method"] == v) {
          flag := false
          break
        }
    }
    if (flag)
      oOptions["Method"] := Data = "" ? "GET" : "POST"  ; 请求方法为空或错误，则根据 Data 是否有值自动判断方法。
    wr.Open(oOptions["Method"], URL, true)  ; true 为异步获取。默认是 false ，龟速的根源！！！卡顿的根源！！！
    ; 如果自己不设置 User-Agent 那么实际上会被自动设置为 Mozilla/4.0 (compatible; Win32; WinHttp.WinHttpRequest.5) 。影响数据抓取。
    if !(oOptions.Has("User-Agent") and oOptions["User-Agent"] != "")
      oRequestHeaders["User-Agent"] := "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"
    if (oRequestHeaders.Has("Accept-Encoding") and InStr(oRequestHeaders["Accept-Encoding"], "gzip"))  ; 这里必须用 oRequestHeaders["Accept-Encoding"] 而不是 oRequestHeaders.Accept-Encoding 。
      oRequestHeaders.Delete("Accept-Encoding")  ; 删掉含 “gzip” 的 “Accept-Encoding” ，避免服务器返回 gzip 压缩后的数据。
    if (oRequestHeaders.Has("Connection") and InStr(oRequestHeaders["Connection"], "Keep-Alive"))
      oRequestHeaders.Delete("Connection")  ; 删掉含 “Keep-Alive” 的 “Connection” ，因为默认就会发送这个值，删掉避免重复发送。
    for k, v in oRequestHeaders  ; 原来的 MSDN 推荐在设置 Cookie 前手动添加一个值，新版找不到这个推荐了，并且 Fiddler 抓包发现这样会让 Cookie 变多，故取消手动添加。
      wr.SetRequestHeader(k, v)  ; SetRequestHeader() 必须 Open() 之后才有效。
    ; 为 NumberOfRetries 设置初始值
    if !(oOptions.Has("NumberOfRetries") and oOptions["NumberOfRetries"] != "")
      oOptions["NumberOfRetries"] := 1
    loop
    {
      wr.Send(Data)
      ValidatedDownloadTimeout := Timeout[2]
      if (wr.WaitForResponse(ValidatedDownloadTimeout) != -1)  ; 根据测试，返回-1代表正确，返回空值或0一般是超时了。
        this.SaveError("请求超时", URL, Options, RequestHeaders, Data, FilePath)
      this.StatusCode := wr.Status()  ; 获取状态码，一般 StatusCode 为200说明请求成功。
      this.StatusText := wr.StatusText()
      if (!oOptions.Has("ExpectedStatusCode") or oOptions["ExpectedStatusCode"] = this.StatusCode)
        break
      ; 尝试指定次数后服务器返回的状态码依旧与预期状态码不一致，则记录错误信息。
      else if (A_Index >= oOptions["NumberOfRetries"])
      {
        Msg := "经过 " oOptions["NumberOfRetries"] " 次尝试，服务器返回状态码始终与期望值不符。"
        this.SaveError(Msg, URL, Options, RequestHeaders, Data, FilePath)
        break
      }
    }
    this.ResponseHeaders := this.解析信息为对象(wr.GetAllResponseHeaders())  ; 存响应头
    temp_ResponseHeaders := this.解析信息为对象(wr.GetAllResponseHeaders())  ; 解析SetCookie为Cookie() 会改变传入的值，所以这里创建一个备份用于解析
    this.解析SetCookie为Cookie(temp_ResponseHeaders)  ; 存 Cookie
    this.Cookie := temp_ResponseHeaders.Has("Cookie") ? temp_ResponseHeaders["Cookie"] : ""
    if (FilePath != "")
      return this.BinArr_ToFile(wr.ResponseBody(), FilePath)  ; 存为文件
    else if (oOptions.Has("Charset") and oOptions["Charset"] != "")
      return this.BinArr_ToString(wr.ResponseBody(), oOptions["Charset"])  ; 存为变量，自定义字符集
    else
      return wr.ResponseText()  ; 存为变量
  }

  /*
  infos 的格式：每行一个参数，行首至第一个冒号为参数名，之后至行尾为参数值。多个参数换行。
  注意第一行的 “GET /?tn=sitehao123 HTTP/1.1” 其实是没有任何作用的，因为没有 “:” 。但复制过来了也并不会影响正常解析。
  换句话说， Chrome 开发者工具中的 “Request Headers” 那段内容直接复制过来就能用。
  
  infos:="
  (
  GET /?tn=sitehao123 HTTP/1.1
  Host: www.baidu.com
  Connection: keep-alive
  Cache-Control: max-age=0
  Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
  User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36 SE 2.X MetaSr 1.0
  DNT: 1
  Referer: http://www.hao123.com/
  Accept-Encoding: gzip,deflate,sdch
  Accept-Language: zh-CN,zh;q=0.8
  )"
  */
  解析信息为对象(infos)
  {
    if (IsObject(infos))
      return infos

    ; 以下两步可将 “infos” 换行符统一为 “`r`n” ，避免正则表达式提取时出错。
    infos := StrReplace(infos, "`r`n", "`n")
    infos := StrReplace(infos, "`n", "`r`n")

    ; 使用正则而不是 StrSplit() 进行处理的原因是，后者会错误处理这样的情况 “程序会根据 “Proxy:” 的值自动设置” 。
    infos_temp := WinHttp.RegEx.GlobalMatch(infos, "m)^\s*([\w\-]*?):(.*$)", 1)
    ; 将正则匹配到的信息存入新的对象中，像这样 {"Connection":"keep-alive", "Cache-Control":"max-age=0"} 。
    obj := Map()
    Loop infos_temp.Length {
      name := Trim(infos_temp[A_Index][1], " `t`r`n`v`f")  ;Trim()的作用就是把“abc: haha”中haha的多余空白符消除
      val := Trim(infos_temp[A_Index][2], " `t`r`n`v`f")

      ; “Set-Cookie” 是可以一次返回多条的，因此特殊处理将返回值存入数组。
      if (name = "Set-Cookie")
      {
        if (!obj.Has(name))
          obj[name] := []
        obj[name].Push(val)
      }
      else
        obj[name] := val
    }

    return obj
  }

  /*
  EnableRedirects:
  ExpectedStatusCode:200
  NumberOfRetries:5
  
  如果 “ShowEmptyNameAndValue=0” ，那么输出的内容将不包含值为空的行（例如第一行）。
  */
  解析对象为信息(obj, ShowEmptyNameAndValue := 1)
  {
    if (!IsObject(obj))
      return obj

    for k, v in obj
    {
      if (ShowEmptyNameAndValue = 0 and Trim(v, " `t`r`n`v`f") = "")
        continue

      if (k = "Set-Cookie")
      {
        loop v.Length
          infos .= k ":" v[A_Index] "`r`n"
      }
      else
        infos .= k ":" v "`r`n"
    }
    return infos
  }

  /*
  在 “GetAllResponseHeaders” 中， “Set-Cookie” 可能一次存在多个，比如 “Set-Cookie:name=a; domain=xxx.com `r`n Set-Cookie:name=b; domain=www.xxx.com” 。
  之后向服务器发送 cookie 的时候，会先验证 domain ，再验证 path ，两者都成功，再发送所有符合条件的 cookies 。
  domain 的匹配方式是从字符串的尾部开始比较。
  path 的匹配方式是从头开始逐字符串比较（例如 /blog 匹配 /blog 、 /blogrool 等等）。需要注意的是， path 只在 domain 完成匹配后才比较。
  当下次访问 “www.xxx.com” 时，假如有2个符合条件的 cookie ，那么发送给服务器的 cookie 应该是 “name=b; name=a” 。
  当下次访问 “xxx.com” 时，假如只有1个符合条件的 cookie，那么发送给服务器的 cookie 应该是 “name=a” 。
  规则是， path 越详细，越靠前。 domain 越详细，越靠前（ domain 和 path 加起来就是网址了）。
  另外需要注意的是， “Set-Cookie” 中没有 domain 或者 path 的话，则以当前 url 为准。
  如果要覆盖一个已有的 cookie 值，那么需要创建一个 name 、 domain 、 path ，完全相同的 “Set-Cookie” （ name 就是 “cookie:name=value; path=/” 中的 name ）。
  当一个 cookie 存在，并且可选条件允许的话，该 cookie 的值会在接下来的每个请求中被发送至服务器。
  其值被存储在名为 Cookie 的 HTTP 消息头中，并且只包含了 cookie 的值，其它的属性全部被去除（ expires 、 domain 、 path 、 secure 全部没有了）。
  如果在指定的请求中有多个 cookies ，那么它们会被分号和空格分开，例如：（ Cookie:value1 ; value2 ; name1=value1 ）
  在没有 expires 属性时， cookie 的寿命仅限于单一的会话中。浏览器的关闭意味这一次会话的结束，所以会话 cookie 只存在于浏览器保持打开的状态之下。
  如果 expires 属性设置了一个过去的时间点，那么这个 cookie 会被立即删除。
  最后一个属性是 secure 。不像其它属性，该属性只是一个标记并且没有其它的值。
  参考 “http://my.oschina.net/hmj/blog/69638” 。
  
  此函数将所有 “Set-Cookie” 忽略全部属性后（例如 Domain 适用站点属性、 Expires 过期时间属性等），存为一个 “Cookie” 。
  传入的值里只有 Cookie ，直接返回；只有 Set-Cookie ，处理成 Cookie 后返回；两者都有，处理并覆盖 Cookie 后返回；两者都无，直接返回。
  Cookie 的 name 和 value 不允许包含分号，逗号和空格符。如果包含可以使用 URL 编码。
  参考 “https://blog.oonne.com/site/blog?id=31” “https://www.cnblogs.com/daysme/p/8052930.html”
  */
  解析SetCookie为Cookie(obj)
  {
    if (!obj.Has("Set-Cookie"))  ; 没有待处理的 “Set-Cookie” 则直接返回。
      return obj

    Cookies := Map()
    loop obj["Set-Cookie"].Length
    {
      ; 根据RFC 2965标准，cookie 的 name 可以和属性相同。
      ; 但因为 name 和 value 总在最前面，所以又不会和属性混淆。
      ; https://tools.ietf.org/html/rfc2965
      Set_Cookie := StrSplit(obj["Set-Cookie"][A_Index], ";", " `t`r`n`v`f")
        ; 可以正确处理 value 中含等号的情况 “Set-Cookie:BAIDUID=C04C13BA70E52C330434FAD20C86265C:FG=1;”
        , NameAndValue := StrSplit(Set_Cookie[1], "=", " `t`r`n`v`f", 2)
        , name := NameAndValue[1]
        , value := NameAndValue[2]
        , Cookies[name] := value
    }
    obj.Delete("Set-Cookie")  ; “Set-Cookie” 转换完成后就删除。

    obj["Cookie"] := ""  ; 同时存在 “Cookie” 和 “Set-Cookie” 时，后者处理完成的值将覆盖前者。
    for k, v in Cookies
      obj["Cookie"] .= k "=" v "; "
    obj["Cookie"] := RTrim(obj["Cookie"], " ")

    return obj
  }

  ValidateTimeout(Timeout, ConnectTimeout, DownloadTimeout)
  {
    Timeout := Number(Timeout)
    ; Timeout 为0或正数，则覆盖 ConnectTimeout 和 DownloadTimeout
    if (Timeout >= 0)
      ct := dt := Round(Timeout)
    else
    {
      ; 将字符串等非法值转换为空值，保留数字。
      ct := Number(ConnectTimeout)
      dt := Number(DownloadTimeout)
      ; 将负数转换为空值。即此时可能值为空值、0、正数。
      ct := ct < 0 ? "" : Round(ct)
      dt := dt < 0 ? "" : Round(dt)
    }

    ; 空值  零  正
    ; 空值  零  正  交叉配对
    if (ct = "" and dt = "")
      ct := 30, dt := -1
    else if (ct = "" and dt = 0)
      ct := 30, dt := -1
    else if (ct = "" and dt > 0)
      ct := 30, dt := Max(ct, dt)
    else if (ct = 0 and dt = "")
      ct := 0, dt := -1
    else if (ct = 0 and dt = 0)
      ct := 0, dt := -1
    else if (ct = 0 and dt > 0)
      ct := 0, dt := dt
    else if (ct > 0 and dt = "")
      ct := ct, dt := -1
    else if (ct > 0 and dt = 0)
      ct := ct, dt := -1
    else if (ct > 0 and dt > 0)
      ct := Max(ct, dt), dt := ct

    return [ct, dt]
  }

  SaveError(Message, URL, Options, RequestHeaders, Data, FilePath)
  {
    this.Error["Message"] := Message
    this.Error["URL"] := URL
    this.Error["Options"] := Options
    this.Error["RequestHeaders"] := RequestHeaders
    this.Error["Data"] := Data
    this.Error["FilePath"] := FilePath
  }

  /*
  CreateFormData - Creates "multipart/form-data" for http post by tmplinshi
  
  https://www.autohotkey.com/boards/viewtopic.php?t=7647
  
  Usage: CreateFormData(&retData, &retHeader, objParam, BoundaryString, RandomBoundaryLength, MimeType)
    retData               - (out) Data used for HTTP POST.
    retHeader             - (out) Content-Type header used for HTTP POST.
    objParam              - (in)  An object defines the form parameters.
    BoundaryString        - (in)  default "----WebKitFormBoundary".
    RandomBoundaryLength  - (in)  default 16.
    MimeType              - (in)  default auto get MimeType.
  
  To specify files, use array as the value. Example:
      objParam := { "key1": "value1"
                  , "upload[]": ["1.png", "2.png"] }
  
  Version    : 1.31 / 2021-04-05 - 支持自定义 BoundaryString RandomBoundaryLength MimeType
                                   默认 BoundaryString 为 ----WebKitFormBoundary + 16位随机数
               1.30 / 2019-01-13 - The file parameters are now placed at the end of the retData
               1.20 / 2016-06-17 - Added CreateFormData_WinInet(), which can be used for VxE's HTTPRequest()
               1.10 / 2015-06-23 - Fixed a bug
               1.00 / 2015-05-14
  */
  CreateFormData(&retData, &retHeader, objParam, BoundaryString := "", RandomBoundaryLength := "", MimeType := "") {

    this.NonNull(BoundaryString, "----WebKitFormBoundary")
      , this.NonNull(RandomBoundaryLength, 16, 1)

    CRLF := "`r`n"

    Boundary := this.RandomBoundary(RandomBoundaryLength)
    BoundaryLine := "--" . BoundaryString . Boundary

    ; Loop input paramters
    binArrs := []
    fileArrs := []
    For k, v in objParam
    {
      If IsObject(v) {
        For i, FileName in v
        {
          str := BoundaryLine . CRLF
            . "Content-Disposition: form-data; name=" "" . k . "" "; filename=" "" . FileName . "" "" . CRLF
            . "Content-Type: " . this.NonNull_ret(MimeType, this.GetMimeType(FileName)) . CRLF . CRLF
          fileArrs.Push(this.BinArr_FromString(str))
          fileArrs.Push(this.BinArr_FromFile(FileName))
          fileArrs.Push(this.BinArr_FromString(CRLF))
        }
      } Else {
        str := BoundaryLine . CRLF
          . "Content-Disposition: form-data; name=" "" . k "" "" . CRLF . CRLF
          . v . CRLF
        binArrs.Push(this.BinArr_FromString(str))
      }
    }

    binArrs.push(fileArrs*)

    str := BoundaryLine . "--" . CRLF
    binArrs.Push(this.BinArr_FromString(str))

    retData := this.BinArr_Join(binArrs*)
    retHeader := "multipart/form-data; boundary=" . BoundaryString . Boundary
  }

  RandomBoundary(length) {
    str := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9
      , "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
      , "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    loop length
    {
      n := Random(1, str.Length)
      ret .= str[n]
    }
    return ret
  }

  GetMimeType(FileName) {
    n := FileOpen(FileName, "r").ReadUInt()
    Return (n = 0x474E5089) ? "image/png"
    : (n = 0x38464947) ? "image/gif"
      : (n & 0xFFFF = 0x4D42) ? "image/bmp"
        : (n & 0xFFFF = 0xD8FF) ? "image/jpeg"
          : (n & 0xFFFF = 0x4949) ? "image/tiff"
            : (n & 0xFFFF = 0x4D4D) ? "image/tiff"
              : "application/octet-stream"
  }

  /*
  https://www.w3schools.com/asp/ado_ref_stream.asp
  https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20
  Update: 2015-6-4 - Added BinArr_ToFile()
  */
  BinArr_FromString(str) {
    oADO := ComObject("ADODB.Stream")

    oADO.Type := 2  ; adTypeText
    oADO.Mode := 3  ; adModeReadWrite
    oADO.Open()
    oADO.Charset := "UTF-8"
    oADO.WriteText(str)

    oADO.Position := 0  ; 位置0， Type 可写。其它位置 Type 只读。 https://www.w3schools.com/asp/prop_stream_type.asp
    oADO.Type := 1  ; adTypeBinary
    oADO.Position := 3  ; Skip UTF-8 BOM
    res := oADO.Read()
    oADO.Close()
    return res
  }

  BinArr_FromFile(FileName) {
    oADO := ComObject("ADODB.Stream")

    oADO.Type := 1  ; adTypeBinary
    oADO.Open()
    oADO.LoadFromFile(FileName)
    res := oADO.Read()
    oADO.Close()
    return res
  }

  BinArr_Join(Arrays*) {
    oADO := ComObject("ADODB.Stream")

    oADO.Type := 1  ; adTypeBinary
    oADO.Mode := 3  ; adModeReadWrite
    oADO.Open()
    For i, arr in Arrays
      oADO.Write(arr)
    oADO.Position := 0
    res := oADO.Read()
    oADO.Close()
    return res
  }

  BinArr_ToString(BinArr, Encoding) {
    oADO := ComObject("ADODB.Stream")

    oADO.Type := 1  ; 以二进制方式操作
    oADO.Mode := 3  ; 可同时进行读写。 Mode 必须在 Open 前才能设置。 https://www.w3schools.com/asp/prop_stream_mode.asp
    oADO.Open()  ; 开启物件
    oADO.Write(BinArr)  ; 写入物件。注意 wr.ResponseBody() 获取到的是无符号的 bytes，通过 adodb.stream 转换成字符串 string

    oADO.Position := 0  ; 位置0， Type 可写。其它位置 Type 只读。 https://www.w3schools.com/asp/prop_stream_type.asp
    oADO.Type := 2  ; 以文字模式操作
    oADO.Charset := Encoding  ; 设定编码方式
    res := oADO.ReadText()  ; 将物件内的文字读出
    oADO.Close()
    return res
  }

  BinArr_ToFile(BinArr, FileName) {
    oADO := ComObject("ADODB.Stream")

    oADO.Type := 1  ; 以二进制方式操作
    oADO.Mode := 3  ; 可同时进行读写。 Mode 必须在 Open 前才能设置。 https://www.w3schools.com/asp/prop_stream_mode.asp
    oADO.Open()  ; 开启物件
    oADO.Write(BinArr)  ; 写入物件。注意没法将 wr.ResponseBody() 存入一个变量，所以必须用这种方式写文件
    oADO.SaveToFile(FileName, 2)  ; 文件存在则覆盖
    oADO.Close()
  }


  Class RegEx
  {
    ; 返回值是数组对象，其每个值都是使用 O 选项返回的匹配对象。
    ; 可用 返回值.Length  判断无匹配。
    ; 可用 返回值.1.Pos[0] 或 返回值[2].Len[1] 等方式获取每个匹配的各种信息（帮助搜索 “匹配对象” ）。
    static GlobalMatch(Haystack, NeedleRegEx, StartingPos := 1)
    {
      Out := [], Len := StrLen(Haystack)
      ; RegExMatch() 返回值为0代表没有匹配，为空代表错误（例如正则表达式语法错误）。
      ; 表达式 “m)” 字符串 “” 能形成零宽匹配，因此需要验证 StartingPos<=Len 避免死循环。
      ; 注意第三个参数，是 引用形式，所以无需引号。
      while StartingPos <= Len and RegExMatch(Haystack, NeedleRegEx, &OutputVar, StartingPos) {
        ; 匹配成功则设置下次匹配起点为上次成功匹配字符串的末尾。
        ; 这样可以使表达式 “ABCABC” ，匹配字符串 “ABCABCABCABC” 时返回2次结果。
        ; 表达式 “(?=10)” 字符串 “100.10” 能形成零宽匹配，返回的位置是1，宽度是0。
        ; 因此需要 Max(OutputVar.Len[0], 1) 将宽度最小值设为1，才能避免死循环。
        StartingPos := OutputVar.Pos[0] + Max(OutputVar.Len[0], 1)
        Out.Push(OutputVar)
      }
      return Out
    }

    ; 此函数作用等同 RegExMatch() ，主要意义是统一返回值格式便于处理。
    static Match(Haystack, NeedleRegEx, StartingPos := 1)
    {
      Out := []
      if (RegExMatch(Haystack, NeedleRegEx, &OutputVar, StartingPos))
        Out.Push(OutputVar)
      return Out
    }

    ; 此函数用于给正则表达式添加选项。
    ; 添加的选项严格区分大小写！！！例如支持 (*ANYCRLF) 不支持 (*AnyCRLF) 。
    ; 选项将被确保存在且仅存在一个，不会出现 OimO)abc.* 这种情况。
    static AddOptions(NeedleRegEx, Options*)
    {
      ; 因为存在 \Qim)\E 这样的免转义规则（表示原义的匹配字符 “im)” ）。
      ; 所以必须使用第一个右括号左边的参数去判断此右括号是否为选项分隔符。
      选项分隔符位置 := InStr(NeedleRegEx, ")")  ; 获取第一个右括号的位置。
      if (选项分隔符位置)
      {
        正则选项 := SubStr(NeedleRegEx, 1, 选项分隔符位置)
        正则本体 := SubStr(NeedleRegEx, 选项分隔符位置 + 1)

        temp := 正则选项
        for v in ["i", "m", "s", "x", "A", "D", "J", "U", "X", "P", "O", "S", "C", "`n", "`r", "`a", A_Space, A_Tab]
          temp := StrReplace(temp, v, , true)
      }

      if (!选项分隔符位置 or temp != ")")  ; temp 若包含除 ")" 之外的字符，则说明它不是选项分隔符。
      {
        正则选项 := ")"  ; 没有选项分隔符，则说明没有正则选项，所以创建一个空选项。
        正则本体 := NeedleRegEx
      }

      flag1 := flag2 := flag3 := 0
      ; 将特殊选项 (*UCP)(*ANYCRLF)(*BSR_ANYCRLF) 去重。
      RegExMatch(正则本体, "^(\Q(*UCP)\E|\Q(*ANYCRLF)\E|\Q(*BSR_ANYCRLF)\E)+", &正则特殊选项)
      if (正则特殊选项)
      {
        if (InStr(正则特殊选项, "(*UCP)"), true)  ; 标记存在哪个特殊选项。true 表示区分大小写。
          flag1 := 1
        if (InStr(正则特殊选项, "(*ANYCRLF)"), true)
          flag2 := 1
        if (InStr(正则特殊选项, "(*BSR_ANYCRLF)"), true)
          flag3 := 1

        ; 删除特殊选项，便于之后单独添加。
        正则本体 := RegExReplace(正则本体, "^(\Q(*UCP)\E|\Q(*ANYCRLF)\E|\Q(*BSR_ANYCRLF)\E)+", , , 1)
      }

      for k, Option in Options
        switch Option, true
        {
          case "(*UCP)":
            flag := 1
          case "(*ANYCRLF)":
            flag := 2
          case "(*BSR_ANYCRLF)":
            flag := 3
          case "i", "m", "s", "x", "A", "D", "J", "U", "X", "P", "O", "S", "C", "``n", "``r", "``a":
            if (!InStr(正则选项, Option, true))  ; 检查目前选项中是否存在待添加选项，确保其唯一。true 表示区分大小写。
              正则选项 := Option 正则选项
        }

      ; 根据标记单独进行特殊选项添加，确保特殊选项唯一。
      if (flag3)
        正则本体 := "(*BSR_ANYCRLF)" 正则本体
      if (flag2)
        正则本体 := "(*ANYCRLF)" 正则本体
      if (flag1)
        正则本体 := "(*UCP)" 正则本体

      return 正则选项 . 正则本体
    }
  }

  ; 变量为空，则使用默认值。变量不为空，则使用变量值。
  ; 同时可以检查变量是否超出最大最小范围。
  ; 注意，默认值不受最大最小范围的限制。
  ; 也就是说
  ; 当变量值为""，默认值为8，范围为2-5，此时变量值会是8。
  ; 当变量值为10，默认值为8，范围为2-5，此时变量值会是5。
  NonNull(&var, DefaultValue, MinValue := "", MaxValue := "")  ; 237ms
  {
    var := var = "" ? DefaultValue : MinValue = "" ? (MaxValue = "" ? var : Min(var, MaxValue)) : (MaxValue != "" ? Max(Min(var, MaxValue), MinValue) : Max(var, MinValue))
  }

  ; 与 NonNull 一致，区别是通过 return 返回值，而不是 ByRef。
  NonNull_Ret(var, DefaultValue, MinValue := "", MaxValue := "")  ; 237ms
  {
    return var = "" ? DefaultValue : MinValue = "" ? (MaxValue = "" ? var : Min(var, MaxValue)) : (MaxValue != "" ? Max(Min(var, MaxValue), MinValue) : Max(var, MinValue))
  }
}