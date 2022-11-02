

function CustomExpBarLimits()
{
    var code =
        " 6A 4E" +
        " 68 38 FF FF FF";

    var refOffsets = pe.findCodes(code);
    if (refOffsets.length === 0)
    {
        return "Failed in Step 1 - Reference PUSHes missing";
    }

    code =
        getEcxSessionHex() +
        " E8 ?? ?? ?? 00" +
        " 50" +
        getEcxSessionHex() +
        " E8 ?? ?? ?? 00";

    var suffix =
        " 85 C0" +
        " A1 ?? ?? ?? 00" +
        " BF 63 00 00 00";

    var type = 1;
    var offset = pe.find(code + suffix, refOffsets[0] - 0x120, refOffsets[0]);

    if (offset === -1)
    {
        suffix =
            " 8B 8E ?? 00 00 00" +
            " BF 63 00 00 00" +
            " 85 C0";
        type = 2;
        offset = pe.find(code + suffix, refOffsets[0] - 0x120, refOffsets[0]);
    }

    if (offset === -1)
    {
        suffix =
            " BF 63 00 00 00" +
            " 85 C0";
        type = 3;
        offset = pe.find(code + suffix, refOffsets[0] - 0x120, refOffsets[0]);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Comparison setup missing";
    }

    var gSession = pe.fetchDWord(offset + 1);
    var jobIdFunc = pe.rawToVa(offset + 10) + pe.fetchDWord(offset + 6);
    var baseBegin = offset;

    offset += code.hexlength() + suffix.hexlength();

    var gLevel;
    if (type === 1)
    {
        gLevel = pe.fetchDWord(offset - 9);
    }
    else
    {
        var offset2 = pe.find(" 81 3D ?? ?? ?? 00 ?? 00 00 00", offset, refOffsets[0]);

        if (offset2 === -1)
        {
            offset2 = pe.find(" 39 3D ?? ?? ?? 00 75", offset, refOffsets[0]);
        }

        if (offset2 === -1)
        {
            return "Failed in Step 1 - First comparison missing";
        }

        gLevel = pe.fetchDWord(offset2 + 2);
    }

    offset = pe.find(" 8B 8E ?? 00 00 00", baseBegin, refOffsets[0]);
    if (offset === -1)
    {
        return "Failed in Step 2 - First ESI Offset missing";
    }

    var gNoBase = pe.fetchDWord(offset + 2);
    var gNoJob = gNoBase + 4;
    var gBarOn = gNoBase + 8;

    var funcOff;
    var baseEnd;
    if (pe.fetchUByte(refOffsets[1] + 8) >= 0xD0)
    {
        funcOff = pe.fetchByte(refOffsets[1] - 1);
        baseEnd = (refOffsets[1] + 11) + pe.fetchByte(refOffsets[1] + 10);
    }
    else
    {
        funcOff = pe.fetchByte(refOffsets[1] + 9);
        baseEnd = (refOffsets[1] + 12) + pe.fetchByte(refOffsets[1] + 11);
    }

    var jobBegin = baseEnd;

    code =
        " 6A 58" +
        " 68 38 FF FF FF";

    var refOffsets2 = pe.findAll(code, jobBegin, jobBegin + 0x120);
    if (refOffsets2.length === 0)
    {
        return "Failed in Step 3 - 2nd Reference PUSHes missing";
    }

    offset = refOffsets2[refOffsets2.length - 1] + code.hexlength();

    if (pe.fetchUByte(offset) === 0xEB)
    {
        offset = (offset + 2) + pe.fetchByte(offset + 1);
    }

    var jobEnd;
    if (pe.fetchUByte(offset + 1) >= 0xD0)
    {
        jobEnd = offset + 2;
    }
    else
    {
        jobEnd = offset + 3;
    }

    code = " 83 3D ?? ?? ?? 00 0A";

    offset = pe.find(code, refOffsets2[0], refOffsets2[refOffsets2.length - 1]);
    if (offset === -1)
    {
        return "Failed in Step 3 - g_jobLevel reference missing";
    }

    var gJobLevel = pe.fetchDWord(offset + 2);

    var fp = new TextFile();
    var inpFile = GetInputFile(fp, "$expBarSpec", _("File Input - Custom Exp Bar Limits"), _("Enter the Exp Bar Spec file"), APP_PATH + "/Input/expBarSpec.txt");
    if (!inpFile)
    {
        return "Patch Cancelled";
    }

    var idLvlTable = [];
    var tblSize = 0;
    var index = -1;
    var i;

    while (!fp.eof())
    {
        var line = fp.readline().trim();
        if (line === "") continue;

        var matches = line.match(/^([\d\-,\s]+):$/);
        if (matches)
        {
            index++;
            var idSet = matches[1].split(",");
            idLvlTable[index] = {
                "idTable": "",
                "lvlTable": [" FF 00", " FF 00"],
            };

            for (i = 0; i < idSet.length; i++)
            {
                var limits = idSet[i].split("-");
                if (limits.length === 1)
                {
                    limits[1] = limits[0];
                }

                idLvlTable[index].idTable += parseInt(limits[0]).packToHex(2);
                idLvlTable[index].idTable += parseInt(limits[1]).packToHex(2);
                tblSize += 4;
            }

            idLvlTable[index].idTable += " FF FF";
            tblSize += 2;
        }
        else
        {
            matches = line.match(/^([bj])\s*=>\s*(\d+)\s*,/);
            if (matches)
            {
                var limit = parseInt(matches[2]).packToHex(2);

                if (matches[1] === "b")
                {
                    idLvlTable[index].lvlTable[0] = limit;
                }
                else
                {
                    idLvlTable[index].lvlTable[1] = limit;
                }
            }
        }
    }
    fp.close();

    code =
        " 52" +
        " 53" +
        " B9" + GenVarHex(1) +
        " E8" + GenVarHex(2) +
        " BB" + GenVarHex(3) +
        " 8B 0B" +
        " 85 C9" +
        " 74 26" +
        " 0F BF 11" +
        " 85 D2" +
        " 78 15" +
        " 39 D0" +
        " 7C 0C" +
        " 0F BF 51 02" +
        " 85 D2" +
        " 78 09" +
        " 39 D0" +
        " 7E 0A" +
        " 83 C1 04" +
        " EB E4" +
        " 83 C3 08" +
        " EB D9" +
        " 8D 7B 04" +
        " EB 05" +
        " BF" + GenVarHex(4) +
        " 5B" +
        " 5A" +
        " 0F B7 07" +
        " 39 05" + GenVarHex(5) +
        " 8B 8E" + GenVarHex(6) +
        " 7C 09" +
        " 6A 4E" +
        " 68 38 FF FF FF" +
        " EB 0C" +
        " 8B 86" + GenVarHex(7) +
        " 83 C0 4C" +
        " 50" +
        " 6A 55" +
        " 8B 01" +
        " FF 50 XX" +
        " 0F B7 47 02" +
        " 39 05" + GenVarHex(8) +
        " 8B 8E" + GenVarHex(9) +
        " 7C 09" +
        " 6A 58" +
        " 68 38 FF FF FF" +
        " EB 0C" +
        " 8B 86" + GenVarHex(10) +
        " 83 C0 58" +
        " 50" +
        " 6A 55" +
        " 8B 01" +
        " FF 50 XX" +
        " E9" + GenVarHex(11);

    var free = alloc.find(tblSize);
    if (free === -1)
    {
        return "Failed in Step 5 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);
    var tblAddr = baseBegin + code.hexlength() + 4;

    code = code.replace(/ XX/g, funcOff.packToHex(1));

    code = ReplaceVarHex(code, 1, gSession);
    code = ReplaceVarHex(code, 2, jobIdFunc - pe.rawToVa(baseBegin + 12));

    code = ReplaceVarHex(code, 3, pe.rawToVa(tblAddr));
    code = ReplaceVarHex(code, 4, pe.rawToVa(tblAddr - 4));

    code = ReplaceVarHex(code, 5, gLevel);
    code = ReplaceVarHex(code, [6, 7], [gNoBase, gBarOn]);

    code = ReplaceVarHex(code, 8, gJobLevel);
    code = ReplaceVarHex(code, [9, 10], [gNoJob, gBarOn]);

    code = ReplaceVarHex(code, 11, jobEnd - (baseBegin + code.hexlength()));

    var tblAddrData = "";
    var tblData = "";
    var addr;

    for (i = 0, addr = 0; i < idLvlTable.length; i++)
    {
        tblAddrData += (freeRva + addr).packToHex(4);
        tblData += idLvlTable[i].idTable;
        addr += idLvlTable[i].idTable.hexlength();

        tblAddrData += idLvlTable[i].lvlTable.join("");
    }

    pe.replaceHex(baseBegin, code + " FF 00 FF 00" + tblAddrData);

    pe.insertHexAt(free, tblSize, tblData);

    return true;
}
