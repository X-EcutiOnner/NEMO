

function UseSSOLoginPacket()
{
    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 1 - " + LANGTYPE[0];
    }

    var passwordEncryptHex = table.getHex4(table.g_passwordEncrypt);

    var code =
        " 80 3D " + passwordEncryptHex + " 00" +
        " 0F 85 ?? ?? 00 00" +
        " A1" + LANGTYPE +
        " ?? ??" +
        " 0F 84 ?? ?? 00 00" +
        " 83 ?? 12" +
        " 0F 84 ?? ?? 00 00";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 80 3D " + passwordEncryptHex + " 00" +
            " 0F 85 ?? ?? 00 00" +
            " 8B ?? " + LANGTYPE +
            " ?? ??" +
            " 0F 84 ?? ?? 00 00" +
            " 83 ?? 12" +
            " 0F 84 ?? ?? 00 00";
        offset = pe.findCode(code);
    }

    if (offset !== -1)
    {
        pe.replaceHex(offset + code.hexlength() - 15, " 90 E9");
        return true;
    }

    code =
        " A0 " + passwordEncryptHex +
        " ?? ??" +
        " 0F 85 ?? ?? 00 00" +
        " A1" + LANGTYPE +
        " ?? ??" +
        " 0F 85 ?? ?? 00 00";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceHex(offset + code.hexlength() - 6, " 90 90 90 90 90 90");

    return true;
}
