// ######################################################################################
// # Purpose : Modify the Aura setting code inside CPlayer::ReLaunchBlurEffects to CALL #
// #           custom function which sets up aura based on user specified limits        #
// ######################################################################################

function CustomAuraLimits()
{
    var code =
        " 68 4E 01 00 00" +
        " 6A 6D";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - Value PUSHes missing";
    }

    offset += code.hexlength();

    code =
        " 8B ?? ?? 00 00 00" +
        " 8B ?? ??" +
        " E8 ?? ?? ?? 00";

    var offset2 = pe.find(code, offset, offset + 0x100);
    if (offset2 === -1)
    {
        return "Failed in Step 1 - ReLaunchBlurEffects call missing";
    }

    offset2 += code.hexlength();

    offset = offset2 + pe.fetchDWord(offset2 - 4);

    offset = pe.find(" 0F 84 ?? ?? 00 00", offset, offset + 0x80);
    if (offset === -1)
    {
        return "Failed in Step 2 - First JE missing";
    }

    var cmpEnd = (offset + 6) + pe.fetchDWord(offset + 2);

    offset = pe.find(" 68 E2 02 00 00", offset + 6, offset + 0x100);
    if (offset === -1)
    {
        return "Failed in Step 2 - 2E2 push missing";
    }

    offset = pe.find(" 0F 84 ?? ?? 00 00", offset + 5, offset + 0x80);
    if (offset === -1)
    {
        return "Failed in Step 2 - JE missing";
    }

    var cmpBegin = (offset + 6) + pe.fetchDWord(offset + 2);

    var directComparison;
    var gLevel;
    var jobIdFunc;
    var zeroAssign;
    var argCount;
    var gAura;

    if (pe.fetchUByte(cmpBegin) === 0xB9)
    {
        directComparison = true;

        var gSession = pe.fetchDWord(cmpBegin + 1);
        jobIdFunc = pe.rawToVa(cmpBegin + 10) + pe.fetchDWord(cmpBegin + 6);

        code = " A1 ?? ?? ?? 00";
        offset = pe.find(code, cmpBegin, cmpBegin + 0x20);

        if (offset === -1)
        {
            code = " 81 3D ?? ?? ?? 00";
            offset = pe.find(code, cmpBegin, cmpBegin + 0x80);
        }

        if (offset === -1)
        {
            return "Failed in Step 3 - Level Comparison missing";
        }

        offset += code.hexlength();

        gLevel = pe.fetchDWord(offset - 4);

        code =
            " 6A ??" +
            " 6A 00" +
            " 8B CE" +
            " FF";
        var argPush = "\x6A\x00";
        offset2 = pe.find(code, offset, offset + 0x20);

        if (offset2 === -1)
        {
            code = code.replace("6A 00", "??");
            argPush = "";
            offset2 = pe.find(code, offset, offset + 0x20);
        }

        if (offset2 === -1)
        {
            return "Failed in Step 3 - Aura Call missing";
        }

        if (argPush === "")
        {
            argPush = pe.fetch(offset2 + 2, 1);
        }

        gAura = [pe.fetchHex(offset2 + 1, 1)];
        gAura[1] = gAura[0];
        gAura[2] = gAura[0];

        argCount = argPush.length;
        argPush = pe.fetchHex(offset2 - 4 * argCount, 4 * argCount);

        if (argPush.substr(0, 3 * argCount) === argPush.substr(9 * argCount))
        {
            argCount = 4;
        }
        else
        {
            argCount = 3;
        }

        zeroAssign = " EB 08 8D 24 24 8D 6D 00 89 C0";
    }
    else
    {
        directComparison = false;

        gLevel = pe.fetchDWord(cmpBegin + 3);

        offset = pe.find(" E8 ?? ?? ?? FF", cmpBegin, cmpBegin + 0x30);
        if (offset === -1)
        {
            return "Failed in Step 4 - Function call missing";
        }

        offset = (offset + 5) + pe.fetchDWord(offset + 1);

        var offset0 = offset;

        code =
            " E8 ?? ?? ?? ??" +
            " 50" +
            getEcxSessionHex() +
            " E8";

        offset = pe.find(code, offset0, offset0 + 0x20);
        if (offset === -1)
        {
            code =
                " E8 ?? ?? ?? ??" +
                " 50" +
                getEcxSessionHex() +
                " E8";

            offset = pe.find(code, offset0, offset0 + 0x20);
        }
        if (offset === -1)
        {
            return "Failed in Step 4 - g_session reference missing";
        }

        jobIdFunc = pe.rawToVa(offset + 5) + pe.fetchDWord(offset + 1);

        code = " C7 86 ?? ?? 00 00 00 00 00 00";
        offset = pe.find(code, offset, offset + 0x180);
        if (offset === -1)
        {
            return "Failed in Step 4 - Zero assignment missing";
        }

        zeroAssign = pe.fetchHex(offset, code.hexlength());

        argCount = 4;
        gAura = [" 7D", " 93", " 92"];
    }

    var fp = new TextFile();
    var inpFile = GetInputFile(fp, "$auraSpec", _("File Input - Custom Aura Limits"), _("Enter the Aura Spec file"), APP_PATH + "/Input/auraSpec.txt");
    if (!inpFile)
    {
        return "Patch Cancelled";
    }

    var idLvlTable = [];
    var tblSize = 0;
    var index = -1;
    var limits;
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
                "lvlTable": "",
            };

            if (index > 0)
            {
                idLvlTable[index - 1].lvlTable += " FF FF";
                tblSize += 2;
            }

            for (i = 0; i < idSet.length; i++)
            {
                limits = idSet[i].split("-");
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
            matches = line.match(/^([\d\-\s]+)\s*=>\s*(\d)\s*,/);
            if (matches)
            {
                limits = matches[1].split("-");

                idLvlTable[index].lvlTable += parseInt(limits[0]).packToHex(2);
                idLvlTable[index].lvlTable += parseInt(limits[1]).packToHex(2);
                idLvlTable[index].lvlTable += gAura[parseInt(matches[2]) - 1];
                tblSize += 5;
            }
        }
    }
    fp.close();

    if (index >= 0)
    {
        idLvlTable[index].lvlTable += " FF FF";
        tblSize += 2;
    }

    code =
        " 56" +
        " 89 CE" +
        " 52" +
        " 53" +
        " B9" + GenVarHex(1) +
        " E8" + GenVarHex(2) +
        " BB" + GenVarHex(3) +
        " 8B 0B" +
        " 85 C9" +
        " 74 49" +
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
        " A1" + GenVarHex(4) +
        " 8B 4B 04" +
        " 85 C9" +
        " 74 1C" +
        " 0F BF 11" +
        " 85 D2" +
        " 78 15" +
        " 39 D0" +
        " 7C 0C" +
        " 0F BF 51 02" +
        " 85 D2" +
        " 78 09" +
        " 39 D0" +
        " 7E 14" +
        " 83 C1 05" +
        " EB E4" +
        " 5B" +
        " 5A" +
        zeroAssign +
        " 5E" +
        " C3" +
        " 90" +
        " 5B" +
        " 5A" +
        " 6A 00".repeat(argCount) +

        " 0F B6 49 04" +
        " 51" +
        " 6A 00" +
        " 8B 06" +
        " 8B CE" +
        " FF 50 08" +
        " 5E" +
        " C3";

    if (!directComparison)
    {
        code = code.replace(" B9" + GenVarHex(1), " 90 90 90 90 90");
    }

    var size = code.hexlength() + 8 * idLvlTable.length + 4 + tblSize;
    var free = alloc.find(size);
    if (free === -1)
    {
        return "Failed in Step 6 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);

    code = ReplaceVarHex(code, 1, gSession);
    code = ReplaceVarHex(code, 2, jobIdFunc - (freeRva + 15));
    code = ReplaceVarHex(code, 3, freeRva + code.hexlength());
    code = ReplaceVarHex(code, 4, gLevel);

    var tblAddrData = "";
    var tblData = "";
    var addr;
    for (i = 0, addr = size - tblSize; i < idLvlTable.length; i++)
    {
        tblAddrData += (freeRva + addr).packToHex(4);
        tblData += idLvlTable[i].idTable;
        addr += idLvlTable[i].idTable.hexlength();

        tblAddrData += (freeRva + addr).packToHex(4);
        tblData += idLvlTable[i].lvlTable;
        addr += idLvlTable[i].lvlTable.hexlength();
    }

    pe.insertHexAt(free, size, code + tblAddrData + " 00 00 00 00" + tblData);

    if (directComparison)
    {
        code =
            " 8B CE" +
            " E8" + (freeRva - pe.rawToVa(cmpBegin + 7)).packToHex(4) +
            " EB" + (cmpEnd - (cmpBegin + 9)).packToHex(1);

        pe.replaceHex(cmpBegin, code);
    }
    else
    {
        offset = pe.find(" E8 ?? ?? ?? FF", cmpBegin, cmpBegin + 0x30);
        pe.replaceDWord(offset + 1, freeRva - pe.rawToVa(offset + 5));

        offset += 5;

        if (offset < cmpEnd)
        {
            pe.replaceHex(offset, " 90".repeat(cmpEnd - offset));
        }
    }

    return true;
}
