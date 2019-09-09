
local function log(fmt, ...)
    print(string.format(fmt, ...))
end

local function convertMatrix(config)
    local matrix = {}
    for y, xl in ipairs(config) do
        local t = {}
        matrix[y] = t
        for x, color in ipairs(xl) do
            t[x] = { x = x, y = y, color = color }
        end
    end
    return matrix
end

local function getPoint(matrix, x, y)
    return matrix[y] and matrix[y][x]
end


local Direction = {
    HORIZONTAL = { tag = "h", x = -1, y = 0 },
    VERTICAL = { tag = "v", x = 0, y = 1 },
}

local DirectionList = { Direction.HORIZONTAL, Direction.VERTICAL }

local function nextContinuousPoint(matrix, ret, point, direction, x, y)
    log("(%s,%s)->(%s,%s)", point.x, point.y, point.x + x, point.y + y)
    local nextPoint = getPoint(matrix, point.x + x, point.y + y)
    if nextPoint then
        if nextPoint.color == point.color then
            if nil == nextPoint[direction.tag] then
                table.insert(ret, nextPoint)
                nextContinuousPoint(matrix, ret, nextPoint, direction, x, y)
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
    local x, y = direction.x, direction.y
    log("\ngetContinuousPoints point(%s,%s)", point.x, point.y)
    log("\ndirection(%s:%s,%s)", direction.tag, direction.x, direction.y)
    nextContinuousPoint(matrix, ret, point, direction, x, y)
    log("\ndirection(%s:%s,%s)", direction.tag, -direction.x, -direction.y)
    nextContinuousPoint(matrix, ret, point, direction, -x, -y)
    if next(ret) then
        return ret
    else
        -- 这里可以回收 ret
        return nil
    end
end

local function add(ret, point)
    local x, y = point.x, point.y
    ret[y] = ret[y] or {}
    ret[y][x] = point
end

local function eliminate(matrix, ret, point)
    for _, direction in pairs(DirectionList) do
        local tag = direction.tag
        if nil == point[direction.tag] then
            local points = getContinuousPoints(matrix, point, direction)
            if points then
                if #points >= 2 then
                    add(ret, point)
                    point[tag] = true

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

local matrix = convertMatrix {
    {1, 1, 1, 1, 1, 1, 1},
    {1, 2, 2, 2, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 2, 2, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
}

local function dump(ret)
    for y = 1, 5 do
        local t = {}
        for x = 1, 7 do
            if ret[y] and ret[y][x] then
                table.insert(t, "o")
            else
                table.insert(t, "x")
            end
        end
        log(table.concat(t, " "))
    end
end

local ret = {}
eliminate(matrix, ret, matrix[2][2])

dump(ret)
