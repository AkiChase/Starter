import { hopeTheme } from "vuepress-theme-hope";
import { zhNavbar } from "./navbar.js";
import { zhSidebar } from "./sidebar.js";



export default hopeTheme({
  hostname: "https://ruchuby.github.io/Starter/",

  author: {
    name: "ruchuby",
    url: "https://github.com/ruchuby",
    email: "xiangyangxiao@outlook.com"
  },


  iconAssets: [
    "https://cdn.bootcdn.net/ajax/libs/font-awesome/6.4.0/css/solid.min.css",
    "https://cdn.bootcdn.net/ajax/libs/font-awesome/6.4.0/css/fontawesome.min.css"
  ],
  iconPrefix: "fas fa-",

  favicon: "/favicon.ico",
  logo: "/logo.svg",
  logoDark: "/logo-tp.svg",


  repo: "ruchuby/Starter",
  docsDir: "/docs",
  docsBranch: "master",

  navbarLayout: {
    start: ["Brand"],
    center: [],
    end: ["Links", "Language", "Repo", "Outlook", "Search"]
  },

  // 禁用打印
  print: false,

  locales: {
    // Chinese locale config
    "/": {
      // navbar
      navbar: zhNavbar,
      // sidebar
      sidebar: zhSidebar,
      footer: 'This site is served by GitHub Pages',
      displayFooter: true,
      // 页面元数据
      metaLocales: {
        editLink: "在 GitHub 上编辑此页",
      },
    },
  },

  plugins: {
    comment: {
      provider: "Giscus",
      repo: "ruchuby/giscusRepo",
      repoId: "R_kgDOJUjnlw",
      category: "Announcements",
      categoryId: "DIC_kwDOJUjnl84CVpfq",
    },

    mdEnhance: {
      // 提示、注释、警告等自定义容器
      container: true,
      // 选项卡
      tabs: true,
      codetabs: true,
      // 附加属性
      attrs: true,
      // 自定义对齐
      align: true,
      // 上下标
      sub: true,
      sup: true,
      // 底部注释引用
      footnote: true,
      // 高亮标记
      mark: true,
      // 启用图片懒加载
      imgLazyload: true,
      // 启用图片标记
      imgMark: true,
      // 启用图片大小
      imgSize: true,
      // 任务列表
      tasklist: true,
      // 导入md文件
      include: true,
      // 流程图支持
      flowchart: true,
    },
  },
});
