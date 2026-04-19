import 'package:flutter/material.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../../models/window_model.dart';

class AndroidSettings extends StatefulWidget {
  const AndroidSettings({super.key});

  @override
  State<AndroidSettings> createState() => _AndroidSettingsState();
}

class _AndroidSettingsState extends State<AndroidSettings> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _buildAndroidWebViewTabSettings(),
    );
  }

  List<Widget> _buildAndroidWebViewTabSettings() {
    final windowModel = Provider.of<WindowModel>(context, listen: true);
    if (windowModel.webViewTabs.isEmpty) {
      return [];
    }
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = currentWebViewModel.webViewController;

    var widgets = <Widget>[
      const ListTile(
        title: Text("当前 WebView（Android）设置"),
        enabled: false,
      ),
      ListTile(
        title: const Text("文字缩放"),
        subtitle: const Text("以百分比设置页面文字缩放。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.textZoom.toString(),
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.textZoom = int.parse(value);
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
        title: const Text("清除会话缓存"),
        subtitle: const Text(
            "设置是否在新窗口打开前清除会话 Cookie 缓存。"),
        value: currentWebViewModel.settings?.clearSessionCache ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.clearSessionCache = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("内置缩放控件"),
        subtitle: const Text(
            "设置 WebView 是否使用内置缩放机制。"),
        value: currentWebViewModel.settings?.builtInZoomControls ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.builtInZoomControls = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("显示缩放控件"),
        subtitle: const Text(
            "设置使用内置缩放机制时 WebView 是否显示屏幕缩放控件。"),
        value: currentWebViewModel.settings?.displayZoomControls ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.displayZoomControls = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("数据库存储 API"),
        subtitle: const Text(
            "设置是否启用数据库存储 API。"),
        value: currentWebViewModel.settings?.databaseEnabled ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.databaseEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("DOM 存储 API"),
        subtitle:
            const Text("设置是否启用 DOM 存储 API。"),
        value: currentWebViewModel.settings?.domStorageEnabled ?? true,
        onChanged: (value) {
          setState(() {
            currentWebViewModel.settings?.domStorageEnabled = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            windowModel.saveInfo();
          });
        },
      ),
      SwitchListTile(
        title: const Text("使用宽视口"),
        subtitle: const Text(
            "设置 WebView 是否支持 HTML \"viewport\" meta 标签，或是否使用宽视口。"),
        value: currentWebViewModel.settings?.useWideViewPort ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.useWideViewPort = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      const ListTile(
        title: Text("混合内容模式"),
        subtitle: Text(
            "配置当安全来源尝试从不安全来源加载资源时 WebView 的行为。"),
      ),
      Container(
        padding: const EdgeInsets.only(
            left: 20.0, top: 0.0, right: 20.0, bottom: 10.0),
        alignment: Alignment.center,
        child: DropdownButton<MixedContentMode>(
          hint: const Text("混合内容模式"),
          onChanged: (value) async {
            currentWebViewModel.settings?.mixedContentMode = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            currentWebViewModel.settings =
                await webViewController?.getSettings();
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.mixedContentMode,
          items: MixedContentMode.values.map((mixedContentMode) {
            return DropdownMenuItem<MixedContentMode>(
              value: mixedContentMode,
              child: Text(
                mixedContentMode.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      SwitchListTile(
        title: const Text("允许访问内容"),
        subtitle: const Text(
            "启用或禁用 WebView 内的 content URL 访问。content URL 访问允许 WebView 从系统已安装的内容提供程序加载内容。"),
        value: currentWebViewModel.settings?.allowContentAccess ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.allowContentAccess = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("允许文件访问"),
        subtitle: const Text(
            "启用或禁用 WebView 内的文件访问。注意：仅影响文件系统访问。"),
        value: currentWebViewModel.settings?.allowFileAccess ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.allowFileAccess = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      const ListTile(
        title: Text("应用缓存路径"),
        subtitle: Text(
            "设置 Application Cache 文件路径。要启用 Application Cache API，必须将此项设为应用可写入的路径。"),
      ),
      Container(
        padding: const EdgeInsets.only(
            left: 20.0, top: 0.0, right: 20.0, bottom: 20.0),
        alignment: Alignment.center,
        child: TextFormField(
          initialValue: currentWebViewModel.settings?.appCachePath,
          keyboardType: TextInputType.text,
          onFieldSubmitted: (value) async {
            currentWebViewModel.settings?.appCachePath = value.trim();
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
      SwitchListTile(
        title: const Text("阻止网络图片"),
        subtitle: const Text(
            "设置 WebView 是否阻止从网络加载图片资源（包括通过 http 与 https 访问的资源）。"),
        value: currentWebViewModel.settings?.blockNetworkImage ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.blockNetworkImage = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("阻止网络加载"),
        subtitle: const Text(
            "设置 WebView 是否不从网络加载资源。"),
        value: currentWebViewModel.settings?.blockNetworkLoads ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.blockNetworkLoads = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      const ListTile(
        title: Text("缓存模式"),
        subtitle: Text(
            "覆盖缓存使用方式。缓存策略基于导航类型。"),
      ),
      Container(
        padding: const EdgeInsets.only(
            left: 20.0, top: 0.0, right: 20.0, bottom: 10.0),
        alignment: Alignment.center,
        child: DropdownButton<CacheMode>(
          hint: const Text("缓存模式"),
          onChanged: (value) async {
            currentWebViewModel.settings?.cacheMode = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            currentWebViewModel.settings =
                await webViewController?.getSettings();
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.cacheMode,
          items: CacheMode.values.map((cacheMode) {
            return DropdownMenuItem<CacheMode>(
              value: cacheMode,
              child: Text(
                cacheMode.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      ListTile(
        title: const Text("草书字体族"),
        subtitle: const Text("设置草书字体族名称。"),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.cursiveFontFamily,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.cursiveFontFamily = value;
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
      ListTile(
        title: const Text("默认等宽字体大小"),
        subtitle: const Text("设置默认等宽字体大小。"),
        trailing: SizedBox(
          width: 50,
          child: TextFormField(
            initialValue:
                currentWebViewModel.settings?.defaultFixedFontSize.toString(),
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.defaultFixedFontSize =
                  int.parse(value);
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
      ListTile(
        title: const Text("默认字体大小"),
        subtitle: const Text("设置默认字体大小。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue:
                currentWebViewModel.settings?.defaultFontSize.toString(),
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.defaultFontSize = int.parse(value);
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
      ListTile(
        title: const Text("默认文本编码名称"),
        subtitle: const Text(
            "设置解码 HTML 页面时使用的默认文本编码名称。"),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.defaultTextEncodingName,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.defaultTextEncodingName = value;
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
      const ListTile(
        title: Text("已禁用的操作模式菜单项"),
        subtitle: Text(
            "根据 menuItems 标志禁用操作模式菜单项。"),
      ),
      Container(
        padding: const EdgeInsets.only(
            left: 20.0, top: 0.0, right: 20.0, bottom: 10.0),
        alignment: Alignment.center,
        child: DropdownButton<ActionModeMenuItem>(
          hint: const Text("操作模式菜单项"),
          onChanged: (value) async {
            currentWebViewModel.settings?.disabledActionModeMenuItems = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            currentWebViewModel.settings =
                await webViewController?.getSettings();
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.disabledActionModeMenuItems,
          items: ActionModeMenuItem.values.map((actionModeMenuItem) {
            return DropdownMenuItem<ActionModeMenuItem>(
              value: actionModeMenuItem,
              child: Text(
                actionModeMenuItem.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      ListTile(
        title: const Text("装饰性字体族"),
        subtitle: const Text("设置装饰性字体族名称。"),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.fantasyFontFamily,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.fantasyFontFamily = value;
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
      ListTile(
        title: const Text("等宽字体族"),
        subtitle: const Text("设置等宽字体族名称。"),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.fixedFontFamily,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.fixedFontFamily = value;
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
      ListTile(
        title: const Text("强制深色"),
        subtitle: const Text("为此 WebView 设置强制深色模式。"),
        trailing: DropdownButton<ForceDark>(
          hint: const Text("强制深色"),
          onChanged: (value) async {
            currentWebViewModel.settings?.forceDark = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            currentWebViewModel.settings =
                await webViewController?.getSettings();
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.forceDark,
          items: ForceDark.values.map((forceDark) {
            return DropdownMenuItem<ForceDark>(
              value: forceDark,
              child: Text(
                forceDark.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      SwitchListTile(
        title: const Text("已启用地理位置"),
        subtitle: const Text("设置是否启用地理位置 API。"),
        value: currentWebViewModel.settings?.geolocationEnabled ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.geolocationEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("布局算法"),
        subtitle: const Text(
            "设置底层布局算法。这将导致 WebView 重新布局。"),
        trailing: DropdownButton<LayoutAlgorithm>(
          hint: const Text("布局算法"),
          onChanged: (value) async {
            currentWebViewModel.settings?.layoutAlgorithm = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            currentWebViewModel.settings =
                await webViewController?.getSettings();
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.layoutAlgorithm,
          items: LayoutAlgorithm.values.map((layoutAlgorithm) {
            return DropdownMenuItem<LayoutAlgorithm>(
              value: layoutAlgorithm,
              child: Text(
                layoutAlgorithm.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      SwitchListTile(
        title: const Text("以概览模式加载"),
        subtitle: const Text(
            "设置 WebView 是否以概览模式加载页面，即缩小内容以按宽度适配屏幕。"),
        value: currentWebViewModel.settings?.loadWithOverviewMode ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.loadWithOverviewMode = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("自动加载图片"),
        subtitle: const Text(
            "设置 WebView 是否加载图片资源。注意：该方法控制所有图片的加载，包括通过 data URI 嵌入的图片。"),
        value: currentWebViewModel.settings?.loadsImagesAutomatically ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.loadsImagesAutomatically = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("最小逻辑字号"),
        subtitle: const Text("设置最小逻辑字号。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue:
                currentWebViewModel.settings?.minimumLogicalFontSize.toString(),
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.minimumLogicalFontSize =
                  int.parse(value);
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
      ListTile(
        title: const Text("初始缩放"),
        subtitle: const Text(
            "设置此 WebView 的初始缩放。0 表示默认。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.initialScale.toString(),
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.initialScale = int.parse(value);
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
        title: const Text("需要初始焦点"),
        subtitle:
            const Text("告知 WebView 是否需要设置节点。"),
        value: currentWebViewModel.settings?.needInitialFocus ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.needInitialFocus = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("离屏预光栅化"),
        subtitle: const Text(
            "设置此 WebView 在离屏但仍附加到窗口时是否对图块进行光栅化。"),
        value: currentWebViewModel.settings?.offscreenPreRaster ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.offscreenPreRaster = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("无衬线字体族"),
        subtitle: const Text("设置无衬线字体族名称。"),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.sansSerifFontFamily,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.sansSerifFontFamily = value;
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
      ListTile(
        title: const Text("衬线字体族"),
        subtitle: const Text("设置衬线字体族名称。"),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.serifFontFamily,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.serifFontFamily = value;
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
      ListTile(
        title: const Text("标准字体族"),
        subtitle: const Text("设置标准字体族名称。"),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.standardFontFamily,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.standardFontFamily = value;
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
        title: const Text("保存表单数据"),
        subtitle: const Text(
            "设置 WebView 是否保存表单数据。在 Android O 及更高版本，平台已实现完整的自动填充功能用于存储表单数据。"),
        value: currentWebViewModel.settings?.saveFormData ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.saveFormData = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("已启用第三方 Cookie"),
        subtitle: const Text(
            "设置 WebView 是否启用第三方 Cookie。"),
        value: currentWebViewModel.settings?.thirdPartyCookiesEnabled ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.thirdPartyCookiesEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("硬件加速"),
        subtitle: const Text(
            "设置 WebView 是否启用硬件加速。"),
        value: currentWebViewModel.settings?.hardwareAcceleration ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.hardwareAcceleration = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("支持多窗口"),
        subtitle: const Text(
            "设置 WebView 是否支持多窗口。"),
        value: currentWebViewModel.settings?.supportMultipleWindows ?? false,
        onChanged: (value) async {
          currentWebViewModel.settings?.supportMultipleWindows = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      const ListTile(
        title: Text("过度滚动模式"),
        subtitle: Text("设置 WebView 的过滚动模式。"),
      ),
      Container(
        padding: const EdgeInsets.only(
            left: 20.0, top: 0.0, right: 20.0, bottom: 10.0),
        alignment: Alignment.center,
        child: DropdownButton<OverScrollMode>(
          hint: const Text("过度滚动模式"),
          onChanged: (value) async {
            currentWebViewModel.settings?.overScrollMode = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            currentWebViewModel.settings =
                await webViewController?.getSettings();
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.overScrollMode,
          items: OverScrollMode.values.map((overScrollMode) {
            return DropdownMenuItem<OverScrollMode>(
              value: overScrollMode,
              child: Text(
                overScrollMode.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      SwitchListTile(
        title: const Text("网络可用"),
        subtitle: const Text("告知 WebView 网络状态。"),
        value: currentWebViewModel.settings?.networkAvailable ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.networkAvailable = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      const ListTile(
        title: Text("滚动条样式"),
        subtitle: Text("指定滚动条样式。"),
      ),
      Container(
        padding: const EdgeInsets.only(
            left: 20.0, top: 0.0, right: 20.0, bottom: 10.0),
        alignment: Alignment.center,
        child: DropdownButton<ScrollBarStyle>(
          hint: const Text("滚动条样式"),
          onChanged: (value) async {
            currentWebViewModel.settings?.scrollBarStyle = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            currentWebViewModel.settings =
                await webViewController?.getSettings();
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.scrollBarStyle,
          items: ScrollBarStyle.values.map((scrollBarStyle) {
            return DropdownMenuItem<ScrollBarStyle>(
              value: scrollBarStyle,
              child: Text(
                scrollBarStyle.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      const ListTile(
        title: Text("垂直滚动条位置"),
        subtitle: Text("设置垂直滚动条位置。"),
      ),
      Container(
        padding: const EdgeInsets.only(
            left: 20.0, top: 0.0, right: 20.0, bottom: 10.0),
        alignment: Alignment.center,
        child: DropdownButton<VerticalScrollbarPosition>(
          hint: const Text("垂直滚动条位置"),
          onChanged: (value) async {
            currentWebViewModel.settings?.verticalScrollbarPosition = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            currentWebViewModel.settings =
                await webViewController?.getSettings();
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.verticalScrollbarPosition,
          items:
              VerticalScrollbarPosition.values.map((verticalScrollbarPosition) {
            return DropdownMenuItem<VerticalScrollbarPosition>(
              value: verticalScrollbarPosition,
              child: Text(
                verticalScrollbarPosition.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      ListTile(
        title: const Text("滚动条淡出前的默认延迟"),
        subtitle: const Text(
            "定义滚动条淡出前等待的延迟（毫秒）。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue: currentWebViewModel
                    .settings?.scrollBarDefaultDelayBeforeFade
                    ?.toString() ??
                "0",
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.scrollBarDefaultDelayBeforeFade =
                  int.parse(value);
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
        title: const Text("已启用滚动条淡出"),
        subtitle: const Text(
            "定义视图未滚动时滚动条是否淡出。"),
        value: currentWebViewModel.settings?.scrollbarFadingEnabled ?? true,
        onChanged: (value) async {
          currentWebViewModel.settings?.scrollbarFadingEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          currentWebViewModel.settings = await webViewController?.getSettings();
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("滚动条淡出时长"),
        subtitle:
            const Text("定义滚动条淡出持续时间（毫秒）。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.scrollBarFadeDuration
                    ?.toString() ??
                "0",
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewModel.settings?.scrollBarFadeDuration =
                  int.parse(value);
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
      ListTile(
        title: const Text("垂直滚动条滑块颜色"),
        subtitle: const Text("设置垂直滚动条滑块颜色。"),
        trailing: SizedBox(
            width: 140.0,
            child: ElevatedButton(
              child: Text(
                currentWebViewModel.settings?.verticalScrollbarThumbColor
                        ?.toString() ??
                    'Pick a color!',
                style: const TextStyle(fontSize: 12.5),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: const Color(0xffffffff),
                          onColorChanged: (value) async {
                            currentWebViewModel
                                .settings?.verticalScrollbarThumbColor = value;
                            webViewController?.setSettings(
                                settings: currentWebViewModel.settings ??
                                    InAppWebViewSettings());
                            currentWebViewModel.settings =
                                await webViewController?.getSettings();
                            windowModel.saveInfo();
                            setState(() {});
                          },
                          labelTypes: const [
                            ColorLabelType.rgb,
                            ColorLabelType.hsv,
                            ColorLabelType.hsl
                          ],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                    );
                  },
                );
              },
            )),
      ),
      ListTile(
        title: const Text("垂直滚动条轨道颜色"),
        subtitle: const Text("设置垂直滚动条轨道颜色。"),
        trailing: SizedBox(
            width: 140.0,
            child: ElevatedButton(
              child: Text(
                currentWebViewModel.settings?.verticalScrollbarTrackColor
                        ?.toString() ??
                    'Pick a color!',
                style: const TextStyle(fontSize: 12.5),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: const Color(0xffffffff),
                          onColorChanged: (value) async {
                            currentWebViewModel
                                .settings?.verticalScrollbarTrackColor = value;
                            webViewController?.setSettings(
                                settings: currentWebViewModel.settings ??
                                    InAppWebViewSettings());
                            currentWebViewModel.settings =
                                await webViewController?.getSettings();
                            windowModel.saveInfo();
                            setState(() {});
                          },
                          labelTypes: const [
                            ColorLabelType.rgb,
                            ColorLabelType.hsv,
                            ColorLabelType.hsl
                          ],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                    );
                  },
                );
              },
            )),
      ),
      ListTile(
        title: const Text("水平滚动条滑块颜色"),
        subtitle: const Text("设置水平滚动条滑块颜色。"),
        trailing: SizedBox(
            width: 140.0,
            child: ElevatedButton(
              child: Text(
                currentWebViewModel.settings?.horizontalScrollbarThumbColor
                        ?.toString() ??
                    'Pick a color!',
                style: const TextStyle(fontSize: 12.5),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: const Color(0xffffffff),
                          onColorChanged: (value) async {
                            currentWebViewModel.settings
                                ?.horizontalScrollbarThumbColor = value;
                            webViewController?.setSettings(
                                settings: currentWebViewModel.settings ??
                                    InAppWebViewSettings());
                            currentWebViewModel.settings =
                                await webViewController?.getSettings();
                            windowModel.saveInfo();
                            setState(() {});
                          },
                          labelTypes: const [
                            ColorLabelType.rgb,
                            ColorLabelType.hsv,
                            ColorLabelType.hsl
                          ],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                    );
                  },
                );
              },
            )),
      ),
      ListTile(
        title: const Text("水平滚动条轨道颜色"),
        subtitle: const Text("设置水平滚动条轨道颜色。"),
        trailing: SizedBox(
            width: 140.0,
            child: ElevatedButton(
              child: Text(
                currentWebViewModel.settings?.horizontalScrollbarTrackColor
                        ?.toString() ??
                    'Pick a color!',
                style: const TextStyle(fontSize: 12.5),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: const Color(0xffffffff),
                          onColorChanged: (value) async {
                            currentWebViewModel.settings
                                ?.horizontalScrollbarTrackColor = value;
                            webViewController?.setSettings(
                                settings: currentWebViewModel.settings ??
                                    InAppWebViewSettings());
                            currentWebViewModel.settings =
                                await webViewController?.getSettings();
                            windowModel.saveInfo();
                            setState(() {});
                          },
                          labelTypes: const [
                            ColorLabelType.rgb,
                            ColorLabelType.hsv,
                            ColorLabelType.hsl
                          ],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                    );
                  },
                );
              },
            )),
      ),
    ];

    return widgets;
  }
}
