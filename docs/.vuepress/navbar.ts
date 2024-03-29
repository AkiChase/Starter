import { navbar } from "vuepress-theme-hope";

export const zhNavbar = navbar([
  { text: "使用指南", icon: "lightbulb", link: "/guide/" },
  { text: "插件指南", icon: "list-ul", link: "/plugin/" },
  { text: "插件开发", icon: "code", link: "/dev/" },
  { text: "API", icon: "screwdriver-wrench", link: "/api/" },
  { text: "更新日志", icon: "clock", link: "/history" }
]);
