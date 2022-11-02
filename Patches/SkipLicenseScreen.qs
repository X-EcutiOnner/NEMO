

function SkipLicenseScreen()
{
    var offset = pe.stringVa("btn_disagree");
    if (offset === -1)
    {
        return "Failed in Step 1 - Unable to find btn_disagree";
    }

    offset = pe.findCode(" 68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - Unable to find reference to btn_disagree";
    }

    offset = pe.find(" FF 24 85 ?? ?? ?? 00", offset - 0x200, offset);
    if (offset === -1)
    {
        return "Failed in Step 2 - Unable to find the switch";
    }

    var refaddr = pe.vaToRaw(pe.fetchDWord(offset + 3));

    var third = pe.fetchHex(refaddr + 8, 4);

    pe.replaceHex(refaddr, third);
    pe.replaceHex(refaddr + 4, third);

    return true;
}
