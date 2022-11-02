

function DeleteCharWithEmail()
{
    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 1 - " + LANGTYPE[0];
    }

    var code =
        " A1" + LANGTYPE +
        " 83 C4 08" +
        " 83 F8 0A" +
        " 74";
    var patchOffset = code.hexlength() - 1;
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        code =
            "83 F9 0A " +
            "74 ?? " +
            "83 F9 0C " +
            "74 ?? " +
            "83 F9 01 " +
            "74 ";
        offset = pe.findCode(code);
        patchOffset = 3;

        pe.replaceHex(offset + patchOffset, "EB");

        code =
            "8B 0D " + LANGTYPE +
            "85 C9 " +
            "75";
        patchOffset = code.hexlength() - 1;
        offset = pe.find(code, offset - 0x30, offset);
        if (offset === -1)
        {
            return "Failed in Step 1c - g_serviceType not found";
        }
    }
    pe.replaceHex(offset + patchOffset, "EB");

    code =
        " 6A 00" +
        " 75 07" +
        " 68 ?? ?? 00 00" +
        " EB 05";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 2 - Comparison missing";
    }

    pe.replaceHex(offset + 2, "EB");

    return true;
}
