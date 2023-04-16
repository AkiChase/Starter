import { defineUserConfig } from "vuepress";
import theme from "./theme.js";
// 搜索插件
import { searchProPlugin } from "vuepress-plugin-search-pro";
// 自定义代码高亮
import { shikiPlugin } from "@vuepress/plugin-shiki";


import { readFileSync } from 'fs';
import { join } from 'path';

export default defineUserConfig({
  base: "/Starter/",

  locales: {
    "/": {
      lang: "zh-CN",
      title: "Starter文档",
      description: "Starter - 极简效率工具",
    },
  },
  theme,
  plugins: [
    searchProPlugin({
      indexContent: true,
    }),
    shikiPlugin({
      theme: "one-dark-pro",
      langs: [{
        id: "autohotkey",
        scopeName: 'source.ahk2',
        grammar: JSON.parse(readFileSync(join(__dirname, 'ahk2.tmLanguage.json'), "utf-8")),
        aliases: ['ahk', 'ahk2', 'ah2'],
        path: join(__dirname, 'ahk2.tmLanguage.json')
      }]
    }),
  ],
});


