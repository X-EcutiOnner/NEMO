

function ChangeDisplayCharDelDelay()
{
    var code =
        " 83 EC 24" +
        " 33 C0" +
        " 56" +
        " 8B 75 08" +
        " 0F 57 C0" +
        " 66 89 06" +
        " 66 0F D6 46 02" +
        " 89 46 0A";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 83 EC 24" +
            " 0F 57 C0" +
            " 83 39 00" +
            " 56" +
            " 8B 75 08" +
            " 0F 11 06" +
            " 7D 06" +
            " C7 01 00 00 00 00";

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var time32Func = imports.ptr("_time32");

    if (time32Func === -1)
    {
        return "Failed in Step 2 - No \"_time32\" function found";
    }

    code =
        " 53" +
        " 56" +
        " 51" +
        " 8B 75 08" +
        " 33 D2" +
        " 89 56 06" +
        " 89 56 0A" +
        " 6A 00" +
        " FF 15" + GenVarHex(1) +
        " 83 C4 04" +
        " 59" +
        " 8B 09" +
        " 3B C1" +
        " 73 22" +
        " 2B C8" +
        " 33 D2" +
        " 8B C1" +
        " BB 3C 00 00 00" +
        " F7 F3" +
        " 66 89 56 0A" +
        " 33 D2" +
        " BB 3C 00 00 00" +
        " F7 F3" +
        " 66 89 46 06" +
        " 66 89 56 08" +
        " 5E" +
        " 5B" +
        " 8B E5" +
        " 5D" +
        " C2 04 00";

    code = ReplaceVarHex(code, 1, time32Func);

    pe.replaceHex(offset, code);

    offset = pe.findCode("52 6A 28 6A 00 6A 0B 6A 00 8D 75");

    if (offset === -1)
    {
        offset = pe.findCode("57 6A 28 6A 00 6A 0B 6A 00 6A 00");
    }

    if (offset === -1)
    {
        offset = pe.findCode("52 6A 28 6A 00 6A 00 6A 0B 6A 00 6A 00");
    }

    if (offset === -1)
    {
        return "Failed in Step 4";
    }

    pe.replaceByte(offset + 2, 0x90);

    return true;
}

function ChangeDisplayCharDelDelay_()
{
    return (pe.findCode("52 6A 28 6A 00 6A 0B 6A 00 8D 75") & pe.findCode("52 6A 28 6A 00 6A 00 6A 0B 6A 00 6A 00") & pe.findCode("57 6A 28 6A 00 6A 0B 6A 00 6A 00")) !== -1;
}
