

function RemoveHourlyAnnounce()
{
    var code =
        " 75 ??" +
        " MovR16" +
        " 66 85 ??" +
        " 75 ??";

    var fpEnb = HasFramePointer();
    if (fpEnb)
    {
        code = code.replace(" MovR16", " 66 8B ?? ??");
    }
    else
    {
        code = code.replace(" MovR16", " 66 8B ?? 24 ??");
    }

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 66", "");
        offset = pe.findCode(code);
    }

    if (offset === -1 && !fpEnb)
    {
        code = code.replace(" 8B ?? 24 ??", " 66 8B ?? ??");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1b - Mov R16 reference not found";
    }

    pe.replaceByte(offset, 0xEB);

    code = "\x25\x64\x20\xBD\xC3\xB0\xA3\xC0\xCC\x20\xB0\xE6\xB0\xFA\xC7\xDF\xBD\xC0\xB4\xCF\xB4\xD9\x2E";
    offset = pe.stringRaw(code);

    if (offset === -1)
    {
        return "Failed in step 2a - string not found";
    }

    offset = pe.findCode("68" + pe.rawToVa(offset).packToHex(4));
    if (offset === -1)
    {
        return "Failed in step 2a - string reference missing";
    }

    offset = pe.find(" B8 B1 7C 21 95", offset - 0xFF, offset);

    if (offset === -1)
    {
        return "Failed in Step 2b - Magic Divisor not found";
    }

    offset = pe.find(" 0F 8E ?? ?? 00 00", offset + 7, offset + 30);

    if (offset === -1)
    {
        offset = pe.find(" 0F 86 ?? 00 00 00", offset + 7, offset + 55);
    }

    if (offset === -1)
    {
        return "Failed in Step 2c - Comparison not found";
    }

    pe.replaceHex(offset, " 90 E9");

    return true;
}
