

function DisableHelpMsg()
{
    var code =
        "6A 0D " +
        "6A 2A ";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "6A 0E " +
            "6A 2A ";

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "6A 0E " +
            "8B 01 " +
            "6A 2A ";

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "6A 0E " +
            "8B 01 " +
            "6A 2F ";

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "6A 0E " +
            "8B 11 " +
            "6A 2F ";

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

    var LANGTYPE = GetLangType();

    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 2 - " + LANGTYPE[0];
    }

    code =
        LANGTYPE +
        "75 ";

    var offset2 = pe.find(code, offset - 0x20, offset);

    if (offset2 === -1)
    {
        code =
            LANGTYPE + "00 " +
            "75 ";

        offset2 = pe.find(code, offset - 0x20, offset);
    }

    if (offset2 === -1)
    {
        code =
            LANGTYPE +
            "?? ?? " +
            "75 ";

        offset2 = pe.find(code, offset - 0x20, offset);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 3 - Pattern not found";
    }

    pe.replaceByte(offset2 + code.hexlength() - 1, 0xEB);

    return true;
}

function DisableHelpMsg_()
{
    return pe.stringRaw("/tip") !== -1;
}
