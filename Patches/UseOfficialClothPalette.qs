

function UseOfficialClothPalette()
{
    if (getActivePatches().indexOf(202) !== -1)
    {
        return "Patch Cancelled - Turn off Custom Job patch first";
    }

    var offset = pe.stringVa("\xC5\xA9\xB7\xE7");
    if (offset === -1)
    {
        return "Failed in Step 1 - Palette prefix missing";
    }

    var offsets = pe.findCodes(" C7 ?? 38" + offset.packToHex(4));

    var offset2 = -1;

    var i;
    for (i = 0; i < offsets.length; i++)
    {
        offset2 = pe.find(" 0F 85 ?? ?? 00 00", offsets[i] - 0x20, offsets[i]);
        if (offset2 !== -1)
        {
            break;
        }
    }

    if (offset2 === -1)
    {
        offsets = pe.findCodes(" C7 00" + offset.packToHex(4) + " E8");

        for (i = 0; i < offsets.length; i++)
        {
            offset2 = pe.find(" 0F 85 ?? ?? 00 00", offsets[i] - 0x20, offsets[i]);
            if (offset2 !== -1)
            {
                break;
            }
        }
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - Prefix reference missing";
    }

    pe.replaceHex(offset2, " 90 90 90 90 90 90");

    return true;
}
