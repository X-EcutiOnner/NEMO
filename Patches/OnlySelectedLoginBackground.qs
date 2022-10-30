

function OnlySelectedBackground(s1, s2)
{
    var fnd = "\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\\T" + s1 + "_\xB9\xE8\xB0\xE6%d-%d.bmp";
    if (s1 === "")
    {
        fnd  += "\x00";
    }

    var rep = s2 + "_\xB9\xE8\xB0\xE6%d-%d.bmp\x00";

    var offset = pe.halfStringRaw(fnd);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replace(offset + 16, rep);

    return true;
}

function OnlyFirstLoginBackground()
{
    return OnlySelectedBackground("2", "");
}

function OnlySecondLoginBackground()
{
    return OnlySelectedBackground("", "2");
}
