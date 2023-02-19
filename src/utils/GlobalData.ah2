class GlobalData {
    ; static rootDir := unset
    ; static imgDir := unset
    ; static bootDir := unset
    ; static dataDir := unset
    ; static customImgDir := unset

    ; static startupData := unset
    ; static startupDataPath := unset
    ; static config := unset
    ; static configPath := unset

    ; static intelligentData := unset
    ; static intelligentDataPath := unset

    static startupSearchResult := []
    static intelligentSearchResult := []

    static intelligentGroups := ["run-with", "search"]
    static intelligentMatchPriority := Map("str", 1, "reg", 2)

    ; static onExitHandler := unset

    static init() {
        SplitPath(A_ScriptDir, , &tmp)
        this.rootDir := tmp

        this.imgDir := this.rootDir "\resource\img"
        this.bootDir := this.rootDir "\boot"
        this.dataDir := this.rootDir "\resource\data"
        this.customImgDir := this.dataDir "\customImg"


        for dirPath in [this.bootDir, this.dataDir, this.customImgDir]
            if (!FileExist(dirPath))
                DirCreate(dirPath)

        this.startupDataPath := this.dataDir "\startupData.txt"
        this.configPath := this.dataDir "\config.json"
        this.intelligentDataPath := this.dataDir "\intelligentData.json"

        this.refreshStartupData()
        this.refreshConfig()
        this.refreshIntelligentData()

        ; 退出前执行
        onExitHandler(*) {
            this.storeStartupData()
            this.storeConfig()
            this.storeIntelligentData()
        }
        this.onExitHandler := onExitHandler
    }

    ; 重新读取智能模式数据
    static refreshIntelligentData() {
        static defaultData := "
        (Join
        {
            "run-with": [
                {
                "enabled": 1,
                "group": "run-with",
                "match": {
                    "exp": [
                    "[^\\s]*(\\.[a-zA-z]{2}[^\\s]*){2}",
                    "https?:(\/{2})?(.*)"
                    ],
                    "mode": "reg"
                },
                "notes": "使用默认浏览器打开网址链接",
                "removable": 0,
                "script": {
                    "mode": "none"
                },
                "thumb": "打开网址.png",
                "title": "打开网址"
                }
            ],
            "search": [
                {
                "enabled": 1,
                "group": "search",
                "match": {
                    "mode": "str"
                },
                "notes": "使用默认浏览器百度搜索",
                "removable": 1,
                "thumb": "百度搜索.ico",
                "title": "百度搜索",
                "url": "https:\/\/www.baidu.com\/s?word={}"
                },
                {
                "enabled": 1,
                "group": "search",
                "match": {
                    "mode": "str"
                },
                "notes": "使用默认浏览器谷歌搜索",
                "removable": 0,
                "thumb": "谷歌搜索.ico",
                "title": "谷歌搜索",
                "url": "https:\/\/www.google.com\/search?q={}"
                }
            ]
            }
        )"
    ; 加载默认值
        default := Jxon_Load(&defaultData)
        if (FileExist(this.intelligentDataPath)) {
            this.intelligentData := DataHelper.loadJSONFile(this.intelligentDataPath)
            for group, itemList in default {
                if !(this.intelligentData.Has(group) and (this.intelligentData[group] is Array) this.intelligentData[group].Length)
                    this.intelligentData[group] := itemList    ; 当前组不存在、非数组、为空则置默认值
            }
        }
        else
            this.intelligentData := default
    }

    ; 保存智能模式数据文件至本地
    static storeIntelligentData() {
        DataHelper.storeJSONFile(this.intelligentData, this.intelligentDataPath)
    }

    ; 重新读取startupData
    static refreshStartupData() {
        if (FileExist(this.startupDataPath))
            this.startupData := DataHelper.loadData(this.startupDataPath)
        else
        {
            FileAppend("", this.startupDataPath)
            this.startupData := []
        }
    }

    ; 保存startupDataPath至本地
    static storeStartupData() {
        DataHelper.storeData(this.startupData, this.startupDataPath)
    }

    ; 重新读取配置文件
    static refreshConfig() {
        if (FileExist(this.configPath))
            this.config := DataHelper.loadJSONFile(this.configPath)
        else
        {
            FileAppend("{}", this.configPath)
            this.config := Map()
        }
    }

    ; 保存配置文件至本地
    static storeConfig() {
        DataHelper.storeJSONFile(this.config, this.configPath)
    }
}