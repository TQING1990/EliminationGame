
-- 消除方向: 横向和纵向
local Direction = {
    HORIZONTAL = { tag = "h", x = -1, y = 0 },
    VERTICAL = { tag = "v", x = 0, y = 1 },
}

-- 用于递归获取连续相同颜色的点
-- 正向
local POSITIVE = 1
-- 反向
local REVERSE = -1

-- 消除最小数量
local ELIMINATE_MIN_COUNT = 3

local function log(fmt, ...)
    print(string.format(fmt, ...))
end

local function getPoint(matrix, x, y)
    return matrix[y] and matrix[y][x]
end

local function nextContinuousPoint(matrix, ret, point, direction, positiveOrReverse)
    local x, y = direction.x * positiveOrReverse, direction.y * positiveOrReverse
    log("(%s,%s)->(%s,%s)", point.x, point.y, point.x + x, point.y + y)
    local nextPoint = getPoint(matrix, point.x + x, point.y + y)
    if nextPoint then
        if nextPoint.color == point.color then
            if nil == nextPoint[direction.tag] then
                table.insert(ret, nextPoint)
                nextContinuousPoint(matrix, ret, nextPoint, direction, positiveOrReverse)
            else
                return false
            end
        else
            log("Different colors")
            return true
        end
    else
        log("Point is not exist")
        return true
    end
end

local function getContinuousPoints(matrix, point, direction)
    local ret = {}
    log("\ngetContinuousPoints point(%s,%s)", point.x, point.y)
    log("\ndirection(%s:%s,%s)", direction.tag, direction.x * POSITIVE, direction.y * POSITIVE)
    nextContinuousPoint(matrix, ret, point, direction, POSITIVE)
    log("\ndirection(%s:%s,%s)", direction.tag, direction.x * REVERSE, direction.y * REVERSE)
    nextContinuousPoint(matrix, ret, point, direction, REVERSE)
    if next(ret) then
        return ret
    else
        -- 这里可以回收 ret
        return nil
    end
end

local function add(ret, point)
    if not point.mark then
        local x, y = point.x, point.y
        ret[y] = ret[y] or {}
        ret[y][x] = point
        point.mark = true
    end
end

local DirectionList = { Direction.HORIZONTAL, Direction.VERTICAL }
local function eliminate(matrix, ret, point)
    for _, direction in pairs(DirectionList) do
        local tag = direction.tag
        if nil == point[direction.tag] then
            local points = getContinuousPoints(matrix, point, direction)
            if points then
                -- 连续的点没有包括自己，所以要减 1
                if #points >= ELIMINATE_MIN_COUNT - 1 then
                    -- 把自己加入到结果中，并且标记这个方向已经ok
                    add(ret, point)
                    point[tag] = true

                    -- 把其他点加入到结果中，并且标记这个方向已经ok
                    for i, p in ipairs(points) do
                        add(ret, p)
                        p[tag] = true
                    end

                    for i, p in ipairs(points) do
                        eliminate(matrix, ret, p)
                    end
                else
                    for i, p in ipairs(points) do
                        p[tag] = false
                    end
                end
            else
                point[tag] = false
            end
        end
    end
end

--[[
    将配置转换为矩阵
    为了直观，将配置的表转换为下面这样的坐标系
    {
       ^
       |  {1, 1, 1, 1, 1, 1, 1},
       |  {1, 2, 2, 2, 1, 1, 1},
       |  {1, 1, 1, 1, 1, 1, 1},
       |  {1, 2, 2, 1, 1, 1, 1},
       |  {1, 1, 1, 1, 1, 1, 1},
       ————————————————————————————>
    }
 
]]
local function convertMatrix(config)
    local matrix = {}
    local ySize = #config
    for i, xl in ipairs(config) do
        local y = ySize - i + 1
        local t = {}
        matrix[y] = t
        for x, color in ipairs(xl) do
            t[x] = { x = x, y = y, color = color }
        end
    end
    return matrix
end

local matrix = convertMatrix {
    {1, 1, 1, 1, 1, 1, 1},
    {1, 2, 2, 2, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 2, 2, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
}

local ret = {}
eliminate(matrix, ret, getPoint(matrix, 2, 4))

local function dump(result)
    for y = 5, 1, -1 do
        local t = {}
        for x = 1, 7 do
            if result[y] and result[y][x] then
                table.insert(t, "o")
            else
                table.insert(t, "x")
            end
        end
        log(table.concat(t, " "))
    end
end

dump(ret)
