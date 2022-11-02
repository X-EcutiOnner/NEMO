

function EnableFlagEmotes()
{
    var code =
        " 05 2E FF FF FF" +
        " 83 F8 08" +
        " 0F 87 ?? ?? 00 00" +
        " FF 24 85";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 05 2E FF FF FF", " 83 C0 ??");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - switch not found";
    }

    var refAddr = pe.vaToRaw(pe.fetchDWord(offset + code.hexlength()));

    var f = new TextFile();
    if (!GetInputFile(f, "$inpFlag", _("File Input - Enable Flag Emoticons"), _("Enter the Flags list file"), APP_PATH + "/Input/flags.txt"))
    {
        return "Patch Cancelled";
    }

    var consts = [];
    while (!f.eof())
    {
        var str = f.readline().trim();
        if (str.charAt(1) === "=")
        {
            var key = parseInt(str.charAt(0));
            if (!isNaN(key))
            {
                var value = parseInt(str.substr(2));
                if (!isNaN(value)) consts[key] = value;
            }
        }
    }
    f.close();

    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 3 - " + LANGTYPE[0];
    }

    code =
        " A1" + LANGTYPE +
        " 85 C0";

    var code2 =
        " 6A 00" +
        " 6A 00" +
        " 6A ??" +
        " 6A 1F" +
        " FF";

    var oldOffsets = [];
    for (var i = 1; i < 10; i++)
    {
        offset = pe.vaToRaw(pe.fetchDWord(refAddr + (i - 1) * 4));

        offset = pe.find(code, offset);
        if (offset === -1)
        {
            return "Failed in Step 3 - First part missing : " + i;
        }

        offset += code.hexlength();

        if (pe.fetchByte(offset) === 0x0F)
        {
            pe.replaceHex(offset, " 90 E9");
            offset += pe.fetchDWord(offset + 2) + 6;
        }
        else
        {
            pe.replaceByte(offset, 0xEB);
            offset += pe.fetchByte(offset + 1) + 2;
        }

        if (consts[i])
        {
            offset = pe.find(code2, offset);
            if (offset === -1)
            {
                return "Failed in Step 3 - Second part missing : " + i;
            }

            if (oldOffsets.indexOf(offset) !== -1)
            {
                return "Found two same offset";
            }
            oldOffsets.push(offset);

            pe.replaceHex(offset + code2.hexlength() - 4, consts[i].toString(16));
        }
    }

    return true;
}
