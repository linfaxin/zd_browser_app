import 'package:flutter_browser/util.dart';

class PopupMenuActions {
  // ignore: constant_identifier_names
  static const String OPEN_NEW_WINDOW = "新建窗口";
  // ignore: constant_identifier_names
  static const String SAVE_WINDOW = "保存窗口";
  // ignore: constant_identifier_names
  static const String SAVED_WINDOWS = "已保存的窗口";
  // ignore: constant_identifier_names
  static const String NEW_TAB = "新建标签页";
  // ignore: constant_identifier_names
  static const String NEW_INCOGNITO_TAB = "新建无痕标签页";
  // ignore: constant_identifier_names
  static const String FAVORITES = "收藏夹";
  // ignore: constant_identifier_names
  static const String HISTORY = "历史记录";
  // ignore: constant_identifier_names
  static const String WEB_ARCHIVES = "网页归档";
  // ignore: constant_identifier_names
  static const String SHARE = "分享";
  // ignore: constant_identifier_names
  static const String FIND_ON_PAGE = "在页面中查找";
  // ignore: constant_identifier_names
  static const String DESKTOP_MODE = "桌面版网站";
  // ignore: constant_identifier_names
  static const String SETTINGS = "设置";
  // ignore: constant_identifier_names
  static const String DEVELOPERS = "开发者工具";
  // ignore: constant_identifier_names
  static const String INAPPWEBVIEW_PROJECT = "InAppWebView 项目";

  static List<String> get choices {
    if (Util.isMobile()) {
      return [
        NEW_TAB,
        NEW_INCOGNITO_TAB,
        FAVORITES,
        HISTORY,
        WEB_ARCHIVES,
        SHARE,
        FIND_ON_PAGE,
        SETTINGS,
        DEVELOPERS,
        INAPPWEBVIEW_PROJECT
      ];
    }
    return [
      OPEN_NEW_WINDOW,
      SAVE_WINDOW,
      SAVED_WINDOWS,
      NEW_TAB,
      NEW_INCOGNITO_TAB,
      FAVORITES,
      HISTORY,
      WEB_ARCHIVES,
      SHARE,
      FIND_ON_PAGE,
      SETTINGS,
      DEVELOPERS,
      INAPPWEBVIEW_PROJECT
    ];
}
}
