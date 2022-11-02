

function DisableQuakeEffect()
{
    var bmpOffset = pe.stringVa(".BMP");
    if (bmpOffset === -1)
    {
        bmpOffset = pe.find("2E 42 4D 50 00");
        if (bmpOffset !== -1)
        {
            bmpOffset = pe.rawToVa(bmpOffset);
        }
    }
    if (bmpOffset === -1)
    {
        return "Failed in Step 1 - BMP not found";
    }

    var code =
        " 68" + bmpOffset.packToHex(4) +
        " 8B";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 68" + bmpOffset.packToHex(4) +
            " 8D";
        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in Step 1 - BMP reference missing";
    }

    code =
        " E8 ?? ?? ?? ??" +
        " 33 C0" +
        " E9 ?? ?? 00 00";
    var offset2 = pe.find(code, offset - 0x80, offset);

    if (offset2 === -1)
    {
        code = code.replace("33 C0 E9 ?? ?? 00 00", "?? ?? 33 C0");
        offset2 = pe.find(code, offset - 0x100, offset);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - SetQuakeInfo call missing";
    }

    offset2 += pe.fetchDWord(offset2 + 1) + 5;

    pe.replaceHex(offset2, " C2 0C 00");
    var offset2Old = offset2;

    code =
        " 6A 01" +
        " E8 ?? ?? ?? ??" +
        " 33 C0" +
        " E9 ?? ?? 00 00";
    offset2 = pe.find(code, offset - 0xA0, offset);

    if (offset2 === -1)
    {
        code = code.replace("33 C0 E9 ?? ?? 00 00", "?? ?? 33 C0");
        offset2 = pe.find(code, offset - 0x120, offset);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 3 - SetQuake call missing";
    }

    offset2 += pe.fetchDWord(offset2 + 3) + 7;

    if (offset2Old == offset2)
    {
        return "Found two same offsets";
    }

    pe.replaceHex(offset2, " C2 14 00");

    return true;
}
