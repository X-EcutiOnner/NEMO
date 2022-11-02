

function ShowExpNumbers()
{
    var offset = pe.halfStringVa("Alt+V, Ctrl+V");
    if (offset === -1)
    {
        return "Failed in Step 1 - String missing";
    }

    var code =
        " 68" + offset.packToHex(4) +
        " 8B";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - String reference missing";
    }

    offset += code.hexlength() + 6;

    code =
        " 8B ?? ?? 00 00 00" +
        " 68 ?? ?? ?? ??" +
        " 68 ?? ?? ?? ??" +
        " E8";

    var offset2 = pe.find(code, offset, offset + 0x300);
    if (offset2 === -1)
    {
        code =
            " 8B ?? ?? 00 00 00" +
            " FF 35 ?? ?? ?? ??" +
            " FF 35 ?? ?? ?? ??" +
            " FF 35 ?? ?? ?? ??" +
            " E8";
        offset2 = pe.find(code, offset, offset + 0x300);
        var newclient = 1;
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - Base Exp addrs missing";
    }

    offset2 += code.hexlength() + 4;

    var curExpBase;
    var totExpBase;
    if (newclient === 1)
    {
        curExpBase = pe.fetchDWord(offset2 - 9);
        totExpBase = pe.fetchDWord(offset2 - 21);
    }
    else
    {
        curExpBase = pe.fetchDWord(offset2 - 9);
        totExpBase = pe.fetchDWord(offset2 - 14);
    }

    offset2 = pe.find(code, offset2, offset + 0x300);
    if (offset2 === -1)
    {
        return "Failed in Step 2 - Job Exp addrs missing";
    }

    offset2 += code.hexlength() + 4;

    var curExpJob;
    var totExpJob;
    if (newclient === 1)
    {
        curExpJob = pe.fetchDWord(offset2 - 9);
        totExpJob = pe.fetchDWord(offset2 - 21);
    }
    else
    {
        curExpJob = pe.fetchDWord(offset2 - 9);
        totExpJob = pe.fetchDWord(offset2 - 14);
    }

    offset = pe.stringVa("SP");

    code =
        " 68" + offset.packToHex(4) +
        " 6A 41" +
        " 6A 11";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 3 - Args missing";
    }

    offset += code.hexlength();

    var rcode = " CE";

    if (pe.fetchUByte(offset) !== 0xE8)
    {
        rcode = pe.fetchHex(offset + 1, 1);
        offset += 2;
    }

    if (pe.fetchUByte(offset) !== 0xE8)
    {
        return "Failed in Step 3 - Call missing";
    }

    var uiTextOut = pe.rawToVa(offset + 5) + pe.fetchDWord(offset + 1);
    var injectAddr = offset;

    var extraPush = "";
    if (pe.getDate() > 20140116)
    {
        extraPush = " 6A 00";
    }

    var extraPush2 = "";
    code =
        " E8 ?? ?? ?? ??" +
        " 6A 00" +
        " 6A 00" +
        " 6A 00" +
        " 6A 0E";
    offset = pe.find(code, injectAddr - 0x20, injectAddr);
    if (offset !== -1)
    {
        extraPush2 = " 6A 00";
    }

    var template =
        " A1" + GenVarHex(1) +
        " 8B 0D" + GenVarHex(2) +
        " 09 C1" +
        " 74 JJ" +
        " 50" +
        " A1" + GenVarHex(3) +
        " 50" +
        " 68" + GenVarHex(4) +
        " 8D 44 24 0C" +
        " 50" +
        " FF 15" + GenVarHex(5) +
        " 83 C4 10" +
        " 89 E0" +
        extraPush2 +
        extraPush +
        " 6A 00" +
        " 6A 0D" +
        " 6A 01" +
        " 6A 00" +
        " 50" +
        " 6A YC" +
        " 6A XC" +
        " 8B" + rcode +
        " E8" + GenVarHex(6);

    var printFunc = imports.ptr("sprintf");

    if (printFunc === -1)
    {
        printFunc = imports.ptr("wsprintfA");
    }

    if (printFunc === -1)
    {
        return "Failed in Step 4 - No print functions found";
    }

    template = ReplaceVarHex(template, 4, pe.halfStringVa("%d / %d"));
    template = ReplaceVarHex(template, 5, printFunc);
    template = template.replace(" XC", " 56");
    template = template.replace(" JJ", (template.hexlength() - 15).packToHex(1));

    code =
        " E8" + GenVarHex(0) +
        " 50" +
        " 83 EC 20" +
        template +
        template +
        " 83 C4 20" +
        " 58" +
        " E9" + GenVarHex(7);

    var size = code.hexlength();
    var free = alloc.find(size);
    if (free === -1)
    {
        return "Failed in Step 4 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);

    code = ReplaceVarHex(code, [1, 2, 3], [totExpBase, curExpBase, curExpBase]);
    code = ReplaceVarHex(code, 6, uiTextOut - (freeRva + 9 + template.hexlength()));
    code = code.replace("YC", "4E");

    code = ReplaceVarHex(code, [1, 2, 3], [totExpJob,  curExpJob,  curExpJob]);
    code = ReplaceVarHex(code, 6, uiTextOut - (freeRva + 9 + template.hexlength() * 2));
    code = code.replace("YC", "68");

    code = ReplaceVarHex(code, 0, uiTextOut - (freeRva + 5));
    code = ReplaceVarHex(code, 7, pe.rawToVa(injectAddr + 5) - (freeRva + size));

    pe.insertHexAt(free, size, code);

    pe.replaceHex(injectAddr, "E9" + (freeRva - pe.rawToVa(injectAddr + 5)).packToHex(4));

    return true;
}
