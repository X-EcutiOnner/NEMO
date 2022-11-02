

function DisableDoram()
{
    var code =
        " FF 77 ??" +
        " 8B CF" +
        " FF 77 ??" +
        " E8";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in step 1";
    }

    pe.replaceHex(offset, "90 6A 00");

    code =
        " C7 ?? ?? FF FF FF 00 00 00 00" +
        " C7 ?? ?? FF FF FF 00 00 00 00" +
        " C7 ?? ?? FF FF FF 00 00 00 00" +
        " 6A 01";

    offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in step 2 - Cannot find 3 MOV [EXP + var_Dx], 0 pattern.";
    }

    offset += 30;

    code =
        " 33 F6" +
        " 8D 87 ?? ?? 00 00" +
        " 8D 49 00";

    var offset2 = pe.find(code, offset, offset + 0x300);

    if (offset2 === -1)
    {
        return "Failed in step 2b - XOR after MOV pattern not found";
    }

    offset2 = offset2 - offset - 5;

    pe.replaceHex(offset, "E9" + offset2.packToHex(4) + " 90 90");

    code =
        " 8B 8D 38 FF FF FF" +
        " 41" +
        " 89 8D 38 FF FF FF" +
        " B8 ?? ?? 00 00" +
        " 83 F9 02";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in step 3";
    }

    pe.replaceHex(offset + code.hexlength(), "90 90 90 90 90 90");
    return true;
}

function DisableDoram_()
{
    return pe.getDate() <= 20170614;
}
