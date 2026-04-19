import 'package:flutter/material.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'package:flutter_browser/multiselect_dialog.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../../models/window_model.dart';

class IOSSettings extends StatefulWidget {
  const IOSSettings({super.key});

  @override
  State<IOSSettings> createState() => _IOSSettingsState();
}

class _IOSSettingsState extends State<IOSSettings> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _buildIOSWebViewSettings(),
    );
  }

  List<Widget> _buildIOSWebViewSettings() {
    final windowModel = Provider.of<WindowModel>(context, listen: true);
    if (windowModel.webViewTabs.isEmpty) {
      return [];
    }
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = currentWebViewModel.webViewController;

    var widgets = <Widget>[
      const ListTile(
        title: Text("当前 WebView（iOS）设置"),
        enabled: false,
      ),
      SwitchListTile(
        title: const Text("禁止过度滚动"),
        subtitle: const Text(
            "设置滚动到达内容边缘时 WebView 是否回弹。"),
        value: currentWebViewModel.settings?.disallowOverScroll ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.disallowOverScroll = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("启用视口缩放"),
        subtitle: const Text(
            "启用后，viewport meta 标签可禁用或限制用户缩放范围。"),
        value: currentWebViewModel.settings?.enableViewportScale ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.enableViewportScale = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("抑制增量渲染"),
        subtitle: const Text(
            "设置 WebView 是否在内容完全加载到内存前抑制渲染。（原文拼写 wheter/suppresses 保留语义）"),
        value: currentWebViewModel.settings?.suppressesIncrementalRendering ??
            false,
        onChanged: (value) {
          currentWebViewModel.settings?.suppressesIncrementalRendering = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("允许通过 AirPlay 播放媒体"),
        subtitle: const Text("启用 AirPlay。"),
        value:
            currentWebViewModel.settings?.allowsAirPlayForMediaPlayback ?? true,
        onChanged: (value) {
          currentWebViewModel.settings?.allowsAirPlayForMediaPlayback = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("允许前进后退导航手势"),
        subtitle: const Text(
            "启用后，水平滑动手势可触发前进/后退列表导航。"),
        value:
            currentWebViewModel.settings?.allowsBackForwardNavigationGestures ??
                true,
        onChanged: (value) {
          currentWebViewModel.settings?.allowsBackForwardNavigationGestures =
              value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("忽略视口缩放限制"),
        subtitle: const Text(
            "设置 WebView 是否始终允许缩放网页，而不论页面作者的意图。"),
        value:
            currentWebViewModel.settings?.ignoresViewportScaleLimits ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.ignoresViewportScaleLimits = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("允许内联媒体播放"),
        subtitle: const Text(
            "启用后，HTML5 媒体可在屏幕布局内联播放，并使用浏览器提供的控件而非原生控件。"),
        value: currentWebViewModel.settings?.allowsInlineMediaPlayback ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.allowsInlineMediaPlayback = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("允许画中画媒体播放"),
        subtitle:
            const Text("启用后允许 HTML5 视频以画中画播放。"),
        value:
            currentWebViewModel.settings?.allowsPictureInPictureMediaPlayback ??
                true,
        onChanged: (value) {
          currentWebViewModel.settings?.allowsPictureInPictureMediaPlayback =
              value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("选择粒度"),
        subtitle: const Text(
            "设置用户可在网页视图中交互选择内容的粒度级别。"),
        trailing: DropdownButton<SelectionGranularity>(
          hint: const Text("粒度"),
          onChanged: (value) {
            currentWebViewModel.settings?.selectionGranularity = value!;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.selectionGranularity,
          items: SelectionGranularity.values.map((selectionGranularity) {
            return DropdownMenuItem<SelectionGranularity>(
              value: selectionGranularity,
              child: Text(
                selectionGranularity.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      ListTile(
        title: const Text("数据检测器类型"),
        subtitle: const Text(
            "指定 dataDetectorTypes 可为匹配该值的网页内容增加交互能力。"),
        trailing: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
          child: Text(currentWebViewModel.settings?.dataDetectorTypes
                  ?.map((e) => e.toString())
                  .join(", ") ??
              ""),
        ),
        onTap: () async {
          final dataDetectoryTypesSelected =
              await showDialog<Set<DataDetectorTypes>>(
            context: context,
            builder: (BuildContext context) {
              return MultiSelectDialog(
                title: const Text("数据检测器类型"),
                items: DataDetectorTypes.values.map((dataDetectorType) {
                  return MultiSelectDialogItem<DataDetectorTypes>(
                      value: dataDetectorType,
                      label: dataDetectorType.toString());
                }).toList(),
                initialSelectedValues:
                    currentWebViewModel.settings?.dataDetectorTypes?.toSet(),
              );
            },
          );
          if (dataDetectoryTypesSelected != null) {
            currentWebViewModel.settings?.dataDetectorTypes =
                dataDetectoryTypesSelected.toList();
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            windowModel.saveInfo();
            setState(() {});
          }
        },
      ),
      SwitchListTile(
        title: const Text("已启用共享 Cookie"),
        subtitle: const Text(
            "设置 WebView 的每次加载请求是否应使用来自 \"HTTPCookieStorage.shared\" 的共享 Cookie。"),
        value: currentWebViewModel.settings?.sharedCookiesEnabled ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.sharedCookiesEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("自动调整滚动指示器内边距"),
        subtitle: const Text(
            "配置滚动指示器内边距是否由系统自动调整。"),
        value: currentWebViewModel
                .settings?.automaticallyAdjustsScrollIndicatorInsets ??
            false,
        onChanged: (value) {
          currentWebViewModel
              .settings?.automaticallyAdjustsScrollIndicatorInsets = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("无障碍忽略颜色反转"),
        subtitle: const Text(
            "设置 WebView 是否忽略反转颜色的无障碍请求。"),
        value: currentWebViewModel.settings?.accessibilityIgnoresInvertColors ??
            false,
        onChanged: (value) {
          currentWebViewModel.settings?.accessibilityIgnoresInvertColors =
              value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("减速率"),
        subtitle: const Text(
            "决定用户抬起手指后的减速速率。"),
        trailing: DropdownButton<ScrollViewDecelerationRate>(
          hint: const Text("减速"),
          onChanged: (value) {
            currentWebViewModel.settings?.decelerationRate = value!;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.decelerationRate,
          items: ScrollViewDecelerationRate.values.map((decelerationRate) {
            return DropdownMenuItem<ScrollViewDecelerationRate>(
              value: decelerationRate,
              child: Text(
                decelerationRate.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      SwitchListTile(
        title: const Text("垂直方向始终回弹"),
        subtitle: const Text(
            "决定垂直滚动到达内容末端时是否始终发生回弹。"),
        value: currentWebViewModel.settings?.alwaysBounceVertical ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.alwaysBounceVertical = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("水平方向始终回弹"),
        subtitle: const Text(
            "决定水平滚动到达内容视图末端时是否始终发生回弹。"),
        value: currentWebViewModel.settings?.alwaysBounceHorizontal ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.alwaysBounceHorizontal = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("滚动到顶部"),
        subtitle:
            const Text("设置是否启用滚动到顶部手势。"),
        value: currentWebViewModel.settings?.scrollsToTop ?? true,
        onChanged: (value) {
          currentWebViewModel.settings?.scrollsToTop = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("是否启用分页"),
        subtitle: const Text(
            "决定滚动视图是否启用分页。"),
        value: currentWebViewModel.settings?.isPagingEnabled ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.isPagingEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("最大缩放比例"),
        subtitle: const Text(
            "指定可应用于滚动视图内容的最大缩放因子的浮点值。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue:
                currentWebViewModel.settings?.maximumZoomScale.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (value) {
              currentWebViewModel.settings?.maximumZoomScale =
                  double.parse(value);
              webViewController?.setSettings(
                  settings:
                      currentWebViewModel.settings ?? InAppWebViewSettings());
              windowModel.saveInfo();
              setState(() {});
            },
          ),
        ),
      ),
      ListTile(
        title: const Text("最小缩放比例"),
        subtitle: const Text(
            "指定可应用于滚动视图内容的最小缩放因子的浮点值。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue:
                currentWebViewModel.settings?.minimumZoomScale.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (value) {
              currentWebViewModel.settings?.minimumZoomScale =
                  double.parse(value);
              webViewController?.setSettings(
                  settings:
                      currentWebViewModel.settings ?? InAppWebViewSettings());
              windowModel.saveInfo();
              setState(() {});
            },
          ),
        ),
      ),
      ListTile(
        title: const Text("内容内边距调整行为"),
        subtitle: const Text(
            "配置如何将安全区内边距加入调整后的内容内边距。"),
        trailing: DropdownButton<ScrollViewContentInsetAdjustmentBehavior>(
          onChanged: (value) {
            currentWebViewModel.settings?.contentInsetAdjustmentBehavior =
                value!;
            webViewController?.setSettings(
                settings:
                    currentWebViewModel.settings ?? InAppWebViewSettings());
            windowModel.saveInfo();
            setState(() {});
          },
          value: currentWebViewModel.settings?.contentInsetAdjustmentBehavior,
          items: ScrollViewContentInsetAdjustmentBehavior.values
              .map((decelerationRate) {
            return DropdownMenuItem<ScrollViewContentInsetAdjustmentBehavior>(
              value: decelerationRate,
              child: Text(
                decelerationRate.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      SwitchListTile(
        title: const Text("是否启用方向锁定"),
        subtitle: const Text(
            "布尔值，决定某个方向的滚动是否被禁用。"),
        value: currentWebViewModel.settings?.isDirectionalLockEnabled ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.isDirectionalLockEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("媒体类型"),
        subtitle:
            const Text("网页视图内容的媒体类型。"),
        trailing: SizedBox(
          width: 100.0,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.mediaType?.toString(),
            onFieldSubmitted: (value) {
              currentWebViewModel.settings?.mediaType =
                  value.isNotEmpty ? value : null;
              webViewController?.setSettings(
                  settings:
                      currentWebViewModel.settings ?? InAppWebViewSettings());
              windowModel.saveInfo();
              setState(() {});
            },
          ),
        ),
      ),
      ListTile(
        title: const Text("页面缩放"),
        subtitle: const Text(
            "网页视图相对于其边界缩放内容的比例因子。"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue: currentWebViewModel.settings?.pageZoom.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (value) {
              currentWebViewModel.settings?.pageZoom = double.parse(value);
              webViewController?.setSettings(
                  settings:
                      currentWebViewModel.settings ?? InAppWebViewSettings());
              windowModel.saveInfo();
              setState(() {});
            },
          ),
        ),
      ),
      SwitchListTile(
        title: const Text("已启用 Apple Pay API"),
        subtitle: const Text(
            "指示是否应在下次页面加载时启用 Apple Pay API（JavaScript 将不可用）。"),
        value: currentWebViewModel.settings?.applePayAPIEnabled ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.applePayAPIEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("页面底层背景色"),
        subtitle: const Text("设置网页背后显示的颜色，当用户滚动超出页面边界时可见。"),
        trailing: SizedBox(
            width: 140.0,
            child: ElevatedButton(
              child: Text(
                currentWebViewModel.settings?.underPageBackgroundColor
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
                                ?.underPageBackgroundColor = value;
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
      SwitchListTile(
        title: const Text("已启用文本交互"),
        subtitle: const Text(
            "指示是否启用文本交互。"),
        value: currentWebViewModel.settings?.isTextInteractionEnabled ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.isTextInteractionEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("站点专用怪异模式已启用"),
        subtitle: const Text(
            "指示 WebKit 是否应用内置变通方案（怪异模式）以提高与某些已知网站的兼容性。可关闭站点专用变通，以便在无这些变通的情况下测试网站。"),
        value: currentWebViewModel.settings?.isSiteSpecificQuirksModeEnabled ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.isSiteSpecificQuirksModeEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("将已知主机升级到 HTTPS"),
        subtitle: const Text(
            "指示是否应将发往已知支持 HTTPS 的服务器的 HTTP 请求自动升级为 HTTPS。"),
        value: currentWebViewModel.settings?.upgradeKnownHostsToHTTPS ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.upgradeKnownHostsToHTTPS = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("已启用元素全屏"),
        subtitle: const Text(
            "指示是否启用全屏 API。"),
        value: currentWebViewModel.settings?.isElementFullscreenEnabled ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.isElementFullscreenEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("已启用查找交互"),
        subtitle: const Text(
            "指示网页视图内置的查找交互原生界面是否启用。"),
        value: currentWebViewModel.settings?.isFindInteractionEnabled ?? false,
        onChanged: (value) {
          currentWebViewModel.settings?.isFindInteractionEnabled = value;
          webViewController?.setSettings(
              settings: currentWebViewModel.settings ?? InAppWebViewSettings());
          windowModel.saveInfo();
          setState(() {});
        },
      ),
    ];

    return widgets;
  }
}
