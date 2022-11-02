

function IgnoreMissingPaletteError()
{
    var offsetHex = pe.stringHex4("CPaletteRes :: Cannot find File : ");

    var code =
        " 68" + offsetHex +
        " 8D";
    var offset2 = pe.findCode(code);

    if (offset2 === -1)
    {
        code = code.replace(" 8D", " C7");
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        code = "BF" + offsetHex;
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 1 - Message Reference missing";
    }

    code =
        " E8 ?? ?? ?? ??" +
        " 84 C0" +
        " 0F 85 ?? ?? 00 00";

    var offset = pe.find(code, offset2 - 0x100, offset2);

    if (offset === -1)
    {
        return "Failed in Step 1 - Function call missing";
    }

    pe.replaceHex(offset + code.hexlength() - 6, "90 E9");

    return true;
}
