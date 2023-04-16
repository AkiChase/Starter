const e=JSON.parse('{"key":"v-483ba9ea","path":"/api/utils/ImagePutHelper.html","title":"ImagePutHelper","lang":"zh-CN","frontmatter":{"title":"ImagePutHelper","author":"ruchuby","order":2,"date":"2023-04-14T00:00:00.000Z","description":"::: warning 本文内容列举翻译API内容，仅供参考。 ::: 具体使用请参考：\\r简单、高效、实用的图片操作库 - AutoAHK (https://www.autoahk.com/archives/37246); \\rImagePut —— 裁剪、缩放 & 其他选项 (../../dev/others/image-put-doc-1.md); ...","head":[["meta",{"property":"og:url","content":"https://ruchuby.github.io/Starter/Starter/api/utils/ImagePutHelper.html"}],["meta",{"property":"og:site_name","content":"Starter文档"}],["meta",{"property":"og:title","content":"ImagePutHelper"}],["meta",{"property":"og:description","content":"::: warning 本文内容列举翻译API内容，仅供参考。 ::: 具体使用请参考：\\r简单、高效、实用的图片操作库 - AutoAHK (https://www.autoahk.com/archives/37246); \\rImagePut —— 裁剪、缩放 & 其他选项 (../../dev/others/image-put-doc-1.md); ..."}],["meta",{"property":"og:type","content":"article"}],["meta",{"property":"og:locale","content":"zh-CN"}],["meta",{"property":"og:updated_time","content":"2023-04-16T08:03:45.000Z"}],["meta",{"property":"article:author","content":"ruchuby"}],["meta",{"property":"article:published_time","content":"2023-04-14T00:00:00.000Z"}],["meta",{"property":"article:modified_time","content":"2023-04-16T08:03:45.000Z"}],["script",{"type":"application/ld+json"},"{\\"@context\\":\\"https://schema.org\\",\\"@type\\":\\"Article\\",\\"headline\\":\\"ImagePutHelper\\",\\"image\\":[\\"\\"],\\"datePublished\\":\\"2023-04-14T00:00:00.000Z\\",\\"dateModified\\":\\"2023-04-16T08:03:45.000Z\\",\\"author\\":[{\\"@type\\":\\"Person\\",\\"name\\":\\"ruchuby\\"}]}"]]},"headers":[{"level":2,"title":"ImagePutBase64(image, extension := \\"\\", quality := \\"\\")","slug":"imageputbase64-image-extension-quality","link":"#imageputbase64-image-extension-quality","children":[]},{"level":2,"title":"ImagePutBitmap(image)","slug":"imageputbitmap-image","link":"#imageputbitmap-image","children":[]},{"level":2,"title":"ImagePutBuffer(image)","slug":"imageputbuffer-image","link":"#imageputbuffer-image","children":[]},{"level":2,"title":"ImagePutClipboard(image)","slug":"imageputclipboard-image","link":"#imageputclipboard-image","children":[]},{"level":2,"title":"ImagePutCursor(image, xHotspot := \\"\\", yHotspot := \\"\\")","slug":"imageputcursor-image-xhotspot-yhotspot","link":"#imageputcursor-image-xhotspot-yhotspot","children":[]},{"level":2,"title":"ImagePutDC(image, alpha := \\"\\")","slug":"imageputdc-image-alpha","link":"#imageputdc-image-alpha","children":[]},{"level":2,"title":"ImagePutDesktop(image)","slug":"imageputdesktop-image","link":"#imageputdesktop-image","children":[]},{"level":2,"title":"ImagePutExplorer(image, default := \\"\\")","slug":"imageputexplorer-image-default","link":"#imageputexplorer-image-default","children":[]},{"level":2,"title":"ImagePutFile(image, filepath := \\"\\", quality := \\"\\")","slug":"imageputfile-image-filepath-quality","link":"#imageputfile-image-filepath-quality","children":[]},{"level":2,"title":"ImagePutFormData(image, boundary := \\"ImagePut-abcdef\\")","slug":"imageputformdata-image-boundary-imageput-abcdef","link":"#imageputformdata-image-boundary-imageput-abcdef","children":[]},{"level":2,"title":"ImagePutHBitmap(image, alpha := \\"\\")","slug":"imageputhbitmap-image-alpha","link":"#imageputhbitmap-image-alpha","children":[]},{"level":2,"title":"ImagePutHex(image, extension := \\"\\", quality := \\"\\")","slug":"imageputhex-image-extension-quality","link":"#imageputhex-image-extension-quality","children":[]},{"level":2,"title":"ImagePutHIcon(image)","slug":"imageputhicon-image","link":"#imageputhicon-image","children":[]},{"level":2,"title":"ImagePutRandomAccessStream(image, extension := \\"\\", quality := \\"\\")","slug":"imageputrandomaccessstream-image-extension-quality","link":"#imageputrandomaccessstream-image-extension-quality","children":[]},{"level":2,"title":"ImagePutSafeArray(image, extension := \\"\\", quality := \\"\\")","slug":"imageputsafearray-image-extension-quality","link":"#imageputsafearray-image-extension-quality","children":[]},{"level":2,"title":"ImagePutScreenshot(image, screenshot := \\"\\", alpha := \\"\\")","slug":"imageputscreenshot-image-screenshot-alpha","link":"#imageputscreenshot-image-screenshot-alpha","children":[]},{"level":2,"title":"ImagePutStream(image, extension := \\"\\", quality := \\"\\")","slug":"imageputstream-image-extension-quality","link":"#imageputstream-image-extension-quality","children":[]},{"level":2,"title":"ImagePutURI(image, extension := \\"\\", quality := \\"\\")","slug":"imageputuri-image-extension-quality","link":"#imageputuri-image-extension-quality","children":[]},{"level":2,"title":"ImagePutWallpaper(image)","slug":"imageputwallpaper-image","link":"#imageputwallpaper-image","children":[]},{"level":2,"title":"ImagePutWICBitmap(image)","slug":"imageputwicbitmap-image","link":"#imageputwicbitmap-image","children":[]},{"level":2,"title":"ImagePutWindow(image, title := \\"\\", pos := \\"\\", style := 0x82C80000, styleEx := 0x9, parent := \\"\\")","slug":"imageputwindow-image-title-pos-style-0x82c80000-styleex-0x9-parent","link":"#imageputwindow-image-title-pos-style-0x82c80000-styleex-0x9-parent","children":[]},{"level":2,"title":"ImageShow(image, title := \\"\\", pos := \\"\\", style := 0x90000000, styleEx := 0x80088, parent := \\"\\")","slug":"imageshow-image-title-pos-style-0x90000000-styleex-0x80088-parent","link":"#imageshow-image-title-pos-style-0x90000000-styleex-0x80088-parent","children":[]},{"level":2,"title":"ImageDestroy(image)","slug":"imagedestroy-image","link":"#imagedestroy-image","children":[]},{"level":2,"title":"ImageWidth(image)","slug":"imagewidth-image","link":"#imagewidth-image","children":[]},{"level":2,"title":"ImageHeight(image)","slug":"imageheight-image","link":"#imageheight-image","children":[]}],"git":{"createdTime":1681630441000,"updatedTime":1681632225000,"contributors":[{"name":"如初","email":"1003019131@qq.com","commits":2}]},"readingTime":{"minutes":5.7,"words":1711},"filePathRelative":"api/utils/ImagePutHelper.md","localizedDate":"2023年4月14日","autoDesc":true,"excerpt":""}');export{e as data};
