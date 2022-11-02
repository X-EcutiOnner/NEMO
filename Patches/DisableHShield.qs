

delete Import_Info;

function DisableHShield()
{
    var offset = pe.stringVa("webclinic.ahnlab.com");

    if (offset === -1)
    {
        return "Failed in Step 1a - String not found";
    }

    offset = pe.findCode("68 " + offset.packToHex(4));

    if (offset === -1)
    {
        return "Failed in Step 1b - Pattern not found";
    }

    var code =
        "74 ?? " +
        "33 C0 ";

    offset = pe.find(code, offset - 0x10, offset);

    if (offset === -1)
    {
        return "Failed in Step 1c - Pattern not found";
    }

    pe.replaceHex(offset, "33 C0 40 90 ");

    if ((pe.getDate() >= 20090000 && pe.getDate() <= 20110228) && !IsSakray())
    {
        code =
            "B8 01 00 00 00 " +
            "5B " +
            "8B E5 " +
            "5D " +
            "C2 10 00 " +
            "E8 ?? ?? ?? ?? " +
            "85 C0 " +
            "75 0E ";

        var repLoc = 12;
        offset = pe.findCode(code);

        if (offset === -1)
        {
            code =
                "B8 01 00 00 00 " +
                "E9 ?? 01 00 00 " +
                "E8 ?? ?? ?? ?? " +
                "85 C0 " +
                "74 DD ";

            repLoc = 10;
            offset = pe.findCode(code);
        }

        if (offset === -1)
        {
            return "Failed in Step 2a - Pattern not found";
        }

        pe.replaceHex(offset + repLoc, "B8 01 " + "00 ".repeat(3));
    }

    offset = pe.stringVa("CHackShieldMgr::Monitoring() failed");

    if (offset !== -1)
    {
        offset = pe.findCode("68 " + offset.packToHex(4) + "FF 15 ");

        if (offset !== -1)
        {
            code =
                "E8 ?? ?? ?? ?? " +
                "84 C0 " +
                "74 16 " +
                "8B ?? " +
                "E8 ";

            offset = pe.find(code, offset - 0x40, offset);
        }

        if (offset !== -1)
        {
            code =
                "90 " +
                "B0 01 " +
                "5E " +
                "C3 ";

            pe.replaceHex(offset, code);
        }
    }

    offset = pe.stringVa("ERROR");

    if (offset === -1)
    {
        return "Failed in Step 4a - String not found";
    }

    var offset2 = imports.ptrValidated("MessageBoxA", "USER32.dll");

    var strHex1 = offset.packToHex(4);
    var strHex2 = offset2.packToHex(4);

    code =
        "68 " + strHex1 +
        "?? " +
        "?? " +
        "FF 15 " + strHex2;

    offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace("?? ?? FF 15 ", "?? 6A 00 FF 15 ");
        offset = pe.findCode(code);
    }

    if (offset !== -1)
    {
        code =
            "80 3D ?? ?? ?? 00 00 " +
            "75 ";

        offset2 = pe.find(code, offset, offset + 0x80);

        if (offset2 === -1)
        {
            code =
                "39 ?? ?? ?? ?? 00 " +
                "75 ";

            offset2 = pe.find(code, offset, offset + 0x80);
        }

        if (offset2 !== -1)
        {
            pe.replaceByte(offset2 + code.hexlength() - 1, 0xEB);
        }
    }

    if (pe.getDate() > 20140700)
    {
        return true;
    }

    var aOffset = pe.stringRaw("aossdk.dll");

    if (aOffset === -1)
    {
        return "Failed in Step 5a - String not found";
    }

    aOffset = "00 ".repeat(8) + (pe.rawToVa(aOffset) - pe.getImageBase()).packToHex(4);

    var hasCustomDLL = getActivePatches().indexOf(211) !== -1;
    var curValue;

    if (hasCustomDLL && typeof Import_Info !== "undefined")
    {
        var tblData = Import_Info.valueSuf;
        var newTblData = " ";

        for (var i = 0; i < tblData.length; i += 20 * 3)
        {
            curValue = tblData.substr(i, 20 * 3);
            if (curValue.indexOf(aOffset) === 3 * 4)
            {
                continue;
            }

            newTblData += curValue;
        }

        if (newTblData !== tblData)
        {
            exe.emptyPatch(211);

            var PEoffset = pe.getPeHeader();

            pe.insertHexAt(Import_Info.offset, (Import_Info.valuePre + newTblData).hexlength(), Import_Info.valuePre + newTblData);
            pe.replaceDWord(PEoffset + 0x18 + 0x60 + 0x08, Import_Info.tblAddr);
            pe.replaceDWord(PEoffset + 0x18 + 0x60 + 0x0C, Import_Info.tblSize);
        }
    }
    else
    {
        var dir = pe.getSubSection(1);
        var finalValue = " 00".repeat(20);
        var lastDLL = " ";

        if (dir.offset === -1)
        {
            throw "Failed in Step 5f - Found wrong offset";
        }

        code = " ";

        for (offset = dir.offset; (curValue = pe.fetchHex(offset, 20)) !== finalValue; offset += 20)
        {
            offset2 = pe.vaToRaw(pe.fetchDWord(offset + 12) + pe.getImageBase());
            var offset3 = pe.find("00 ", offset2);
            var curDLL = pe.fetch(offset2, offset3 - offset2);

            if (lastDLL === curDLL || curDLL === "aossdk.dll")
            {
                continue;
            }

            code += curValue;
            lastDLL = curDLL;
        }

        code += finalValue;

        pe.replaceHex(dir.offset, code);
    }

    return true;
}

function DisableHShield_()
{
    return pe.stringRaw("aossdk.dll") !== -1;
}

function _DisableHShield()
{
    if (getActivePatches().indexOf(211) !== -1)
    {
        exe.setCurrentPatch(211);
        exe.emptyPatch(211);
        UseCustomDLL();
    }
}
