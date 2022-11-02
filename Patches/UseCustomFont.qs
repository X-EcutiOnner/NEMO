

function UseCustomFont()
{
    var goffset = pe.halfStringVa("Gulim");
    if (goffset === -1)
    {
        return "Failed in Step 1 - Gulim not found";
    }

    var offset = pe.find(goffset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - Gulim reference not found";
    }

    var newFont = exe.getUserInput("$newFont", XTYPE_FONT, _("Font input"), _("Select the new Font Family"), "Arial");

    var free = pe.stringRaw(newFont);

    if (free === -1)
    {
        free = alloc.find(newFont.length + 1);

        if (free === -1)
        {
            return "Failed in Step 2 - Not enough free space";
        }

        pe.insertAt(free, newFont.length + 1, newFont);
    }

    var freeRva = pe.rawToVa(free);

    goffset &= 0xFFF00000;
    do
    {
        pe.replaceDWord(offset, freeRva);
        offset += 4;
    } while ((pe.fetchDWord(offset) & goffset) === goffset);

    return true;
}
