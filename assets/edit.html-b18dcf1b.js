import{_ as t,W as r,X as c,Y as a,Z as e,$ as n,a2 as s,a1 as o,C as i}from"./framework-c2f75a01.js";const p="/Starter/images/edit-intelligent-mode.jpg",g={},l=o('<p>在理解了智能模式的相关概念之后，你就可以正确地配置<strong>原生智能项</strong>了</p><h2 id="智能项实例参考" tabindex="-1"><a class="header-anchor" href="#智能项实例参考" aria-hidden="true">#</a> 智能项实例参考</h2><p>右键右下角托盘图标打开菜单，点击<strong>编辑智能模式</strong>，进入<strong>智能模式编辑界面</strong></p><p><img src="'+p+'" alt="智能模式编辑界面" loading="lazy"></p><p>默认情况下，<strong>Starter</strong> 带有三个<strong>原生智能项</strong>作为你配置智能项的参考。你可以根据需要添加、编辑或删除智能项，以便根据个人习惯打开应用程序、网站等。</p><p>打开网址位于<strong>启动分组</strong>，百度搜索和谷歌搜索位于<strong>搜索分组</strong>。匹配模式都是 <code>reg</code>，即使用正则表达式进行匹配和替换。</p>',6),h=o('<h3 id="_1-打开网址" tabindex="-1"><a class="header-anchor" href="#_1-打开网址" aria-hidden="true">#</a> 1. 打开网址</h3><p>该智能项带有两对正则表达式</p><ol><li><p><code>[^\\s]*(\\.[a-zA-z]{2}[^\\s]*){2}</code>，<code>$0</code></p><p>匹配带有两个以上&quot;.&quot;的文本，不替换任何内容（实际上是将原始文本替换成原始文本）</p></li><li><p><code>https?:/{2}(.+)</code>，<code>$0</code></p><p>匹配以 <code>http://</code> 或者 <code>https://</code> 开头的文本，不替换任何内容（同上）</p></li></ol><p>脚本模式为 <code>none</code>，启动处理程序直接执行输入的内容</p><p><strong>实现的效果就是如果输入文本是网址链接，那么将使用默认浏览器打开这个链接</strong></p><h3 id="baidu-search-example" tabindex="-1"><a class="header-anchor" href="#baidu-search-example" aria-hidden="true">#</a> 2. 百度搜索</h3><p>该智能项带有一对正则表达式</p><p><code>(bd|baidu|百度)\\s+(?&lt;query&gt;.*)</code>, <code>${query}</code></p><p>匹配以 <code>bd</code>、<code>baidu</code>、<code>百度</code> 开头 + <code>空格</code> + <code>搜索词</code> 的文本，将原始文本替换为<code>搜索词</code></p><p>示例：<code>bd xxx</code> 将被替换为 <code>xxx</code>，作为<strong>传递的内容</strong>。</p><p><strong>实现的效果就是如果输入文本是 <code>bd xxx</code>，那么将使用默认浏览器进行百度搜索 <code>xxx</code></strong></p><h3 id="_3-谷歌搜索" tabindex="-1"><a class="header-anchor" href="#_3-谷歌搜索" aria-hidden="true">#</a> 3. 谷歌搜索</h3><p>该智能项带有一对正则表达式</p><p><code>(gg|谷歌)\\s+(?&lt;query&gt;.*)</code>, <code>${query}</code></p><p>与 <a href="#baidu-search-example">2. 百度搜索</a> 一样，除了开头是 <code>gg</code> 或 <code>谷歌</code></p><p><strong>实现的效果就是如果输入文本是 <code>gg xxx</code>，那么将使用默认浏览器进行百度搜索 <code>xxx</code></strong></p><h2 id="更多配置" tabindex="-1"><a class="header-anchor" href="#更多配置" aria-hidden="true">#</a> 更多配置</h2><ol><li>在 <code>reg</code> 匹配模式时，右键<strong>正则匹配替换模式列表</strong>可以打开菜单，进行添加、修改、删除等操作。</li><li>在<strong>图标文件</strong>一栏中，点击<strong>选择</strong>按钮，可以选择带有图片资源的文件作为智能项的图标，储存至用户数据。</li><li>在<strong>搜索分组</strong>时，点击<strong>获取</strong>按钮，可以尝试获取<strong>搜索URL</strong>对应的网站图标，下载至用户数据。</li></ol>',18);function x(u,_){const d=i("RouterLink");return r(),c("div",null,[l,a("p",null,[e("接下来依次解释这三个实例的具体功能与含义，可以与"),n(d,{to:"/guide/intelligent/concept.html"},{default:s(()=>[e("基本概念")]),_:1}),e("相互对照。")]),h])}const b=t(g,[["render",x],["__file","edit.html.vue"]]);export{b as default};
