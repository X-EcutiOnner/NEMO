

function _IHL_InjectComparison(rcode, ptr, min, limit, opsize)
{
    var pre = "";
    if (opsize === 2)
    {
        pre = " 66";
    }

    var code =
        pre + " 83" + (0xB8 + rcode).packToHex(1) + ptr + min.packToHex(1) +
        " 7D 0A" +
        pre + " C7" + (0x80 + rcode).packToHex(1) + ptr + min.packToHex(opsize) +
        " 90";

    if (limit > 0x7F)
    {
        code += pre + " 81" + (0xB8 + rcode).packToHex(1) + ptr + limit.packToHex(opsize);
    }
    else
    {
        code += pre + " 83" + (0xB8 + rcode).packToHex(1) + ptr + limit.packToHex(1);
    }

    code +=
        " 7E 0A" +
        pre + " C7" + (0x80 + rcode).packToHex(1) + ptr + limit.packToHex(opsize) +
        " 90" +
        " C3";

    var free = alloc.find(code.hexlength());

    if (free !== -1)
    {
        pe.insertHexAt(free, code.hexlength(), code);
    }

    return free;
}

function _IHL_JumpNCall(begin, end, func)
{
    var code = " EB" + ((end - 5) - (begin + 2)).packToHex(1);
    pe.replaceHex(begin, code);

    code = " E8" + (pe.rawToVa(func) - pe.rawToVa(end)).packToHex(4);
    pe.replaceHex(end - 5, code);
}

function _IHL_UpdateScrollBar(oldLimit, newLimit)
{
    var code =
        " 6A" + (oldLimit + 1).packToHex(1) +
        " 6A 01" +
        " 6A" + oldLimit.packToHex(1) +
        " E8";

    var offsets = pe.findCodes(code);
    if (offsets.length === 0)
    {
        return -1;
    }

    var csize = code.hexlength();
    var func = pe.rawToVa(offsets[0] + csize + 4) + pe.fetchDWord(offsets[0] + csize);

    if (newLimit > 0x7E)
    {
        code = " 68" + (newLimit + 1).packToHex(4);
    }
    else
    {
        code = " 6A" + (newLimit + 1).packToHex(1);
    }

    code += " 6A 01";

    if (newLimit > 0x7F)
    {
        code += " 68" + newLimit.packToHex(4);
    }
    else
    {
        code += " 6A" + newLimit.packToHex(1);
    }

    code +=
        " E8" + GenVarHex(1) +
        " C3";

    var free = alloc.find(code.hexlength());
    if (free === -1)
    {
        return -2;
    }

    var freeRva = pe.rawToVa(free);

    code = ReplaceVarHex(code, 1, func - (freeRva + code.hexlength() - 1));

    pe.insertHexAt(free, code.hexlength(), code);

    for (var i = 0; i < offsets.length; i++)
    {
        pe.replaceHex(offsets[i], " 90".repeat(csize - 1));
        pe.replaceDWord(offsets[i] + csize, freeRva - pe.rawToVa(offsets[i] + csize + 4));
    }

    return 0;
}

function IncreaseHairLimits()
{
    var refOffset = pe.findCodes(" 68 14 27 00 00");
    if (refOffset.length === 0)
    {
        return "Failed in Step 1 - PUSH missing";
    }

    if (refOffset.length != 2)
    {
        return "Failed in Step 1 - PUSH count is wrong";
    }

    var index = 1;
    if (pe.getDate() >= 20180528)
    {
        index = 0;
    }
    refOffset = refOffset[index];

    var code =
        " 8B 8B ?? ?? 00 00" +
        " 41" +
        " 8B C1" +
        " 89 8B ?? ?? 00 00" +
        " 83 F8 08" +
        " 7E 06" +
        " 89 BB ?? ?? 00 00";
    var type = 1;
    var cmpLoc = 15;
    var offset = pe.find(code, refOffset + 0x60, refOffset + 0x220);

    if (offset === -1)
    {
        code =
            " FF 83 ?? ?? 00 00" +
            " 83 BB ?? ?? 00 00 08" +
            " 7E 0A" +
            " C7 83 ?? ?? 00 00 00 00 00 00";
        type = 2;
        cmpLoc = 6;
        offset = pe.find(code, refOffset + 0x160, refOffset + 0x1C0);
    }

    if (offset === -1)
    {
        code =
            " BB 01 00 00 00" +
            " 01 9D ?? ?? 00 00" +
            " 83 BD ?? ?? 00 00 08" +
            " 7E 06" +
            " 89 BD ?? ?? 00 00";
        type = 3;
        cmpLoc = 11;
        offset = pe.find(code, refOffset + 0x160, refOffset + 0x1C0);
    }

    if (offset === -1)
    {
        code =
            " 83 BB ?? ?? 00 00 00" +
            " 7D 0A" +
            " C7 83 ?? ?? 00 00 00 00 00 00" +
            " B8 07 00 00 00" +
            " 39 83 ?? ?? 00 00" +
            " 7E 06" +
            " 89 83 ?? ?? 00 00";
        type = 4;
        cmpLoc = 0;
        offset = pe.find(code, refOffset + 0x300, refOffset + 0x3C0);
    }

    if (offset === -1)
    {
        code =
            " 89 ?? ?? ?? 00 00" +
            " 85 C0" +
            " 79 0C" +
            " C7 83 ?? ?? 00 00 00 00 00 00" +
            " EB 0F" +
            " 83 F8 08" +
            " 7E 0A" +
            " C7 83 ?? ?? 00 00 08 00 00 00";
        type = 5;
        cmpLoc = 6;
        offset = pe.find(code, refOffset + 0x300, refOffset + 0x3C0);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - HairColor comparison missing";
    }

    var hCPtr = pe.fetchHex(offset + 2, 4);
    var hCBegin = offset + cmpLoc;
    var hCEnd = offset + code.hexlength();

    var hCLimit;
    if (type === 4)
    {
        hCLimit = 7;
    }
    else
    {
        hCLimit = 8;
    }

    var code2;
    var code3;

    switch (type)
    {
        case 1:
        {
            code2 =
                " 66 FF 8B ?? 00 00 00" +
                " 66 39 BB ?? 00 00 00" +
                " 75 09" +
                " 66 C7 83 ?? 00 00 00 17 00";
            code3 =
                " 66 FF 83 ?? 00 00 00" +
                " 66 8B 83 ?? 00 00 00" +
                " 66 3D 18 00" +
                " 75 09" +
                " 66 C7 83 ?? 00 00 00 01 00";

            cmpLoc = 7;
            break;
        }
        case 2:
        {
            code2 =
                " 66 FF 8B ?? 00 00 00" +
                " 0F B7 83 ?? 00 00 00" +
                " 33 C9" +
                " 66 3B C8" +
                " 75 0C" +
                " BA 17 00 00 00" +
                " 66 89 93 ?? 00 00 00";
            code3 =
                " 66 FF 83 ?? 00 00 00" +
                " 0F B7 83 ?? 00 00 00" +
                " B9 18 00 00 00" +
                " 66 3B C8" +
                " 75 0C" +
                " BA 01 00 00 00" +
                " 66 89 93 ?? 00 00 00";

            cmpLoc = 7;
            break;
        }
        case 3:
        {
            code2 =
                " 66 01 B5 ?? 00 00 00" +
                " 0F B7 85 ?? 00 00 00" +
                " 33 C9" +
                " 66 3B C8" +
                " 75 0C" +
                " BA 17 00 00 00" +
                " 66 89 95 ?? 00 00 00";
            code3 =
                " 66 FF 85 ?? 00 00 00" +
                " 0F B7 85 ?? 00 00 00" +
                " B9 18 00 00 00" +
                " 66 3B C8" +
                " 75 0C" +
                " BA 01 00 00 00" +
                " 66 89 95 ?? 00 00 00";

            cmpLoc = 7;
            break;
        }
        case 4:
        {
            if (pe.getDate() < 20130605)
            {
                code2 = " 83 BB ?? ?? 00 00 00";
                cmpLoc = 0;
            }
            else
            {
                code2 =
                    " 89 93 ?? ?? 00 00" +
                    " 85 D2";
                cmpLoc = 6;
            }

            code2 +=
                " 7D 0A" +
                " C7 83 ?? ?? 00 00 00 00 00 00" +
                " B8 16 00 00 00" +
                " 39 83 ?? ?? 00 00" +
                " 7E 06" +
                " 89 83 ?? ?? 00 00";
            break;
        }
        case 5:
        {
            code2 =
                " 89 ?? ?? ?? 00 00" +
                " 85 C0" +
                " 79 0C" +
                " C7 83 ?? ?? 00 00 00 00 00 00" +
                " EB 0F" +
                " 83 F8 16" +
                " 7E 0A" +
                " C7 83 ?? ?? 00 00 16 00 00 00";
            cmpLoc = 6;
            break;
        }
        default:
            break;
    }

    offset = pe.find(code2, hCBegin - 0x300, hCBegin);

    if (offset === -1)
    {
        offset = pe.find(code2, hCEnd, hCEnd + 0x200);
    }

    if (offset === -1)
    {
        return "Failed in Step 2 - HairStyle comparison missing";
    }

    var hSPtr = pe.fetchHex(offset + 2, 4);
    var hSBegin = offset + cmpLoc;
    var hSEnd = offset + code2.hexlength();
    var hSAddon;

    if (type < 4)
    {
        hSAddon = 1;
    }
    else
    {
        hSAddon = 0;
    }

    if (typeof code3 === "string")
    {
        offset = pe.find(code3, hSEnd + 0x50, hSEnd + 0x400);
        if (offset === -1)
        {
            return "Failed in Step 2 - 2nd HairStyle comparison missing";
        }

        var hSBegin2 = offset + cmpLoc;
        var hSEnd2 = offset + code3.hexlength();
    }

    var hCNewLimit = exe.getUserInput("$hairColorLimit", XTYPE_WORD, _("Number Input"), _("Enter new hair color limit"), hCLimit, hCLimit, 1000);

    var hSNewLimit = exe.getUserInput("$hairStyleLimit", XTYPE_WORD, _("Number Input"), _("Enter new hair style limit"), 0x16, 0x16, 1000);

    if (hCNewLimit === hCLimit && hSNewLimit === 0x16)
    {
        return "Patch Cancelled - No limits changed";
    }

    var rcode;
    if (type === 3)
    {
        rcode = 5;
    }
    else
    {
        rcode = 3;
    }
    var free;

    if (hCNewLimit !== hCLimit)
    {
        free = _IHL_InjectComparison(rcode, hCPtr, 0, hCNewLimit, 4);
        if (free === -1)
        {
            return "Failed in Step 4 - Not enough free space";
        }

        _IHL_JumpNCall(hCBegin, hCEnd, free);

        if (_IHL_UpdateScrollBar(hCLimit, hCNewLimit) === -2)
        {
            return "Failed in Step 4 - Not enough free space(2)";
        }
    }

    if (hSNewLimit !== 0x16)
    {
        free = _IHL_InjectComparison(rcode, hSPtr, hSAddon, hSNewLimit + hSAddon, type < 4 ? 2 : 4);
        if (free === -1)
        {
            return "Failed in Step 5 - Not enough free space";
        }

        _IHL_JumpNCall(hSBegin, hSEnd, free);

        if (typeof hSBegin2 !== "undefined")
        {
            _IHL_JumpNCall(hSBegin2, hSEnd2, free);
        }

        if (_IHL_UpdateScrollBar(0x16, hSNewLimit) === -2)
        {
            return "Failed in Step 4 - Not enough free space(2)";
        }
    }

    return true;
}
