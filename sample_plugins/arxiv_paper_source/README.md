# arXiv & Crossref Open Papers 河图学术插件

基于开放学术文献 API（Crossref / OpenAlex / arXiv）的河图（Hetu）脚本全功能插件，支持在端侧脱网/在线检索全球学术论文、分类浏览、学者主页档案与作者作品流。

## 契约能力
- **开源免费 & 礼貌池加速**：支持通过 `getConfigSchema()` 配置个人 Email 进入 OpenAlex 礼貌加速池；
- **全契约函数支持**：
  - `getConfigSchema()`：声明动态用户配置表单；
  - `search(query, page, {config})`：学术论文关键词全文检索，支持自动拦截 `author:` 前缀定向拉取学者作品；
  - `getExploreConfig()`：内置 AI、ML、量子计算、生物信息、大模型、脑机神经等学科分类；
  - `explore(filterId, page, {config})`：学科分类定向探索；
  - `getDetail(id, {config})`：论文详情与摘要解析；
  - `getAuthorProfile(authorKey, {config})`：学者主页档案（展示机构、发表量、总被引数）；
  - `getAuthorWorks(authorKey, page, {config})`：学者名下完整学术作品流。

## 目录结构
- `manifest.json`：插件标准元数据声明（`id: org.crossref.arxiv.paper`, `contentType: paper`, `version: 1.1.0`）；
- `source.ht`：图灵完备的河图执行脚本源码；
- `test_paper_plugin.dart`：插件本地独立验证脚本；
- `README.md`：插件使用与接口说明。

