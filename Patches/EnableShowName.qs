

function EnableShowName()
{
    var code =
        " 85 C0" +
        " 74 ??" +
        " 83 F8 06" +
        " 74 ??" +
        " 83 F8 0A";

    var offset = pe.findCode(code);
    if (offset == -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offset + 2, 0xEB);

    return true;
}
