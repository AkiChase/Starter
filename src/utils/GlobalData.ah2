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

    ; static startupSearchResult := unset
    ; static intelligentSearchResult := unset

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

        this.refreshstartupData()
        this.refreshConfig()
        this.refreshIntelligentData()

        ; 退出前执行
        onExitHandler(*) {
            this.storestartupData()
            this.storeConfig()
            this.storeIntelligentData()
        }
        this.onExitHandler := onExitHandler
    }

    ; 重新读取智能模式数据
    static refreshIntelligentData() {
        if (FileExist(this.intelligentDataPath))
            this.intelligentData := DataHelper.loadJSON(this.intelligentDataPath)
        else
        {
            FileAppend("{}", this.intelligentDataPath)
            this.config := Map()
        }
    }

    ; 保存智能模式数据文件至本地
    static storeIntelligentData() {
        DataHelper.storeJSON(this.intelligentData, this.intelligentDataPath)
    }

    ; 重新读取startupData
    static refreshstartupData() {
        if (FileExist(this.startupDataPath))
            this.startupData := DataHelper.loadData(this.startupDataPath)
        else
        {
            FileAppend("", this.startupDataPath)
            this.startupData := []
        }
    }

    ; 保存startupDataPath至本地
    static storestartupData() {
        DataHelper.storeData(this.startupData, this.startupDataPath)
    }

    ; 重新读取配置文件
    static refreshConfig() {
        if (FileExist(this.configPath))
            this.config := DataHelper.loadJSON(this.configPath)
        else
        {
            FileAppend("{}", this.configPath)
            this.config := Map()
        }
    }

    ; 保存配置文件至本地
    static storeConfig() {
        DataHelper.storeJSON(this.config, this.configPath)
    }
}