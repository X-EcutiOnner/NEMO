

function EnableDNSSupport()
{
    var offset = pe.stringVa("211.172.247.115");
    if (offset === -1)
    {
        return "Failed in Step 1 - IP not found";
    }

    var code = "C7 05 ?? ?? ?? 00" + offset.packToHex(4);

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - g_accountAddr assignment missing";
    }

    var gAccountAddr = pe.fetchHex(offset + 2, 4);

    code =
        " E8 ?? ?? ?? FF" +
        " 8B C8" +
        " E8 ?? ?? ?? FF" +
        " 50" +
        getEcxWindowMgrHex() +
        " E8 ?? ?? ?? FF" +
        " A1" + gAccountAddr;
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " E8 ?? ?? ?? FF" +
            " 8B C8" +
            " E8 ?? ?? ?? FF" +
            " 50" +
            getEcxWindowMgrHex() +
            " E8 ?? ?? ?? FF" +
            " 8B ??" + gAccountAddr;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            " E8 ?? ?? ?? FF" +
            " 8B C8" +
            " E8 ?? ?? ?? FF" +
            " 50" +
            getEcxWindowMgrHex() +
            " E8 ?? ?? ?? FF" +
            " 8B 0D ?? ?? ?? ??" +
            " E8 ?? ?? ?? FF" +
            " 8B ??" + gAccountAddr;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            " E8 ?? ?? ?? FF" +
            " 8B C8" +
            " E8 ?? ?? ?? FF" +
            " 50" +
            getEcxWindowMgrHex() +
            " E8 ?? ?? ?? FF" +
            " 8B 0D ?? ?? ?? ??" +
            " E8 ?? ?? ?? 00" +
            " 8B ??" + gAccountAddr;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    var gResMgr = pe.rawToVa(offset + 5) + pe.fetchDWord(offset + 1);

    var dnscode =
        " E8" + GenVarHex(1) +
        " 60" +
        " 8B 35" + GenVarHex(2) +
        " 56" +
        " FF 15" + GenVarHex(3) +
        " 8B 48 0C" +
        " 8B 11" +
        " 89 D0" +
        " 0F B6 48 03" +
        " 51" +
        " 0F B6 48 02" +
        " 51" +
        " 0F B6 48 01" +
        " 51" +
        " 0F B6 08" +
        " 51" +
        " 68" + GenVarHex(4) +
        " 68" + GenVarHex(5) +
        " FF 15" + GenVarHex(6) +
        " 83 C4 18" +
        " C7 05" + GenVarHex(7) + GenVarHex(8) +
        " 61" +
        " C3" +
        " 00" +
        "127.0.0.1".toHex() + " 00".repeat(7);

    var size = dnscode.hexlength();

    var free = alloc.find(size);
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    pe.replaceHex(offset + 1, (pe.rawToVa(free) - pe.rawToVa(offset + 5)).packToHex(4));

    var uGethostbyname = imports.ptrValidated("gethostbyname", "ws2_32.dll", 52);

    var ipFormat = pe.stringVa("%d.%d.%d.%d");
    if (ipFormat === -1)
    {
        return "Failed in Step 4 - IP string missing";
    }

    gResMgr -= pe.rawToVa(free + 5);

    offset = pe.rawToVa(free + size - (3 * 1 + 4 * 3 + 1));

    dnscode = ReplaceVarHex(dnscode, 1, gResMgr);
    dnscode = ReplaceVarHex(dnscode, 2, gAccountAddr);
    dnscode = ReplaceVarHex(dnscode, 3, uGethostbyname);
    dnscode = ReplaceVarHex(dnscode, 4, ipFormat);
    dnscode = ReplaceVarHex(dnscode, 5, offset);
    dnscode = ReplaceVarHex(dnscode, 6, imports.ptrValidated("wsprintfA", "USER32.dll"));
    dnscode = ReplaceVarHex(dnscode, 7, gAccountAddr);
    dnscode = ReplaceVarHex(dnscode, 8, offset);

    pe.insertHexAt(free, size, dnscode);

    return true;
}
