

function LoadItemInfoPerServer()
{
    var code =
        " C1 ?? 05" +
        " 66 83 ?? ?? ?? ?? 00 00 03";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

    offset += code.hexlength();

    code =
        " B9 ?? ?? ?? 00" +
        " E8 ?? ?? ?? ??" +
        " 8B ?? ?? ?? 00 00";
    var directCall = true;
    var offset2 = pe.find(code, offset, offset + 0x40);

    if (offset2 === -1)
    {
        code = code.replace(" E8", " FF 15");
        directCall = false;
        offset2 = pe.find(code, offset, offset + 0x40);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 1 - StringAllocator call missing";
    }

    var allocInject = offset2 + 5;

    offset = pe.stringVa("ItemInfo file Init");
    if (offset === -1)
    {
        return "Failed in Step 2 - ItemInfo String missing";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 2 - ItemInfo String reference missing";
    }

    code =
        " E8 ?? ?? ?? ??" +
        " 8B 0D ?? ?? ?? 00" +
        " E8 ?? ?? ?? ??";

    offset = pe.find(code, offset - 0x30, offset);
    if (offset === -1)
    {
        return "Failed in Step 2 - ItemInfo Loader missing";
    }

    var refMov = pe.fetchHex(offset + 5, 6);

    var code2 =
        " 90 90" +
        " B0 01" +
        " EB 05";

    pe.replaceHex(offset + 5, code2);

    offset += code.hexlength();
    offset += pe.fetchDWord(offset - 4);
    var iiLoaderFunc = pe.rawToVa(offset);

    offset2 = pe.stringVa("main");
    if (offset2 === -1)
    {
        return "Failed in Step 3 - main string missing";
    }

    code =
        " 68" + offset2.packToHex(4) +
        " 68 EE D8 FF FF" +
        " ??" +
        " E8 ?? ?? ?? 00";
    offset2 = pe.find(code, offset, offset + 0x200);

    if (offset2 === -1)
    {
        code = code.replace(" FF FF ?? E8", "FF FF FF 75 ?? E8");
        offset2 = pe.find(code, offset, offset + 0x200);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 3 - main push missing";
    }

    var mainInject = offset2 + code.hexlength() - 5;

    offset = pe.find(" 6A 00 6A 02 6A 00", mainInject + 5, mainInject + 0x20);
    if (offset === -1)
    {
        return "Failed in Step 3 - Arg Count Push missing";
    }

    pe.replaceByte(offset + 5, 1);

    code =
        refMov +
        " 68 ?? ?? ?? 00" +
        " E8 ?? ?? ?? FF";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 4 - ItemInfo copy function missing";
    }

    offset += refMov.hexlength();

    var iiPush = pe.fetchHex(offset, 5);
    var iiCopierFunc = pe.rawToVa(offset + 10) + pe.fetchDWord(offset + 6);

    code =
        " 8B ??" +
        " 8B ??" +
        " 83 ?? 04" +
        " ??" +
        " ??" +
        " E8 ?? ?? ?? 00" +
        " 83 C4 08";
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 8B ?? 8B ??", " FF ??");
        code = code.replace(" ?? ?? E8", " FF ?? E8");

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 5 - String Pusher missing";
    }

    offset += code.hexlength() - 3;

    var stringPushFunc = pe.rawToVa(offset) + pe.fetchDWord(offset - 4);

    code =
        " E8" + GenVarHex(1) +
        " 83 C4 08" +
        " FF 35" + GenVarHex(2) +
        " 83 EC 04" +
        " E8" + GenVarHex(3) +
        " E9" + GenVarHex(4) +
        " 00 00 00 00";

    var free = alloc.find(code.hexlength());
    if (free === -1)
    {
        return "Failed in Step 6 - Not enough space available";
    }

    var freeRva = pe.rawToVa(free);
    var serverAddr = freeRva + code.hexlength() - 4;

    offset = pe.rawToVa(mainInject + 5) + pe.fetchDWord(mainInject + 1) - (freeRva + 5);
    code = ReplaceVarHex(code, 1, offset);
    code = ReplaceVarHex(code, 2, serverAddr);
    code = ReplaceVarHex(code, 3, stringPushFunc - (serverAddr - 5));
    code = ReplaceVarHex(code, 4, pe.rawToVa(mainInject + 5) - serverAddr);

    offset = freeRva - pe.rawToVa(mainInject + 5);
    pe.replaceHex(mainInject, "E9" + offset.packToHex(4));

    pe.insertHexAt(free, code.hexlength(), code);

    code =
        " E8" + GenVarHex(1) +
        " 8B 44 24 FC" +
        " 3B 05" + GenVarHex(2) +
        " 74 20" +
        " A3" + GenVarHex(3) +
        refMov +
        " E8" + GenVarHex(4) +
        refMov +
        iiPush +
        " E8" + GenVarHex(5) +
        " E9" + GenVarHex(6);

    if (!directCall)
    {
        code = code.replace("E8", "FF 15");
    }

    free = alloc.find(code.hexlength());
    if (free === -1)
    {
        return "Failed in Step 7 - Not enough space available";
    }

    freeRva = pe.rawToVa(free);

    if (directCall)
    {
        offset = pe.rawToVa(allocInject + 5) + pe.fetchDWord(allocInject + 1) - (freeRva + 5);
    }
    else
    {
        offset = pe.fetchDWord(allocInject + 2);
    }

    code = ReplaceVarHex(code, 1, offset);
    code = ReplaceVarHex(code, 2, serverAddr);
    code = ReplaceVarHex(code, 3, serverAddr);

    offset = iiLoaderFunc - (freeRva + code.hexlength() - (refMov.hexlength() + iiPush.hexlength() + 10));
    code = ReplaceVarHex(code, 4, offset);

    offset = iiCopierFunc - (freeRva + code.hexlength() - 5);
    code = ReplaceVarHex(code, 5, offset);

    offset = pe.rawToVa(allocInject + 5) - (freeRva + code.hexlength());
    code = ReplaceVarHex(code, 6, offset);

    offset = freeRva - pe.rawToVa(allocInject + 5);
    pe.replaceHex(allocInject, "E9" + offset.packToHex(4));

    if (!directCall)
    {
        pe.replaceByte(allocInject + 5, 0x90);
    }

    pe.insertHexAt(free, code.hexlength(), code);

    return true;
}

function LoadItemInfoPerServer_()
{
    return pe.stringRaw("System/iteminfo.lub") !== -1;
}
