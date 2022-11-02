

function DisableAutofollow()
{
    if (table.get(table.m_lastLockOnPcGid) === 0)
    {
        return "Auto follow not found";
    }
    var lastLockOnPcGid = table.getHex4(table.m_lastLockOnPcGid);

    var code =
        "8B 87 ?? ?? ?? 00 " +
        "A3 " + lastLockOnPcGid;
    var starOffset = 6;
    var endOffset = 11;

    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        code =
            "8B 8B ?? ?? ?? 00 " +
            "89 0D " + lastLockOnPcGid;
        starOffset = 6;
        endOffset = 12;

        offsets = pe.findCodes(code);
    }

    if (offsets.length === 0)
    {
        code =
            "8B 83 ?? ?? 00 00 " +
            "A3 " + lastLockOnPcGid;
        starOffset = 6;
        endOffset = 11;

        offsets = pe.findCodes(code);
    }

    if (offsets.length === 0)
    {
        code =
            "FF 90 ?? ?? 00 00 " +
            "A3 " + lastLockOnPcGid;
        starOffset = 6;
        endOffset = 11;

        offsets = pe.findCodes(code);
    }

    if (offsets.length === 0)
    {
        return "Failed in Step 1";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        var offset = offsets[i];
        pe.setNopsRange(offset + starOffset, offset + endOffset);
    }

    return true;
}
