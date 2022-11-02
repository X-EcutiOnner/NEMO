

function EnforceOfficialLoginBackground()
{
    var code =
        " 74 ??" +
        " 83 F8 04" +
        " 74 ??" +
        " 83 F8 08" +
        " 74 ??" +
        " 83 F8 09" +
        " 74 ??" +
        " 83 F8 0E" +
        " 74 ??" +
        " 83 F8 03" +
        " 74 ??" +
        " 83 F8 0A" +
        " 74 ??" +
        " 83 F8 01" +
        " 74 ??" +
        " 83 F8 0B";

    var offsets = pe.findCodes(code);
    if (offsets.length === 0)
    {
        code = code.replace(" 83 F8 0E 74 ??", "");
        offsets = pe.findCodes(code);
    }
    if (offsets.length === 0)
    {
        return "Failed in Step 1";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        pe.replaceByte(offsets[i], 0xEB);
    }

    return true;
}
