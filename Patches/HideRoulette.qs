

function HideRoulette()
{
    var code =
        " 74 0F" +
        " 68 B5 00 00 00" +
        getEcxWindowMgrHex() +
        " E8";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - Reference Code missing";
    }

    offset += code.hexlength() + 4;

    if (pe.fetchDWord(offset + 1) !== 0x11D)
    {
        return "Patch Cancelled - Roulette is already hidden";
    }

    pe.replaceHex(offset, "EB 0D");
    return true;
}

function HideRoulette_()
{
    return pe.stringRaw("\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\\basic_interface\\roullette\\RoulletteIcon.bmp") !== -1;
}
