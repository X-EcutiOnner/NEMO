

function SkipResurrectionButton()
{
    var offset = pe.findCode(" 68 C5 1D 00 00");
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceHex(offset + 1, " FF FF");

    return true;
}
