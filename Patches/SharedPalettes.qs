

function SharedPalettes(prefix, newString)
{
    var offset = pe.stringVa(prefix + "%s%s_%d.pal");

    if (offset === -1)
    {
        offset = pe.stringVa(prefix + "%s_%s_%d.pal");
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Format String missing";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - Format String reference missing";
    }

    var free = alloc.find(newString.length);
    if (free === -1)
    {
        return "Failed in Step 2 - Not enough free space";
    }

    pe.insertAt(free, newString.length, newString);

    pe.replaceHex(offset + 1, pe.rawToVa(free).packToHex(4));

    return true;
}

function SharedBodyPalettesV1()
{
    return SharedPalettes("\xB8\xF6\\", "\xB8\xF6\\body%.s_%s_%d.pal\x00");
}

function SharedBodyPalettesV2()
{
    return SharedPalettes("\xB8\xF6\\", "\xB8\xF6\\body%.s%.s_%d.pal\x00");
}

function SharedHeadPalettesV1()
{
    return SharedPalettes("\xB8\xD3\xB8\xAE\\\xB8\xD3\xB8\xAE", "\xB8\xD3\xB8\xAE\\head%.s_%s_%d.pal\x00");
}

function SharedHeadPalettesV2()
{
    return SharedPalettes("\xB8\xD3\xB8\xAE\\\xB8\xD3\xB8\xAE", "\xB8\xD3\xB8\xAE\\head%.s%.s_%d.pal\x00");
}
