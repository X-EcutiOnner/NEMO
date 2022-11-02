

function DisableMultipleWindows()
{
    var funcOffset = imports.ptrValidated("CoInitialize", "ole32.dll");

    var code =
        " E8 ?? ?? ?? FF" +
        " ??" +
        " FF 15" + funcOffset.packToHex(4);
    var stolenCodeOffset = 0;
    var continueOffset = 5;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " E8 ?? ?? ?? FF" +
            " 6A 00 " +
            " FF 15" + funcOffset.packToHex(4);
        continueOffset = 5;
        stolenCodeOffset = 0;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            " E8 ?? ?? ?? 00" +
            " 6A 00 " +
            " FF 15" + funcOffset.packToHex(4);
        continueOffset = 5;
        stolenCodeOffset = 0;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            " 8B 35 ?? ?? ?? ??" +
            " 6A 00 " +
            " FF 15" + funcOffset.packToHex(4);
        continueOffset = 6;
        stolenCodeOffset = [0, 6];
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - CoInitialize call missing";
    }

    if (pe.fetchUByte(offset + code.hexlength()) === 0xA1)
    {
        pe.replaceHex(offset + code.hexlength(), " B8 FF FF FF 00");
        return true;
    }

    if (stolenCodeOffset === 0)
    {
        var resetTimer = pe.fetchDWord(offset - 4 + 5) + pe.rawToVa(offset + 5);
        code = " E8" + GenVarHex(0);
    }
    else
    {
        code = pe.fetchHexBytes(offset, stolenCodeOffset);
    }

    code =
        code +
            " 56" +
            " 33 F6" +
            " 68" + GenVarHex(1) +
            " FF 15" + GenVarHex(2) +
            " E8 0D 00 00 00" +
            "CreateMutexA\x00".toHex() +
            " 50" +
            " FF 15" + GenVarHex(3) +
            " E8 0F 00 00 00" +
            "Global\\Surface\x00".toHex() +
            " 56" +
            " 56" +
            " FF D0" +
            " 85 C0" +
            " 74 0F" +
            " 56" +
            " 50" +
            " FF 15" + GenVarHex(4) +
            " 3D 02 01 00 00" +
            " 75 26" +
            " 68" + GenVarHex(5) +
            " FF 15" + GenVarHex(6) +
            " E8 0C 00 00 00" +
            "ExitProcess\x00".toHex() +
            " 50" +
            " FF 15" + GenVarHex(7) +
            " 56" +
            " FF D0" +
            " 5E" +
            " 68" + GenVarHex(8) +
            " C3" +
            "KERNEL32\x00".toHex();

    var csize = code.hexlength();

    var free = alloc.find(csize);
    if (free === -1)
    {
        return "Failed in Step 2 - Not enough free space";
    }

    pe.replaceHex(offset, "E9" + (pe.rawToVa(free) - pe.rawToVa(offset + 5)).packToHex(4));

    code = ReplaceVarHex(code, 0, resetTimer - pe.rawToVa(free + 5));
    code = ReplaceVarHex(code, 8, pe.rawToVa(offset + continueOffset));

    code = ReplaceVarHex(code, 4, imports.ptrValidated("WaitForSingleObject", "KERNEL32.dll"));

    offset = pe.rawToVa(free + csize - 9);
    code = ReplaceVarHex(code, 1, offset);
    code = ReplaceVarHex(code, 5, offset);

    offset = imports.ptrValidated("GetModuleHandleA", "KERNEL32.dll");
    code = ReplaceVarHex(code, 2, offset);
    code = ReplaceVarHex(code, 6, offset);

    offset = imports.ptrValidated("GetProcAddress", "KERNEL32.dll");
    code = ReplaceVarHex(code, 3, offset);
    code = ReplaceVarHex(code, 7, offset);

    pe.insertHexAt(free, csize, code);

    return true;
}
