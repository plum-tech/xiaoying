class CourseIcons {
  static const Map<String, List<String>> _courseToCategory = {
    'art': [
      '手绘',
      '速写',
      '插图',
      '图文',
      '创作',
      '摄影',
      '构图',
      '美术',
      '水彩',
      '油画',
      '素描',
      '艺术',
      '雕塑',
      '装饰',
      '写生',
      '技法',
      '视觉',
      '漆艺',
      'UI',
      '广告',
      '美学'
    ],
    'biological': ['生物', '环境', '花卉', '药物', '微生物', '材料'],
    'history': ['文化', '历史', '设计史', '书画', '文明史'],
    'building': ['建筑', '轨道', '铁道', '桥梁', '结构力学', '房屋', '建材', '工程', '混凝土', '建设'],
    'chemical': ['化学', '传热学', '仪器', '药剂', '腐蚀', '制药', '化妆品', '酒', '香精', '聚合物', '水质', '药理'],
    'engineering': ['测量', '力学', '光谱', '检测', '有限单元'],
    'practice': ['实习', '实训', '营销', '就业', '实践', '职业'],
    'circuit': ['电工', '电磁', '电子', '信号', '数码', '数字', '嵌入式', 'EDA', '单片机'],
    'computer': [
      'Python',
      '计算机',
      '程序设计',
      '软件',
      'web',
      '开发',
      '建模',
      '非线性编辑',
      '微机',
      '图形',
      '操作系统',
      '数据结构',
      'C语言',
      '编译',
      '人工智能'
    ],
    'control': ['控制', '半导体', '泵', '电源', '系统', '故障诊断', '接触网', '维修', '液压', '气压', '汽轮机'],
    'experiment': ['特效', '会展', '实验', '活性剂', '光学'],
    'electricity': ['化工', '给水', '燃烧', '管网', '热工', '玻璃', '固废', '发电厂'],
    'music': ['音频', '音乐', '产品设计'],
    'social': ['园林'],
    'geography': ['生态', '一带一路', '大气污染', '地理'],
    'economic': ['估价', '贸易', '会计', '经济', '货币'],
    'physical': ['土壤', '国际', '物理'],
    'design': ['规划', '园艺', '线造型', '制图', '设计', 'Design', 'CAD'],
    'mechanical': ['工艺', '设备', '装备', '机械', '机电', '金属', '钢'],
    'sports': ['篮球'],
    'internship': ['香原料', '美容', '品评', '社区', '心理', '采编', '招聘', '妇女'],
    'political': ['珠宝'],
    'running': ['体育'],
    'language': ['英语', '德语', '语言', '法语', '日语', '英文', '英汉', '专业外语'],
    'ideological': ['思想道德', '毛泽东', '法治', '近现代史', '马克思', '政策', '政治'],
    'reading': ['植物', '信息论'],
    'management': ['食品', '管理', '项目', '关系', '安全', '行为', '社会'],
    'training': ['通信', '网络', '物联网', '文献检索'],
    'business': ['多媒体', '动画', '审计', '企业'],
    'statistical': ['数据分析', '数据挖掘', '数据库', '大数据', '市场', '调研', '证券', '统计'],
    'mathematics': ['计算', '复变函数', '概率论', '积分', '数学', '代数'],
    'technology': ['空调', '技术', '科学', '科技'],
    'generality': ['书籍'],
    'literature': ['文学', '编辑', '新闻', '报刊'],
    'curriculum': ['论文'],
  };

  static const _fallbackCat = "principle";

  static String query(String curriculum, {String fallback = _fallbackCat}) {
    for (var title in _courseToCategory.keys) {
      for (var item in _courseToCategory[title]!) {
        if (curriculum.contains(item)) {
          return title;
        }
      }
    }
    return fallback;
  }

  static const String _courseIconDir = 'assets/course';

  static String iconPathOf({String? courseName, String? iconName}) {
    final String icon;
    if (iconName != null && _courseToCategory.containsKey(iconName)) {
      icon = iconName;
    } else if (courseName != null) {
      icon = query(courseName);
    } else {
      icon = _fallbackCat;
    }
    return "$_courseIconDir/$icon.png";
  }
}
