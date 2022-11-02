

function ChatColorGuild()
{
    var code =
        " 6A 04" +
        " 68 B4 FF B4 00";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 6A 04", " 6A 04 8D ?? ?? ?? FF FF");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var color = exe.getUserInput("$guildChatColor", XTYPE_COLOR, _("Color input"), _("Select the new Guild Chat Color"), 0x00B4FFB4);
    if (color === 0x00B4FFB4)
    {
        return "Patch Cancelled - New Color is same as old";
    }

    pe.replaceDWord(offset + code.hexlength() - 4, color);

    return true;
}

function ChatColorGM()
{
    var offset1 = pe.findCode("68 FF 8D 1D 00");
    if (offset1 === -1)
    {
        return "Failed in Step 1 - Orange color not found";
    }

    var offset2 = pe.find("68 FF FF 00 00", offset1 - 0x30, offset1 + 0x30);
    if (offset2 === -1)
    {
        return "Failed in Step 1 - Cyan not found";
    }

    var offset3 = pe.find("68 00 FF FF 00", offset1 - 0x30, offset1 + 0x30);
    if (offset3 === -1)
    {
        return "Failed in Step 1 - Yellow not found";
    }

    var color = exe.getUserInput("$gmChatColor", XTYPE_COLOR, _("Color input"), _("Select the new GM Chat Color"), 0x0000FFFF);
    if (color === 0x0000FFFF)
    {
        return "Patch Cancelled - New Color is same as old";
    }

    pe.replaceDWord(offset1 + 1, color);
    pe.replaceDWord(offset2 + 1, color);
    pe.replaceDWord(offset3 + 1, color);

    return true;
}

function ChatColorPlayerSelf()
{
    var offsets = pe.findCodes(" 68 00 78 00 00");
    if (offsets.length === 0)
    {
        return "Failed in Step 1 - Dark Green missing";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        var offset = pe.find(" 68 00 FF 00 00", offsets[i] + 5, offsets[i] + 40);
        if (offset !== -1) break;
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Green not found";
    }

    var color = exe.getUserInput("$yourChatColor", XTYPE_COLOR, _("Color input"), _("Select the new Self Chat Color"), 0x0000FF00);
    if (color === 0x0000FF00)
    {
        return "Patch Cancelled - New Color is same as old";
    }

    pe.replaceDWord(offset + 1, color);

    return true;
}

function ChatColorPlayerOther()
{
    var code =
        " 6A 01" +
        " 68 FF FF FF 00";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var color = exe.getUserInput("$otherChatColor", XTYPE_COLOR, _("Color input"), _("Select the new Other Player Chat Color"), 0x00FFFFFF);
    if (color === 0x00FFFFFF)
    {
        return "Patch Cancelled - New Color is same as old";
    }

    pe.replaceDWord(offset + code.hexlength() - 4, color);

    return true;
}

function ChatColorPartySelf()
{
    var code =
        " 6A 03" +
        " 68 FF C8 00 00";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 6A 03", " 6A 03 8D ?? ?? ?? FF FF");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var color = exe.getUserInput("$yourpartyChatColor", XTYPE_COLOR, _("Color input"), _("Select the new Self Party Chat Color"), 0x0000C8FF);
    if (color === 0x0000C8FF)
    {
        return "Patch Cancelled - New Color is same as old";
    }

    pe.replaceDWord(offset + code.hexlength() - 4, color);

    return true;
}

function ChatColorPartyOther()
{
    var code =
        " 6A 03" +
        " 68 FF C8 C8 00";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 6A 03", " 6A 03 8D ?? ?? ?? FF FF");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var color = exe.getUserInput("$otherpartyChatColor", XTYPE_COLOR, _("Color input"), _("Select the new Others Party Chat Color"), 0x00C8C8FF);
    if (color === 0x00C8C8FF)
    {
        return "Patch Cancelled - New Color is same as old";
    }

    pe.replaceDWord(offset + code.hexlength() - 4, color);

    return true;
}

function HighlightSkillSlotColor()
{
    var code =
        "0F B6 0D ?? ?? ?? ?? " +
        "6B ?? 1D " +
        "68 B4 FF B4 00 " +
        "8B ?? " +
        "6A 18 " +
        "83 C1 05 ";
    var colorOffset = [11, 4];
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "0F B6 0D ?? ?? ?? ?? " +
            "6B ?? 1D " +
            "8B ?? " +
            "68 B4 FF B4 00 " +
            "6A 18 " +
            "83 C1 05 ";
        colorOffset = [13, 4];
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

    var color = exe.getUserInput("$HSkillSColor", XTYPE_COLOR, _("Color input"), _("Select new Highlight Skillslot Color"), 0x00B4FFB4);
    if (color === 0x00B4FFB4)
    {
        return "Patch Cancelled - New Color is same as old";
    }

    pe.replaceDWord(offset + colorOffset[0], color);

    return true;
}
