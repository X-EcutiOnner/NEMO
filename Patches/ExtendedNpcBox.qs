

function ExtendNpcBox()
{
    var offset = pe.stringVa("|%02x");
    if (offset === -1)
    {
        return "Failed in Step 1 - Format string missing";
    }

    var offsets = pe.findCodes("68" + offset.packToHex(4));
    if (offsets.length === 0)
    {
        return "Failed in Step 1 - String reference missing";
    }

    var i;
    for (i = 0; i < offsets.length; i++)
    {
        offset = pe.find("81 EC ?? 08 00 00", offsets[i] - 0x80, offsets[i]);
        if (offset !== -1)
        {
            break;
        }
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Function not found";
    }

    var stackSub = pe.fetchDWord(offset + 2);

    var fpEnb = HasFramePointer();
    var code;
    if (fpEnb)
    {
        code =
            " 8B E5" +
            " 5D" +
            " C2 04 00";
    }
    else
    {
        code =
            " 81 C4" + stackSub.packToHex(4) +
            " C2 04 00";
    }

    var offset2 = pe.find(code, offsets[i] + 5, offset + 0x200);
    if (offset2 === -1)
    {
        return "Failed in Step 1 - Function end missing";
    }

    var value = exe.getUserInput("$npcBoxLength", XTYPE_DWORD, _("Number Input"), _("Enter new NPC Dialog box length (2052 - 4096)"), 0x804, 0x804, 0x1000);
    if (value === 0x804)
    {
        return "Patch Cancelled - New value is same as old";
    }

    pe.replaceDWord(offset + 2, value + stackSub - 0x804);
    if (!fpEnb)
    {
        pe.replaceDWord(offset2 + 2, value + stackSub - 0x804);
    }
    var j;

    if (fpEnb)
    {
        for (i = 0; i <= 3; i++)
        {
            code = (i - stackSub).packToHex(4);
            offsets = pe.findAll(code, offset + 6, offset2);
            for (j = 0; j < offsets.length; j++)
            {
                pe.replaceDWord(offsets[j], i - value);
            }
        }
    }
    else
    {
        for (i = 0x804; i <= 0x820; i += 4)
        {
            offsets = pe.findAll(i.packToHex(4), offset + 6, offset2);
            for (j = 0; j < offsets.length; j++)
            {
                pe.replaceDWord(offsets[j], value + i - 0x804);
            }
        }
    }

    return true;
}
