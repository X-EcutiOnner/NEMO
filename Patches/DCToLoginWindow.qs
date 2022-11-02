

function DCToLoginWindow()
{
    if (getActivePatches().indexOf(40) === -1 && pe.getDate() < 20181113)
    {
        return "Patch Cancelled - Restore Login Window patch is necessary but not enabled";
    }

    var code = " 68 35 06 00 00";

    var offsets = pe.findCodes(code);
    if (offsets.length !== 2)
    {
        code = " 68 E5 07 00 00 E8";
        offsets = pe.findCodes(code);
    }
    if (offsets.length !== 2)
    {
        return "Failed in Part 1 - MsgString ID missing";
    }

    offsets[0] += 5;
    offsets[1] += 5;

    var offset = pe.stringVa("%s(%d)");
    if (offset === -1)
    {
        return "Failed in Part 2 - Format string missing";
    }

    var soffset = pe.find(" 68" + offset.packToHex(4), offsets[1], offsets[1] + 0x120);
    if (offset === -1)
    {
        return "Failed in Part 2 - Format reference missing";
    }

    code =
        " E8 ?? ?? ?? FF" +
        " 8B 0D ?? ?? ?? 00";
    var refOffset = 5;

    offset = pe.find(code, soffset + 0x5, soffset + 0x80);
    if (offset === -1)
    {
        code =
        " C2 04 00" +
        " 8B 0D ?? ?? ?? 00" +
        " 6A 00";
        offset = pe.find(code, soffset + 0x5, soffset + 0xB0);
        refOffset = 3;
    }

    if (offset === -1)
    {
        return "Failed in Part 2 - Reference Address missing";
    }

    offset += refOffset;

    var movEcx = pe.fetchHex(offset, 6);

    code =
        " 6A 02" +
        " FF D0";

    var offset2 = pe.find(code, offset + 0x6, offset + 0x20);

    if (offset2 === -1)
    {
        code = code.replace(" D0", " 50 18");
        offset2 = pe.find(code, offset + 0x6, offset + 0x20);
    }

    if (offset2 === -1)
    {
        return "Failed in Part 2 - Mode Changer call missing";
    }

    var zeroPushes = pe.findAll(" 6A 00", offset + 6, offset2);
    if (zeroPushes.length === 0)
    {
        return "Failed in Part 2 - Zero Pushes not found";
    }

    offset2 += code.hexlength();

    code =
        movEcx +
        " 8B 01" +
        " 6A 00".repeat(zeroPushes.length) +
        " 68 1D 27 00 00" +
        " C7 41 0C 03 00 00 00" +
        " 68" + pe.rawToVa(offset2).packToHex(4) +
        " FF 60 18";

    var free = pe.insertHex(code);

    pe.replaceHex(offset, " 90 E9" + (pe.rawToVa(free) - pe.rawToVa(offset + 6)).packToHex(4));

    if (pe.fetchUByte(offsets[0]) === 0xEB)
    {
        offset = offsets[0] + 2 + pe.fetchByte(offsets[0] + 1);
    }
    else
    {
        offset = pe.find(" E9 ?? ?? 00 00", offsets[0], offsets[0] + 0x100);
        if (offset === -1)
        {
            return "Failed in Part 4 - JMP to Mode call missing";
        }

        offset += 5 + pe.fetchDWord(offset + 1);
    }

    code =
        getEcxWindowMgrHex() +
        " E8 ?? ?? ?? FF";
    var jumpOffset = 10;

    var joffset = pe.find(code, offset, offset + 0x100);
    if (joffset === -1)
    {
        code =
            " E8 ?? ?? ?? FF" +
            " 8B 07";
        joffset = pe.find(code, offset, offset + 0x100);
        jumpOffset = 5;
    }
    if (joffset === -1)
    {
        return "Failed in Part 4 - ErrorMsg call missing";
    }

    joffset += jumpOffset;

    code =
        " 6A 02" +
        " 8B CF" +
        " FF 50 18";

    offset2 = pe.find(code, joffset, joffset + 0x20);

    if (offset2 === -1)
    {
        code = code.replace(" 50 18", " D0");
        offset2 = pe.find(code, joffset, joffset + 0x20);
    }

    if (offset2 === -1)
    {
        code = code.replace(" D0", " D2").replace(" 8B CF", "");
        offset2 = pe.find(code, joffset, joffset + 0x20);
    }

    if (offset2 === -1)
    {
        code = code.replace(" D2", " 50 18");
        offset2 = pe.find(code, joffset, joffset + 0x20);
    }

    if (offset2 === -1)
    {
        return "Failed in Part 4 - Mode Call missing";
    }

    offset2 += code.hexlength();

    code =
        movEcx +
        " 8B 01" +
        " 6A 00".repeat(zeroPushes.length) +
        " 68 8D 00 00 00" +
        " 68" + pe.rawToVa(offset2).packToHex(4) +
        " FF 60 18";

    free = pe.insertHex(code);

    pe.replaceHex(joffset, " E9" + (pe.rawToVa(free) - pe.rawToVa(joffset + 5)).packToHex(4));

    return true;
}

function DCToLoginWindow_()
{
    return pe.getDate() > 20100730;
}
