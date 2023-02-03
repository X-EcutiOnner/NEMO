

function DisableFilenameCheck()
{
    var hwndHex = table.getHex4(table.g_hMainWnd);

    var code =
        " 84 C0" +
        " 74 07" +
        " E8 ?? ?? FF FF" +
        " EB 05" +
        " E8 ?? ?? FF FF" +
        " 84 C0" +
        " 75";
    var patchOffset = 18;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 84 C0" +
            " 74 0C" +
            " E8 ?? ?? FF FF" +
            " EB 0A BE 01 00 00 00" +
            " E8 ?? ?? FF FF" +
            " 84 C0" +
            " 75";
        patchOffset = 23;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "85 C0 " +
            "74 10 " +
            "83 BD ?? ?? ?? FF 01 " +
            "75 07 " +
            "E8 ?? ?? ?? FF " +
            "EB 05 " +
            "E8 ?? ?? ?? FF " +
            "84 C0 " +
            "75 1C " +
            "6A 00 " +
            "6A 00 " +
            "68 ?? ?? ?? 00 " +
            "FF 35 ?? ?? ?? 00 " +
            "FF 15 ?? ?? ?? ?? " +
            "33 C0 " +
            "E9 ";
        patchOffset = 27;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "85 C0 " +
            "74 10 " +
            "83 BD ?? ?? ?? FF 01 " +
            "75 07 " +
            "E8 ?? ?? ?? FF " +
            "EB 05 " +
            "E8 ?? ?? ?? FF " +
            "84 C0 " +
            "75 1C " +
            "6A 00 " +
            "6A 00 " +
            "68 ?? ?? ?? 00 " +
            "FF 35 ?? ?? ?? 01 " +
            "FF 15 ?? ?? ?? ?? " +
            "33 C0 " +
            "E9 ";
        patchOffset = 27;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "85 C0 " +
            "74 10 " +
            "83 BD ?? ?? ?? FF 01 " +
            "75 07 " +
            "E8 54 ?? ?? FF " +
            "EB 05 " +
            "E8 2D ?? ?? FF " +
            "84 C0 " +
            "75 18 " +
            "6A 00 " +
            "6A 00 " +
            "68 ?? ?? ?? 00 " +
            "FF ?? " + hwndHex +
            "FF D7 " +
            "33 C0 " +
            "E9 ";
        patchOffset = 27;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "85 C0 " +
            "74 10 " +
            "83 BD ?? ?? ?? FF 01 " +
            "75 07 " +
            "E8 ?? ?? ?? FF " +
            "EB 05 " +
            "E8 ?? ?? ?? FF " +
            "84 C0 " +
            "75 18 " +
            "6A 00 " +
            "6A 00 " +
            "68 ?? ?? ?? 00 " +
            "FF 35 " + hwndHex +
            "FF D6 " +
            "33 C0 " +
            "E9 ";
        patchOffset = 27;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "85 C0 " +
            "74 10 " +
            "83 BD ?? ?? ?? FF 01 " +
            "75 07 " +
            "E8 ?? ?? ?? FF " +
            "EB 05 " +
            "E8 ?? ?? ?? FF " +
            "84 C0 " +
            "75 18 " +
            "6A 00 " +
            "6A 00 " +
            "68 ?? ?? ?? 00 " +
            "FF 35 " + hwndHex +
            "FF D7 " +
            "33 C0 " +
            "E9 ";
        patchOffset = 27;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offset + patchOffset, 0xEB);

    return true;
}
