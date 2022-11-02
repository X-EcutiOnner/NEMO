

function UseAsciiOnAllLangTypes()
{
    var offset = pe.findCode("F6 04 ?? 80 75");
    if (offset === -1)
    {
        offset = pe.findCode("80 3C ?? 00 7C");
    }
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceHex(offset + 4, " 90 90");

    return true;
}
