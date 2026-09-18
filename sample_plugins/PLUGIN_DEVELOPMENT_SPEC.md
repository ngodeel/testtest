# PyroMagma 超级通用河图插件开发规范白皮书 (Hetu Plugin Development Specification)

本规范白皮书旨在为 PyroMagma 平台的所有河图脚本 (`*.ht`) 插件开发者提供**标准化、无沟通成本**的完整接口文档、数据契约与 Hook 规范。

---

## 一、 插件与宿主分工铁律

1. **宿主 App (`pyro_magma`) 纯空壳调度**: 仅作为通用调度容器与路由中枢，严禁硬编码特定媒体的解析逻辑。
2. **插件 (`source.ht`) 100% 负责数据清洗**: 插件存在的唯一价值，就是将外部千奇百怪的网络响应（HTML, JSON, XML），清洗并组装为符合本白皮书规范的**标准数据契约对象 (Standard DTO)**。
3. **彻底隔离**: 插件运行在独立的 Hetu 脚本虚拟机沙盒中，通过 `module:http`, `module:host_webview`, `module:storage` 进行安全交互。

---

## 二、 完整 Hook 接口与方法签名汇总表

每一个完整的 Hetu Script 插件可以实现以下全部或部分 Hook 方法：

| Hook 方法 | 必选/可选 | 调用时机 | 核心职责 |
| :--- | :--- | :--- | :--- |
| `manifest()` | **必选** | 插件加载装配时 | 返回插件元数据、标识符与能力声明（`supportsSearch`, `supportsScrobble` 等） |
| `init(context)` | **必选** | 插件实例化时 | 初始化 HTTP 客户端或配置全局 Header / User-Agent |
| `getConfigSchema()` | 可选 | 渲染设置界面时 | 返回用户配置项表单（API Key, Market, 代理设置等） |
| `getExploreConfig()`| 可选 | 打开发现探索页时 | 返回分类目录列表（Hot, Latest, Category 等） |
| `search(query, page, {config})` | 可选 | 用户搜索/加载 Feed 流时 | 核心检索 Hook，将外部 API 清洗为标准数据条目列表 |
| `explore(category, page, {config})` | 可选 | 切换探索分类时 | 按分类拉取清洗数据条目列表 |
| `getDetail(contentId, {config})` | 可选 | 进入三级详情页时 | 拉取完整细粒度元数据（如为空则复用 `search` 返回值） |
| `push(contentId, payload, {config})` | 可选 | 用户主动发起反推时 | **主动推送 Hook**：连通外部 API（如 Zotero）存入知识库 |
| `scrobble(contentId, payload, {config})` | 可选 | **后台进度达标时自动触发** | **静默打卡 Hook**：无感上报听歌/观影/追漫进度（Last.fm, Trakt, Bangumi, Readwise） |
| `pull(query, {config})` | 可选 | 执行增量拉取时 | 从外部同步历史记录或播放列表 |

---

## 三、 标准条目与 Author DTO 数据契约

`search()` 与 `explore()` 返回的列表中的每个条目 Map，**必须严格遵循**以下 Key 标准：

```json
{
  "id": "10.1038/s41591-018-0300-7",
  "title": "High-performance medicine: human and AI convergence",

  // 图像资源规范：强行拆分为小缩略图与 4K 高清大图
  "thumbnail": "https://example.com/thumb_small.jpg",  // 瀑布流/沉浸流卡片列表秒开用（几十 KB）
  "url": "https://example.com/high_res_4k.jpg",          // 全屏预览/详情页按需拉取用

  // 标准 Author DTO 契约 (必须 100% 完整拼装)
  "author": {
    "id": "author_openalex_123",
    "name": "Eric J. Topol",
    "avatar": "https://example.com/avatar.jpg",
    "bio": "Scripps Research Institute",
    "homeUrl": "https://openalex.org/authors/A5084515381",
    "authorUrl": "author:author_openalex_123",

    // 多模态领域统计数据 (根据领域填充)
    "stats": {
      "worksCount": 42,
      "followersCount": 12800,
      "readsCount": 350000,        // 图书/小说/漫画阅读数
      "listenersCount": 92000,     // 音频/播客听众数
      "viewsCount": 1500000,       // 视频/影视播放数
      "downloadsCount": 8900,      // 壁纸/摄影下载数
      "citationsCount": 420        // 学术论文被引量
    }
  },

  "description": "Full abstract, intro or content text...",
  "category": "Cardiology & AI",
  "tags": ["AI", "Medicine", "DeepLearning"],
  "contentType": "paper",          // 媒体类型: wallpaper / paper / novel / comic / audio / video / news
  "published": "2024-01-01"
}
```

---

## 四、 静默打卡 (Scrobble) 与 主动推送 (Push) 协议区别

### 1. 主动推送 (`push` Hook)
- **触发入口**：用户在界面（如论文详情页）点击“推送存入 Zotero”按钮。
- **数据流**：界面弹出选择框 -> 派发 `GenericPushIntent` -> 宿主调用对应插件的 `push(contentId, payload)`。

### 2. 后台静默打卡 (`scrobble` Hook)
- **触发入口**：**零点击，完全无感**。
- **能力声明**：插件的 `manifest()` 必须声明：
  ```javascript
  'supportsScrobble': true,
  'scrobbleTargetTypes': ['audio', 'music', 'video', 'comic', 'novel'],
  'scrobbleThreshold': { 'dwellSeconds': 30, 'progressRatio': 0.8 }
  ```
- **数据流**：阅读器/播放器后台持续通过 `BehaviorTracker` 抛出 `BehaviorEvent` -> 事件总线 `BehaviorEventBus` 判定进度/停留时长达标 -> 后台 Worker 自动调用插件的 `scrobble(contentId, payload)` 提交打卡到 Last.fm / Trakt / Bangumi / Readwise！

---

## 五、 参考模板与代码范例

- **超级通用插件标准模板**：[STANDARD_PLUGIN_TEMPLATE.ht](file:///c:/Users/Ngokel/Desktop/en/designed/wallpaper/packages/sample_plugins/STANDARD_PLUGIN_TEMPLATE.ht)
- **示例打卡插件**：
  - [lastfm_scrobble_plugin/source.ht](file:///c:/Users/Ngokel/Desktop/en/designed/wallpaper/packages/sample_plugins/lastfm_scrobble_plugin/source.ht)
  - [trakt_scrobble_plugin/source.ht](file:///c:/Users/Ngokel/Desktop/en/designed/wallpaper/packages/sample_plugins/trakt_scrobble_plugin/source.ht)
  - [bangumi_scrobble_plugin/source.ht](file:///c:/Users/Ngokel/Desktop/en/designed/wallpaper/packages/sample_plugins/bangumi_scrobble_plugin/source.ht)
  - [readwise_sync_plugin/source.ht](file:///c:/Users/Ngokel/Desktop/en/designed/wallpaper/packages/sample_plugins/readwise_sync_plugin/source.ht)
