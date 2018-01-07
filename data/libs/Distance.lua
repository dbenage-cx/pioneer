-- Copyright © 2018 Pioneer Developers. See AUTHORS.txt for details
-- Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

local Lang = import("Lang")

local l = Lang.GetResource("core")

local Distance = {}
Distance.__index = Distance

setmetatable(Distance, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

Distance.UnitType = {}

Distance.UnitType["M"]                  =   {basemeters = 1,                    name = l.UNIT_METERS}
Distance.UnitType["METERS"]             =   {basemeters = 1,                    name = l.UNIT_METERS}
Distance.UnitType["KM"]                 =   {basemeters = 1000,                 name = l.UNIT_KILOMETERS}
Distance.UnitType["KILOMETERS"]         =   {basemeters = 1000,                 name = l.UNIT_KILOMETERS}
Distance.UnitType["MM"]                 =   {basemeters = 1000000,              name = l.UNIT_MILLION_METERS}
Distance.UnitType["MILLION_METERS"]     =   {basemeters = 1000000,              name = l.UNIT_MILLION_METERS}
Distance.UnitType["AU"]                 =   {basemeters = 149597870700,         name = l.UNIT_AU}
Distance.UnitType["ASTRONOMICAL_UNITS"] =   {basemeters = 149597870700,         name = l.UNIT_AU}
Distance.UnitType["LY"]                 =   {basemeters = 9460730472580800,     name = l.UNIT_LY}
Distance.UnitType["LIGHT_YEARS"]        =   {basemeters = 9460730472580800,     name = l.UNIT_LY}
-- Distance.UnitType["PC"]                 =   {basemeters = 30856775814913673,    name = l.UNIT_PARSEC}
-- Distance.UnitType["PARSEC"]             =   {basemeters = 30856775814913673,    name = l.UNIT_PARSEC}


function Distance.new(conv_value, unit_type)
    local self = setmetatable({}, Distance)
    if not unit_type then unit_type = "M" end
    local conv_ratio = self.UnitType[unit_type].basemeters
    self.value = conv_value * conv_ratio
    return self
end

-- Method:get
--
-- Return value of distance in meters or in provided unit type
--
-- > distance:get(unit_type)
--
-- Parameters:
--
--   unit_type - optional, key for converted to unit type, defaults to "METERS"
--
function Distance:get(unit_type)
    if not self then self = setmetatable({}, Distance) end
    if not unit_type then unit_type = "METERS" end
    local conv_ratio = self.UnitType[unit_type].basemeters
    return self.value / conv_ratio
end


-- Method:to_string
--
-- Return value formatted to string with a unit type identifier
--
-- > distance:to_string(cutoff_factor, format_token)
--
-- Parameters:
--
--   cutoff_factor - optional, factor applied to base conversion rate to determine suitability of a unit type, defaults to 0.66
--
--   format_token - optional, string format template which is passed a numeric and string value, defaults to "%.2f%s"
--
function Distance:to_string(cutoff_factor, format_token)
    if not self then self = setmetatable({}, Distance) end
    if self.value <= 0 then return "" end

    if not cutoff_factor then cutoff_factor = 0.66 end
    if not format_token then format_token = "%.2f%s" end

    local value, name
    -- provide exception to cutoff of parsec, to utilize light year more commonly
    -- if self.value > self.UnitType["LY"].basemeters * 1000 * cutoff_factor then
    --     value = self:get("PC")
    --     name = self.UnitType["PC"].name
    -- else
    if self.value > self.UnitType["LY"].basemeters * cutoff_factor then
        value = self:get("LY")
        name = self.UnitType["LY"].name
    elseif self.value > self.UnitType["AU"].basemeters * cutoff_factor then
        value = self:get("AU")
        name = self.UnitType["AU"].name
    elseif self.value > self.UnitType["MM"].basemeters * cutoff_factor then
        value = self:get("MM")
        name = self.UnitType["MM"].name
    elseif self.value > self.UnitType["KM"].basemeters * cutoff_factor then
        value = self:get("KM")
        name = self.UnitType["KM"].name
    else
        value = self:get("M")
        name = self.UnitType["M"].name
    end

    return string.format(format_token, value, name)
end

-- Function:convert
--
-- Converts a given value from one unit type to another
--
-- > Distance.convert(value, from, to)
--
-- Parameters:
--
--   value - value to convert from
--
--   from - unit type to convert from
--
--   to - unit type to convert to
--
function Distance.convert(value, from, to)
    local self = setmetatable({}, Distance)
    return (self.UnitType[from].basemeters * value) / self.UnitType[to].basemeters
end


return Distance
