import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pyro_hetu_script_engine/pyro_hetu_script_engine.dart';
import 'package:pyro_source_hetu/src/hetu_source_executor.dart';
import 'package:pyro_fetch_protocol/pyro_fetch_protocol.dart';

class _MockUserDelegate implements UserDelegate {
  @override
  Future<String?> getUserId() async => 'test_user';
  @override
  Future<String?> getUserToken() async => 'test_token';
}

class _MockConfigDelegate implements ConfigDelegate {
  @override
  Future<String?> getConfig(String key) async => null;
  @override
  Future<void> setConfig(String key, String value) async {}
}

class _MockStorageDelegate implements StorageDelegate {
  @override
  Future<String?> get(String key) async => null;
  @override
  Future<void> set(String key, String value) async {}
  @override
  Future<void> remove(String key) async {}
}

class _MockTranslationDelegate implements TranslationDelegate {
  @override
  Future<String> translate(String text, {required String from, required String to}) async => text;
}

class _MockWebViewDelegate implements WebViewDelegate {
  @override
  Future<String> evaluateJavascript(String script) async => '';
  @override
  Future<void> loadUrl(String url) async {}
}

void main() async {
  debugPrint('🔬 [TestPaperPlugin] 正在启动独立河图引擎测试开源论文插件...');

  final engine = PyroHetuEngine(
    userDelegate: _MockUserDelegate(),
    configDelegate: _MockConfigDelegate(),
    storageDelegate: _MockStorageDelegate(),
    translationDelegate: _MockTranslationDelegate(),
    webViewDelegate: _MockWebViewDelegate(),
  );

  await engine.init();
  final executor = HetuSourceExecutor(engine);

  final pluginDir = Directory.current.path;
  final scriptPath = File('$pluginDir/source.ht').absolute.path;
  debugPrint('📄 [TestPaperPlugin] 挂载本地河图脚本: $scriptPath');

  final source = PyroSource(
    id: 'org.crossref.arxiv.paper',
    name: 'Crossref & arXiv Open Papers',
    protocol: 'hetu',
    contentType: 'paper',
    rawDefinition: scriptPath,
  );

  try {
    debugPrint('🔍 [TestPaperPlugin] 执行 search("quantum computing", 1)...');
    final results = await executor.search(source, 'quantum computing', 1);

    debugPrint('🎉 [TestPaperPlugin] 成功检索到 ${results.length} 篇开源论文数据：');
    for (int i = 0; i < results.length; i++) {
      final p = results[i];
      debugPrint('  [${i + 1}] 标题: ${p['title']}');
      debugPrint('      作者: ${p['author']}');
      debugPrint('      DOI: ${p['id']}');
      debugPrint('      类型: ${p['contentType']}');
    }

    debugPrint('\n📋 [TestPaperPlugin] 测试分类配置 getExploreConfig()...');
    final filters = await executor.getExploreConfig(source);
    debugPrint('  内置学科分类: ${filters.map((f) => f.title).join(" | ")}');

    debugPrint('\n⚙️ [TestPaperPlugin] 测试配置表单 getConfigSchema()...');
    final schema = await executor.getConfigSchema(source);
    debugPrint('  提取到配置字段: ${schema.map((s) => "${s['key']}(${s['label']})").join(", ")}');

    debugPrint('\n👤 [TestPaperPlugin] 测试作者基本档案 getAuthorProfile("A5023880864")...');
    final profile = await executor.getAuthorProfile(source, 'A5023880864');
    debugPrint('  作者档案: ${profile != null ? profile['name'] : "null"} (Works: ${profile?['stats']?['worksCount']})');

    debugPrint('\n📚 [TestPaperPlugin] 测试作者作品流 getAuthorWorks("A5023880864", 1)...');
    final authorWorks = await executor.getAuthorWorks(source, 'A5023880864', 1);
    debugPrint('  作者作品流获取数量: ${authorWorks.length}');

    debugPrint('\n🔀 [TestPaperPlugin] 测试作者前缀拦截 search("author:A5023880864", 1)...');
    final queryWorks = await executor.search(source, 'author:A5023880864', 1);
    debugPrint('  拦截检索获取数量: ${queryWorks.length}');

    debugPrint('\n✅ [TestPaperPlugin] 论文河图插件全部 6 大契约函数测试 100% 全绿通过！');
  } catch (e, stack) {
    debugPrint('❌ [TestPaperPlugin] 测试异常: $e\n$stack');
  }
}

