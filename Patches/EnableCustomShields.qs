

MaxShield = 10;
function EnableCustomShields()
{
    var offset = pe.stringVa("_\xB0\xA1\xB5\xE5");
    if (offset === -1)
    {
        return "Failed in Step 1 - Guard not found";
    }

    var code = " C7 ?? 04" + offset.packToHex(4);
    var type = 2;

    var hookReq = pe.findCode(code);

    if (hookReq === -1)
    {
        code = code.replace("C7 ?? 04", " 6A 03 8B ?? C7 00");

        type = 1;

        hookReq = pe.findCode(code);
    }

    if (hookReq === -1)
    {
        return "Failed in Step 1 - Guard reference missing";
    }

    var regPush;
    if (type === 1)
    {
        regPush = " 83 E8 04 50";
    }
    else
    {
        regPush = pe.fetchHex(hookReq + 1, 1).replace("4", "5");
    }

    offset = pe.stringVa("_\xB9\xF6\xC5\xAC\xB7\xAF");
    if (offset === -1)
    {
        return "Failed in Step 1 - Buckler not found";
    }

    if (type === 1)
    {
        code = " C7 00" + offset.packToHex(4);
    }
    else
    {
        code = " C7 ?? 08" + offset.packToHex(4);
    }

    offset = pe.find(code, hookReq, hookReq + 0x38);
    if (offset === -1)
    {
        return "Failed in Step 1 - Buckler reference missing";
    }

    var retReq = offset + code.hexlength();

    var funcName = "ReqShieldName\x00";
    var free = alloc.find(funcName.length + 0xB + 0x50 + 0x12);
    if (free === -1)
    {
        return "Failed in Part 2 - Not enough free space";
    }

    code =
        funcName.toHex() +
        " 60" +
        " BF 01 00 00 00" +
        " BB" + MaxShield.packToHex(4);

    var result = GenLuaCaller(free + code.hexlength(), funcName, pe.rawToVa(free), "d>s", " 57");
    if (result.indexOf("LUA:") !== -1)
    {
        return result;
    }

    code += result;

    code +=
        " 8A 08" +
        " 84 C9" +
        " 74 07" +
        " 8B 4C 24 20" +
        " 89 04 B9" +
        " 47" +
        " 39 DF" +
        " 7E";

    code += (funcName.length + 0xB - (code.hexlength() + 1)).packToHex(1);

    code +=
        " 61" +
        " 83 C4 04" +
        " E9";

    code += (pe.rawToVa(retReq) - pe.rawToVa(free + code.hexlength() + 4)).packToHex(4);

    pe.insertHexAt(free, code.hexlength(), code);

    code = regPush + " E9";
    code += (pe.rawToVa(free + funcName.length) - pe.rawToVa(hookReq + code.hexlength() + 4)).packToHex(4);

    pe.replaceHex(hookReq, code);

    var retVal = InjectLuaFiles(
        "Lua Files\\DataInfo\\jobName",
        [
            "Lua Files\\DataInfo\\ShieldTable",
            "Lua Files\\DataInfo\\ShieldTable_F",
        ]
    );
    if (typeof retVal === "string")
    {
        return retVal;
    }

    code =
        " 3D D0 07 00 00" +
        " 7E ??" +
        " 50" +
        getEcxSessionHex() +
        " E8";

    var offsets = pe.findCodes(code);
    if (offsets.length === 0)
    {
        return "Failed in Step 3 - GetShieldType call missing";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        offset = pe.find("E8 ?? ?? ?? ?? 85 C0", offsets[i] - 0x40, offsets[i]);

        if (offset === -1)
        {
            offset = pe.find("E8 ?? ?? ?? ?? 33 ?? 85 C0", offsets[i] - 0x40, offsets[i]);
        }

        if (offset !== -1)
        {
            break;
        }
    }

    if (offset === -1)
    {
        return "Failed in Step 3 - GetWeaponType call missing";
    }

    pe.replaceHex(offset, " 90 58 83 C8 FF");

    offset = offsets[0] + code.hexlength();
    var hookMap = offset + 4 + pe.fetchDWord(offset);

    funcName = "GetShieldID\x00";
    free = alloc.find(funcName.length + 0x5 + 0x3D + 0x4);
    if (free === -1)
    {
        return "Failed in Part 4 - Not enough free space";
    }

    code =
        funcName.toHex() +
        " 52" +
        " 8B 54 24 08";

    result = GenLuaCaller(free + code.hexlength(), funcName, pe.rawToVa(free), "d>d", " 52");
    if (result.indexOf("LUA:") !== -1)
    {
        return result;
    }

    code += result;

    code +=
        " 5A" +
        " C2 04 00";

    pe.insertHexAt(free, code.hexlength(), code);

    pe.replaceHex(hookMap, "E9" + (pe.rawToVa(free + funcName.length) - pe.rawToVa(hookMap + 5)).packToHex(4));

    code =
        " 50" +
        " 6A 05" +
        " 8B";
    offset = pe.find(code, hookReq - 0x30, hookReq);

    if (offset === -1)
    {
        code =
            " 05 00 00 00" +
            " 2B";

        offset = pe.find(code, hookReq - 0x60, hookReq);
        if (offset === -1)
        {
            return "Failed in Step 5 - No Allocator PUSHes found";
        }

        pe.replaceHex(offset, MaxShield.packToHex(4));

        code =
            " 83 F8 05" +
            " 73";

        offset = pe.find(code, offset - 0x10, offset);
        if (offset === -1)
        {
            return "Failed in Step 5 - Comparison Missing";
        }
    }
    pe.replaceByte(offset + 2, MaxShield);

    return true;
}
