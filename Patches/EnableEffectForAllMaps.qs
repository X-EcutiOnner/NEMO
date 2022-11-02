

function EnableEffectForAllMaps()
{
    var offset = pe.stringVa("Lua Files\\EffectTool\\");
    if (offset === -1)
    {
        return "Failed in Step 1 - String missing";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - String Reference missing";
    }

    offset = pe.find("0F 84 ?? ?? 00 00", offset - 0x20, offset);
    if (offset === -1)
    {
        return "Failed in Step 2 - Jump missing";
    }

    pe.replaceHex(offset, "EB 04");

    return true;
}
