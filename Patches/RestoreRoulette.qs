

function RestoreRoulette()
{
    var movEcx  = getEcxWindowMgrHex();
    var makeWin = table.get(table.UIWindowMgr_MakeWindow);

    var code =
        " 74 0F" +
        " 68 B5 00 00 00" +
        movEcx +
        " E8";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    var offset2 = offset + code.hexlength() + 4;

    var mode;
    if (pe.getDate() > 20150800)
    {
        mode = 0x10C;
    }
    else
    {
        mode = 0x11D;
    }

    if (pe.fetchDWord(offset2 + 1) === mode)
    {
        return "Patch Cancelled - Roulette is already enabled";
    }

    code +=
        GenVarHex(1) +
        " 68" + GenVarHex(2) +
        movEcx +
        " E8" + GenVarHex(3) +
        " E9" + GenVarHex(4);

    var free = alloc.find(code.hexlength());
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    var refAddr = pe.rawToVa(free + (offset2 - offset));

    code = ReplaceVarHex(code, 1, makeWin - refAddr);
    code = ReplaceVarHex(code, 2, mode);
    code = ReplaceVarHex(code, 3, makeWin - (refAddr + 15));
    code = ReplaceVarHex(code, 4, pe.rawToVa(offset2) - (refAddr + 20));

    pe.insertHexAt(free, code.hexlength(), code);
    pe.replaceHex(offset, "E9" + (pe.rawToVa(free) - pe.rawToVa(offset + 5)).packToHex(4));

    return true;
}

function RestoreRoulette_()
{
    return pe.stringRaw("\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\\basic_interface\\roullette\\RoulletteIcon.bmp") !== -1;
}
