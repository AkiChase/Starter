import { sidebar } from "vuepress-theme-hope";

export const zhSidebar = sidebar({
  "/guide/": [
    {
      text: "快速上手",
      icon: "lightbulb",
      link: "/guide/get-started/intro",
      prefix: "get-started/",
      children: "structure" // structure生成会包括README, README定义index:false将其隐藏
    },
    {
      text: "启动模式",
      icon: "bolt",
      link: "/guide/startup/",
    },
    {
      text: "智能模式",
      icon: "face-laugh",
      collapsible: true,
      link: "/guide/intelligent/",
      prefix: "intelligent/",
      children: "structure"
    },
    {
      text: "插件界面",
      icon: "list-ul",
      link: "/guide/plugin/",
    },
    {
      text: "自启界面",
      icon: "desktop",
      link: "/guide/boot/",
    },
    {
      text: "关于界面",
      icon: "circle-info",
      link: "/guide/about/",
    },
    {
      text: "用户数据",
      icon: "user",
      link: "/guide/user-data/",
    }
  ],
  "/plugin/": "structure",
  "/dev/": "structure"
});
