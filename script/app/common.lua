-- add by Ferchiel
-- mail: ferchiel@163.com
-- C++ used

-- local RTL_UNDERLINE_COLOR_TYPE = {
-- 	FONT_COLOR = 1,
-- 	STROKE_COLOR = 2,
-- 	CUSTOM_COLOR = 3,
-- }

cc.exports.Config = {
	-- RT = RichText
	-- RTE = RichTextElement
	-- RTL = RichTextLabel
	-- RTA = RichTextAtlas
	RTL_FONT = 'font/gamefont.ttf',
	RTL_FONT_SIZE = 22,
	RTL_STROKE_SIZE = 1,
	RTL_UNDERLINE_SIZE = 2,
	RTL_UNDERLINE_COLOR_TYPE = 'FONT_COLOR',		--
	RTL_SHADOW_SIZE = cc.size(0, -1),
	RTL_SHADOW_COLOR = cc.c4b(64, 64, 64, 255),
	RTL_MIN_WIDTH = -1,
	RTA_FONT = 'uires/ui/number/font_fightforce_2.png',
	RTA_WIDTH = 16,
	RTA_HEIGHT = 20,
	RTA_START = '0',
	RT_ROW_SPACING = 0,
	RTL_TAB_INSTEAD = '    ',
	RT_MINIMUM_ROW_HEIGHT = 10,
	RT_HORIZONTAL_ALIGNMENT = 'left',			-- left middle right
	RT_VERTICAL_ALIGNMENT = 'bottom',
	RT_DEBUG_LINE = false,
}

-- 不能忍啊！
-- _G.table.find = function(t, e)
--     for i, v in ipairs(t) do
--         if v == e then
--             return i
--         end
--     end
--     return 0
-- end



