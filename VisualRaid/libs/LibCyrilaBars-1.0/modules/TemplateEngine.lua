local MAJOR, MINOR = "tmp", 1
local tmp = {}

local lib = LibStub("LibCyrilaBars-1.0")

local templates = {}

function tmp:RegisterTemplate(name,tbl)
	templates[name] = tbl
end


lib:ModuleRegister(MAJOR, MINOR, tmp)

--lib:ModuleReplaceMethod("oldmethod", newmethod)