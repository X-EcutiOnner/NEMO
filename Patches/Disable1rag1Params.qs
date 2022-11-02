

function Disable1rag1Params()
{
    var offset = pe.stringVa("1rag1");

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var strHex = offset.packToHex(4);

    var code =
        "68 " + strHex +
        "?? " +
        "FF ?? " +
        "83 C4 08 " +
        "85 ?? " +
        "75 ";
    var jmpOffset = 13;

    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "68 " + strHex +
            "?? " +
            "E8 ?? ?? ?? ?? " +
            "83 C4 08 " +
            "85 ?? " +
            "75 ";
        jmpOffset = 16;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "68 " + strHex +
            "?? " +
            "C7 05 ?? ?? ?? ?? 01 00 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "83 C4 08 " +
            "85 ?? " +
            "75 ";
        jmpOffset = 26;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    pe.replaceHex(offset + jmpOffset, "EB ");

    return true;
}

function Disable1rag1Params_()
{
    return pe.stringRaw("1rag1") !== -1;
}
