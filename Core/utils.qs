

function IsZero()
{
    return pe.find("53 6F 66 74 77 61 72 65 5C 47 72 61 76 69 74 79 20 53 6F 66 74 5C 52 65 6E 65 77 53  65 74 75 70 20 5A 65 72 6F") !== -1;
}

function GetLangType()
{
    var offset = pe.stringVa("america");
    if (offset === -1)
    {
        return ["'america' not found"];
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return ["'america' reference missing"];
    }

    offset = pe.find(" C7 05 ?? ?? ?? ?? 01 00 00 00", offset + 5);
    if (offset === -1)
    {
        return ["g_serviceType assignment missing"];
    }

    var lang = pe.fetchHex(offset + 2, 4);
    if (lang !== table.getHex4(table.g_serviceType))
    {
        return ["found wrong g_serviceType"];
    }
    return lang;
}

function GetServerType()
{
    var offset = pe.stringVa("sakray");
    if (offset === -1)
    {
        throw "'sakray' not found";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        throw "'sakray' reference missing";
    }

    offset = pe.find(" C7 05 ?? ?? ?? ?? 01 00 00 00", offset + 5);
    if (offset === -1)
    {
        throw "g_serverType assignment missing";
    }

    return pe.fetchDWord(offset + 2);
}

function GetWinMgrInfo(skipError)
{
    var offset = pe.stringVa("NUMACCOUNT");
    if (offset === -1)
    {
        return "NUMACCOUNT missing";
    }

    var code =
        getEcxWindowMgrHex() +
        "E8 ?? ?? ?? ?? " +
        "6A 00 " +
        "6A 00 " +
        "68 " + offset.packToHex(4);

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "NUMACCOUNT reference missing";
    }

    return {
        "gWinMgr": pe.fetchHex(offset, 5),
        "makeWin": pe.fetchDWord(offset + 6) + pe.rawToVa(offset) + 10,
    };
}

function HasFramePointer()
{
    return (pe.fetch(pe.sectionRaw(CODE)[0], 3) === "\x55\x8B\xEC") || table.get(table.packetVersion) > 20190000;
}

function GetInputFile(f, varname, title, prompt, fpath)
{
    var inp = "";
    while (inp === "")
    {
        inp = exe.getUserInput(varname, XTYPE_FILE, title, prompt, fpath);
        if (inp === "" || inp === false)
        {
            return false;
        }

        if (f.open(inp) === false)
        {
            throw "Cant open file";
        }
        if (f.eof())
        {
            f.close();
            inp = "";
        }
    }
    return inp;
}
