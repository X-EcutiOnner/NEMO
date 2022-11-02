

function IncreaseScreenshotQuality()
{
    var fpEnb = HasFramePointer();
    var code;
    if (fpEnb)
    {
        code =
            " C7 85 ?? ?? FF FF 03 00 00 00" +
            " C7 85 ?? ?? FF FF 02 00 00 00";
    }
    else
    {
        code =
            " C7 44 24 ?? 03 00 00 00" +
            " C7 44 24 ?? 02 00 00 00";
    }
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        if (fpEnb)
        {
            code =
                " C7 45 ?? 03 00 00 00" +
                " C7 45 ?? 02 00 00 00";
        }
        else
        {
            code =
                " C7 84 24 ?? ?? 00 00 03 00 00 00" +
                " C7 84 24 ?? ?? 00 00 02 00 00 00";
        }

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var csize = code.hexlength() / 2;

    var newvalue = exe.getUserInput("$uQuality", XTYPE_BYTE, _("Number Input"), _("Enter the new quality factor (0-100)"), 50, 0, 100);
    if (newvalue === 50)
    {
        return "Patch Cancelled - New value is same as old";
    }

    var offset2;
    if (fpEnb)
    {
        offset2 = offset + 2;
    }
    else
    {
        offset2 = offset + 3;
    }

    if ((pe.fetchUByte(offset + 1) & 0x80) === 0)
    {
        offset2 = pe.fetchByte(offset2) + 60;
    }
    else
    {
        offset2 = pe.fetchDWord(offset2) + 60;
    }

    if (offset2 < -128 || offset2 > 127)
    {
        if (fpEnb)
        {
            code = " C7 85" + offset2.packToHex(4) + newvalue.packToHex(4);
        }
        else
        {
            code = " C7 84 24" + offset2.packToHex(4) + newvalue.packToHex(4);
        }
    }

    else if (fpEnb)
    {
        code = " C7 45" + offset2.packToHex(1) + newvalue.packToHex(4);
    }
    else
    {
        code = " C7 44 24" + offset2.packToHex(1) + newvalue.packToHex(4);
    }

    if (code.hexlength() < csize)
    {
        code += " 90".repeat(csize - code.hexlength());
    }
    else if (code.hexlength() > csize)
    {
        code += " 90".repeat(csize * 2 - code.hexlength());
    }

    pe.replaceHex(offset, code);

    return true;
}
