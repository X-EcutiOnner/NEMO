

function IgnoreResourceErrors()
{
    var hwndHex = table.getHex4(table.g_hMainWnd);

    var code =
        "E8 ?? ?? ?? FF " +
        "MovEax " +
        "8B 0D " + hwndHex +
        "6A 00 ";

    var fpEnb = HasFramePointer();

    if (fpEnb)
    {
        code = code.replace("MovEax", "8B 45 08 ");
    }
    else
    {
        code = code.replace("MovEax", "8B 44 24 04 ");
    }

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? FF " +
            "6A 00 " +
            "68 ?? ?? ?? 00 " +
            "FF 75 08 ";

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        offset = pe.stringVa("Failed to load Winsock library!");

        if (offset === -1)
        {
            return "Failed in Step 1 - String not found";
        }

        code =
            "68 " + offset.packToHex(4) +
            "E8 ";

        offset = pe.findCode(code);

        if (offset === -1)
        {
            return "Failed in Step 1 - Pattern not found";
        }

        offset = offset + 10 + pe.fetchDWord(offset + 6);

        code =
            "E8 ?? ?? ?? FF " +
            "FF 75 0C " +
            "68 ?? ?? ?? 00 " +
            "FF 75 08 ";

        offset = pe.find(code, offset, offset + 0x20);

        if (offset === -1)
        {
            return "Failed in Step 1 - Pattern not found";
        }
    }

    if (fpEnb)
    {
        pe.replaceHex(offset + 5, " 33 C0 5D C3");
    }
    else
    {
        pe.replaceHex(offset + 5, " 33 C0 C3 90");
    }

    return true;
}

function IgnoreResourceErrors_()
{
    return pe.getDate() >= 20100000;
}
