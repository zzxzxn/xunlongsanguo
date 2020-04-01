cc.exports.COLOR_TYPE = {
	RED = cc.c4b(255,30,0, 255),
	GREEN = cc.c4b(36,255,0, 255),
	BLUE = cc.c4b(58,205,248, 255),
	WHITE = cc.c4b(255,255,255, 255),
	BLACK = cc.c4b(0, 0, 0, 255),
	ORANGE = cc.c4b(254,165,0, 255),
	ORANGE1 = cc.c4b(254,108,0, 255),
	ORANGE2 = cc.c4b(249,221,84, 255),
	GOLD = cc.c4b(255,255,0, 255),
	GRAY = cc.c4b(163,163,163, 255),
	PURPLE = cc.c4b(216,93,235, 255),
	YELLOW = cc.c4b(246,255,0, 255),
	PALE = cc.c4b(255,247,228, 255), --标题亮白
	DARK = cc.c4b(207,186,141, 255), --标题灰暗
	OFFWHITE = cc.c4b(247,241,227, 255), -- 战斗力用米白色
	BROWN = cc.c4b(114,96,67,255), -- 新加的棕色
	TOWERATT = cc.c4b(159,133,97,255), -- 爬塔属性
	ZYQCOLOR = cc.c4b(107,20,133, 255), -- 捉妖曲新加颜色
	NEWPURPLE = cc.c4b(100,61,147, 255) -- 捉妖曲新加紫色
}

cc.exports.COLOR_QUALITY = {
	[1] = COLOR_TYPE.WHITE,--cc.c4b(255,255,255, 255),
	[2] = COLOR_TYPE.GREEN,--cc.c4b(115,255,91, 255),
	[3] = COLOR_TYPE.BLUE,--cc.c4b(0,246,255, 255),
	[4] = COLOR_TYPE.PURPLE,--cc.c4b(216,93,235, 255),
	[5] = COLOR_TYPE.ORANGE,--cc.c4b(254,165,0, 255),
	[6] = COLOR_TYPE.RED,--cc.c4b(255,30,0, 255)
	[7] = COLOR_TYPE.GOLD--cc.c4b(255,30,0, 255)
}

cc.exports.COLOROUTLINE_TYPE = {
	RED = cc.c4b(0, 0, 0, 255),
	GREEN = cc.c4b(0, 0, 0, 255),
	BLUE = cc.c4b(0, 0, 0, 255),
	WHITE = cc.c4b(0, 0, 0, 255),
	BLACK = cc.c4b(0, 0, 0, 255),
	ORANGE = cc.c4b(0, 0, 0, 255),
	ORANGE1 = cc.c4b(0, 0, 0, 255),
	GOLD = cc.c4b(0, 0, 0, 255),
	GRAY = cc.c4b(0, 0, 0, 255),
	PURPLE = cc.c4b(0, 0, 0, 255),
	YELLOW = cc.c4b(0, 0, 0, 255),
	PALE = cc.c4b(78,49,17, 255), --标题描边
	DARK = cc.c4b(78,49,17, 255), --标题描边
	OFFWHITE = cc.c4b(27,9,5, 255), -- 战斗力用米白色描边
	WHITE1 = cc.c4b(165,70,6, 255), -- 橙色按钮上的文字描边
	WHITE2 = cc.c4b(9,69,121, 255), -- 蓝色按钮上的文字描边
	WHITE3 = cc.c4b(13,97,2, 255), -- 绿色按钮上的文字描边
	GRAY1 = cc.c4b(89,89,89, 255), 	-- 按钮置灰的描边
	BROWN = cc.c4b(0,0,0,0), -- 新加的棕色
	TOWERATT = cc.c4b(78,49,17, 77), -- 爬塔属性
	ZYQCOLOR = cc.c4b(107,20,133, 255) -- 捉妖曲新加颜色
}

cc.exports.COLOROUTLINE_QUALITY = COLOROUTLINE_TYPE.BLACK

cc.exports.COLOROUTLINE_QUALITYFORJADESEAL = {
	[1] = cc.c4b(0,80,154,255),
	[2] = cc.c4b(23,96,6,255),
	[3] = cc.c4b(0,80,154,255),
	[4] = cc.c4b(95,6,96,255),
	[5] = cc.c4b(154,64,14,255),
	[6] = cc.c4b(143,5,5,255)
}

cc.exports.ENABLESHADOW_TYPE = {
	NORMAL = 1,
	TITLE = 2,
	FIGHTFORCE = 3,
	BUTTON = 4,
	BROWN = 5,
	WHITE = 6,
	RED = 7,
	YELLOW = 8,
}

cc.exports.DEFAULTEQUIP ={
	"uires/ui/common/default_tou.png",
	"uires/ui/common/default_wuqi.png",
	"uires/ui/common/default_yao.png",
	"uires/ui/common/default_xiong.png",
	"uires/ui/common/default_jiao.png",
	"uires/ui/common/default_xianglian.png"
}

cc.exports.DEFAULTEQUIPPART ={
	"uires/ui/common/default_tou_1.png",
	"uires/ui/common/default_wuqi_1.png",
	"uires/ui/common/default_yao_1.png",
	"uires/ui/common/default_xiong_1.png",
	"uires/ui/common/default_jiao_1.png",
	"uires/ui/common/default_xianglian_1.png"
}

cc.exports.DEFAULTSOLDEREQUIP ={
	"uires/ui/common/default_wuqi.png",
	"uires/ui/common/default_xianglian.png",
	"uires/ui/common/default_xiong.png",
	"uires/ui/common/default_tou.png",
	"uires/ui/common/default_jiao.png",
	"uires/ui/common/default_yao.png"
}

cc.exports.COLOR_FRAME = {
	[1] = "uires/ui/common/frame_gray.png",
	[2] = "uires/ui/common/frame_green.png",
	[3] = "uires/ui/common/frame_blue.png",
	[4] = "uires/ui/common/frame_purple.png",
	[5] = "uires/ui/common/frame_yellow.png",
	[6] = "uires/ui/common/frame_red.png",
	[7] = "uires/ui/common/frame_gold.png"
}

cc.exports.COLOR_FRAME_TYPE = {
	[1] = COLOR_FRAME[1],
	[2] = COLOR_FRAME[2],
	[3] = COLOR_FRAME[3],
	[4] = COLOR_FRAME[4],
	[5] = COLOR_FRAME[5],
	[6] = COLOR_FRAME[6],
	[7] = COLOR_FRAME[7],
	[11] = COLOR_FRAME[6]
}

cc.exports.COLOR_CHIP = {
	[1] = "uires/ui/common/chip_blue.png",
	[2] = "uires/ui/common/chip_blue.png",
	[3] = "uires/ui/common/chip_blue.png",
	[4] = "uires/ui/common/chip_purple.png",
	[5] = "uires/ui/common/chip_yellow.png",
	[6] = "uires/ui/common/chip_red.png",
	[7] = "uires/ui/common/chip_gold.png"
}

cc.exports.COLOR_CARDBG = {
	[1] = "uires/ui/common/card_blue.png",
	[2] = "uires/ui/common/card_green.png",
	[3] = "uires/ui/common/card_blue.png",
	[4] = "uires/ui/common/card_purple.png",
	[5] = "uires/ui/common/card_yellow.png",
	[6] = "uires/ui/common/card_red.png",
	[7] = "uires/ui/common/card_gold.png"
}

cc.exports.COLOR_TABBG = {
	[1] = "uires/ui/common/tab_blue.png",
	[2] = "uires/ui/common/tab_green.png",
	[3] = "uires/ui/common/tab_blue.png",
	[4] = "uires/ui/common/tab_purple.png",
	[5] = "uires/ui/common/tab_yellow.png",
	[6] = "uires/ui/common/tab_red.png",
	[7] = "uires/ui/common/tab_gold.png"
}

cc.exports.COLOR_TITLEBG = {
	[1] = "uires/ui/common/title_blue.png",
	[2] = "uires/ui/common/title_green.png",
	[3] = "uires/ui/common/title_blue.png",
	[4] = "uires/ui/common/title_purple.png",
	[5] = "uires/ui/common/title_yellow.png",
	[6] = "uires/ui/common/title_red.png",
	[7] = "uires/ui/common/title_gold.png"
}

cc.exports.COLOR_ITEMFRAME = {
	DEFAULT = "uires/ui/common/frame_gray.png",
	GRAY = "uires/ui/common/frame_gray.png",
	GREEN = "uires/ui/common/frame_green.png",
	BLUE = "uires/ui/common/frame_blue.png",
	PURPLE = "uires/ui/common/frame_purple.png",
	ORANGE = "uires/ui/common/frame_yellow.png",
	RED = "uires/ui/common/frame_red.png",
	GOLD = "uires/ui/common/frame_gold.png",
}

cc.exports.PROFESSIONTYPE_ICON = {
	"uires/ui/common/professiontype_1.png",
	"uires/ui/common/professiontype_2.png",
	"uires/ui/common/professiontype_3.png",
	"uires/ui/common/professiontype_4.png"
}

cc.exports.ABILITY_ICON = {
	[1] = 'uires/ui/common/professiontype_1.png',
	[2] = 'uires/ui/common/professiontype_2.png',
	[3] = 'uires/ui/common/professiontype_3.png',
	[4] = 'uires/ui/common/professiontype_4.png',
}

cc.exports.ATTRIBUTE_INDEX = {
	ATK = 1,
	PHYDEF = 2,
	MAGDEF = 3,
	HP = 4,
	HIT = 5,
	DODGE = 6,
	CRIT = 7,
	RESI = 8,
	MOVESPEED = 9,
	ATTACKSPEED = 10,
	DMGINCREASE = 11,
	DMGREDUCE = 12,
	CRITDMG = 13,
	IGNOREDEF = 14,
	CUREINCREASE = 15,
	DROPITEM = 16,
	DROPGOLD = 17,
	MP = 18,
	RECOVERMP = 19,
	HITPERCENT = 20,
	DODGEPERCENT = 21,
	CRITPERCENT = 22,
	RESIPERCENT = 23,
	MOVESPEEDPERCENT = 24,
	ATTACKSPEEDPERCENT = 25,
	PVPDMGINCREASE = 26,
	PVPDMGREDUCE = 27
}

cc.exports.CDTXTYPE = {
    FRONT = 1,           --文字在前
    BACK = 2,            --文字在后
    NONE = 3,            --无文字
}

cc.exports.MAXROlENUM = 7 --最大槽位
cc.exports.MAXEQUIPNUM = 6 --最多6件装备
cc.exports.MAXNUM = 18014398509481984 --2^54 设定一个最大数值
cc.exports.MAXSOLDIERLV = 15
cc.exports.MAXPROMOTEDLV = 15
cc.exports.MaxSkilLv = 15
cc.exports.GLOBAL_ZORDER = {
	GUIDE_FINGER = 99999 -- 新手引导的手指
}

cc.exports.ITEM_CELL_TYPE = {
	HEADPIC = 1,
	HERO = 2,
	ITEM = 3,
	SKILL = 4,
	OTHER = 5
}
