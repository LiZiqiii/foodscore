import 'package:flutter/material.dart';

/// 首页数据模型，封装单条列表项的可展示字段。
class HomeItemModel {
  const HomeItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.iconColor,
    required this.duration,
    required this.calories,
  });

  /// 唯一标识，便于后续对接接口或本地存储。
  final int id;

  /// 训练/课程标题。
  final String title;

  /// 副标题描述。
  final String subtitle;

  /// 分类标签文案。
  final String tag;

  /// 列表项左侧图标。
  final IconData icon;

  /// 图标背景色。
  final Color iconColor;

  /// 训练时长文案。
  final String duration;

  /// 消耗卡路里文案。
  final String calories;
}

/// 首页控制器：集中管理页面文案、样式常量与 20 条测试数据。
class HomePageController {
  HomePageController._();

  // ---------------------------------------------------------------------------
  // 页面文案
  // ---------------------------------------------------------------------------

  /// 页面主标题。
  static const String pageTitle = '今日训练';

  /// 页面副标题。
  static const String pageSubtitle = '为你推荐 20 个精选课程';

  /// 搜索框占位提示。
  static const String searchHint = '搜索课程、教练或标签';

  /// 底部统计区标题。
  static const String statsTitle = '本周概览';

  /// 空列表提示（预留，当前测试数据不为空）。
  static const String emptyTip = '暂无推荐课程';

  // ---------------------------------------------------------------------------
  // 样式与布局常量（避免在 UI 层硬编码魔法数字）
  // ---------------------------------------------------------------------------

  /// 主卡片圆角半径（设计稿 38，运行时由 .r 做屏幕适配）。
  static const double cardBorderRadius = 38;

  /// 主卡片整体透明度。
  static const double cardOpacity = 0.85;

  /// 主卡片水平外边距占屏宽比例，保证宽度自适应。
  static const double cardHorizontalMarginRatio = 0.06;

  /// 主卡片最大宽度比例，避免超宽屏拉伸过度。
  static const double cardMaxWidthRatio = 0.92;

  /// 列表项圆角。
  static const double itemBorderRadius = 16;

  /// 主色，用于强调文字与按钮。
  static const Color primaryColor = Color(0xFF4C6EF5);

  /// 页面背景渐变色起始色。
  static const Color backgroundStartColor = Color(0xFFE8EDFF);

  /// 页面背景渐变色结束色。
  static const Color backgroundEndColor = Color(0xFFF7F8FC);

  /// 卡片描边颜色。
  static const Color cardBorderColor = Colors.white;

  /// 标签背景色。
  static const Color tagBackgroundColor = Color(0xFFEEF2FF);

  // ---------------------------------------------------------------------------
  // 统计区展示数据
  // ---------------------------------------------------------------------------

  static const List<Map<String, String>> weeklyStats = [
    {'label': '训练天数', 'value': '5 天'},
    {'label': '总时长', 'value': '4.5 小时'},
    {'label': '消耗', 'value': '1860 kcal'},
  ];

  // ---------------------------------------------------------------------------
  // 20 条测试数据
  // ---------------------------------------------------------------------------

  /// 首页推荐列表，共 20 条，供列表循环渲染。
  static const List<HomeItemModel> itemList = [
    HomeItemModel(
      id: 1,
      title: '晨间唤醒拉伸',
      subtitle: '温和唤醒身体，改善僵硬感',
      tag: '拉伸',
      icon: Icons.self_improvement,
      iconColor: Color(0xFF74C0FC),
      duration: '12 分钟',
      calories: '68 kcal',
    ),
    HomeItemModel(
      id: 2,
      title: '核心力量入门',
      subtitle: '激活腹部与腰背稳定肌群',
      tag: '力量',
      icon: Icons.fitness_center,
      iconColor: Color(0xFF63E6BE),
      duration: '18 分钟',
      calories: '120 kcal',
    ),
    HomeItemModel(
      id: 3,
      title: '燃脂 HIIT 冲刺',
      subtitle: '短时高强度，快速提升心率',
      tag: '有氧',
      icon: Icons.local_fire_department,
      iconColor: Color(0xFFFF8787),
      duration: '20 分钟',
      calories: '210 kcal',
    ),
    HomeItemModel(
      id: 4,
      title: '办公室肩颈修复',
      subtitle: '久坐人群专属，缓解酸痛',
      tag: '康复',
      icon: Icons.accessibility_new,
      iconColor: Color(0xFFB197FC),
      duration: '15 分钟',
      calories: '75 kcal',
    ),
    HomeItemModel(
      id: 5,
      title: '下肢塑形训练',
      subtitle: '臀腿协同发力，塑造线条',
      tag: '塑形',
      icon: Icons.directions_run,
      iconColor: Color(0xFFFFD43B),
      duration: '25 分钟',
      calories: '180 kcal',
    ),
    HomeItemModel(
      id: 6,
      title: '瑜伽流动基础',
      subtitle: '呼吸与体式配合，提升柔韧',
      tag: '瑜伽',
      icon: Icons.spa,
      iconColor: Color(0xFF8CE99A),
      duration: '30 分钟',
      calories: '130 kcal',
    ),
    HomeItemModel(
      id: 7,
      title: '跳绳间歇挑战',
      subtitle: '高效心肺训练，增强协调',
      tag: '有氧',
      icon: Icons.sports_gymnastics,
      iconColor: Color(0xFFFF922B),
      duration: '16 分钟',
      calories: '165 kcal',
    ),
    HomeItemModel(
      id: 8,
      title: '俯卧撑进阶计划',
      subtitle: '由易到难，逐步提升上肢力量',
      tag: '力量',
      icon: Icons.sports_martial_arts,
      iconColor: Color(0xFF4DABF7),
      duration: '14 分钟',
      calories: '95 kcal',
    ),
    HomeItemModel(
      id: 9,
      title: '冥想放松引导',
      subtitle: '缓解压力，改善睡眠质量',
      tag: '放松',
      icon: Icons.nightlight_round,
      iconColor: Color(0xFF9775FA),
      duration: '10 分钟',
      calories: '30 kcal',
    ),
    HomeItemModel(
      id: 10,
      title: '壶铃全身循环',
      subtitle: '复合动作训练，提升功能性力量',
      tag: '力量',
      icon: Icons.sports_kabaddi,
      iconColor: Color(0xFF20C997),
      duration: '22 分钟',
      calories: '195 kcal',
    ),
    HomeItemModel(
      id: 11,
      title: '骑行模拟训练',
      subtitle: '低冲击有氧，保护膝关节',
      tag: '有氧',
      icon: Icons.pedal_bike,
      iconColor: Color(0xFF339AF0),
      duration: '28 分钟',
      calories: '220 kcal',
    ),
    HomeItemModel(
      id: 12,
      title: '普拉提核心控制',
      subtitle: '强调控制与稳定，雕刻腰腹',
      tag: '普拉提',
      icon: Icons.airline_seat_recline_normal,
      iconColor: Color(0xFFF783AC),
      duration: '24 分钟',
      calories: '140 kcal',
    ),
    HomeItemModel(
      id: 13,
      title: '战绳爆发力',
      subtitle: '全身爆发力与耐力综合训练',
      tag: '力量',
      icon: Icons.waves,
      iconColor: Color(0xFF66D9E8),
      duration: '18 分钟',
      calories: '175 kcal',
    ),
    HomeItemModel(
      id: 14,
      title: '晨跑前热身',
      subtitle: '动态拉伸，降低运动损伤风险',
      tag: '热身',
      icon: Icons.directions_walk,
      iconColor: Color(0xFFA9E34B),
      duration: '8 分钟',
      calories: '45 kcal',
    ),
    HomeItemModel(
      id: 15,
      title: '腹肌雕刻 7 分钟',
      subtitle: '短时高效，适合碎片时间',
      tag: '核心',
      icon: Icons.monitor_heart,
      iconColor: Color(0xFFFF6B6B),
      duration: '7 分钟',
      calories: '55 kcal',
    ),
    HomeItemModel(
      id: 16,
      title: '太极养生八式',
      subtitle: '缓慢连贯，适合中老年群体',
      tag: '养生',
      icon: Icons.wb_sunny,
      iconColor: Color(0xFFFFC078),
      duration: '20 分钟',
      calories: '80 kcal',
    ),
    HomeItemModel(
      id: 17,
      title: '游泳陆上模仿',
      subtitle: '无泳池也能练肩背与核心',
      tag: '专项',
      icon: Icons.pool,
      iconColor: Color(0xFF748FFC),
      duration: '17 分钟',
      calories: '110 kcal',
    ),
    HomeItemModel(
      id: 18,
      title: '平衡与协调训练',
      subtitle: '提升本体感觉，预防跌倒',
      tag: '康复',
      icon: Icons.balance,
      iconColor: Color(0xFF94D82D),
      duration: '13 分钟',
      calories: '70 kcal',
    ),
    HomeItemModel(
      id: 19,
      title: '拳击空击组合',
      subtitle: '释放情绪，锻炼心肺与反应',
      tag: '搏击',
      icon: Icons.sports_mma,
      iconColor: Color(0xFFE64980),
      duration: '19 分钟',
      calories: '185 kcal',
    ),
    HomeItemModel(
      id: 20,
      title: '睡前舒缓伸展',
      subtitle: '放松神经系统，帮助入眠',
      tag: '放松',
      icon: Icons.bedtime,
      iconColor: Color(0xFF845EF7),
      duration: '11 分钟',
      calories: '40 kcal',
    ),
  ];
}
