

function DisableMapInterface()
{
    var code =
        " 68 8C 00 00 00" +
        getEcxWindowMgrHex() +
        " E8 ?? ?? ?? ??" +
        " 84 C0" +
        " 0F 85 ?? ?? 00 00" +
        " 68 8C 00 00 00" +
        getEcxWindowMgrHex() +
        " E8";

    var offsets = pe.findCodes(code);
    if (offsets.length === 0)
    {
        return "Failed in Step 1 - No matches found";
    }

    var i;
    for (i = 0; i < offsets.length; i++)
    {
        pe.replaceHex(offsets[i], "EB 0F");
        pe.replaceHex(offsets[i] + 17, "90 E9");
    }

    code = code.replace(" 0F 85 ?? ?? 00 00", " 75 ??");

    offsets = pe.findCodes(code);

    for (i = 0; i < offsets.length; i++)
    {
        pe.replaceHex(offsets[i], "EB 0F");
        pe.replaceByte(offsets[i] + 17, 0xEB);
    }

    code =
        " 68 8C 00 00 00" +
        " 8B ??" +
        " E8 ?? ?? ?? FF" +
        " 5E";
    var offset = pe.findCode(code);

    if (offset !== -1)
    {
        pe.replaceHex(offset, "EB 0A");
    }

    return true;
}
