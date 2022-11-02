

function RestoreLoginWindow()
{
    var code =
        " 50" +
        " E8 ?? ?? ?? FF" +
        " 8B C8" +
        " E8 ?? ?? ?? FF" +
        " 50" +
        getEcxWindowMgrHex() +
        " E8 ?? ?? ?? FF" +
        " 80 3D ?? ?? ?? 00 00" +
        " 74 13" +
        " C6 ?? ?? ?? ?? 00 00" +
        " C7 ?? ?? 04 00 00 00" +
        " E9";

    var codeOffset = pe.findCode(code);

    if (codeOffset === -1)
    {
        code = code.replace(" 80 3D ?? ?? ?? 00", " 80 3D ?? ?? ?? 01");
        code = code.replace(" C6 ?? ?? ?? ?? 00", " C6 ?? ?? ?? ?? 01");
        codeOffset = pe.findCode(code);
    }

    if (codeOffset === -1)
    {
        return "Failed in Step 1";
    }

    var movEcx = getEcxWindowMgrHex();

    var offset = pe.stringVa("NUMACCOUNT");
    if (offset === -1)
    {
        return "Failed in Step 2 - NUMACCOUNT not found";
    }

    code =
        movEcx +
        " E8 ?? ?? ?? FF" +
        " 6A 00" +
        " 6A 00" +
        " 68" + offset.packToHex(4);

    var o2 = pe.findCode(code);
    if (o2 === -1)
    {
        return "Failed in Step 2 - MakeWindow not found";
    }

    var windowMgr = ((o2 + 10 + pe.fetchDWord(o2 + 6)) - (codeOffset + 24 + 2 + 5 + 5)).packToHex(4);

    code =
        " 6A 03" +
        movEcx +
        " E8" + windowMgr +
        " EB 09";

    pe.replaceHex(codeOffset + 24, code);

    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 4 - " + LANGTYPE[0];
    }

    var passwordEncryptHex = table.getHex4(table.g_passwordEncrypt);

    code =
        " 80 3D " + passwordEncryptHex + " 00" +
        " 0F 85 ?? ?? 00 00" +
        " A1" + LANGTYPE +
        " ?? ??" +
        " 0F 84 ?? ?? 00 00" +
        " 83 ?? 12" +
        " 0F 84 ?? ?? 00 00";
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" A1", " 8B ??");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            " 80 3D " + passwordEncryptHex + " 00" +
            " 0F 85 ?? ?? 00 00" +
            " 8B ??" + LANGTYPE +
            " ?? ??" +
            " 0F 84 ?? ?? 00 00" +
            " 83 ?? 12" +
            " 0F 84 ?? ?? 00 00";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 4 - LangType comparison missing";
    }

    offset += code.hexlength();

    var repl;
    if (pe.fetchUByte(offset) === 0x83 && pe.fetchByte(offset + 2) === 0x0C)
    {
        repl = "EB 18";
    }
    else
    {
        repl = "EB 0F";
    }

    pe.replaceHex(offset - 0x11, repl);

    code =
        " 6A 00" +
        " 6A 00" +
        " 6A 00" +
        " 68 F6 00 00 00" +
        " FF";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 5 - Unable to find g_modeMgr code";
    }

    code =
        " 83 3D ?? ?? ?? ?? 01" +
        " 75 ??" +
        " 8B 0D";

    offset = pe.find(code, offset - 30, offset);
    if (offset === -1)
    {
        return "Failed in Step 5 - Start of Function missing";
    }

    var infix =
        pe.fetchHex(offset + code.hexlength() - 2, 6) +
        " 8B 01" +
        " 8B 50 18";

    var pushes = pe.findAll("6A 00", offset + code.hexlength() + 4, offset + code.hexlength() + 16);

    var hwndHex = table.getHex4(table.g_hMainWnd);

    code =
        " 8B F1" +
        " 8B 46 04" +
        " C7 40 14 00 00 00 00" +
        " 83 3D" + LANGTYPE + " 0B" +
        " 75 1D" +
        " 8B 0D " + hwndHex +
        " 6A 01" +
        " 6A 00" +
        " 6A 00" +
        " 68 ?? ?? ?? 00" +
        " 68 ?? ?? ?? 00" +
        " 51" +
        " FF 15 ?? ?? ?? 00" +
        " C7 06 00 00 00 00";

    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 8B F1" +
            " 8B 46 04" +
            " C7 40 14 00 00 00 00" +
            " 83 3D" + LANGTYPE + " 0B" +
            " 75 1C" +
            " 6A 01" +
            " 6A 00" +
            " 6A 00" +
            " 68 ?? ?? ?? 00" +
            " 68 ?? ?? ?? 00" +
            " FF 35 " + hwndHex +
            " FF 15 ?? ?? ?? 00" +
            " C7 06 00 00 00 00";

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 5 - Unable to find SendMsg function";
    }

    var replace =
        " 52" +
        " 50" +
        infix +

        " 6A 00".repeat(pushes.length) +
        " 68 1D 27 00 00" +
        " C7 41 0C 03 00 00 00" +
        " FF D2" +
        " 58" +
        " 5A";

    replace += " EB" + (code.hexlength() - replace.hexlength() - 2).packToHex(1);

    pe.replaceHex(offset, replace);

    if (pe.getDate() >= 20130320 && pe.getDate() <= 20140226)
    {
        offset = pe.stringVa("ID");
        if (offset === -1)
        {
            return "Failed in Step 6 - ID not found";
        }

        offset = pe.findCode("6A 01 6A 00 68" + offset.packToHex(4));
        if (offset === -1)
        {
            return "Failed in Step 6 - ID reference not found";
        }

        offset = pe.find("50 E8 ?? ?? ?? 00 EB", offset - 80, offset);
        if (offset === -1)
        {
            return "Failed in Step 6 - Function not found";
        }

        var call = pe.fetchDWord(offset + 2) + offset + 6;

        offset = pe.find("E9", call);
        if (offset === -1)
        {
            return "Failed in Step 6 - Jump Not found";
        }

        call = offset + 5 + pe.fetchDWord(offset + 1);

        offset = pe.find(" 6A 13 FF 15 ?? ?? ?? 00 25 FF 00 00 00", call);
        if (offset === -1)
        {
            return "Failed in Step 6 - Pattern not found";
        }

        pe.replaceHex(offset + 2, " 31 C0 83 C4 0C 90");
    }

    return true;
}

function RestoreLoginWindow_()
{
    return pe.getDate() > 20100803 && !IsZero();
}
