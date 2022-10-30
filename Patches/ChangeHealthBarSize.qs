
function ChangeHealthBarSize()
{
    var code =
        " 8B 8F ?? ?? ?? ??" +
        " 6A 09" +
        " 6A 3C" +
        " E8";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        code = code.replace(" 8B 8F", " 8B 8E");
        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in Step 1";
    }
    offset += 6;

    code =
        " 8B 86 ?? 00 00 00" +
        " 83 E8 1E" +
        " 89 45 D4";

    var offset2 = pe.findCode(code);
    if (offset2 === -1)
    {
        code = code.replace(" 89 45 D4", " 8B BE ?? 00 00 00");
        offset2 = pe.findCode(code);
    }
    if (offset2 === -1)
    {
        return "Failed in Step 2";
    }
    offset2 += 8;

    var width = exe.getUserInput("$hpWidth", XTYPE_BYTE, _("hp bar width (default 60)"), _("Enter new hp bar width in pixels"), "60", 1, 127);
    var height = exe.getUserInput("$hpHeight", XTYPE_BYTE, _("hp bar height (default 9)"), _("Enter new hp bar height in pixels"), "9", 1, 127);

    pe.replaceByte(offset + 1, height);
    pe.replaceByte(offset + 3, width);
    pe.replaceByte(offset2, width >> 1);

    return true;
}
