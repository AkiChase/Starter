import { defineUserConfig } from "vuepress";
import theme from "./theme.js";
// 搜索插件
import { searchProPlugin } from "vuepress-plugin-search-pro";
import { autoCatalogPlugin } from "vuepress-plugin-auto-catalog";

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
  ],
});
