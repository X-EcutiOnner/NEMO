

function LoadCustomQuestLua()
{
    var prefix = "lua files\\quest\\";
    if (pe.stringRaw(prefix + "Quest_function") === -1)
    {
        return "Failed in Step 1 - Quest_function not found";
    }

    var f = new TextFile();
    if (!GetInputFile(f, "$inpQuest", _("File Input - Load Custom Quest Lua"), _("Enter the Lua list file"), APP_PATH + "/Support/Luafiles514/Lua Files/quest/quest_function.lub"))
    {
        return "Patch Cancelled";
    }

    var files = [];
    while (!f.eof())
    {
        var line = f.readline().trim();
        if (line.charAt(0) !== "/" && line.charAt(1) !== "/")
        {
            files.push(prefix + line);
        }
    }
    f.close();

    if (files.length > 0)
    {
        var retVal = InjectLuaFiles(prefix + "Quest_function", files);
        if (typeof retVal === "string")
        {
            return retVal;
        }
    }

    return true;
}

function LoadCustomQuestLua_()
{
    return pe.stringRaw("lua files\\quest\\Quest_function") !== -1;
}
