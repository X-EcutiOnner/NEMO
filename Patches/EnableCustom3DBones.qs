

function EnableCustom3DBones()
{
    var offset = pe.stringVa("model\\3dmob_bone\\%d_%s.gr2");
    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var offset2 = pe.findCode("68" + offset.packToHex(4));
    if (offset2 === -1)
    {
        return "Failed in Step 1 - String reference missing";
    }

    var code =
        " C6 05 ?? ?? ?? 00 00" +
        " 83 FE 09";
    offset = pe.find(code, offset2 - 0x80, offset2);

    if (offset === -1)
    {
        code = code.replace("09", "0A");
        offset = pe.find(code, offset2 - 0x80, offset2);
    }

    if (offset === -1)
    {
        return "Failed in Step 2 - Comparison missing";
    }

    offset += code.hexlength();

    code =
        " 85 FF" +
        " 75 27";
    offset2 = pe.find(code, offset, offset + 0x20);

    if (offset2 === -1)
    {
        code = code.replace("27", "28");
        offset2 = pe.find(code, offset, offset + 0x20);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - Index Test missing";
    }

    pe.replaceHex(offset2, " 90 90 EB");

    switch (pe.fetchUByte(offset))
    {
        case 0x77:
        case 0x7D: {
            pe.replaceHex(offset, " 90 90");
            break;
        }
        case 0x0F: {
            pe.replaceHex(offset, " EB 04");
            break;
        }
        default: {
            return "Failed in Step 3";
        }
    }

    offset = pe.stringVa("too many vertex granny model!");

    if (offset !== -1)
    {
        offset = pe.findCode(" 68" + offset.packToHex(4) + " E8");
    }

    if (offset !== -1)
    {
        pe.replaceHex(offset + 5, " 90 90 90 90 90");
    }

    return true;
}
