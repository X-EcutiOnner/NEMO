

function FixChatAt()
{
    var code =
        " 74 04" +
        " C6 ?? ?? 00" +
        " 5F" +
        " 5E";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 8B CE" +
            " E8 ?? ?? 00 00" +
            " 84 C0" +
            " 74 ??" +
            " 8B ?? ?? ?? 00 00";

        offset = pe.findCode(code);
        if (offset === -1)
        {
            return "Failed in Step 2 - Function call missing";
        }

        var func = pe.rawToVa(offset + 7) + pe.fetchDWord(offset + 3);

        code =
            " 60" +
            " 0F B6 41 2C" +
            " 85 C0" +
            " 74 1C" +
            " 8B 35" + GenVarHex(1) +
            " 6A 12" +
            " FF D6" +
            " 85 C0" +
            " 74 0E" +
            " 6A 11" +
            " FF D6" +
            " 85 C0" +
            " 74 06" +
            " 61" +
            " 33 C0" +
            " C2 04 00" +
            " 61" +
            " 68" + GenVarHex(2) +
            " C3";

        var csize = code.hexlength();

        var free = alloc.find(csize);
        if (free === -1)
        {
            return "Failed in Step 3 - Not enough free space";
        }

        code = ReplaceVarHex(code, 1, imports.ptrValidated("GetAsyncKeyState", "USER32.dll"));
        code = ReplaceVarHex(code, 2, func);

        pe.replaceDWord(offset + 3, pe.rawToVa(free) - pe.rawToVa(offset + 7));

        pe.insertHexAt(free, csize, code);
    }
    else
    {
        pe.replaceHex(offset + 5, "01");
    }

    return true;
}
