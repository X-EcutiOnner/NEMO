

function EnableGuildWhenInClan()
{
    var code =
        " 68 2D 0A 00 00" +
        " E8 ?? ?? ?? FF" +
        " 50";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        code =
            " 68 2D 0A 00 00" +
            " E9 ?? ?? ?? FF" +
            " B8";
        offset = pe.findCode(code);

        if (offset === -1)
        {
            return "Failed in Step 1 - reference to MsgStr with ID 2605 missing.";
        }
    }

    pe.replaceByte(offset - 2, 0xEB);

    code =
        " 0F 85 ?? ?? FF FF" +
        " B8 68 01 00 00";

    offset = pe.find(code, offset, offset + 0x200);

    if (offset === -1)
    {
        return "Failed in Step 2 - magic jump not found";
    }

    pe.replaceHex(offset, " 90".repeat(6));

    return true;
}

function EnableGuildWhenInClan_()
{
    return pe.stringRaw("/clanchat") !== -1;
}
