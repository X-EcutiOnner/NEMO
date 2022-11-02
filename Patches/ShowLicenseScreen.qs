

function ShowLicenseScreen()
{
    var offset = pe.stringVa("model\\3dmob\\guildflag90_1.gr2");
    if (offset === -1)
    {
        return "Failed in Step 1 - Guild String missing";
    }

    var code =
        " 6A 05" +
        " 68" + offset.packToHex(4);

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - String Reference missing";
    }

    offset += code.hexlength();

    code =
        " 83 F8 04" +
        " 74 ??" +
        " 83 F8 08" +
        " 74 ??" +
        " 83 F8 09" +
        " 74 ??" +
        " 83 F8 06" +
        " 75";

    offset = pe.find(code, offset, offset + 0x60);
    if (offset === -1)
    {
        return "Failed in Step 2 - LangType comparison missing";
    }

    pe.replaceByte(offset + 3, 0xEB);

    return true;
}
