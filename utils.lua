function math.sign(v)
    return (v >= 0 and 1) or -1
end

function math.round(v, bracket)
    bracket = bracket or 1
    return math.floor((v or 0) / bracket + math.sign(v or 0) * 0.5) * bracket
end

function inside(p, cp1, cp2)
    return (cp2.x - cp1.x) * (p.y - cp1.y) > (cp2.y - cp1.y) * (p.x - cp1.x)
end

function intersection(cp1, cp2, s, e)
    local dcx, dcy = cp1.x - cp2.x, cp1.y - cp2.y
    local dpx, dpy = s.x - e.x, s.y - e.y
    local n1 = cp1.x * cp2.y - cp1.y * cp2.x
    local n2 = s.x * e.y - s.y * e.x
    local n3 = 1 / (dcx * dpy - dcy * dpx)
    local x = (n1 * dpx - n2 * dcx) * n3
    local y = (n1 * dpy - n2 * dcy) * n3
    return {x = x, y = y}
end

function clip(_subjectPolygon, _clipPolygon)
    local subjectPolygon = toCoordinates(_subjectPolygon)
    local clipPolygon = toCoordinates(_clipPolygon)

    local outputList = subjectPolygon
    local cp1 = clipPolygon[#clipPolygon]
    for _, cp2 in ipairs(clipPolygon) do -- WP clipEdge is cp1,cp2 here
        local inputList = outputList
        outputList = {}
        local s = inputList[#inputList]
        for _, e in ipairs(inputList) do
            if inside(e, cp1, cp2) then
                if not inside(s, cp1, cp2) then
                    outputList[#outputList + 1] = intersection(cp1, cp2, s, e)
                end
                outputList[#outputList + 1] = e
            elseif inside(s, cp1, cp2) then
                outputList[#outputList + 1] = intersection(cp1, cp2, s, e)
            end
            s = e
        end
        cp1 = cp2
    end
    return fromCoordinates(outputList)
end

function toCoordinates(vertices)
    local result = {}
    for i = 1, #vertices, 2 do
        result[#result + 1] = {x = vertices[i], y = vertices[i + 1]}
    end
    return result
end

function fromCoordinates(vertices)
    local result = {}
    for i, p in ipairs(vertices) do
        result[#result + 1] = p.x
        result[#result + 1] = p.y
    end
    return result
end

function table.copy(mytable) --mytable = the table you need to copy
    newtable = {}

    for k, v in pairs(mytable) do
        newtable[k] = v
    end
    return newtable
end

function prettyprint(...)
    local myVar = {...}

    local output = {}
    for i, v in pairs(myVar) do
        output[#output + 1] = math.round(v, 0.01)
    end
    print(unpack(output))
end

function fif(condition, trueValue, falseValue)
    if condition then
        return trueValue
    else
        return falseValue
    end
end
