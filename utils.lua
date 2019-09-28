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

function clip(subjectPolygon, clipPolygon)
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
    return outputList
end

function polygonCenter(polygon)
    local x, y
    for _, p in ipairs(polygon) do
        x = x + p.x
        y = y + p.y
    end

    return x / #polygon, y / #polygon
end

function printTable(table, indent)
    indent = indent or 0

    if indent == 0 then
        print("<table>")
    end

    for k, v in pairs(table) do
        if type(v) == "table" then
            print(string.rep(">", indent + 1) .. k)
            printTable(v, indent + 2)
        else
            print(string.rep(">", indent + 1) .. k, v)
        end
    end

    if indent == 0 then
        print("</table>")
    end
end
