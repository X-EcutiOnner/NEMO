

function ReadQuestid2displaydottxt()
{
    var txtHex = pe.stringHex4("questID2display.txt");

    var code =
        " 6A 00" +
        " 68" + txtHex;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 6A 00" +
            " 8D ?? ??" +
            " 68" + txtHex;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    if (pe.fetchByte(offset - 1) === 0)
    {
        pe.replaceHex(offset - 6, " 90 90 90 90 90 90");
    }
    else
    {
        pe.replaceHex(offset - 2, " 90 90");
    }

    return true;
}

function ReadQuestid2displaydottxt_()
{
    return !IsZero() && (pe.stringRaw("questID2display.txt") !== -1);
}
