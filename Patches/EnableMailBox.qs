

function EnableMailBox()
{
    var code  =
        " 74 ??" +
        " 83 F8 08" +
        " 74 ??" +
        " 83 F8 09" +
        " 74 ??";

    var pat1 = " 8B 8E ?? 00 00 00";
    var pat2 = " BB 01 00 00 00";

    var offsets = pe.findCodes(code + pat1);
    if (offsets.length !== 3)
    {
        return "Failed in Step 1 - First pattern not found";
    }

    var i;
    for (i = 0; i < 3; i++)
    {
        pe.replaceHex(offsets[i] - 2, " EB 0C");
    }

    var offset = pe.findCode(code + pat2);
    if (offset === -1)
    {
        return "Failed in Step 1 - Second pattern not found";
    }

    pe.replaceHex(offset - 2, " EB 0C");

    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 2 - " + LANGTYPE[0];
    }

    code =
        " 0F 84 ?? ?? 00 00" +
        " 83 F8 08" +
        " 0F 84 ?? ?? 00 00" +
        " 83 F8 09" +
        " 0F 84 ?? ?? 00 00";

    pat1 = " A1" + LANGTYPE + " ?? ??";

    offsets = pe.findCodes(pat1 + code);

    if (offsets.length < 3 || offsets.length > 4)
    {
        return "Failed in Step 2 - LangType comparisons missing";
    }

    for (i = 0; i < offsets.length; i++)
    {
        pe.replaceHex(offsets[i] + 5, " EB 18");
    }

    if (offsets.length === 3)
    {
        pat2 = " 6A 23";

        offset = pe.findCode(code + pat2);
        if (offset === -1)
        {
            return "Failed in Step 3";
        }

        pe.replaceHex(offset - 2, " EB 18");
    }

    return true;
}

function EnableMailBox_()
{
    return pe.getDate() >= 20130320 || pe.getDate() <= 20140800;
}
