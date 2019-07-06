/*---------------------------------------------------------------------------
	Global tables
---------------------------------------------------------------------------*/
UBR.Languages = {}


/*---------------------------------------------------------------------------
	Loading language files
---------------------------------------------------------------------------*/
local langPath = GM.FolderName.."/language/"
local langFiles = file.Find(langPath.."*.lua", "LUA")
for k, v in pairs(langFiles) do
	local fp = langPath..v
	if(SERVER) then	AddCSLuaFile(fp) end

	local tbl = include(fp)
	local name = string.StripExtension(v)

	UBR.Languages[name] = tbl
end


/*---------------------------------------------------------------------------
	Returning the table of a language by name (or default language)
---------------------------------------------------------------------------*/
function UBR.GetLanguageTable(name)
	local lang = UBR.Languages[name || UBR.Config.Language]
	return lang || {}
end


/*---------------------------------------------------------------------------
	Resolves a language string
---------------------------------------------------------------------------*/
function UBR.ResolveString(str, ...)
	return string.format(UBR.GetLanguageTable()[str] || "[INVALID] "..str, ...)
end