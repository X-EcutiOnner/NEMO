

function EnableMultipleGRFsV2()
{
    var grf = pe.stringHex4("data.grf");

    var code =
        " 68" + grf +
        getEcxFileMgrHex();

    var offset = pe.findCode(code);
    var pushOffset = 0;
    var fnoffset;
    var addpackOffset = -1;

    if (offset === -1)
    {
        code =
            getEcxFileMgrHex() +
            "85 C0 " +
            "0F 95 05 ?? ?? ?? ?? " +
            "68 " + grf +
            "E8 ";
        offset = pe.findCode(code);
        pushOffset = 14;
        fnoffset = offset;
        addpackOffset = 20;
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var setECX = getEcxFileMgrHex();

    if (addpackOffset === -1)
    {
        code =
            " E8 ?? ?? ?? ??" +
            " 8B ?? ?? ?? ?? 00" +
            " A1 ?? ?? ?? 00";
        fnoffset = pe.find(code, offset + 10, offset + 40);
        addpackOffset = 1;
    }

    if (fnoffset === -1)
    {
        code =
            " E8 ?? ?? ?? ??" +
            " A1 ?? ?? ?? 00";
        fnoffset = pe.find(code, offset + 10, offset + 40);
    }

    if (fnoffset === -1)
    {
        code =
            " E8 ?? ?? ?? ??" +
            " BF ?? ?? ?? 00";
        fnoffset = pe.find(code, offset + 10, offset + 40);
    }

    if (fnoffset === -1)
    {
        return "Failed in Step 2";
    }

    var AddPak = pe.rawToVa(fnoffset + addpackOffset + 4) + pe.fetchDWord(fnoffset + addpackOffset);

    var f = new TextFile();
    if (!GetInputFile(f, "$inpMultGRF", _("File Input - Enable Multiple GRF"), _("Enter your INI file"), APP_PATH + "/Input/DATA.INI"))
    {
        return "Patch Cancelled";
    }

    if (f.eof())
    {
        return "Patch Cancelled";
    }

    var temp = [];
    while (!f.eof())
    {
        var str = f.readline().trim();
        if (str.charAt(1) === "=")
        {
            var key = parseInt(str.charAt(0));
            if (!isNaN(key))
            {
                temp[key] = str.substr(2);
            }
        }
    }

    f.close();

    var grfs = [];
    for (var i = 0; i < 10; i++)
    {
        if (temp[i])
        {
            grfs.push(temp[i]);
        }
    }
    if (!grfs[0])
    {
        grfs.push("data.grf");
    }

    var template =
        " 68" + GenVarHex(1) +
        setECX +
        " E8" + GenVarHex(2);

    var strcode = grfs.join("\x00") + "\x00";
    var size = strcode.length + grfs.length * template.hexlength() + 2;

    var free = alloc.find(size);
    if (free === -1)
    {
        return "Failed in Step 4 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);

    var o2 = freeRva + grfs.length * template.hexlength() + 2;
    var fn = AddPak - o2 + 2;

    code = "";
    for (var j = 0; j < grfs.length; j++)
    {
        code = ReplaceVarHex(template, [1, 2], [o2, fn]) + code;
        o2 += grfs[j].length + 1;
        fn += template.hexlength();
    }
    code += " C3 00";
    code += strcode.toHex();

    pe.replaceByte(offset + pushOffset, 0xB9);
    pe.replaceDWord(fnoffset + addpackOffset, freeRva - pe.rawToVa(fnoffset + addpackOffset + 4));

    pe.insertHexAt(free, size, code);

    offset = pe.stringRaw("rdata.grf");
    if (offset !== -1)
    {
        pe.replaceByte(offset, 0);
    }

    return true;
}
