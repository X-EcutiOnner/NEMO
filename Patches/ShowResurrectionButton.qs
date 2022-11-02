

function ShowResurrectionButton()
{
    var offset = pe.findCode(" 68 C5 1D 00 00");
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    offset += 15;

    var code =
        " 8B 48 ??" +
        " 85 C9" +
        " 75 ??";

    var offset2 = pe.find(code + code + code, offset, offset + 0x40);

    if (offset2 === -1)
    {
        code =
            " 83 78 ?? 00" +
            " 75 ??";

        offset2 = pe.find(code + code + code, offset, offset + 0x40);
    }

    if (offset2 === -1)
    {
        code =
            " 39 58 ??" +
            " 0F 85 ?? 00 00 00";

        offset2 = pe.find(code + code + code, offset, offset + 0x40);
    }

    if (offset2 === -1)
    {
        code =
            " 83 78 ?? 00" +
            " 0F 85 ?? 00 00 00";

        offset2 = pe.find(code + code + code, offset, offset + 0x40);
    }
    if (offset2 === -1)
    {
        code =
            " 83 78 ?? 00" +
            " 0F 85 ?? 01 00 00";

        offset2 = pe.find(code + code + code, offset, offset + 0x40);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - No comparisons matched";
    }

    pe.replaceHex(offset2, "EB" + (3 * code.hexlength() - 2).packToHex(1));

    return true;
}
