import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/models/browser_model.dart';
import 'package:flutter_browser/models/search_engine_model.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'package:flutter_browser/util.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../models/window_model.dart';
import '../../project_info_popup.dart';

class CrossPlatformSettings extends StatefulWidget {
  const CrossPlatformSettings({super.key});

  @override
  State<CrossPlatformSettings> createState() => _CrossPlatformSettingsState();
}

class _CrossPlatformSettingsState extends State<CrossPlatformSettings> {
  final TextEditingController _customHomePageController =
      TextEditingController();
  final TextEditingController _customUserAgentController =
      TextEditingController();

  @override
  void dispose() {
    _customHomePageController.dispose();
    _customUserAgentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final windowModel = Provider.of<WindowModel>(context, listen: true);
    final children = _buildBaseSettings();
    if (windowModel.webViewTabs.isNotEmpty) {
      children.addAll(_buildWebViewTabSettings());
    }

    return ListView(
      children: children,
    );
  }

  List<Widget> _buildBaseSettings() {
    final browserModel = Provider.of<BrowserModel>(context, listen: true);
    final windowModel = Provider.of<WindowModel>(context, listen: true);
    final settings = browserModel.getSettings();

    var widgets = <Widget>[
      const ListTile(
        title: Text("常规设置"),
        enabled: false,
      ),
      ListTile(
        title: const Text("搜索引擎"),
        subtitle: Text(settings.searchEngine.name),
        trailing: DropdownButton<SearchEngineModel>(
          hint: const Text("搜索引擎"),
          onChanged: (value) {
            setState(() {
              if (value != null) {
                settings.searchEngine = value;
              }
              browserModel.updateSettings(settings);
            });
          },
          value: settings.searchEngine,
          items: SearchEngines.map((searchEngine) {
            return DropdownMenuItem(
              value: searchEngine,
              child: Text(searchEngine.name),
            );
          }).toList(),
        ),
      ),
      ListTile(
        title: const Text("主页"),
        subtitle: Text(settings.homePageEnabled
            ? (settings.customUrlHomePage.isEmpty
                ? "开"
                : settings.customUrlHomePage)
            : "关"),
        onTap: () {
          _customHomePageController.text = settings.customUrlHomePage;

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(0.0),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    StatefulBuilder(
                      builder: (context, setState) {
                        return SwitchListTile(
                          title: Text(settings.homePageEnabled ? "开" : "关"),
                          value: settings.homePageEnabled,
                          onChanged: (value) {
                            setState(() {
                              settings.homePageEnabled = value;
                              browserModel.updateSettings(settings);
                            });
                          },
                        );
                      },
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      return ListTile(
                        enabled: settings.homePageEnabled,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                onSubmitted: (value) {
                                  setState(() {
                                    settings.customUrlHomePage = value;
                                    browserModel.updateSettings(settings);
                                    Navigator.pop(context);
                                  });
                                },
                                keyboardType: TextInputType.url,
                                decoration: const InputDecoration(
                                    hintText: '自定义主页网址'),
                                controller: _customHomePageController,
                              ),
                            )
                          ],
                        ),
                      );
                    })
                  ],
                ),
              );
            },
          );
        },
      ),
      FutureBuilder(
        future: InAppWebViewController.getDefaultUserAgent(),
        builder: (context, snapshot) {
          var deafultUserAgent = "";
          if (snapshot.hasData) {
            deafultUserAgent = snapshot.data as String;
          }

          return ListTile(
            title: const Text("默认 User Agent"),
            subtitle: Text(deafultUserAgent),
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: deafultUserAgent));
            },
          );
        },
      ),
      SwitchListTile(
        title: const Text("启用调试"),
        subtitle: const Text(
            "允许调试本应用中任意 WebView 加载的网页内容。在 iOS 16.4 以下版本中，调试模式始终开启。"),
        value: settings.debuggingEnabled,
        onChanged: (value) {
          setState(() {
            settings.debuggingEnabled = value;
            browserModel.updateSettings(settings);
            if (windowModel.webViewTabs.isNotEmpty) {
              var webViewModel = windowModel.getCurrentTab()?.webViewModel;
              if (Util.isAndroid()) {
                InAppWebViewController.setWebContentsDebuggingEnabled(
                    settings.debuggingEnabled);
              }
              webViewModel?.settings?.isInspectable = settings.debuggingEnabled;
              webViewModel?.webViewController?.setSettings(
                  settings: webViewModel.settings ?? InAppWebViewSettings());
              windowModel.saveInfo();
            }
          });
        },
      ),
      FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          String packageDescription = "";
          if (snapshot.hasData) {
            PackageInfo packageInfo = snapshot.data as PackageInfo;
            packageDescription =
                "包名：${packageInfo.packageName}\n版本：${packageInfo.version}\n构建号：${packageInfo.buildNumber}";
          }
          return ListTile(
            title: const Text("应用包信息"),
            subtitle: Text(packageDescription),
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: packageDescription));
            },
          );
        },
      ),
      ListTile(
        leading: Container(
          height: 35,
          width: 35,
          margin: const EdgeInsets.only(top: 6.0, left: 6.0),
          child: const CircleAvatar(
              backgroundImage: AssetImage("assets/icon/icon.png")),
        ),
        title: const Text("Flutter InAppWebView 项目"),
        subtitle: const Text(
            "https://github.com/pichillilorenzo/flutter_inappwebview"),
        trailing: const Icon(Icons.arrow_forward),
        onLongPress: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return const ProjectInfoPopup();
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return const ProjectInfoPopup();
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      )
    ];

    if (Util.isAndroid()) {
      widgets.addAll(<Widget>[
        FutureBuilder(
          future: InAppWebViewController.getCurrentWebViewPackage(),
          builder: (context, snapshot) {
            String packageDescription = "";
            if (snapshot.hasData) {
              WebViewPackageInfo packageInfo =
                  snapshot.data as WebViewPackageInfo;
              packageDescription =
                  "${packageInfo.packageName ?? ""} - ${packageInfo.versionName ?? ""}";
            }
            return ListTile(
              title: const Text("WebView 组件信息"),
              subtitle: Text(packageDescription),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: packageDescription));
              },
            );
          },
        )
      ]);
    }

    return widgets;
  }

  List<Widget> _buildWebViewTabSettings() {
    var windowModel = Provider.of<WindowModel>(context, listen: true);
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = currentWebViewModel.webViewController;

    var widgets = <Widget>[
      const ListTile(
        title: Text("当前 WebView 设置"),
        enabled: false,
      ),
      SwitchListTile(
        title: const Text("启用 JavaScript"),
        subtitle:
            const Text("设置 WebView 是否启用 JavaScript。"),
        value: currentWebViewModel.settings?.javaScriptEnabled ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.javaScriptEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("启用缓存"),
        subtitle:
            const Text("设置 WebView 是否使用浏览器缓存。"),
        value: currentWebViewModel.settings?.cacheEnabled ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.cacheEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      StatefulBuilder(
        builder: (context, setState) {
          return ListTile(
            title: const Text("自定义 User Agent"),
            subtitle: Text(
                currentWebViewModel.settings?.userAgent?.isNotEmpty ?? false
                    ? currentWebViewModel.settings!.userAgent!
                    : "设置自定义 User Agent…"),
            onTap: () {
              _customUserAgentController.text =
                  currentWebViewModel.settings?.userAgent ?? "";

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: const EdgeInsets.all(0.0),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  onSubmitted: (value) async {
                                    currentWebViewModel.settings?.userAgent =
                                        value;
                                    webViewController?.setSettings(
                                        settings:
                                            currentWebViewModel.settings ??
                                                InAppWebViewSettings());
                                    currentWebViewModel.settings =
                                        await webViewController?.getSettings();
                                    windowModel.saveInfo();
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                  decoration: const InputDecoration(
                                      hintText: '自定义 User Agent'),
                                  controller: _customUserAgentController,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.go,
                                  maxLines: null,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      SwitchListTile(
        title: const Text("支持缩放"),
        subtitle: const Text(
            "设置 WebView 是否支持通过屏幕缩放控件与手势进行缩放。"),
        value: currentWebViewModel.settings?.supportZoom ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.supportZoom = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("媒体播放需用户手势"),
        subtitle: const Text(
            "设置 WebView 是否阻止 HTML5 音频或视频自动播放。"),
        value: currentWebViewModel.settings?.mediaPlaybackRequiresUserGesture ??
            true,
        onChanged: (value) async {
          currentWebViewModel.settings?.mediaPlaybackRequiresUserGesture =
              value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("显示纵向滚动条"),
        subtitle: const Text(
            "设置是否绘制纵向滚动条。"),
        value: currentWebViewModel.settings?.verticalScrollBarEnabled ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.verticalScrollBarEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("显示横向滚动条"),
        subtitle: const Text(
            "设置是否绘制横向滚动条。"),
        value: currentWebViewModel.settings?.horizontalScrollBarEnabled ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.horizontalScrollBarEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("禁用纵向滚动"),
        subtitle: const Text(
            "设置是否允许纵向滚动。"),
        value: currentWebViewModel.settings?.disableVerticalScroll ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.disableVerticalScroll = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("禁用横向滚动"),
        subtitle: const Text(
            "设置是否允许横向滚动。"),
        value: currentWebViewModel.settings?.disableHorizontalScroll ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.disableHorizontalScroll = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("禁用上下文菜单"),
        subtitle:
            const Text("设置是否启用上下文菜单。"),
        value: currentWebViewModel.settings?.disableContextMenu ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.disableContextMenu = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("最小字号"),
        subtitle: const Text("设置最小字体大小。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue:
                currentWebViewModel.settings?.minimumFontSize.toString(),
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.minimumFontSize = int.parse(value);
              webViewController?.setSettings(
                  settings:
                      currentWebViewModel.settings ?? InAppWebViewSettings());
              currentWebViewModel.settings =
                  await webViewController?.getSettings();
              windowModel.saveInfo();
              setState(() {});
            },
          ),
        ),
      ),
      SwitchListTile(
        title: const Text("允许 file URL 访问其他 file URL"),
        subtitle: const Text(
            "设置在 file 协议页面中运行的 JavaScript 是否可访问其他 file 协议资源。"),
        value:
            currentWebViewModel.settings?.allowFileAccessFromFileURLs ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.allowFileAccessFromFileURLs = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("允许 file URL 跨源访问"),
        subtitle: const Text(
            "设置在 file 协议页面中运行的 JavaScript 是否可访问任意来源的内容。"),
        value: currentWebViewModel.settings?.allowUniversalAccessFromFileURLs ??
            false,
        onChanged: (value) async {
          currentWebViewModel.settings?.allowUniversalAccessFromFileURLs =
              value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
    ];

    return widgets;
  }
}
