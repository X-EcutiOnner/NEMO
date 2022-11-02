

function EnableProxySupport()
{
    var offset = pe.stringVa("Failed to setup select mode");
    if (offset === -1)
    {
        return "Failed in Step 1 - setup string not found";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - setup string reference missing";
    }

    var code =
        " FF 15 ?? ?? ?? ??" +
        " 83 F8 FF" +
        " 75 ??" +
        " 8B ?? ?? ?? ?? ??" +
        " FF ??" +
        " 3D 33 27 00 00";
    var offset2 = pe.find(code, offset - 0x50, offset);
    var bIndirectCALL;

    if (offset2 === -1)
    {
        code =
            " E8 ?? ?? ?? ??" +
            " 83 F8 FF" +
            " 75 ??" +
            " E8 ?? ?? ?? ??" +
            " 3D 33 27 00 00";

        offset2 = pe.find(code, offset - 0x90, offset);
        if (offset2 === -1)
        {
            return "Failed in Step 2";
        }

        bIndirectCALL = false;
    }
    else
    {
        bIndirectCALL = true;
        pe.replaceHex(offset2, " 90 E8");
        offset2++;
    }

    var connAddr = pe.fetchDWord(offset2 + 1);
    if (!bIndirectCALL)
    {
        connAddr += pe.rawToVa(offset2 + 5);
    }

    code =
        " A1" + GenVarHex(1) +
        " 85 C0" +
        " 75 08" +
        " 8B 46 0C" +
        " A3" + GenVarHex(2) +
        " 89 46 0C";

    if (pe.find(" 89 43 0C B8 02 00 00 00", offset2 - 0x50, offset2) !== -1)
    {
        code = code.replace(" 8B 46 0C", " 8B 43 0C");
        code = code.replace(" 89 46 0C", " 89 43 0C");
    }

    if (pe.find(" 8D 47 08 ", offset2 - 0x20, offset2) !== -1)
    {
        code = code.replace(" 8B 46 0C", " 8B 47 0C");
        code = code.replace(" 89 46 0C", " 89 47 0C");
    }

    if (bIndirectCALL)
    {
        code += " FF 25" + connAddr.packToHex(4);
    }
    else
    {
        code += " E9" + GenVarHex(3);
    }

    var csize = code.hexlength();

    offset = alloc.find(0x4 + csize);
    if (offset === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    var offsetRva = pe.rawToVa(offset);

    code = ReplaceVarHex(code, [1, 2], [offsetRva, offsetRva]);

    if (!bIndirectCALL)
    {
        code = ReplaceVarHex(code, 3, connAddr - (offsetRva + csize));
    }

    pe.replaceDWord(offset2 + 1, offsetRva + 4 - pe.rawToVa(offset2 + 5));

    pe.insertHexAt(offset, 4 + csize, " 00 00 00 00" + code);

    return true;
}
