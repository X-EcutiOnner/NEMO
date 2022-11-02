

function ReadDataFolderFirst()
{
    var offset = pe.stringVa("loading");
    if (offset === -1)
    {
        return "Failed in Step 1 - loading not found";
    }

    var code =
        " 74 07" +
        " C6 05 ?? ?? ?? ?? 01" +
        " 68" + offset.packToHex(4);

    var repl = " 90 90";
    var gloc = 4;
    var firstOffset = 0;

    var offset2 = pe.findCode(code);

    if (offset2 === -1)
    {
        code =
            " 0F 45 ??" +
            " 88 ?? ?? ?? ?? ??" +
            " 68" + offset.packToHex(4);

        repl = " 90 8B";
        gloc = 5;
        firstOffset = 0;

        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        code =
            "0F B6 0D ?? ?? ?? ?? " +
            "85 C0 " +
            "68 " + offset.packToHex(4) +
            "0F 45 CE " +
            "88 0D ";
        repl = " 90 8B";
        gloc = 3;
        firstOffset = 14;
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 1 - loading reference missing";
    }

    pe.replaceHex(offset2 + firstOffset, repl);

    var gReadFolderFirst = pe.fetchDWord(offset2 + gloc);

    var offsets = pe.findCodes(" 80 3D" + gReadFolderFirst.packToHex(4) + " 00");
    var i;

    if (offsets.length !== 0)
    {
        for (i = 0; i < offsets.length; i++)
        {
            offset = pe.find(" 74 ?? E8", offsets[i] + 0x7, offsets[i] + 0x20);
            if (offset === -1)
            {
                return "Failed in Step 2 - Iteration No." + i;
            }

            pe.replaceHex(offset, " 90 90");
        }

        return true;
    }

    offsets = pe.findCodes(" A0" + gReadFolderFirst.packToHex(4));
    if (offsets === -1)
    {
        return "Failed in Step 3 - No Comparisons found";
    }

    for (i = 0; i < offsets.length; i++)
    {
        offset = pe.find(" 0F 84 ?? ?? 00 00", offsets[i] + 0x5, offsets[i] + 0x20);
        if (offset === -1)
        {
            return "Failed in Step 3 - Iteration No." + i;
        }

        pe.replaceHex(offset, " 90 90 90 90 90 90");
    }

    return true;
}
