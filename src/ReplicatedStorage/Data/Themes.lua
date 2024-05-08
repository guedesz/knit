
local Themes = {
    THEMES_AMOUNT = 2
}

Themes.List = {

    [1] = {
        MinLevel = 1,
        MaxLevel = 4,
        Name = "Castle",
    },

    [2] = {
        MinLevel = 5,
        MaxLevel = 15,
        Name = "Testing"
    },
}


function Themes:getThemeByLevel(level: number)
    
    local themeName, Theme
    for i = 1, self.THEMES_AMOUNT do
        local theme = Themes.List[i]

        if level < theme.MinLevel then
            continue
        end

       themeName = theme.Name
       Theme = theme
    end

    if not themeName then
       return false, warn("error getting theme for level:", level)
    end

    return themeName, Theme
end

return Themes