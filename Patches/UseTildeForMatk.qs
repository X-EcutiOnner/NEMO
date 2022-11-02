

function UseTildeForMatk()
{
    var offset = pe.stringVa("%d + %d");
    if (offset === -1)
    {
        return "Failed in Step 1 - Format string missing";
    }

    var offsets = pe.findCodes("68" + offset.packToHex(4));
    if (offsets.length !== 5)
    {
        return "Failed in Step 1 - Not enough matches";
    }

    offset = pe.halfStringVa("%d ~ %d");
    if (offset === -1)
    {
        offset = alloc.find(8);
        if (offset === -1)
        {
            return "Failed in Step 2 - Not enough free space";
        }

        pe.insertAt(offset, 8, "%d ~ %d");

        offset = pe.rawToVa(offset);
    }

    pe.replaceDWord(offsets[1] + 1, offset);

    return true;
}
