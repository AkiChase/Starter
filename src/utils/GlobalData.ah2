class GlobalData {
    ; static rootDir := unset
    ; static imgDir := unset
    ; static bootDir := unset
    ; static dataDir := unset
    ; static pluginDir := unset
    ; static customImgDir := unset

    ; static startupData := unset
    ; static startupDataPath := unset
    ; static config := unset
    ; static configPath := unset

    ; static intelligentData := unset
    ; static intelligentDataPath := unset

    static startupSearchResult := []
    static intelligentSearchResult := []
    static intelligentRegMap := Map()

    static intelligentGroups := ["run-with", "search"]
    static intelligentMatchPriority := Map("str", 1, "reg", 2)

    static hotkeyList := []
    ; static onExitHandler := unset

    static init() {
        SplitPath(A_ScriptDir, , &tmp)
        this.rootDir := tmp

        this.imgDir := this.rootDir "\resource\img"
        this.pluginDir := this.rootDir "\src\plugin"
        this.dataDir := this.rootDir "\resource\data"
        this.customImgDir := this.dataDir "\customImg"
        this.bootDir := this.dataDir "\boot"


        for dirPath in [this.dataDir, this.bootDir, this.customImgDir, this.pluginDir]
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
                    "https?:\/{2}(.+)"
                    ],
                    "mode": "reg",
                    "replace": [
                    "$0",
                    "$0"
                    ]
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
                    "exp": [
                    "(bd|baidu|百度)\\s+(?<query>.*)"
                    ],
                    "mode": "reg",
                    "replace": [
                    "${query}"
                    ]
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
                    "exp": [
                    "(gg|谷歌)\\s+(?<query>.*)"
                    ],
                    "mode": "reg",
                    "replace": [
                    "${query}"
                    ]
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

    ; 生成默认配置
    static newDefaultConfig(key?) {
        if (IsSet(key)) {
            switch key {
                case "plugin":
                    return []
                case "hotkey":
                    return [Map(
                        "index", 3,
                        "key", "CapsLock",
                        "block", false
                    ), Map(
                        "index", 4,
                        "key", "CapsLock",
                        "block", false
                    )]
            }
        } else {
            config := Map()
            config["plugin"] := []
            config["hotkey"] := [Map(
                "index", 3,
                "key", "CapsLock",
                "block", false
            ), Map(
                "index", 4,
                "key", "CapsLock",
                "block", false
            )]
            return config
        }
    }

    ; 重新读取配置文件
    static refreshConfig() {
        if (FileExist(this.configPath)) {
            try {
                this.config := DataHelper.loadJSONFile(this.configPath)
                if (Type(this.config) != "Map") {
                    this.config := this.newDefaultConfig()
                }

                for name in ["plugin", "hotkey"] {
                    if (!this.config.Has(name))
                        this.config[name] := this.newDefaultConfig(name)
                }
                pluginDefault := this.newDefaultConfig("plugin")
                ; 热键数量变化则重置
                if (this.config["hotkey"].Length < pluginDefault.Length)
                    this.config["hotkey"] := pluginDefault
            } catch {
                this.config := this.newDefaultConfig()
                this.storeConfig()
            }
        } else {
            this.config := this.newDefaultConfig()
            this.storeConfig()
        }
    }

    ; 保存配置文件至本地
    static storeConfig() {
        DataHelper.storeJSONFile(this.config, this.configPath)
    }
}