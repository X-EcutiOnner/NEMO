

function ShowRegisterButton()
{
    var offset = pe.stringVa("http://ro.hangame.com/login/loginstep.asp?prevURL=/NHNCommon/NHN/Memberjoin.asp");
    if (offset === -1)
    {
        return "Failed in Step 1 - String missing";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - String reference missing";
    }

    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 2 - " + LANGTYPE[0];
    }

    var code =
        " 83 3D" + LANGTYPE + " 00" +
        " 75 ??";
    var codeSuffix =
        " 83 3D ?? ?? ?? 00 01" +
        " 75";
    var type = 1;

    var offset2 = pe.find(code + codeSuffix, offset - 0x30, offset);
    if (offset2 === -1)
    {
        if (offset2 === -1)
        {
            codeSuffix = codeSuffix.replace(" 83 3D ?? ?? ?? 00 01", " 83 3D ?? ?? ?? 01 01");
            offset2 = pe.find(code + codeSuffix, offset - 0x30, offset);
        }

        if (offset2 === -1)
        {
            code =
                " A1" + LANGTYPE +
                " 85 C0" +
                " 0F 85 ?? 00 00 00";
            type = 2;
            offset2 = pe.find(code + codeSuffix, offset - 0x30, offset);
            codeSuffix = codeSuffix.replace(" 83 3D ?? ?? ?? 01 01", " 83 3D ?? ?? ?? 00 01");
            offset2 = pe.find(code + codeSuffix, offset - 0x30, offset);
        }
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - Langtype comparison missing";
    }

    offset2 += code.hexlength();

    if (type == 1)
    {
        pe.replaceByte(offset2 - 2, 0xEB);
        offset2 += pe.fetchByte(offset2 - 1);
    }
    else
    {
        pe.replaceHex(offset2 - 6, "90 E9");
        offset2 += pe.fetchDWord(offset2 - 4);
    }

    offset2 += 10;

    code =
    " 8B 41 04" +
  " C7 40 14 00 00 00 00" +
  " C7 01 00 00 00 00" +
  " C3";

    var free = alloc.find(code.hexlength());
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    pe.insertHexAt(free, code.hexlength(), code);

    pe.replaceDWord(offset2 - 4, pe.rawToVa(free) - pe.rawToVa(offset2));

    offset = pe.stringVa("btn_request_b");
    if (offset === -1)
    {
        return "Failed in Step 4 - Button prefix missing";
    }

    offset = pe.findCode(offset.packToHex(4) + " C7");
    if (offset === -1)
    {
        return "Failed in Step 4 - Prefix reference missing";
    }

    code =
        " 83 ?? 03" +
        " 75 25" +
        " A1" + LANGTYPE;

    offset2 = pe.find(code, offset + 0xA0, offset + 0x100);
    if (offset2 === -1)
    {
        return "Failed in Step 4 - Langtype comparison missing";
    }

    pe.replaceByte(offset2 + 3, 0xEB);

    return true;
}
