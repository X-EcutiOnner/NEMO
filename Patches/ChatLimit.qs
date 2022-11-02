

function ChatLimit(option)
{
    var LANGTYPE = GetLangType();

    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 1a - " + LANGTYPE[0];
    }

    var code =
        "83 3D " + LANGTYPE + "0A " +
        "74 ?? ";

    if (HasFramePointer())
    {
        code += "83 7D 08 02 ";
    }
    else
    {
        code += "83 7C 24 04 02 ";
    }

    code += "7C ";
    var isLong = false;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace("0A 74 ?? 83 7C 24 04 02 7C ", "0A 74 ?? 83 7D 08 02 7C ");
        isLong = false;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code = code.replace("0A 74 ?? 83 ", "0A 0F 84 ?? 00 00 00 83 ");
        code = code.replaceAt(-3, "0F 8C ");
        isLong = true;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1b - Pattern not found";
    }

    offset += code.hexlength() - 2;

    if (isLong)
    {
        offset--;
    }

    if (option === 1)
    {
        var flood = exe.getUserInput("$allowChatFlood", XTYPE_BYTE, _("Number Input"), _("Enter new chat limit (0-127, default is 2):"), 2, 0, 127);

        if (flood === 2)
        {
            return "Patch Cancelled - New value is same as old value";
        }

        pe.replaceHex(offset, flood.packToHex(1));
    }
    else if (isLong)
    {
        pe.replaceHex(offset + 1, "90 E9 ");
    }
    else
    {
        pe.replaceHex(offset + 1, "EB ");
    }

    return true;
}

function RemoveChatLimit()
{
    return ChatLimit(0);
}

function AllowChatFlood()
{
    return ChatLimit(1);
}
