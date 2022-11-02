

function RestoreCashShop()
{
    var movEcx  = getEcxWindowMgrHex();
    var makeWin = table.get(table.UIWindowMgr_MakeWindow);

    var code =
        " 75 0F" +
        " 68 9F 00 00 00" +
        movEcx +
        " E8";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    var offset2 = offset + code.hexlength() + 4;

    if (pe.find("68 BE 00 00 00" + movEcx, offset - 0x30, offset) !== -1)
    {
        return "Patch Cancelled - Icon is already there";
    }

    code +=
        GenVarHex(1) +
        " 68 BE 00 00 00" +
        movEcx +
        " E8" + GenVarHex(2) +
        " E9" + GenVarHex(3);

    var free = alloc.find(code.hexlength());
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    var refAddr = pe.rawToVa(free + (offset2 - offset));

    code = ReplaceVarHex(code, 1, makeWin - refAddr);
    code = ReplaceVarHex(code, 2, makeWin - (refAddr + 15));
    code = ReplaceVarHex(code, 3, pe.rawToVa(offset2) - (refAddr + 20));

    pe.insertHexAt(free, code.hexlength(), code);
    pe.replaceHex(offset, "E9" + (pe.rawToVa(free) - pe.rawToVa(offset + 5)).packToHex(4));

    return true;
}

function RestoreCashShop_()
{
    return pe.stringRaw("NC_CashShop") !== -1;
}
