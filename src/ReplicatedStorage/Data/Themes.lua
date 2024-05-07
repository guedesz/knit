local Themes = {

}

Themes.List = {

    ["Castle"] = {
        MinLevel = 1,
        MaxLevel = 5,
        Name = "Castle",
    },

    ["Testing"] = {
        MinLevel = 5,
        MaxLevel = 15,
        Name = "Testing"
    },



}

function Themes:getThemeByLevel(level: number)
    

    for themeName, info in self.List do
        
        if level < info.MinLevel then
            continue
        end

        if level > info.MaxLevel then
            continue
        end

        return themeName, info
    end

    warn("error getting theme for level:", level)
    return false
end

return Themes