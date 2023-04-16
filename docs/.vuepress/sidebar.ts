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
      text: "设置界面",
      icon: "gear",
      link: "/guide/setting/",
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
  "/api/": "structure",
  "/dev/": [
    {
      text: "快速上手",
      icon: "lightbulb",
      link: "/dev/get-started",
    },
    {
      text: "插件启动项",
      icon: "bolt",
      link: "/dev/startup",
    },
    {
      text: "插件智能项",
      icon: "face-laugh",
      link: "/dev/intelligent/",
      prefix: "intelligent/",
      children: "structure"
    },
    {
      text: "插件模式",
      icon: "list-ul",
      link: "/dev/plugin-mode/",
      prefix: "plugin-mode/",
      children: "structure"
    },
    {
      text: "ImagePut",
      icon: "image",
      link: "/dev/image-put",
    },
    {
      text: "其他内容",
      icon: "ellipsis",
      link: "/dev/others/",
      collapsible: true,
      prefix: "others/",
      children: "structure"
    },
  ],
  "/history": []
});
