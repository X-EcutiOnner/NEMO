

function Enable64kHairstyle()
{
    var code = "\xC0\xCE\xB0\xA3\xC1\xB7\\\xB8\xD3\xB8\xAE\xC5\xEB\\%s\\%s_%s.%s";
    var doramOn = false;
    var offset = pe.stringRaw(code);

    if (offset === -1)
    {
        code = "\\\xB8\xD3\xB8\xAE\xC5\xEB\\%s\\%s_%s.%s";
        doramOn = true;
        offset = pe.stringRaw(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    pe.replaceByte(offset + code.length - 7, 0x75);

    offset = pe.findCode("68" + pe.rawToVa(offset).packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - String reference missing";
    }

    var fpEnb = HasFramePointer();
    if (!fpEnb)
    {
        offset -= 4;
    }
    else
    {
        offset -= 3;
    }

    if (pe.fetchUByte(offset) !== 0x8D)
    {
        offset -= 3;
    }

    if (pe.fetchUByte(offset) !== 0x8D)
    {
        return "Failed in Step 2 - Unknown instruction before reference";
    }

    var regNum = pe.fetchUByte(offset - 2) - 0x50;
    if (regNum < 0 || regNum > 7)
    {
        return "Failed in Step 2 - Missing Reg PUSH";
    }

    var regc;
    if (fpEnb)
    {
        regc = (0x45 | (regNum << 3)).packToHex(1);
    }
    else
    {
        regc = (0x44 | (regNum << 3)).packToHex(1);
    }

    if (fpEnb)
    {
        code =
            " 83 7D ?? 10" +
            " 8B" + regc + " ??" +
            " 73 03" +
            " 8D" + regc + " ??";
    }
    else
    {
        code =
            " 83 7C 24 ?? 10" +
            " 8B" + regc + " 24 ??" +
            " 73 04" +
            " 8D" + regc + " 24 ??";
    }
    var offset2 = pe.find(code, offset - 0x50, offset);

    if (offset2 === -1)
    {
        if (fpEnb)
        {
            code =
                " 83 7D ?? 10" +
                " 8D" + regc + " ??" +
                " 0F 43" + regc + " ??";
        }
        else
        {
            code =
                " 83 7C 24 ?? 10" +
                " 8D" + regc + " 24 ??" +
                " 0F 43" + regc + " 24 ??";
        }

        offset2 = pe.find(code, offset - 0x50, offset);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - Register assignment missing";
    }

    var assignOffset = offset2;
    var csize = code.hexlength();

    code =
        " 6A FF" +
        " 68 ?? ?? ?? 00" +
        " 64 A1 00 00 00 00" +
        " 50" +
        " 83 EC";
    offset = pe.find(code, offset2 - 0x1B0, offset2);

    if (offset === -1)
    {
        code =
            " 6A FF" +
            " 68 ?? ?? ?? 00" +
            " 64 A1 00 00 00 00" +
            " 50" +
            " 81 EC";
        offset = pe.find(code, offset2 - 0x280, offset2);
    }

    if (offset === -1)
    {
        offset = pe.find(code, offset2 - 0x2A0, offset2);
    }

    if (offset === -1)
    {
        return "Failed in Step 3 - Function start missing";
    }

    offset += code.hexlength();

    var arg5Dist = 5 * 4;

    if (fpEnb)
    {
        arg5Dist += 4;
    }
    else
    {
        arg5Dist += 7 * 4;

        if (pe.fetchUByte(offset - 2) === 0x81)
        {
            arg5Dist += pe.fetchDWord(offset);
        }
        else
        {
            arg5Dist += pe.fetchByte(offset);
        }

        code =
            " A1 ?? ?? ?? 00" +
            " 33 C4" +
            " 50";
        if (pe.find(code, offset + 0x4, offset + 0x20) !== -1)
        {
            arg5Dist += 4;
        }
    }

    if (fpEnb)
    {
        code = " 8B" + regc + arg5Dist.packToHex(1);
    }
    else if (arg5Dist > 0x7F)
    {
        code = " 8B" + (0x84 | (regNum << 3)).packToHex(1) + " 24" + arg5Dist.packToHex(4);
    }
    else
    {
        code = " 8B" + regc + " 24" + arg5Dist.packToHex(1);
    }

    code += " 8B" + ((regNum << 3) | regNum).packToHex(1);
    code += " 90".repeat(csize - code.hexlength());

    pe.replaceHex(assignOffset, code);

    code =
        " 8B ?? ?? ?? ?? 00" +
        " 8B ?? 00" +
        " 8B 14";
    var offsets = pe.findAll(code, offset, assignOffset);

    if (offsets.length === 0)
    {
        code =
            " 8B ??" +
            " 8B ?? ?? ?? ?? 00" +
            " 8B 14";
        offsets = pe.findAll(code, offset, assignOffset);
    }

    if (offsets.length === 0)
    {
        code =
            " 8B ??" +
            " A1 ?? ?? ?? 00" +
            " 8B 14";
        offsets = pe.findAll(code, offset, assignOffset);
    }

    if (offsets.length === 0)
    {
        code =
            " 8B ??" +
            " A1 ?? ?? ?? 01" +
            " 8B 14";
        offsets = pe.findAll(code, offset, assignOffset);
    }

    if (offsets.length === 0)
    {
        return "Failed in Step 4 - Table fetchers missing";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        offset2 = offsets[i] + code.hexlength();
        pe.replaceWord(offset2 - 1, 0x9010 + (pe.fetchByte(offset2) & 0x7));
    }

    code =
        " 7C 05" +
        " 83 ?? ??" +
        " 7E ??" +
        " C7";
    offset2 = pe.find(code, offset + 4, offset + 0x50);

    if (offset2 === -1)
    {
        code =
            " 78 05" +
            " 83 ?? ??" +
            " 7E ??" +
            " C7";
        offset2 = pe.find(code, offset + 4, offset + 0x50);
    }

    if (offset2 === -1 && doramOn)
    {
        offset2 = pe.find(code, offset + 0x100, offset + 0x200);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 5 - Limit checker missing";
    }

    offset2 += code.hexlength();

    pe.replaceByte(offset2 - 3, 0xEB);

    code = pe.fetchUByte(offset2);
    if (code === 0x04 || code > 0x07)
    {
        pe.replaceByte(offset2 + 2, 2);
    }
    else
    {
        pe.replaceByte(offset2 + 1, 2);
    }

    return true;
}

function Enable64kHairstyle_()
{
    var code = "\\\xB8\xD3\xB8\xAE\xC5\xEB\\%s\\%s_%s.%s";
    var offset = pe.stringRaw(code);

    return pe.getDate() > 20111102 && offset === -1;
}
