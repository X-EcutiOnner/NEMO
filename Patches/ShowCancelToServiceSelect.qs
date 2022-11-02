

function ShowCancelToServiceSelect()
{
    var offset = pe.stringVa("btn_intro_b");
    if (offset === -1)
    {
        return "Failed in Step 1 - btn_intro_b missing";
    }

    var code = offset.packToHex(4) + " C7";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - btn_intro_b reference missing";
    }

    offset += code.hexlength();

    if (HasFramePointer())
    {
        code = " C7 45 ?? BD 00 00 00";
    }
    else
    {
        code = " C7 44 24 ?? BD 00 00 00";
    }

    var offset2 = pe.find(code, offset, offset + 0x40);

    if (offset2 === -1)
    {
        if (HasFramePointer())
        {
            code = " C7 85 ?? FF FF FF  BD 00 00 00";
        }
        else
        {
            code = " C7 84 24 ?? FF FF FF BD 00 00 00";
        }

        offset2 = pe.find(code, offset, offset + 0x40);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - login coordinate missing";
    }

    offset = offset2 + code.hexlength();

    pe.replaceByte(offset - 4, 0x90);

    code = code.replace(" BD 00", " B2 01");

    offset = pe.find(code, offset, offset + 0x30);
    if (offset === -1)
    {
        return "Failed in Step 2 - cancel coordinate missing";
    }

    offset += code.hexlength();

    pe.replaceHex(offset - 4, " BD 00");

    return true;
}

function ShowCancelToServiceSelect_()
{
    return pe.getDate() > 20100803 && !IsZero();
}
