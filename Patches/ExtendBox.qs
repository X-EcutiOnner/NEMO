

function ExtendBox(index)
{
    var offset_for_patch = 3;

    var offsets = pe.findCodes(" C7 40 ?? 46 00 00 00");

    if (offsets.length < 4)
    {
        offset_for_patch = 6;
        offsets = pe.findCodes(" C7 80 ?? ?? ?? ?? 46 00 00 00");
    }

    if (offsets.length < 4)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offsets[index] + offset_for_patch, 0xEA);

    return true;
}

function ExtendChatBox()
{
    return ExtendBox(3);
}

function ExtendChatRoomBox()
{
    return ExtendBox(0);
}

function ExtendPMBox()
{
    return ExtendBox(2);
}
