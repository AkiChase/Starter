class GlobalData {
    static rootDir := unset
    static imgDir := unset
    static bootDir := unset
    static dataDir := unset

    static programData := unset
    static programDataPath := unset
    static config := unset
    static configPath := unset

    static searchResult := unset

    static init() {
        SplitPath(A_ScriptDir, , &tmp)
        this.rootDir := tmp

        this.imgDir := this.rootDir "\resource\img"
        this.bootDir := this.rootDir "\boot"
        this.dataDir := this.rootDir "\resource\data"

        for dirPath in [this.bootDir, this.dataDir]
            if (!FileExist(dirPath))
                DirCreate(dirPath)

        this.programDataPath := this.dataDir "\programData.txt"
        this.configPath := this.dataDir "\config.json"
        this.refreshProgramData()
        this.refreshConfig()
    }

    ; 重新读取programData
    static refreshProgramData() {
        if (FileExist(this.programDataPath))
            this.programData := DataHelper.loadData(this.programDataPath)
        else
        {
            FileAppend("", this.programDataPath)
            this.programData := []
        }
    }

    ; 保存programDataPath至本地
    static storeProgramData() {
        DataHelper.storeData(this.programData, this.programDataPath)
    }

    ; 重新读取配置文件
    static refreshConfig() {
        if (FileExist(this.configPath))
            this.config := DataHelper.loadConfig(this.configPath)
        else
        {
            FileAppend("{}", this.configPath)
            this.config := Map()
        }
    }

    ; 保存配置文件至本地
    static storeConfig() {
        DataHelper.storeConfig(this.config, this.configPath)
    }
}