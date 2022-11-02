

function SkipServiceSelect()
{
    var offset = pe.stringVa("passwordencrypt");

    if (offset === -1)
    {
        return "Failed in Step 1 - Reference not found";
    }

    var hideAccountListHex = table.getHex4(table.g_hideAccountList);

    var code =
        "74 07 " +
        "C6 05 " + hideAccountListHex + " 01 " +
        "68 " + offset.packToHex(4);

    var repl = "90 90 ";
    var offset2 = pe.findCode(code);

    if (offset2 === -1)
    {
        code =
            "0F 45 ?? " +
            "88 ?? " + hideAccountListHex +
            "68 " + offset.packToHex(4);

        repl = "90 8B ";
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        code =
            "0F 45 ?? " +
            "88 ?? " + hideAccountListHex +
            "8B ?? " +
            "68 " + offset.packToHex(4);

        repl = "90 8B ";
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    pe.replaceHex(offset2, repl);

    return true;
}
