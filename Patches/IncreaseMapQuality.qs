

function IncreaseMapQuality()
{
    var code =
        " 51" +
        " 68 00 01 00 00" +
        " 68 00 01 00 00" +
        " B9 ?? ?? ?? 00" +
        " E8 ?? ?? ?? FF";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 51", " 50");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code = code.replace(" 00 B9 ?? ?? ?? 00 E8", " 00 E8");
        offset = pe.findCode(code);
        var ecxRemove = true;
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - CreateTexture call missing";
    }

    if (pe.fetchByte(offset - 1) === 0x01)
    {
        offset--;
    }
    else
    {
        if (ecxRemove)
        {
            offset = pe.find("6A 01 ", offset - 15, offset);
        }
        else
        {
            offset = pe.find("6A 01 ", offset - 10, offset);
        }

        if (offset === -1)
        {
            return "Failed in Step 1 - pf push missing";
        }

        offset++;
    }

    pe.replaceByte(offset, 4);

    return true;
}
