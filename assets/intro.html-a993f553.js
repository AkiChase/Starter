import{_ as c,W as i,X as d,Y as t,Z as e,$ as o,a2 as s,a1 as l,C as a}from"./framework-3e0345fd.js";const h={},_=t("h2",{id:"项目初衷",tabindex:"-1"},[t("a",{class:"header-anchor",href:"#项目初衷","aria-hidden":"true"},"#"),e(" 项目初衷")],-1),u=t("p",null,[t("strong",null,"Starter"),e(" 的初衷源于我没有找到一个"),t("strong",null,"真正让自己满意的"),e("启动工具或效率工具。")],-1),p=t("p",null,"我只是想要一个搜索框，输入内容，就能启动我想要的东西，最好还能有一些支持扩展的功能。",-1),g={href:"https://u.tools/",target:"_blank",rel:"noopener noreferrer"},f={href:"https://github.com/rubickCenter/rubick",target:"_blank",rel:"noopener noreferrer"},b=l('<p>然而，它们都存在一些问题：</p><ul><li>基于 Electron（相当于一个浏览器），对于启动工具来说过于臃肿了。</li><li>不能设置双击 <code>CapsLK</code> 键呼出搜索框，而其他快捷键或是不方便或是易误触。</li><li>搜索结果不能完全自定义。虽然能通过插件曲线救国，但是终究不太方便。</li></ul><p>总之，虽然各种快速启动工具很多，但它们总会有不符合我个人习惯的地方， 或是 UI 太丑，或是操作逻辑不适应，或是匹配方式无法完全自定义，或是捆绑太多内容，或是体积庞大、性能有限...</p><p>因此，我决定自己开发一个启动工具，以满足自己的需求，并分享给其他需要的人使用。</p><p>这就是 <strong>Starter</strong> 的初衷。</p><h2 id="项目特点" tabindex="-1"><a class="header-anchor" href="#项目特点" aria-hidden="true">#</a> 项目特点</h2><ul><li><h3 id="编程语言" tabindex="-1"><a class="header-anchor" href="#编程语言" aria-hidden="true">#</a> 编程语言</h3></li></ul>',7),k={href:"https://www.autohotkey.com/",target:"_blank",rel:"noopener noreferrer"},x=t("code",null,"AHK",-1),m=t("code",null,"AHK",-1),A=t("strong",null,"V2",-1),K=l('<p>这门语言语法简单、开发快速、无需安装运行环境，因此，完全可以作为 <strong>Starter</strong> 的开发语言。</p><p>作为我掌握时间最久，却没有产出任何开源作品的编程语言，我决定用它来开发 <strong>Starter</strong>。</p><p>虽然 <code>AHK</code> 可以使用基于 <code>WebView</code> 的 UI界面，而且使用 <strong>Web 开发</strong> 的方式可以获得更加精美的界面， 但为了确保开源项目能被更多 <strong>AHKer</strong> 接受，我决定采用 <code>AHK</code> 自带的 <code>Gui</code> 控件，即 <strong>Win32 Gui</strong> 控件。</p><p>这样也能为 <strong>AHKer</strong> 提供一个使用 <code>AHK</code> 开发的实例。</p><ul><li><h3 id="小巧精美" tabindex="-1"><a class="header-anchor" href="#小巧精美" aria-hidden="true">#</a> 小巧精美</h3></li></ul><p><strong>Starter</strong> 将贯彻<strong>轻量</strong>、<strong>绿色</strong>、<strong>简洁</strong>和<strong>美观</strong>的理念，为用户提供更好的使用体验。</p><ul><li><h3 id="可扩展" tabindex="-1"><a class="header-anchor" href="#可扩展" aria-hidden="true">#</a> 可扩展</h3></li></ul>',7),S=t("strong",null,"AHKer",-1),H=t("strong",null,"Starter",-1),V=t("code",null,"API",-1),w=t("strong",null,"Starter",-1),C=t("strong",null,"Starter",-1);function I(L,v){const r=a("ExternalLinkIcon"),n=a("RouterLink");return i(),d("div",null,[_,u,p,t("p",null,[e("在启动软件的设计上，我比较喜欢 "),t("a",g,[e("uTools"),o(r)]),e(" 或者其开源替代品 "),t("a",f,[e("rubick"),o(r)]),e("。")]),b,t("p",null,[t("a",k,[e("Autohotkey"),o(r)]),e("是一门小众而冷门的脚本语言，但它确实是我的编程启蒙语言。 尽管我曾一度嫌弃 "),x,e(" 那些不规范的语法，但 "),m,e(" 的 "),A,e(" 版本已经规范了代码格式，并且支持了更多现代化语法。")]),K,t("p",null,[e("每个 "),S,e(" 都能够使用 "),H,e(" 提供的 "),V,e(" 接口来"),o(n,{to:"/dev/"},{default:s(()=>[e("开发")]),_:1}),e("和加载自己的插件扩展，从而打造专属于自己的工具。")]),t("p",null,[e("非开发者也可以在 "),w,e(" 日渐丰富的"),o(n,{to:"/plugin/"},{default:s(()=>[e("插件库")]),_:1}),e("中挑选自己心仪的插件进行装载，扩展 "),C,e(" 的能力")])])}const N=c(h,[["render",I],["__file","intro.html.vue"]]);export{N as default};