local ClassDisplayObj = require("script/app/obj/displayobj")

cc.exports.DisplayData = {

}

function DisplayData:getDisplayObj(data)
	return ClassDisplayObj.new(data)
end

function DisplayData:getDisplayObjs(datas)
    local arr = {}
    if datas then
        for k, v in ipairs(datas) do
            table.insert(arr, ClassDisplayObj.new(v))
        end
    end
    return arr
end