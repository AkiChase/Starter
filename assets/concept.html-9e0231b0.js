import{_ as c,W as l,X as g,Y as t,Z as n,$ as o,a1 as a,a0 as s,C as i}from"./framework-c8ebc670.js";const h="/Starter/assets/run-with-4e16f70d.jpg",d="/Starter/assets/search-8a33a617.jpg",p={},_=t("p",null,"智能模式的功能比较特殊，有一些相关概念需要你提前了解，以便更好地理解如何使用智能模式。",-1),u=t("h2",{id:"智能项",tabindex:"-1"},[t("a",{class:"header-anchor",href:"#智能项","aria-hidden":"true"},"#"),n(" 智能项")],-1),f=t("p",null,[t("strong",null,"原生智能项"),n("是指你在智能模式编辑界面中手动添加、删除或修改的智能项，与插件无关。")],-1),m=t("p",null,[t("strong",null,"插件智能项"),n("是指通过插件添加的智能项。插件智能项只能通过插件的编写者更新或修改，有的插件可能会为用户提供"),t("strong",null,"增删改"),n("智能项的方式。")],-1),v={class:"hint-container tip"},x=t("p",{class:"hint-container-title"},"提示",-1),R=t("strong",null,"原生智能项",-1),b=t("strong",null,"原生智能项",-1),k=s('<p><strong>原生智能项</strong>的功能或许很强大，或许很鸡肋，因人而异。</p><ul><li><p>它可以根据你的文本输入，快速打开某个网页的搜索页面，并搜索输入的内容。</p></li><li><p>它可以根据你的文本输入，启动某个程序，并传递输入的命令行参数。</p></li></ul><div class="hint-container warning"><p class="hint-container-title">注意</p><p>接下来的内容比较复杂、繁琐，如果你没有上诉需求或者不喜欢折腾，可以停止阅读本章。</p></div><h2 id="匹配模式" tabindex="-1"><a class="header-anchor" href="#匹配模式" aria-hidden="true">#</a> 匹配模式</h2><p><strong>匹配</strong>指的是当前智能项会出现在搜索结果中，设定不同匹配模式可以灵活的匹配不同的输入内容</p>',5),w={class:"hint-container warning"},L=s('<p class="hint-container-title">注意</p><p>目前，<strong>原生智能项</strong>仅支持匹配<strong>文本</strong>输入类型的内容，暂时不支持<strong>工作窗口信息、文件、位图</strong>等输入类型的匹配。</p><p>这是为了避免<strong>原生智能项</strong>的相关概念变得更加复杂，同时也降低了<strong>智能模式编辑界面</strong>的复杂程度。</p>',3),z=t("strong",null,"工作窗口信息、文件、位图",-1),E=t("strong",null,"插件智能项",-1),S=s('<h3 id="_1-字符串模式-str" tabindex="-1"><a class="header-anchor" href="#_1-字符串模式-str" aria-hidden="true">#</a> 1. 字符串模式(str)</h3><p><strong>智能模式搜索框</strong>输入内容为<strong>任意字符串</strong>时匹配，输入内容<strong>原封不动地传递</strong>给启动处理程序。</p><div class="hint-container tip"><p class="hint-container-title">提示</p><p>启动处理程序具体做什么在后续会有解释，此时你只要知道它会接收<strong>传递的内容</strong>作为参数进行后续处理</p></div><h3 id="_2-正则匹配替换模式-reg" tabindex="-1"><a class="header-anchor" href="#_2-正则匹配替换模式-reg" aria-hidden="true">#</a> 2. 正则匹配替换模式(reg)</h3><p>在<strong>正则匹配替换模式</strong>下，原生智能项会有一个正则表达式二元列表，列表的每项包含一对表达式：<strong>匹配表达式</strong>，<strong>替换表达式</strong></p><p>在智能模式搜索框输入文本时，对于每个原生智能项，<strong>Starter</strong> 依次使用该项中所有<strong>匹配表达式</strong>进行正则匹配，直到有一个表达式与输入文本匹配为止。如果所有表达式都无法匹配，则该智能项不会出现在搜索结果中。</p><div class="hint-container tip"><p class="hint-container-title">提示</p><p>对某个智能项的<strong>匹配表达式</strong>的匹配顺序是<strong>从上到下</strong>，也就是排在越前面的表达式优先级越高。</p></div><p>对于这一类智能项，<strong>Starter</strong> 将使用该项的替换表达式对输入内容进行替换，替换后的结果就是所谓的<strong>传递的内容</strong>。</p><p>正则匹配与替换参考:</p>',9),q={href:"https://deerchao.cn/tutorials/regex/regex.htm#mission",target:"_blank",rel:"noopener noreferrer"},N={href:"https://orz707.gitee.io/v2/docs/commands/RegExReplace.htm",target:"_blank",rel:"noopener noreferrer"},V=s('<h3 id="_3-匹配优先级" tabindex="-1"><a class="header-anchor" href="#_3-匹配优先级" aria-hidden="true">#</a> 3. 匹配优先级</h3><p>搜索结果展示的优先级取决于匹配规则的优先级，匹配规则的优先级越高在搜索结果越靠前。在<strong>原生智能项</strong>中，所有 <code>reg</code> 匹配的规则优先级都高于 <code>str</code> 匹配的规则，而<strong>插件智能项</strong>的规则优先级更高。</p><h2 id="智能项分组" tabindex="-1"><a class="header-anchor" href="#智能项分组" aria-hidden="true">#</a> 智能项分组</h2><p><strong>原生启动项</strong>有两个分组，<strong>启动分组</strong>和<strong>搜索分组</strong>，不同分组中的<strong>启动处理程序</strong>略有区别</p><p>启动处理接下来介绍不同分组、不同条件下<strong>启动处理程序</strong>的具体功能</p><h3 id="_1-启动分组-run-with" tabindex="-1"><a class="header-anchor" href="#_1-启动分组-run-with" aria-hidden="true">#</a> 1. 启动分组(run-with)</h3><p><img src="'+h+'" alt="run-with分组" loading="lazy"></p><p><strong>启动处理程序</strong>将收到的<strong>传递内容</strong>按当前原生智能项的<strong>脚本模式</strong>执行启动。</p><div class="hint-container tip"><p class="hint-container-title">提示</p><p>脚本模式是<strong>启动分组</strong>内原生智能项<strong>特有</strong>的选项，<strong>搜索分组</strong>内原生智能项不具有该选项</p></div><ul><li>空模式(none)</li></ul><p>启动处理程序<strong>直接执行传递的内容</strong>，即直接执行 <code>Run(传递的内容)</code>，此时程序路径无效。</p>',11),y=t("code",null,"Run()",-1),B={href:"https://orz707.gitee.io/v2/docs/commands/Run.htm",target:"_blank",rel:"noopener noreferrer"},C=t("code",null,"Target",-1),T=s('<ul><li>单参数模式(arg)</li></ul><p>启动处理程序将<strong>传递的内容</strong>视为<strong>一个</strong>命令行参数(对<strong>传递的内容</strong>中的双引号进行转义，再用双引号包裹)，然后用此参数启动填写的<strong>程序路径</strong></p><p>即执行 <code>Run(程序路径 &quot;传递的内容&quot;)</code></p><ul><li>多参数模式(args)</li></ul><p>启动处理程序将<strong>传递的内容</strong>视为<strong>完整的</strong>命令行参数(对<strong>传递的内容</strong>不做任何处理)，用此参数启动填写的<strong>程序路径</strong>。</p><p>即执行 <code>Run(程序路径 传递的内容)</code></p><h3 id="_2-搜索分组-search" tabindex="-1"><a class="header-anchor" href="#_2-搜索分组-search" aria-hidden="true">#</a> 2. 搜索分组(search)</h3><p><img src="'+d+'" alt="run-with分组" loading="lazy"></p><p><strong>启动处理程序</strong>将收到的内容填充到<strong>搜索URL</strong>中&quot;{}&quot;所在位置，启动填充后的URL。</p>',9),W={class:"hint-container tip"},j=t("p",{class:"hint-container-title"},"提示",-1),I=t("code",null,"Run(Target)",-1),U={href:"https://orz707.gitee.io/v2/docs/commands/Run.htm",target:"_blank",rel:"noopener noreferrer"};function A(H,X){const e=i("RouterLink"),r=i("ExternalLinkIcon");return l(),g("div",null,[_,u,f,m,t("div",v,[x,t("p",null,[n("本章提到的内容都针对"),R,n("，非开发者只需要了解"),b,n("即可，若有兴趣请移步"),o(e,{to:"/dev/intelligent/basics.html"},{default:a(()=>[n("插件开发 - 插件智能项")]),_:1})])]),k,t("div",w,[L,t("p",null,[z,n("等输入类型，只有"),E,n("才可以设定相关的匹配条件，相关内容请移步"),o(e,{to:"/dev/intelligent/basics.html"},{default:a(()=>[n("插件开发 - 插件智能项")]),_:1})])]),S,t("ol",null,[t("li",null,[t("a",q,[n("正则表达式30分钟入门教程 (deerchao.cn)"),o(r)])]),t("li",null,[t("a",N,[n("RegExReplace - 语法 & 使用 | AutoHotkey v2"),o(r)])])]),V,t("p",null,[y,n(" 函数细节可参考"),t("a",B,[n("Run / RunWait - 语法 & 使用 "),o(r)]),n("中的 "),C,n(" 参数。")]),T,t("div",W,[j,t("p",null,[n("启动处理程序的根本功能就是 "),I,n(" 参考"),t("a",U,[n("Run / RunWait - 语法 & 使用 "),o(r)])])])])}const Z=c(p,[["render",A],["__file","concept.html.vue"]]);export{Z as default};
