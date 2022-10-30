

function SkipCheaterCheck(msgNum)
{
    var code =
        " 85 C0" +
        " 74 ??" +
        " 6A 00" +
        " 6A 00" +
        " 68 FF FF 00 00" +
        " 68" + msgNum.packToHex(4);
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 85 C0" +
            " 74 ??" +
            " ??" +
            " ??" +
            " 68 FF FF 00 00" +
            " 68" + msgNum.packToHex(4);
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offset + 2, 0xEB);

    return true;
}

function SkipCheaterFriendCheck()
{
    return SkipCheaterCheck(0x395);
}

function SkipCheaterGuildCheck()
{
    return SkipCheaterCheck(0x397);
}
