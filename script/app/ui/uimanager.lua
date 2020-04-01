-- 创建全局变量
cc.exports.UIManager = {
	mainNode = nil,
	battleNode = nil,
	currentNode = nil,
	actionNode = nil,		-- 跨界面动画层
	menuNode = nil,			-- 目录层
	widgetArr = nil,
	widgetMap = nil,
	topNodeIndex = nil,
	topZOrder = nil,
	uiConf = nil,
	touchwidget = nil,
	currBgm = 0,
	clickAniArr = {}
}

cc.exports.GAME_UI = {
	UI_LOGIN = 1,  							-- 登陆界面
	UI_BATTLE = 2,							-- 战斗界面
	UI_MAINSCENE = 3,						-- 大地图
	UI_ROLEMAIN = 4,						-- 武将
	UI_ROLELIST = 5,						-- 武将选择
	UI_MAINCITY = 6,						-- 主城
	UI_ROLECARDINFO = 7,					-- 武将卡片信息
	UI_GETWAY = 8,							-- 获取路径
	UI_EXPEDITION = 9,						-- 征战界面
	UI_COMBAT = 10,							-- 切磋界面
	UI_PATROL = 11,							-- 巡逻界面
	UI_PREFECTURE= 12,						-- 抢夺太守
	UI_GEMSELECT = 13,						-- 宝石选择
	UI_ROLESELECTLISTOUTSIDE = 14,			-- 武将列表
	UI_RAIDSUI = 15,						-- 扫荡界面
	UI_EQUIPSELECT = 16,					-- 装备选择
	UI_BATTLE_VICTORY = 17,					-- 战斗胜利
	UI_BATTLE_FAILURE = 18,					-- 战斗失败
	UI_PATROL_SPEED = 19,					-- 加速巡逻
	UI_PATROL_AWARDS = 20,					-- 巡逻奖励
	UI_ROLE_RESOLVE =22,					-- 批量分解
	UI_SOLDOER_SKILL =23,					-- 小兵技能
	UI_BAG =24,								-- 背包
	UI_GEMUPGRADE = 25,						-- 宝石升级
	UI_CAMP = 26,							-- 创建阵营
	UI_SELL = 27,							-- 出售物品
	UI_FUSION = 28,							-- 熔炼
	UI_TAVERN = 29,							-- 招募
	UI_FORGE = 30,							-- 打造
	UI_GOLDMINE = 31,						-- 金矿
	UI_VIEWPREFECTURE = 32,					-- 查看太守
	UI_XXXXXXXXXXXXXXXXXXX1 = 34,			-- 该界面已删除
	UI_XXXXXXXXXXXXXXXXXXX2 = 35,			-- 该界面已删除
	UI_XXXXXXXXXXXXXXXXXXX3 = 36,			-- 该界面已删除
	UI_SHOP = 37,							-- 商店
	UI_GOLDMINEREPORT = 38,					-- 金矿战报
	UI_ARENA = 39,							-- 竞技场主界面
	UI_ARENA_RANK = 40,						-- 竞技场排行界面
	UI_ARENA_CHANGERANK = 42,				-- 竞技场排行变更界面
	UI_UPGRADE_STAR = 43,					-- 吞噬
	UI_TOWER_MAIN = 44,						-- 爬塔主界面
	UI_TOWER_RANK = 45,						-- 爬塔排行界面
	UI_TOWER_AWARDS = 46,					-- 爬塔奖励界面(已删除)
	UI_TOWER_AUTOFIGHT = 47,				-- 爬塔扫荡界面
	UI_TREASURE = 50,						-- 宝物
	UI_SUIT = 51,							-- 套装
	UI_SOLDIEREQUIPTIPS = 52,				-- 小兵装备tips
	UI_STRENGHENPOPUPUI = 53,				-- 强化
	UI_SHOPMAIN = 54,						-- 商店主界面
	UI_SHOPMAIN = 55,						-- 商店主界面
	UI_SHOPTIPS = 56,						-- 商店tips
	UI_TAVERN_ANIMATE = 57,					-- 酒馆招募动画界面
	UI_ROLEEXCHANGE = 58,					-- 武将变化
	UI_EMAIL = 59,							-- 邮箱
	UI_READEMAIL = 60,						-- 读邮箱
	UI_TASK = 61,						    -- 任务
	UI_SHOWAWARD = 62,						-- 展示奖励
	UI_SKILLTIPS = 63,						-- 技能tips
	UI_ACTIVEBOX = 64,						-- 活跃度宝箱
	UI_TOWER_ATTAWARD = 65,					-- 爬塔属性奖励界面
	UI_CAMPAIGN = 66,						-- 主城征战
	UI_SHIPPERS = 67,						-- 运镖
	UI_SHIPPERSSELECT = 68,					-- 物资选择
	UI_SHIPPERSPLUNDER = 69,				-- 镖车掠夺
	UI_SHIPPERREPORT = 71,					-- 战报
	UI_SHIPPERSSUCCESS = 72,				-- 运送成功
	UI_BATTLE_COUNTER = 73,					-- 克制关系界面
	UI_USE = 74,							-- 批量使用
	UI_PROFESSTIPS = 75,					-- 职业tips使用
	UI_EQUIPONHERIT = 76,					-- 装备传承独立界面
	UI_LEGIONMAIN = 77,						-- 军团主界面
	UI_LEGIONAPPLY = 78,					-- 军团申请创建界面
	UI_LEGIONICONSELECTUI = 79,				-- 军团icon选择界面
	UI_LEGIONMANAGEUI = 80,					-- 军团管理界面
	UI_LEGIONINFOUI = 81,					-- 军团信息界面
	UI_LEGIONSETTINGUI = 82,				-- 军团设置界面
	UI_LEGIONPUBSETTINGUI = 83,				-- 军团公告设置界面
	UI_LEGIONAPPLYLISTUI = 84,				-- 军团申请列表界面
	UI_LEGIONMEMBERINFOUI = 85,				-- 军团成员信息
	UI_LEGIONPOSMANAGEUI = 86,				-- 军团职位管理界面
	UI_LEGIONLOGUI = 87,					-- 军团日志界面
	UI_LEGIONACTIVITYMAINUI = 88,			-- 军团活动主面板界面
	UI_LEGIONACTIVITYBOONUI = 89,			-- 军团活动红包界面
	UI_LEGIONACTIVITYSHAKEUI = 90,			-- 军团活动摇钱树界面
	UI_LEGIONACTIVITYMERCENARYUI = 91,		-- 军团活动佣兵界面
	UI_LEGIONACTIVITYTRIALUI = 92,			-- 军团活动试练之地界面
	UI_LEGIONACTIVITYROLELISTUI = 93,		-- 军团活动武将列表界面
	UI_LEGIONACTIVITYTRIALSTARUI = 94,		-- 军团活动试练之地夺星奖励界面
	UI_LEGIONACTIVITYSELROLELISTUI = 95,	-- 军团活动试练之地佣兵雇佣界面
	UI_GUIDEFIRST = 97,						-- 新手引导第一个专用的界面
	UI_SKILL_UPGRADE = 98,					-- 主角技能升级界面
	UI_WORLDWAR = 99,						-- 群雄争霸主界面
	UI_WORLDWARGOWAR = 100,					-- 群雄争霸争霸界面
	UI_WORLDWARLIST = 101,					-- 群雄争霸排行榜
	UI_WORLDWARREPORT = 102,				-- 群雄争霸战斗记录
	UI_WORLDWARAWARD = 103,					-- 群雄争霸奖励
	UI_WORLDWARKNOCKOUTUI = 104,			-- 群雄争霸淘汰赛
	UI_WORLDWARREPLAY = 105,				-- 群雄争霸回放
	UI_WORLDWARSUPPORT = 106,				-- 群雄争霸支持界面
	UI_WORLDWARMYSUPPORT = 107,				-- 群雄争霸我的支持界面
	UI_WORLDWARPRICERANK = 108,				-- 群雄争霸身价界面
	UI_WORLDWARMYREPLAY = 109,				-- 群雄争霸我的战绩
	UI_WORLDWARFEATSWALL = 110,				-- 群雄争霸功勋墙
	UI_WORLDWARHELP = 111,					-- 群雄争霸帮助界面
	UI_MAPAWARD = 112,						-- 大地图奖励
	UI_POWEREND = 113,						-- 势力灭亡
	UI_CLOUDOPEN = 114,						-- 云雾散开
	UI_LEGIONTEAMMAIN = 115,				-- 军团组队挂机主界面(已删除)
	UI_LEGIONTEAM = 116,					-- 军团组队挂机队伍界面(已删除)
	UI_LEGIONMYTEAM = 117,					-- 军团组队挂机我的队伍界面(已删除)
	UI_LEGIONTEAMBAG = 118,					-- 军团组队挂机仓库(已删除)
	UI_MODULEOPENUI = 119,					-- 功能开启
	UI_MAPTALK = 120,						-- 大地图对话
	UI_CITYCRAFT = 121,						-- 皇城争霸主界面
	UI_CITYCRAFTREPORT = 123,				-- 皇城争霸战报界面
	UI_CITYCRAFTOFFICE = 124,				-- 皇城争霸官职界面
	UI_CITYCRAFTPLAYERINFO = 125,			-- 皇城争霸玩家信息界面
	UI_ALTARMAINUI = 126,					-- 祭坛界面
	UI_SIGNMAINUI = 127,					-- 签到界面
	UI_RANKINGLISTUI = 128,					-- 排行榜主界面
	UI_SIGNREWARDUI = 129,					-- 签到累计奖励界面
	UI_GUARDMAP = 130,						-- 领地讨伐地图界面
	UI_GUARDMAIN = 131,						-- 领地讨伐主界面
	UI_GUARDLIST = 132,						-- 领地讨伐武将列表
	UI_GUARDSKILL = 133,					-- 领地巡逻技能界面
	UI_COUNTRYSELECT = 134,					-- 选择国家界面
	UI_COUNTRYMAIN = 135,					-- 国家主界面
	UI_COUNTRYOFFICEAWARDS = 136,			-- 官职奖励界面
	UI_COUNTRYOFFICETIPS = 137,				-- 官职tips界面
	UI_GUARDFRIENDLISTUI = 138,				-- 领地军团好友界面
	UI_RECHARGE = 139,						-- 充值
	UI_JADESEAL = 140,						-- 玉玺
	UI_GUIDESECOND = 141,					-- 新手引导第二个专用界面
	UI_SETTINGINFO = 142,					-- 君主设置信息界面
	UI_SETTINGCHANGENAME = 143,				-- 君主设置更换昵称
	UI_SETTINGCHANGEHEAD = 144,				-- 君主设置更换头像
	UI_SETTINGEXCHANGE = 145,				-- 君主设置兑换激活码
	UI_SETTINGSYSTEM = 146,					-- 君主设置系统界面
	UI_JADESEALAWARD = 147,					-- 玉玺领奖界面
	UI_LEGIONLEVELSMAIN = 148,				-- 军团副本主界面
	UI_LEGIONLEVELS = 149,					-- 军团副本关卡界面
	UI_LEGIONLEVELSBATTLE = 150,			-- 军团副本挑战界面
	UI_LEGIONLEVELSDM = 151,				-- 军团副本伤害排名界面
	UI_BOSSINFO = 152,						-- BOSS或太守信息界面
	UI_CHAT = 153,				            -- 聊天界面
	UI_FIRSTWEEKACTIVITY = 154,			    -- 七日活动界面
	UI_FATETIP = 155,						-- 缘分Tip界面
	UI_BATTLEDAMAGECOUNT = 156,				-- 战斗伤害统计界面
	UI_SOLDIERINFO = 157,					-- 小兵信息
	UI_CHECKINFO = 158,						-- 查看玩家信息界面
	UI_FIRSTRECHARGE = 159,					-- 首冲界面
	UI_TRAININGMAIN = 160,					-- 训练馆主界面
	UI_TRAININGSELECT = 161,				-- 训练馆武将选择界面
	UI_HONORHALL = 162,						-- 荣誉殿堂
	UI_TAGWALL = 163,						-- 印象墙
	UI_ARENA_V2 = 164,						-- 竞技场主界面 V2
	UI_ACTIVITY = 166,                      -- 活动主界面
	UI_ARENA_V2_REPORT = 167,				-- 竞技场战报界面
	UI_ARENA_V2_AWARD = 168,				-- 竞技场奖励界面
	UI_SOLDIER_UPGRADE = 169,				-- 小兵进阶DuangDuangDuang界面
	UI_JADESEALGETAWARD = 170,				-- 玉玺领奖界面
	UI_FATESHOW = 171,						-- 缘分展示界面
	UI_LEGIONCITYMAINUI = 172,				-- 军团城池主界面
	UI_LEGIONCITYINFOUI = 173,				-- 军团城池信息界面
	UI_LEGIONCITYLISTUI = 174,				-- 军团城池列表界面
	UI_LEGIONCITYAREASELECTUI = 175,		-- 军团城池区域选择界面界面
	UI_LEGIONCITYLOGUI = 176,				-- 军团城池战报界面
	UI_LEGIONCITYATTACKLISTUI = 177,		-- 军团城池攻击列表界面
	UI_LEGIONCITYUPGRADEUI = 178,			-- 军团城池升级界面
	UI_MINE = 179,				            -- 挖矿主界面
	UI_MINECOLLECTQUEUE = 180,				-- 挖矿收矿队列
	UI_MINECOLLECTLIST = 181,				-- 挖矿收矿结果
	UI_LEGIONMEMBERLISTUI = 182,			-- 军团成员大厅界面
	UI_ARENA_V2_DAILY = 183,				-- 竞技场每日奖励 界面V2
	UI_ACTIVITYGIFTDETAIL = 184,			-- 竞技场每日奖励 界面V2(已删除)
	UI_ARENA_HIGHESTRANK = 185,				-- 竞技场最高排行
	UI_RESCOPY_DIFFICULTY = 186,			-- 资源副本难度选择
	UI_ACTIVITY_PETITIONHELP = 187,			-- 活动请愿东风帮助界面
	UI_ACTIVITY_PETITIONTIPS = 188,			-- 活动请愿东风Tips界面
	UI_RANKINGLIST_V3 = 189,				-- 排行榜 第三版
	UI_TASKATT = 190,						-- 主线任务属性
	UI_EXCHANGEEGG = 191,					-- 兑换材料(已删除)
	UI_ROLETUPOINFO = 192,					-- 武将突破详细信息
	UI_DRESSMERGE = 193,					-- 小兵装备合成
	UI_LEGIONEXPINFO = 194,					-- 军团经验tips
	UI_MINEENTRANCE = 195,					-- 金矿入口
	UI_DRAGONHELP = 196,					-- 龙蛋帮助界面
	UI_ROLEATTTIPS = 197,					-- 武将属性tips
	UI_MILITARYUI = 198,					-- 军机处
	UI_NOTICE = 199,					    -- 公告
	UI_KING_LVUP = 200,					    -- 君主等级提升
	UI_CHART_MAIN_PANNEL = 201,				-- 图鉴主界面
	UI_CHART_INFO = 202,				    -- 图鉴卡牌信息
	UI_MILITARYGETWAYUI = 203,			    -- 军机处前往
	UI_TAVEN_TEN_PANNEL = 204,			    -- 招募十连抽
	UI_TAVEN_LIMIT_PANNEL = 205,			-- 招募限时抽奖
	UI_TAVEN_LIMIT_AWARD_PANNEL = 206,		-- 招募限时奖励获得
	UI_TAVEN_EXCHANGE_PANNEL = 207,			-- 招募将星兑换
	UI_MAP_GOD = 208,						-- 得物品，黑底
	UI_EMBATTLE = 209,						-- 防守布阵
	UI_SKILL_SELECT = 210,					-- 技能选择
	UI_LIUBEI_INFO = 211,					-- 刘备信息
	UI_LEGIONWAR_MAIN = 212,				-- 军团战主界面
	UI_LEGIONWAR_AWARDS = 213,				-- 军团战团战奖励界面
	UI_LEGIONWAR_BATTLELIST = 214,			-- 军团战历史战绩界面
	UI_LEGIONWAR_BATTLE = 215,				-- 军团战战斗界面
	UI_LEGIONWAR_LOG = 216,					-- 军团战日志界面
	UI_LEGIONWAR_CITYINFO = 217,			-- 军团战节点信息界面
	UI_LEGIONWAR_CITYDEF = 218,				-- 军团战防守增筑界面
	UI_LEGIONWAR_CITYDEFLIST = 219,			-- 军团战防守派遣界面
    UI_COUNTRY_JADE_MAIN_PANNEL = 220,		-- 国家合璧主界面
    UI_COUNTRY_JADE_CHOOSECOUNTRY = 221,	-- 国家合璧选择国家
    UI_COUNTRY_JADE_REPORT = 222,		    -- 国家合璧战报
    UI_COMMON_TIPS = 223,		            -- 通用tips
    UI_LUCKY_WHEEL_RANK = 224,		        -- 幸运转盘全服排行榜
	UI_BATTLEREPORTRESULT = 225,			-- 战报结算界面
	UI_EXPEDITION_CELL = 226,				-- 内城界面
    UI_COUNTRY_JADE_AWARD_PANNEL = 227,		-- 国家合璧奖励查看界面
	UI_HEROBOX = 228,						-- 武将选择箱
	UI_LEGIONWAR_BUFF = 229,				-- 军团战妙计界面
	UI_LEGIONWAR_RANKINFO = 230,			-- 军团战段位总览
	UI_TAVERN_MASTER = 231,					-- 名人招募
	UI_GET_MONEY_DRAGON = 232,				-- 招财龙
	UI_WAR_COLLEGE = 233,					-- 战争学院
    UI_HELP_MAIN_PANNEL = 234,			    -- 帮助界面
    UI_TREASURE_MERGE_PANEL = 235,			-- 龙晶合成界面
    UI_ROLE_SELECT_FIGHT = 236,			    -- 选择武将界面
    UI_TIPS_DRAGONGEM = 237,				-- 龙晶tips界面
    UI_LEGION_DONATE = 238,					-- 军团捐献界面
    UI_TRIBUTE = 239,						-- 百姓进贡界面
    UI_DRAGON_INFO = 240,					-- 龙信息界面
    UI_GUIDESTORY = 241,					-- 引导剧情界面
    UI_LORDCOUNTRYSALARY = 242,				-- 太守国俸界面
    UI_DRAGON_DIDI_PANEL = 243,			    -- 滴滴打龙界面
    UI_POKEDEX = 244,			    		-- 图鉴界面
    UI_POKEDEX_HERO = 245,			    	-- 图鉴全图界面
    UI_POINTS_EXCHANGE_AWARD = 246,			-- 积分兑换奖励界面
    UI_ACTIVE_TAVERN_ACTIVE_BOX = 247,		-- 招募活动宝箱界面
    UI_ACTIVE_TAVERN_ACTIVE_AWARD = 248,	-- 招募活动领取卡牌界面
    UI_COUNTRY_JADE_SUCESS_PANEL = 249,	    -- 合璧成功或被抢界面
    UI_SKILL_UPGRADE_PANEL = 250,	    	-- 技能升级界面(已删除)
    UI_GET_WAY_DROP = 251,	    	        -- 宝箱道具具体内容展示
    UI_GUIDE_UPGRADE_GOD = 252,	    	    -- 新手引导神器升星
    UI_EQUIP_DISMANTLING = 253,	    		-- 拆解
    UI_CHICKEN_SUIT = 254,	    		    -- 鸡年套装
    UI_OPEN_BOX = 255,	                    -- 开宝箱
    UI_LEGION_TRIAL_MAIN_PANNEL = 256,	    -- 军团试炼开黑主界面
    UI_LEGION_TRIAL_GET_AWARD_PANNEL = 257, -- 军团试炼领取奖励界面
    UI_LEGION_TRIAL_RESET_COIN_PANNEL = 258,-- 军团试炼重置硬币界面
    UI_LEGION_TRIAL_ACHIEVEMENT_PANNEL = 259,-- 军团试炼成就界面
    UI_LEGION_TRIAL_ADD_RATE_PANNEL = 260,  -- 军团试炼倍率显示界面
    UI_LEGION_TRIAL_ADVENTURE_PANNEL = 261, -- 军团试炼冒险界面
    UI_DIGMINE = 262,						-- 新版挖矿
    UI_GEM_FILL = 263,	                    -- 宝石镶嵌
    UI_EQUIP_REFINE = 264,	                -- 装备精炼
    UI_EQUIP_REFINE_LV_UP = 265,	        -- 装备精炼升级
    UI_GEM_MERGE_MAIN = 266,	        	-- 宝石一键合成主界面
    UI_GEM_MERGE = 267,	        			-- 宝石一键合成
    UI_BATTLE_COUNTER_V2 = 268,	        	-- 兵种克制界面
    UI_EQUIP_UPGRADE_STAR = 269,	        -- 装备升星

    UI_INLAY_DRAGON_GEM = 270,	        	-- 龙晶镶嵌界面
    UI_TIPS_DRAGONGEM_FRAGMENT = 271,       -- 龙晶碎片tips界面
    UI_ROLE_LV_UP_ONE_LEVEL_PANNEL = 272,	-- 武将提升一级界面
    UI_COUNTRY_PILLAR = 273,				-- 国家栋梁
    UI_LEGION_MEMBER_AGAINST_PANEL = 274,	-- 团员弹劾界面
    UI_GET_WAY_FRAGMENT_UI_PANNEL = 275,	-- 碎片tips

    UI_INFINITE_BATTLE_MAIN = 276,			-- 无限关卡主界面
    UI_INFINITE_BATTLE = 277,				-- 无限关卡关卡
    UI_INFINITE_BATTLE_BOSS = 278,			-- 无限关卡BOSS界面
    UI_INFINITE_STAR_AWARD = 279,			-- 无限关卡星星奖励
    UI_INFINITE_BATTLE_BOSS_LEVEL_UP = 280,	-- 无限关卡BOSS升级界面
    UI_FRIENDS_MAIN_PANEL = 281,			-- 好友主界面
    UI_FRIENDS_FIND_PANEL = 282,			-- 好友搜索界面
    UI_FRIENDS_FINDBOSS_PANEL = 283,		-- 好友boss搜索界面
    UI_FRIENDS_BOSS_PANEL = 284,			-- 好友boss界面
    UI_FRIENDS_RANK_PANEL = 285,			-- 好友伤害排行界面
    UI_FRIENDS_AWARDS_PANEL = 286,			-- 好友伤害排行奖励界面
    UI_TOTAL_BATTLE_REPORT = 287,			-- 总战报界面
    UI_FRIENDS_BOSS_RESULT = 288,			-- 好友BOSS结算界面
    UI_WORLD_MAP_UI = 289,                  -- 领地战
    UI_WORLD_MAP_ELEMENT = 290,             -- 领地战资源采集界面
    UI_WORLD_MAP_CREATURE = 291,            -- 领地战生物采集界面
    UI_WORLD_MAP_ATTACKPLAYER = 292,        -- 领地战攻击玩家
    UI_WORLD_MAP_FUNC = 293,                -- 领地战功能界面
    UI_WORLD_MAP_EXPLOR = 294,              -- 领地战探索界面
    UI_WORLD_MAP_ACHIEVE = 295,             -- 领地战成就界面
    UI_WORLD_MAP_MATERIAL = 296,            -- 领地战材料界面
    UI_WORLD_MAP_ENEMYLIST = 297,           -- 领地战敌人列表
    UI_WORLD_MAP_MESSAGEBOX = 298,          -- 领地战确认框
    UI_LEGION_BUILDING_UPGRADE = 299,       -- 城池升级界面
    UI_LEGION_CITY_COMPARE = 300,           -- 城池对比界面
    UI_WORLD_MAP_ELEMENTVT = 301,           -- 领地战功能新界面
    UI_ACTIVITY_ONE_YUAN_BUY = 302,			-- 1元购界面
    UI_JADE_SEAL_AWARD_NEW = 303,			-- 领取武将新界面
    UI_GET_WAY_FRAGMENT_SPECIAL = 304,		-- 新的碎片tips
    UI_WORLD_MAP_SAMLL_MAP = 305,			-- 领地战小地图
    UI_POP_WINDOW_MAIN_OPEN_SEVEN = 306,	-- 弹窗主界面-七天乐
    UI_WORLD_MAP_REPORT = 307,		        -- 领地战战报
    UI_ACTIVITY_ONE_YUAN_BUY = 308,			-- 1元购界面
    UI_JADE_SEAL_AWARD_NEW = 309,			-- 领取武将新界面
    UI_GET_WAY_FRAGMENT_SPECIAL = 310,		-- 新的碎片tips
    UI_POP_WINDOW_MAIN_FIRST_PAY = 311,		-- 弹窗主界面-首充
    UI_CHECK_INFO_MAIN = 312,		        -- 玩家信息查看新界面
    UI_LEGION_CITY_UPGRAGE_EFFECT = 313,	-- 军团城池升级效果界面
    UI_ACTIVITY_THREE_YUAN_BUY = 314,		-- 3元购界面
    UI_NEW_CHAT = 315,		                -- 新版聊天
    UI_DIGMINE_EVENT = 316,					-- 挖矿事件界面
    UI_SIX_SELECT_ONE_AWARD = 317,			-- 六选一转盘界面
    UI_TIPS_JADE_SEAL_ADDITION = 318,		-- 玉玺加成tips界面
    UI_WORLD_MAP_BOSS = 319,				-- 领地战BOSS
    UI_WORLD_MAP_BELONG = 320,				-- 领地战BOSS奖励归属
    UI_WORLD_MAP_DAMAGE_RANK = 321,			-- 领地战BOSS伤害排行
    UI_WORLD_MAP_BOSS_LIST = 322,			-- 领地战BOSS列表
    UI_LEGION_WISH_GIVE_MAIN = 323,	        -- 军团许愿赠送主界面
    UI_LEGION_WISH_GIVE_GIFT = 324,		    -- 军团许愿赠送弹窗界面
    UI_LEGION_WISH_LOG = 325,		        -- 军团许愿赠送日志界面
    UI_LEGION_WISH_MAKE_WISH = 326,		    -- 军团许愿许愿望界面
    UI_LEGION_WISH_WEEK_AWARD = 327,		-- 军团许愿周奖励界面
    UI_WORLD_MAP_BOSS_TIP = 328,			-- 领地战Boss界面tips
    UI_ROLE_FATE_FATE_CONSPIRACY_ACTIVE = 329,		    -- 缘分激活界面
    UI_ROLE_FATE_FATE_CONSPIRACY_CHOOSE_HERO = 330,		-- 缘分选择武将界面
    UI_ROLE_FATE_FATE_CONSPIRACY_UPGRADE = 331,		    -- 缘分升级界面界面
    UI_ROLE_PROMOTED_PANEL = 351,			-- 武将封神界面
	UI_ROLE_PROMOTED_TIPS_PANEL = 352,		-- 武将封神tips界面
	UI_ROLE_PROMOTED_UPGRADE_PANEL = 353,	-- 武将封神升级界面
	UI_ROLE_PROMOTED_PROVIEW_PANEL = 354,	-- 武将封神预览界面
	UI_ROLE_PROMOTED_UPGRADEMAX_PANEL = 355,-- 武将封神品质提升界面
	UI_ROLE_PROMOTED_LUCKY_WHEEL_PANEL = 356,-- 武将封神幸运转盘界面
	UI_ROLE_PROMOTED_LUCKY_WHEEL_RANK_PANEL = 357,-- 武将封神幸运转盘排行界面
	UI_BATTLE_COUNT_DOWN = 358,					-- 计算战斗倒计时界面
	UI_WORLD_MAP_RULE_BOOK = 359,			-- 领地战图鉴
	UI_SITTING_HEAD_FRAME = 360,			-- 更换头像框
	UI_RES_GET_BACK = 361,					-- 资源找回主界面
	UI_RES_GET_BACK_CELL = 362,				-- 资源找回界面
	UI_NEW_TASK = 363,						-- 新任务界面
	UI_NEW_TASK_NOBILITY = 364,				-- 任务爵位展示界面
	UI_NEW_TASK_NOBILITY_UP = 365,			-- 任务爵位晋级界面
	UI_NEW_LEGIONCITY_SUIPIAN = 366,		-- 碎片获得途径界面
    UI_CITY_CRAFT_REMARK_PANEL = 367,		-- 关卡备注界面
    UI_CHART_PROMOTED_PROVIEW_PANEL = 368,	-- 将星录封将技能界面
    UI_PEOLPLE_KING_MAIN = 369,				-- 人皇主界面
    UI_PEOLPLE_KING_CHANGE_LOOK = 370,		-- 幻形界面
    UI_PEOLPLE_KING_AWAKE_WEAPON = 372,		-- 圣武觉醒界面
    UI_PEOLPLE_KING_SKILL_UP = 373,			-- 人皇技能提升界面
    UI_PEOLPLE_KING_SUIT_BUFF = 374,		-- 人皇套装加成
    UI_PEOLPLE_KING_GET_SURFACE = 375,		-- 人皇获得外观界面
    UI_ACTIVITY_EIGHT_YUAN_BUY = 376,		-- 8元购界面
    UI_ACTIVITY_PROMOTE_GET_SOUL = 377,		-- 封将送将魂活动
	UI_COUNTRYWAR_MAP = 380,		        -- 国战地图
	UI_COUNTRYWAR_MAIN = 381,		        -- 国战主界面
	UI_COUNTRYWAR_AWARD = 382,		        -- 国战奖励
	UI_COUNTRYWAR_LIST = 383,		        -- 国战排行
	UI_COUNTRYWAR_ORDER = 384,		        -- 国战集结令
	UI_COUNTRYWAR_TASK = 385,		        -- 国战任务
	UI_COUNTRYWAR_BATTLEFIELD_INFO = 386,	-- 国战战场信息
	UI_COUNTRYWAR_MATCH = 387,		        -- 国战匹配界面
	UI_COUNTRYWAR_CITY_INFO = 388,		    -- 国战城池信息
	UI_COUNTRYWAR_VICTORY = 389,		    -- 国战胜利界面
	UI_COUNTRYWAR_DEFEAT = 390,			    -- 国战失败界面
	UI_COUNTRYWAR_CITY_LOG = 391,			-- 国战城池日志
	UI_COUNTRYWAR_CITY_PLAYER_INFO = 392,	-- 国战城池玩家信息
	UI_POP_WINDOW_MAIN_DAILY_RECHARGE = 393,		        -- 弹窗主界面-每日充值
	UI_POP_WINDOW_MAIN_SINGLE_RECHARGE = 394,		        -- 弹窗主界面-单充
	UI_POP_WINDOW_MAIN_EXCHANGE_POINTS = 395,		        -- 弹窗主界面-积分兑换
	UI_POP_WINDOW_MAIN_TODAY_DOUBLE = 396,		            -- 弹窗主界面-今日双倍
	UI_POP_WINDOW_MAIN_TAVERN_RECRUIT = 397,		        -- 弹窗主界面-限时酒馆招募
	UI_POP_WINDOW_MAIN_LUCKY_DRAGON = 398,		            -- 弹窗主界面-招财龙
	UI_POP_WINDOW_MAIN_TAVERN_RECRUIT_LEVEL = 399,		    -- 弹窗主界面-等级酒馆招募
	UI_RES_GET_BACK_ALL = 400,				-- 资源全部找回界面
	UI_OPEN_RANK = 401,						-- 开服排行
    UI_ACTIVITY_HAPPY_WHEEL_LOG = 402,	    -- 祈福历史
	UI_AUTOREBORN = 430,					-- 一键突破
	UI_AUTOUPGRADESTAR = 431,				-- 一键升品

	UI_EXCLUSIVE_MAIN = 440,				-- 宝物主界面
	UI_EXCLUSIVE_RECRUIT_ENTRANCE = 441,	-- 宝物入口
	UI_CHOOSE_EXCLUSIVE2_PANEL = 442,		-- 替换宝物
	UI_EXCLUSIVE_CHECK_MAIN = 443,		    -- 鉴宝主界面
	UI_EXCLUSIVE_POKEDEX = 444,				-- 宝物图鉴
	UI_EXCLUSIVE_TIPS = 445,				-- 宝物图鉴
    UI_EXCLUSIVE_CHECK_TEN_MAIN = 446,		-- 鉴宝十连抽
    UI_EXCLUSIVE_ANIMATE = 447,		        -- 鉴宝抽奖动画

	UI_CLOUD_BUY_ITEM = 448,				-- 云购道具
	UI_CLOUD_BUY_NOTICE = 449,				-- 云购奖励公示
	UI_CLOUD_BUY_MY_CODE = 450,				-- 我的云购码

	UI_MILITARY_ENTRANCE = 451,				-- 指引入口
	UI_GEMUPGRADE_NEW = 452,				-- 宝石合成新

	UI_EXCLUSIVE_PUT = 453,					-- 宝物放入
	UI_TERRITORIALWAR_GET_ALL = 454,		-- 宝物放入
	UI_NB_SKY = 455,						-- 宝物放入
	UI_NB_SKY_DISPLAY = 456,				-- 宝物放入
	UI_INTEGRAL_CARNIVAL_AWARD = 457,		-- 积分奖励界面

	UI_GUIDECREATENAME = 458,				-- 新手引导设置名字界面

	UI_LV_GROW_FUND = 459,					-- 主界面成长基金
	-- UI_LV_GROW_FUND_CELL = 460,				-- 主界面成长基金CELL

	UI_RECHARGE_WAITING = 900,			    -- 充值等待
	UI_LOGIN_YSDK = 901,					-- 腾讯sdk登录界面
	UI_CREATENAME = 999					    -- 创建账号
}

local UI_TYPE = {
	MAINSCENE = 1,
	BATTLE = 2,
	MENU = 3,
	ACTOIN = 4,
	GUIDE = 5,
	MESSAGE = 6
}

cc.exports.UI_SHOW_TYPE = {
	STUDIO = 1,
	MOVEINL = 2,
	SCALEIN = 3,
	CUSTOM = 999
}

cc.exports.UI_HIDE_TYPE = {
	STUDIO = 1,
	MOVEOUTR = 2,
	SCALEOUT = 3
}

local MESSAGEBOX_TAG = 9999
local LOADING_TAG = 1000
local BLOCK_TOUCH_LOADING = 888

-- 目录层 3 	包括SideBar
-- 动画层 4 	包括各种 跨界面无法确定坐标的层
-- 新手引导层 5
-- 提示层 6 	包括各种 messageBox 各种弹窗 更新属性 等等

function UIManager:init(scene, node)
	self.scene = scene
	self.mainNode = node
	self.guideNode = cc.Node:create()	-- 新手引导
	self.actionNode = cc.Node:create()	-- 跨界面动画Node
	self.menuNode = cc.Node:create()	-- 目录Node
	self.notice = promptmgr:init() -- 弹窗界面
	self.touchwidget = ccui.Widget:create()
	local winSize = cc.Director:getInstance():getWinSize()
	self.touchwidget:setContentSize(winSize)
	self.touchwidget:setAnchorPoint(cc.p(0,0))
	self.notice:setContentSize(winSize)
	self.notice:setPosition(cc.p(winSize.width/2,winSize.height/2))
	self.notice:setAnchorPoint(cc.p(0.5,0.5))
	self.sidebar = self:getSidebar()
	if not self.sidebar then
		self.sidebar = require('script/app/ui/sidebar/sidebarui').new()
	end
	local sidebarNode = self.sidebar:getNode()
	self.menuNode:addChild(sidebarNode)
	scene:addChild(self.menuNode, 3)
	scene:addChild(self.actionNode, 4)
	scene:addChild(self.guideNode, 5)
	scene:addChild(self.notice, 6)
	scene:addChild(self.touchwidget, 7)
	self.widgetArr = {}
	self.widgetMap = {}
	self.topNodeIndex = 0
	self.topZOrder = 0
	self.uiConf = GameData:getConfData('local/ui')
	self.currBgm = 0
	self:initTouchLayer()
end

function UIManager:showUI(uiObj, showType)

	if self.widgetMap[uiObj.uiIndex] ~= nil then
		print("already show")
		for k, v in pairs(self.widgetArr) do
			if v.uiIndex == uiObj.uiIndex and self.topNodeIndex ~= uiObj.uiIndex then
				local obj = table.remove(self.widgetArr, k)
				table.insert(self.widgetArr, obj)
				self.topZOrder = self.topZOrder + 1
				if self.widgetMap[self.topNodeIndex] then
					self.widgetMap[self.topNodeIndex]:onCover()
				end
				self.topNodeIndex = obj.uiIndex
				obj.root:setLocalZOrder(self.topZOrder)
				self.sidebar:show(uiObj.uiData.sidebar,uiObj.uiData.sz)
				CustomEventMgr:dispatchEvent(CUSTOM_EVENT.UI_SHOW, obj.uiIndex)
				obj:onShow()
				if obj.uiData.bgm > 0 and obj.uiData.bgm ~= self.currBgm then
					self.currBgm = obj.uiData.bgm
					AudioMgr.PlayAudio(obj.uiData.bgm)
				end
				break
			end
		end
		return
	end

	local uiData = self.uiConf[uiObj.uiIndex]
	if not uiData then
		print("can not find ui from dat")
		return
	end

	-- 处理互斥
	if uiData.mutex > 0 then
		for k, v in pairs(self.widgetArr) do
			if uiData.mutex == v.uiData.mutex then
				print("find a mutex ui:" .. v.uiData.name)
				self:hideMutexUI(v)
				break
			end
		end
	end

	local widgetPath = uiData.uiPath
	local node = cc.CSLoader:createNode(widgetPath)
	self.sidebar:show(uiData.sidebar,uiData.sz)
	self.topZOrder = self.topZOrder + 1

	if(uiData.uiType == UI_TYPE.MENU) then
		self.menuNode:addChild(node, self.topZOrder)
	else
		self.mainNode:addChild(node, self.topZOrder)
	end
	print("going to show:" .. uiData.className)

	if self.widgetMap[self.topNodeIndex] then
		self.widgetMap[self.topNodeIndex]:onCover()
	end
	table.insert(self.widgetArr, uiObj)
	self.widgetMap[uiObj.uiIndex] = uiObj
	self.topNodeIndex = uiObj.uiIndex
	uiObj:initWithNode(node, uiData)
	if uiData.bgm > 0 and uiData.bgm ~= self.currBgm then
		self.currBgm = uiData.bgm
		AudioMgr.PlayAudio(uiData.bgm)
	end
	if showType then
		if showType == UI_SHOW_TYPE.STUDIO then
			self:setBlockTouch(true)
			local action = cc.CSLoader:createTimeline(widgetPath)
			node:runAction(action)
			action:gotoFrameAndPlay(0, false)
			-- action:play("show", false)
			self.mainNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
				-- xx.Utils:Get():setActionTimelineAnimationEndCallFunc(action, "show", function ()
				-- 	xx.Utils:Get():removeActionTimelineAnimationEndCallFunc(action, "show")
					self:setBlockTouch(false)
					uiObj:_onShowUIAniOver()
				-- end)
			end)))
		elseif showType == UI_SHOW_TYPE.MOVEINL then
			if node:getChildrenCount() > 0 then
				local child = node:getChildren()[1]
				if child:getChildrenCount() > 0 then
					self:setBlockTouch(true)
					local child2 = child:getChildren()[1]
					local endPos = cc.p(child2:getPosition())
					local winSize = cc.Director:getInstance():getWinSize()
					local startPos = cc.p(-winSize.width/2, endPos.y)
					child2:setPosition(startPos)
					child2:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.MoveTo:create(0.3, endPos), cc.CallFunc:create(function ()
						self:setBlockTouch(false)
						uiObj:_onShowUIAniOver()
					end)))
				end
			end
		elseif showType == UI_SHOW_TYPE.SCALEIN then
			if node:getChildrenCount() > 0 then
				local child = node:getChildren()[1]
				if child:getChildrenCount() > 0 then
					self:setBlockTouch(true)
					local child2 = child:getChildren()[1]
					local currScale = child2:getScale()
					child2:setScale(0)
					child2:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.ScaleTo:create(0.3, currScale), cc.CallFunc:create(function ()
						self:setBlockTouch(false)
						uiObj:_onShowUIAniOver()
					end)))
				end
			end
		end
	else
		uiObj:_onShowUIAniOver()
	end
end

function UIManager:hideUI(uiObj, hideType)
	if self.widgetMap[uiObj.uiIndex] == nil then -- 并没有打开这个界面
		print("not show:" .. uiObj.uiData.className)
		return
	end
	print("going to hide:" .. uiObj.uiData.className)
	local function finalHide()
		uiObj:onClose()
		uiObj.root:removeFromParent()
		self.widgetMap[uiObj.uiIndex] = nil
		local widgetNum = #self.widgetArr
		if self.topNodeIndex == uiObj.uiIndex then -- 需要关闭的界面在最上层
			table.remove(self.widgetArr)
			widgetNum = widgetNum - 1
			if widgetNum > 0 then
				local topNode = self.widgetArr[widgetNum]
				self.topNodeIndex = topNode.uiIndex
				self.topZOrder = topNode:getLocalZOrder()
				self.sidebar:show(topNode.uiData.sidebar,topNode.uiData.sz)
				CustomEventMgr:dispatchEvent(CUSTOM_EVENT.UI_SHOW, topNode.uiIndex)
				topNode:onShow()
				if topNode.uiData.bgm > 0 then
					if topNode.uiData.bgm ~= self.currBgm then
						self.currBgm = topNode.uiData.bgm
						AudioMgr.PlayAudio(topNode.uiData.bgm)
					end
				elseif uiObj.uiData.bgm ~= 0 then
					local bgm = nil
					while widgetNum > 1 do
						widgetNum = widgetNum - 1
						local nextNode = self.widgetArr[widgetNum]
						if nextNode.uiData.bgm > 0 then
							bgm = nextNode.uiData.bgm
							break
						end
					end
					if bgm and bgm ~= self.currBgm then
						self.currBgm = bgm
						AudioMgr.PlayAudio(bgm)
					end
				end
			end
		else
			for i = widgetNum, 1, -1 do
				if uiObj == self.widgetArr[i] then
					table.remove(self.widgetArr, i)
					break
				end
			end
		end
	end
	if hideType then
		if hideType == UI_HIDE_TYPE.STUDIO then
			self:setBlockTouch(true)
			self.mainNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
				local action = cc.CSLoader:createTimeline(widgetPath)
				uiObj.root:runAction(action)
				action:play("hide", false)
				xx.Utils:Get():setActionTimelineAnimationEndCallFunc(action, "hide", function ()
					xx.Utils:Get():removeActionTimelineAnimationEndCallFunc(action, "hide")
					self:setBlockTouch(false)
					finalHide()
				end)
			end)))
		elseif hideType == UI_HIDE_TYPE.MOVEOUTR then
			if uiObj.root:getChildrenCount() > 0 then
				local child = uiObj.root:getChildren()[1]
				if child:getChildrenCount() > 0 then
					self:setBlockTouch(true)
					local child2 = child:getChildren()[1]
					local startPos = cc.p(child2:getPosition())
					local winSize = cc.Director:getInstance():getWinSize()
					local endPos = cc.p(startPos.x + winSize.width, startPos.y)
					child2:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.MoveTo:create(0.3, endPos), cc.DelayTime:create(0.05), cc.CallFunc:create(function ()
						self:setBlockTouch(false)
						finalHide()
					end)))
				else
					finalHide()
				end
			else
				finalHide()
			end
		elseif hideType == UI_HIDE_TYPE.SCALEOUT then
			if uiObj.root:getChildrenCount() > 0 then
				local child = uiObj.root:getChildren()[1]
				if child:getChildrenCount() > 0 then
					self:setBlockTouch(true)
					local child2 = child:getChildren()[1]
					child2:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.ScaleTo:create(0.3, 0), cc.DelayTime:create(0.05), cc.CallFunc:create(function ()
						self:setBlockTouch(false)
						finalHide()
					end)))
				else
					finalHide()
				end
			else
				finalHide()
			end
		else
			finalHide()
		end
	else
		finalHide()
	end
end

function UIManager:hideMutexUI(uiObj)
	if self.widgetMap[uiObj.uiIndex] == nil then -- 并没有打开这个界面
		print("not show:" .. uiObj.uiData.className)
		return
	end
	print("going to hide mutexUI:" .. uiObj.uiData.className)
	uiObj:onClose()
	self.mainNode:removeChild(uiObj.root)
	self.widgetMap[uiObj.uiIndex] = nil
	for k, v in pairs(self.widgetArr) do
		if uiObj == v then
			table.remove(self.widgetArr, k)
			break
		end
	end
	self.mainNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
	    collectgarbage("collect")
	end)))
end

-- old api
-- function UIManager:showPrompt(str, color, prompt)
-- 	if self.prompt then
-- 		local label = self.prompt:getChildByTag(1)
-- 		label:setTextColor(color)
-- 		label:setString(str)
-- 		self.prompt:stopAllActions()
-- 		self.prompt:setOpacity(255)
-- 	else
-- 		self.prompt = prompt
-- 		self:addToPromptNode(prompt, 1)
-- 	end
-- 	self.prompt:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.FadeOut:create(1), cc.CallFunc:create(function ()
-- 	    self.prompt:removeFromParent()
--      	self.prompt = nil
-- 	end)))
-- end

-- old api
-- 废弃
-- function UIManager:addToPromptNode(node, promptType)
-- 	if promptType == 2 then
-- 		local node1 = self.promptNode:getChildByTag(MESSAGEBOX_TAG)
-- 		if node1 then
-- 			node1:removeFromParent()
-- 		end
-- 		node:setTag(MESSAGEBOX_TAG)
-- 	end
-- 	self.promptNode:addChild(node)
-- 	node:setLocalZOrder(promptType)
-- end

function UIManager:addAction(node)
	self.actionNode:addChild(node)
end

function UIManager:clearAction()
	self.loadingFlag = nil
	self.loadingUI = nil
	self.actionNode:removeAllChildren()
	self.touchwidget:removeChildByTag(BLOCK_TOUCH_LOADING)
end

function UIManager:showSidebar(tab1,tab2,isFadeIn,isNotUpdateNewImgs)
	self.sidebar:show(tab1,tab2,isFadeIn,isNotUpdateNewImgs)
end

function UIManager:getIsHide()
	return self.sidebar:getIsHide()
end

function UIManager:runNum(ntype,num)
	self.sidebar:runNum(ntype,num)
end

function UIManager:updateSidebar()
	self.sidebar:update()
end

function UIManager:getSidebar()
	return self.sidebar
end

function UIManager:closeAllUI()
	local uiCount = #self.widgetArr
	for i = uiCount, 1, -1 do
		local obj = table.remove(self.widgetArr, i)
		print("going to hide ui by closeall:" .. obj.uiData.className)
		obj:onClose()
		obj.root:removeFromParent()
	end
	self.topNodeIndex = 0
	self.topZOrder = 0
	self.widgetArr = {}
	self.widgetMap = {}
	collectgarbage("collect")
	collectgarbage("collect")
	Game:releaseCaches()
end

function UIManager:removeAll()
	local uiCount = #self.widgetArr
	for i = uiCount, 1, -1 do
		local obj = table.remove(self.widgetArr, i)
		obj:onClose()
		obj.root:removeFromParent()
	end
	self.topNodeIndex = 0
	self.topZOrder = 0
	self.widgetArr = {}
	self.widgetMap = {}
	self.scene:removeAllChildren()
	self.currBgm = 0
	AudioMgr.stopMusic()
	collectgarbage("collect")
	collectgarbage("collect")
	Game:releaseCaches()
end

-- 暂时并没有用到 万一以后需要呢？
--[[
function UIManager:createCamera()
	-- WTF
	if not self.camera then
		local director = cc.Director:getInstance()
		local winSize = director:getWinSize()
		local eyez = director:getZEye()
		self.camera = cc.Camera:createPerspective(60, winSize.width / winSize.height, 10, eyez + winSize.height / 2)
		self.camera:setPosition3D(cc.vec3(winSize.width / 2, winSize.height / 2, eyez))
		self.camera:lookAt(cc.vec3(winSize.width / 2, winSize.height / 2, 0), cc.vec3(0, 1, 0))
		self.camera:setCameraFlag(cc.CameraFlag.USER1)
		self.scene:addChild(self.camera)
	end

	return self.camera
end

function UIManager:clearCamera()
	if self.camera then
		self.camera:removeFromParent()
		self.camera = nil
	end
end
]]
-- 新手引导相关
function UIManager:getGuideNode()
	return self.guideNode
end

function UIManager:getTopNodeIndex()
	return self.topNodeIndex
end

function UIManager:getUIByIndex(index)
	return self.widgetMap[index]
end


function UIManager:runLoadingAction(autoRemove, callback)
	local winSize = cc.Director:getInstance():getWinSize()
	local widget = ccui.Widget:create()
	widget:setTag(BLOCK_TOUCH_LOADING)
	widget:setContentSize(winSize)
	widget:setAnchorPoint(cc.p(0,0))
	widget:setTouchEnabled(true)
	self.touchwidget:addChild(widget)
	
	local ani = GlobalApi:createAniByName("ui_loading")
	ani:setScale(10)
	ani:setTag(LOADING_TAG)
	ani:setPosition(cc.p(winSize.width/2, winSize.height/2))
	ani:getAnimation():playWithIndex(0, -1, 0)
	self.actionNode:addChild(ani)
	self.loadingFlag = true
	ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
		if movementType == 1 then
			self.touchwidget:removeChildByTag(BLOCK_TOUCH_LOADING)
			if autoRemove then
				ani:removeFromParent()
				self.loadingFlag = nil
			else
				if self.loadingFlag then
					self.loadingFlag = nil
				else
					ani:removeFromParent()
				end
			end
			if callback then
				callback()
			end
		end
	end)
end

function UIManager:removeLoadingAction()
	if self.loadingFlag then
		self.loadingFlag = nil
	else
		self.actionNode:removeChildByTag(LOADING_TAG)
	end
end

function UIManager:getLoadingUI()
	if self.loadingUI == nil then
		self.loadingUI = require("script/app/ui/loading/loadingui").new(2)
		local panel = self.loadingUI:getPanel()
		self.actionNode:addChild(panel)
		local winSize = cc.Director:getInstance():getWinSize()
		panel:setPosition(cc.p(winSize.width/2, winSize.height/2))
	end
	return self.loadingUI
end

function UIManager:hideLoadingUI()
	if self.loadingUI then
		self.loadingUI:removeFromParent()
		self.loadingUI = nil
	end
end

function UIManager:initTouchLayer()
	self.touchwidget:setTouchEnabled(true)
	self.touchwidget:setSwallowTouches(false)
	self.touchEffectSpeed = 1
	self.touchwidget:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			local pos = sender:getTouchBeganPosition()
			local selectAni = self:getClickAni()
			selectAni:getAnimation():play("idle" .. math.random(1, 5), -1, 0)
			selectAni:setPosition(pos)
		end
	end)
end

function UIManager:getClickAni()
	local ani
	if #self.clickAniArr > 0 then
		ani = table.remove(self.clickAniArr)
	else
		ani = GlobalApi:createLosslessAniByName("ui_dianji")
		self.touchwidget:addChild(ani)
		ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
			if movementType == 1 then
				ani:setVisible(false)
				table.insert(self.clickAniArr, ani)
			end
		end)
	end
	ani:getAnimation():setSpeedScale(self.touchEffectSpeed)
	ani:setVisible(true)
	return ani
end

function UIManager:setTouchEffectSpeed(speed)
	if self.touchEffectSpeed ~= speed then
		self.touchEffectSpeed = speed
		local children = self.touchwidget:getChildren()
		for k, v in pairs(children) do
			v:getAnimation():setSpeedScale(speed)
		end
	end
end

function UIManager:setBlockTouch(flag)
	self.touchwidget:setSwallowTouches(flag)
end

function UIManager:isBlockTouch()
	return self.touchwidget:isSwallowTouches()
end

function UIManager:playCurrBgm()
	if self.currBgm > 0 then
		AudioMgr.PlayAudio(self.currBgm)
	end
end

function UIManager:playBgm(id)
	local bgmId = cc.AUDIO_INVAILD_ID
	if self.currBgm ~= id then
		self.currBgm = id
		bgmId = AudioMgr.PlayAudio(self.currBgm)
	end
	return bgmId
end

function UIManager:backToLogin()
	collectgarbage("restart")
	CustomEventMgr:dispatchEvent(CUSTOM_EVENT.BACK_TO_LOGIN)
    if UserData and UserData:getUserObj() and UserData:getUserObj().Sid then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(UserData:getUserObj().Sid)
        UserData:getUserObj().Sid = nil
    end
    GuideMgr:forceOver()
	self:closeAllUI()
	self:hideLoadingUI()
	self:clearAction()
	Game:purgeWhenBackToLogin()
	self.currBgm = 0

	LoginMgr:showLogin()
	LoginMgr:showCreateName()
end

function UIManager:getMainScene()
	return self.scene
end

function UIManager:showLoadMask()
	if self.loadMask == nil then
		self.loadMask = require("script/app/ui/loading/loadMask").new()

		local panel = self.loadMask:getRoot()
		local winSize = cc.Director:getInstance():getWinSize()
		panel:setPosition(cc.p(winSize.width/2, winSize.height/2))
		self.touchwidget:addChild(panel)
	end
end

function UIManager:hideLoadMask()
	if self.loadMask then
		local panel = self.loadMask:getRoot()
		panel:removeFromParent()
		self.loadMask = nil
	end
end