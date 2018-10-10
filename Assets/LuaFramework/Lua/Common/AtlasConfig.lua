
local atlasConfig = {
    ["Button"] = {
		Name = "sprite",
		AtlasPath = "Assets/LuaFramework/AssetsPackage/UI/Image/Button/anniu.png",
	},
}

function AtlasConfig(name)
    return atlasConfig[name]
end

--util:SetSprite(LoginPanel.btnLogin,AtlasConfig("Button").Name,AtlasConfig("Button").AtlasPath);