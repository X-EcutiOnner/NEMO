// /=====================================================///
// / Patch Functions wrapping over EnableSkills function ///
// /=====================================================///

SKL =
{
    "Offset": -1,
    "Prefix": "",
    "PatchID": false,
    "Error": false,
};

function LoadSkillTypeLua(id, offset)
{
    if (SKL.Prefix === "")
    {
        SKL.Prefix = "Lua Files\\SkillInfo";
        if (pe.getDate() >= 20100817)
        {
            SKL.Prefix += "z";
        }
    }

    if (!SKL.PatchID)
    {
        SKL.Offset = InjectLuaFiles(
            SKL.Prefix + "\\SkillInfo_F",
            [
                SKL.Prefix + "\\SkillType",
                SKL.Prefix + "\\SkillType_F",
            ],
            offset
        );
        if (typeof SKL.Offset === "string")
        {
            SKL.Error = SKL.Offset;
            SKL.Offset = -1;
        }
        else
        {
            SKL.Error = false;
            SKL.PatchID = id;
        }
    }
}

function EnableSkills(oldPatn, newPatn, patchID, funcName, isPlayerFn)
{
    var code;
    if (pe.getDate() < 20100817)
    {
        code = oldPatn;
    }
    else
    {
        code = newPatn;
    }

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - ID checker missing";
    }

    var fnBegin;
    if (HasFramePointer())
    {
        fnBegin = offset - 6;
    }
    else
    {
        fnBegin = offset - 3;
    }

    if (isPlayerFn)
    {
        LoadSkillTypeLua(patchID, fnBegin + 0x100);
    }
    else
    {
        LoadSkillTypeLua(patchID);
    }

    if (typeof SKL.Error === "string")
    {
        return "Failed in Step 2 - " + SKL.Error;
    }
    var result;

    if (isPlayerFn)
    {
        result = GenLuaCaller(fnBegin + 4, funcName, pe.rawToVa(fnBegin + 0x80), "d>d", " 50");
        if (result.indexOf("LUA:") !== -1)
        {
            return result;
        }
        code =
            " 8B 44 24 04"   +
            result   +
            " C3";

        pe.replaceHex(fnBegin, code);

        pe.replace(fnBegin + 0x80, funcName);
    }
    else
    {
        var free = alloc.find(funcName.length + 0x3D + 1);
        if (free === -1)
        {
            return "Failed in Step 4 - Not enough free space";
        }

        result = GenLuaCaller(free, funcName, pe.rawToVa(fnBegin + 0x10), "d>d", " 52");
        if (result.indexOf("LUA:") !== -1)
        {
            return result;
        }
        code =
            funcName.toHex() +
            result +
            " C3";

        pe.insertHexAt(free, code.hexlength(), code);

        code =
            " 52" +
            " 8B 54 24 08" +
            " E8" + GenVarHex(1) +
            " 5A" +
            " C2 04 00";
        code = ReplaceVarHex(code, 1, pe.rawToVa(free + funcName.length) - pe.rawToVa(fnBegin + 10));

        pe.replaceHex(fnBegin, code);
    }
    return true;
}

function _EnableSkills(patchID)
{
    if (SKL.PatchID === patchID)
    {
        SKL.PatchID = false;
        for (var id = 229; id <= 231; id++)
        {
            if (id !== patchID && RefreshPatch(id))
            {
                break;
            }
        }
    }
}

function _EnablePlayerSkills()
{
    _EnableSkills(233);
}

function _EnableHomunSkills()
{
    _EnableSkills(234);
}

function _EnableMerceSkills()
{
    _EnableSkills(235);
}

function EnableMerceSkills()
{
    return EnableSkills(
        " 3D 08 20 00 00"   +
        " 7C ??"   +
        " 3D 31 20 00 00"
        ,
        " 8D ?? F8 DF FF FF"   +
        " 83 ?? 29"
        ,
        235,
        "IsMercenarySkill\0",
        false
    );
}

function EnablePlayerSkills()
{
    return EnableSkills(
        " 3D 7D 02 00 00" +
        " 0F 8F ?? ?? 00 00" +
        " 3D 7C 02 00 00",
        " 3D 06 01 00 00" +
        " 7F ??" +
        " 0F 84 ?? ?? 00 00",
        233,
        "IsPlayerSkill\0",
        true
    );
}

function EnableHomunSkills()
{
    return EnableSkills(
        " 3D 40 1F 00 00"   +
        " 7C ??"   +
        " 3D 51 1F 00 00"
        ,
        " 05 C0 E0 FF FF"   +
        " B9 2C 00 00 00"
        ,
        234,
        "IsHomunSkill\0",
        false
    );
}
