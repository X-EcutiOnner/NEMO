

function DisableGameGuard()
{
    var offset = pe.stringVa("GameGuard Error: %lu");
    if (offset === -1)
    {
        return "Failed in Step 1 - GameGuard String missing";
    }

    offset = pe.findCode(" 68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - GG String Reference missing";
    }

    var code =
        " 55" +
        " 8B EC" +
        " 6A FF" +
        " 68";

    offset = pe.find(code, offset - 0x160, offset);
    if (offset === -1)
    {
        return "Failed in Step 1 - ProcessFindHack Function missing";
    }

    offset = pe.rawToVa(offset);

    code =
        " E8 ?? ?? 00 00" +
        " 84 C0" +
        " 74 04" +
        " C6 ?? ?? 01";

    var offsets = pe.findCodes(code);
    if (offsets.length === 0)
    {
        return "Failed in Step 2 - No Calls found matching ProcessFindHack";
    }

    code = " EB 07 90 90 90";
    var i;

    for (i = 0; i < offsets.length; i++)
    {
        var offset2 = pe.fetchDWord(offsets[i] + 1) + pe.rawToVa(offsets[i] + 5);
        if (offset2 === offset)
        {
            pe.replaceHex(offsets[i], code);
            break;
        }
    }

    if (offset2 !== offset)
    {
        return "Failed in Step 2 - No Matched calls are to ProcessFindHack";
    }

    offset = pe.stringVa("nProtect GameGuard");
    if (offset === -1)
    {
        return "Failed in Step 3 - nProtect string missing";
    }

    code =
        " 68" + offset.packToHex(4) +
        " 50" +
        " FF 35";

    offsets = pe.findCodes(code);
    if (offsets.length === 0)
    {
        return "Failed in Step 3 - nProtect references missing";
    }

    code =
        " 84 C0" +
        " 74 ??" +
        " E8 ?? ?? ?? FF" +
        " 8B C8" +
        " E8";

    for (i = 0; i < offsets.length; i++)
    {
        offset = pe.find(code, offsets[i] - 0x50, offsets[i]);

        if (offset !== -1)
        {
            pe.replaceByte(offset + 2, 0xEB);
        }
    }

    return true;
}

function DisableGameGuard_()
{
    return pe.stringRaw("GameGuard Error: %lu") !== -1 && pe.getDate() < 20210000;
}
