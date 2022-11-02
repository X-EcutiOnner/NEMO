

function HKLMtoHKCU()
{
    var offsets = pe.findCodes(" 68 02 00 00 80");

    if (!offsets[0])
    {
        return "Failed in Step 1";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        if (pe.fetchByte(offsets[i] + 5) !== 0x3B)
        {
            pe.replaceByte(offsets[i] + 1, 1);
        }
    }

    return true;
}
