

function KoreaServiceTypeXMLFix()
{
    var offset = pe.stringVa("Unknown ServiceType !!!");
    if (offset === -1)
    {
        return "Failed in Step 1 - Error String missing";
    }

    var offsets = pe.findCodes(" 68" + offset.packToHex(4));
    if (offsets.length === 0)
    {
        return "Failed in Step 1 - No references found";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        var code =
            " FF 24 ?? ?? ?? ?? 00" +
            " E8 ?? ?? ?? ??" +
            " E9 ?? ?? ?? ??" +
            " 6A 00" +
            " E8";
        var repl = " 90 90 90 90 90";
        var offset2 = 12;

        offset = pe.find(code, offsets[i] - 0x30, offsets[i]);

        if (offset === -1)
        {
            code = code.replace(" E9 ?? ?? ?? ??", " EB ??");
            repl = " 90 90";

            offset = pe.find(code, offsets[i] - 0x30, offsets[i]);
        }

        if (offset === -1)
        {
            code =
                " 75 ??" +
                " E8 ?? ?? ?? ??" +
                " E9 ?? ?? ?? ??" +
                " 6A 00" +
                " E8";
            repl = " 90 90 90 90 90";
            offset2 = 7;

            offset = pe.find(code, offsets[i] - 0x30, offsets[i]);
        }

        if (offset === -1)
        {
            return "Failed in Step 2 - Calls missing for iteration no." + i;
        }

        pe.replaceHex(offset + offset2, repl);

        offset = pe.vaToRaw(pe.fetchDWord(offset + 3));
        if (offset < 0)
        {
            return "Failed in step 2c - found wrong offset for iteration no." + i;
        }

        code = pe.fetchHex(offset, 4);
        pe.replaceHex(offset + 4, code);
    }

    return true;
}

