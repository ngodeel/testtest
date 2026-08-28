# arXiv & Crossref Open Papers 河图学术插件

基于开放学术论文 API（Crossref / arXiv）的河图（Hetu）脚本全功能插件，支持在端侧脱网/在线检索全球学术论文、分类浏览与元数据解析。

## 特性
- **开源免费**：基于开放文献 DOI 与 Crossref 开源 API，无需任何个人 Key；
- **全生命周期方法支持**：
  - `search(query, page)`：学术论文关键词全文检索；
  - `getExploreConfig()`：内置 AI、ML、量子计算、生物信息、大模型等学科分类；
  - `explore(filterId, page)`：学科分类定向探索；
  - `getDetail(id)`：论文详情与摘要解析；
  - `getChapters(id)`：官方开放论文全文与 PDF 链接解析；
  - `getContent(id, chapterId)`：论文正文及官方文献 DOI 链接生成。

## 目录结构
- `manifest.json`：插件标准元数据声明（`id: org.crossref.arxiv.paper`, `contentType: paper`）；
- `source.ht`：图灵完备的河图执行脚本源码；
- `README.md`：插件使用与接口说明。
