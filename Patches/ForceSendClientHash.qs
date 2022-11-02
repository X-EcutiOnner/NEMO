

function ForceSendClientHash()
{
    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 1 -" + LANGTYPE[0];
    }

    var code =
        " 8B ??" + LANGTYPE +
        " 33 C0" +
        " 83 ?? 06" +
        " 74";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    offset += code.hexlength();

    pe.replaceByte(offset - 1, 0xEB);

    offset += 1 + pe.fetchByte(offset);

    code =
        " 85 C0" +
        " 75 ??" +
        " A1";

    offset = pe.find(code, offset);
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    offset += code.hexlength() - 1;

    pe.replaceByte(offset - 2, 0xEB);

    offset += pe.fetchByte(offset - 1);

    code =
        " 83 F8 06" +
        " 75";

    offset = pe.find(code, offset);
    if (offset === -1)
    {
        return "Failed in Step 3";
    }

    offset += code.hexlength() - 1;

    pe.replaceByte(offset, 0xEB);

    return true;
}
