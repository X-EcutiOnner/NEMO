

function DisableNagleAlgorithm()
{
    var code =
    GenVarHex(0) +
        " 55" +
        " 8B EC" +
        " 83 EC 0C" +
        " C7 45 F8 01 00 00 00" +
        " 8B 45 10" +
        " 50" +
        " 8B 4D 0C" +
        " 51" +
        " 8B 55 08" +
        " 52" +
        " FF 15" + GenVarHex(1) +
        " 89 45 FC" +
        " 83 7D FC FF" +
        " 74 3C" +
        " E8 0B 00 00 00" +
        " 73 65 74 73 6F 63 6B 6F 70 74 00" +
        " 68" + GenVarHex(2) +
        " FF 15" + GenVarHex(3) +
        " 50" +
        " FF 15" + GenVarHex(4) +
        " 89 45 F4" +
        " 83 7D F4 00" +
        " 74 11" +
        " 6A 04" +
        " 8D 45 F8" +
        " 50" +
        " 6A 01" +
        " 6A 06" +
        " 8B 4D FC" +
        " 51" +
        " FF 55 F4" +
        " 8B 45 FC" +
        " 8B E5" +
        " 5D" +
        " C2 0C 00";

    var size = code.hexlength();

    var free = alloc.find(size);
    if (free === -1)
    {
        return "Failed in Step 2 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);

    var sockFunc = imports.ptrValidated("socket", "ws2_32.dll", 23);

    code = ReplaceVarHex(code, 0, freeRva + 4);
    code = ReplaceVarHex(code, 1, sockFunc);
    code = ReplaceVarHex(code, 2, pe.stringVa("ws2_32.dll"));
    code = ReplaceVarHex(code, 3, imports.ptrValidated("GetModuleHandleA", "KERNEL32.dll"));
    code = ReplaceVarHex(code, 4, imports.ptrValidated("GetProcAddress", "KERNEL32.dll"));

    pe.insertHexAt(free, size, code);

    var offsets = pe.findCodes(" FF 25" + sockFunc.packToHex(4));

    var i;
    for (i = 0; i < offsets.length; i++)
    {
        pe.replaceDWord(offsets[i] + 2, freeRva);
    }

    offsets = pe.findCodes(" FF 15" + sockFunc.packToHex(4));

    for (i = 0; i < offsets.length; i++)
    {
        pe.replaceDWord(offsets[i] + 2, freeRva);
    }

    return true;
}
