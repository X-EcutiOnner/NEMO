

function FixHomunculusAI()
{
    var code =
        "55 " +
        "8B EC " +
        "8B 89 E0 00 00 00 " +
        "8B 01 " +
        "3B C1 " +
        "74 0E " +
        "8B 55 08 " +
        "39 50 08 " +
        "74 0C " +
        "8B 00 " +
        "3B C1 " +
        "75 F5 " +
        "32 C0 " +
        "5D " +
        "C2 04 00 " +
        "B0 01 " +
        "5D " +
        "C2 04 00 ";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in step 1: function missing.";
    }

    offset += 0x1D;

    pe.replaceHex(offset, "B0 01 ");

    code =
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "68 86 00 00 00 ";

    var offsets = pe.findCodes(code);

    if (offsets.length !== 2)
    {
        code =
            "6A 00 " +
            "6A 00 " +
            "6A 00 " +
            "6A 00 " +
            "68 86 00 00 00 ";

        offsets = pe.findCodes(code);
    }

    if (offsets.length !== 2)
    {
        return "Failed in Step 4";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        offset = pe.find("84 C0 74 ?? ", offsets[i] - 8, offsets[i]);

        if (offset === -1)
        {
            return "Failed in Step 4.1";
        }

        offset += 2;
        pe.replaceByte(offset, 0xEB);
    }

    return true;
}
