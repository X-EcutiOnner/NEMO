

function UsePlainTextDescriptions()
{
    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 1 - " + LANGTYPE[0];
    }

    var code =
        " 83 3D" + LANGTYPE + " 00" +
        " 75 ??" +
        " 56" +
        " 57";
    var repLoc = 7;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 75 ?? 56 57", " 75 ?? 57");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code = code.replace(" 75 ?? 57", " 75 ?? 8B 4D 08 56");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            " A1" + LANGTYPE +
            " 56" +
            " 85 C0" +
            " 57" +
            " 75";
        repLoc = code.hexlength() - 1;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - LangType Comparison missing";
    }

    pe.replaceByte(offset + repLoc, 0xEB);

    return true;
}
