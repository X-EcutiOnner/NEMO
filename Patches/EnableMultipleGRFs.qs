

function EnableMultipleGRFs()
{
    var grf = pe.stringHex4("data.grf");

    var code =
        " 68" + grf +
        getEcxFileMgrHex();
    var offset = pe.findCode(code);
    var pushOffset = 0;
    var fnoffset;
    var addpackOffset = -1;

    if (offset === -1)
    {
        code =
            getEcxFileMgrHex() +
            "85 C0 " +
            "0F 95 05 ?? ?? ?? ?? " +
            "68 " + grf +
            "E8 ";
        offset = pe.findCode(code);
        pushOffset = 14;
        fnoffset = offset;
        addpackOffset = 20;
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var setECX = getEcxFileMgrHex();

    if (addpackOffset === -1)
    {
        code =
            " E8 ?? ?? ?? ??" +
            " 8B ?? ?? ?? ?? 00" +
            " A1 ?? ?? ?? 00";
        fnoffset = pe.find(code, offset + 10, offset + 40);
        addpackOffset = 1;
    }

    if (fnoffset === -1)
    {
        code =
            " E8 ?? ?? ?? ??" +
            " A1 ?? ?? ?? 00";
        fnoffset = pe.find(code, offset + 10, offset + 40);
        addpackOffset = 1;
    }

    if (fnoffset === -1)
    {
        code =
            " E8 ?? ?? ?? ??" +
            " BF ?? ?? ?? 00";
        fnoffset = pe.find(code, offset + 10, offset + 40);
        addpackOffset = 1;
    }

    if (fnoffset === -1)
    {
        return "Failed in Step 2";
    }

    var AddPak = pe.rawToVa(fnoffset + addpackOffset + 4) + pe.fetchDWord(fnoffset + addpackOffset);

    code =
        " C8 80 00 00" +
        " 60" +
        " 68" + GenVarHex(1) +
        " FF 15" + GenVarHex(2) +
        " 85 C0" +
        " 74 23" +
        " 8B 3D" + GenVarHex(3) +
        " 68" + GenVarHex(4) +
        " 89 C3" +
        " 50" +
        " FF D7" +
        " 85 C0" +
        " 74 0F" +
        " 89 45 F6" +
        " 68" + GenVarHex(5) +
        " 89 D8" +
        " 50" +
        " FF D7" +
        " 85 C0" +
        " 74 6E" +
        " 89 45 FA" +
        " 31 D2" +
        " 66 C7 45 FE 39 00" +
        " 52" +
        " 68" + GenVarHex(6) +
        " 6A 74" +
        " 8D 5D 81" +
        " 53" +
        " 8D 45 FE" +
        " 50" +
        " 50" +
        " 68" + GenVarHex(7) +
        " FF 55 F6" +
        " 8D 4D FE" +
        " 66 8B 09" +
        " 8D 5D 81" +
        " 66 3B 0B" +
        " 5A" +
        " 74 0E" +
        " 52" +
        " 53"   +
        setECX +
        " E8" + GenVarHex(8) +
        " 5A" +
        " 42" +
        " FE 4D FE" +
        " 80 7D FE 30" +
        " 73 C1" +
        " 85 D2" +
        " 75 20" +
        " 68" + GenVarHex(9) +
        " 68" + grf +
        " 66 C7 45 FE 32 00" +
        " 8D 45 FE" +
        " 50" +
        " 68" + GenVarHex(10) +
        " FF 55 FA" +
        " 85 C0" +
        " 75 97" +
        " 61" +
        " C9" +
        " C3 00";

    var iniFile = input.getString(
        "$dataINI",
        _("String Input"),
        _("Enter the name of the INI file"),
        "DATA.INI",
        20
    );
    if (iniFile === "")
    {
        iniFile = ".\\DATA.INI";
    }
    else
    {
        iniFile = ".\\" + iniFile;
    }

    var strings = ["KERNEL32", "GetPrivateProfileStringA", "WritePrivateProfileStringA", "Data", iniFile];

    var size = code.hexlength();
    var i;
    for (i = 0; i < strings.length; i++)
    {
        size = size + strings[i].length + 1;
    }

    var free = alloc.find(size + 8);
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);

    pe.replaceByte(offset + pushOffset, 0xB9);
    pe.replaceDWord(fnoffset + addpackOffset, freeRva - pe.rawToVa(fnoffset + addpackOffset + 4));

    var memPosition = freeRva + code.hexlength();
    code = ReplaceVarHex(code, 1, memPosition);
    code = ReplaceVarHex(code, 2, imports.ptrValidated("GetModuleHandleA", "KERNEL32.dll"));
    code = ReplaceVarHex(code, 3, imports.ptrValidated("GetProcAddress", "KERNEL32.dll"));

    memPosition = memPosition + strings[0].length + 1;
    code = ReplaceVarHex(code, 4, memPosition);

    memPosition = memPosition + strings[1].length + 1;
    code = ReplaceVarHex(code, 5, memPosition);

    memPosition = memPosition + strings[2].length + 1;
    code = ReplaceVarHex(code, 7, memPosition);
    code = ReplaceVarHex(code, 10, memPosition);

    memPosition = memPosition + strings[3].length + 1;
    code = ReplaceVarHex(code, 6, memPosition);
    code = ReplaceVarHex(code, 9, memPosition);

    code = ReplaceVarHex(code, 8, AddPak - (freeRva + 115) - 5);

    for (i = 0; strings[i]; i++)
    {
        code = code + strings[i].toHex() + " 00";
    }
    code += " 00".repeat(8);

    pe.insertHexAt(free, size + 8, code);

    offset = pe.stringRaw("rdata.grf");
    if (offset !== -1)
    {
        pe.replaceByte(offset, 0);
    }

    return true;
}
