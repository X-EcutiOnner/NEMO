

function EnableWhoCommand()
{
    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 1 - " + LANGTYPE[0];
    }

    var code =
        " A1" + LANGTYPE +
        " 83 F8 03" +
        " 0F 84 ?? ?? 00 00" +
        " 83 F8 08" +
        " 0F 84 ?? ?? 00 00" +
        " 83 F8 09" +
        " 0F 84 ?? ?? 00 00" +
        " 8D";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " A1" + LANGTYPE +
            " 83 F8 03" +
            " 0F 84 ?? ?? 00 00" +
            " 83 F8 08" +
            " 0F 84 ?? ?? 00 00" +
            " 83 F8 09" +
            " 0F 84 ?? ?? 00 00" +
            " B8";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - LangType comparison missing";
    }

    pe.replaceHex(offset + 5, "90 EB 18");

    code =
        " 68 B2 00 00 00" +
        " E8 ?? ?? ?? ??" +
        " 83 C4 04";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 2 - MsgStr call missing";
    }

    var aidHex = (table.get(table.g_session) + table.get(table.CSession_m_accountId)).packToHex(4);

    code =
        " 75 ??" +
        " A1 " + aidHex +
        " 50" +
        " E8 ?? ?? ?? FF" +
        " 83 C4 04" +
        " 84 C0" +
        " 75";
    var patchOffset = 0;
    var offset2 = pe.find(code, offset - 0x60, offset);
    if (offset2 === -1)
    {
        code =
            " 75 ??" +
            " FF 35 " + aidHex +
            " E8 ?? ?? ?? FF" +
            " 83 C4 04" +
            " 84 C0" +
            " 75";
        patchOffset = 0;
        offset2 = pe.find(code, offset - 0x60, offset);
    }
    if (offset2 === -1)
    {
        code =
            " 75 ??" +
            " FF 35 " + aidHex +
            " E8 ?? ?? ?? 00" +
            " 83 C4 04" +
            " 84 C0" +
            " 75";
        patchOffset = 0;
        offset2 = pe.find(code, offset - 0x60, offset);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - LangType comparison missing";
    }

    pe.replaceByte(offset2 + patchOffset, 0xEB);

    return true;
}
