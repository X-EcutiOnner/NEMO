

function EnableMonsterTables()
{
    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 1 - " + LANGTYPE[0];
    }

    var code =
        LANGTYPE +
        " 83 C4 04" +
        " 83 ?? 13" +
        " 0F 85 ?? ?? 00 00";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 -  Comparison not found";
    }

    pe.replaceHex(offset + code.hexlength() - 6, " 90 E9");

    return true;
}
