

delete Import_Info;
var dllFile = false;

function UseCustomDLL()
{
    var hasHShield = getActivePatches().indexOf(15) !== -1;

    var dir = pe.getSubSection(1);
    if (dir.offset === -1)
    {
        throw "found wrong offset in GetDataDirectory";
    }

    var finalValue = " 00".repeat(20);
    var curValue;
    var dirData = "";
    var offset = dir.offset;

    for (; (curValue = pe.fetchHex(offset, 20)) !== finalValue; offset += 20)
    {
        var offset2 = pe.vaToRaw(pe.fetchDWord(offset + 12) + pe.getImageBase());
        var offset3 = pe.find("00", offset2);
        var curDLL = pe.fetch(offset2, offset3 - offset2);

        if (hasHShield && curDLL === "aossdk.dll") continue;

        dirData += curValue;
    }

    var fp = new TextFile();
    if (!dllFile)
    {
        dllFile = GetInputFile(fp, "$customDLL", _("File Input - Use Custom DLL"), _("Enter the DLL info file"), APP_PATH + "/Input/dlls.txt");
    }

    if (!dllFile)
    {
        return "Patch Cancelled";
    }

    var dllNames = [];
    var fnNames = [];
    var dptr = -1;

    while (!fp.eof())
    {
        var line = fp.readline().trim();
        if (line === "" || line.indexOf("//") == 0) continue;
        if (line.length > 4 && (line.indexOf(".dll") - line.length) == -4)
        {
            dptr++;
            dllNames.push({"offset": 0, "value": line});
            fnNames[dptr] = [];
        }
        else
        {
            fnNames[dptr].push({"offset": 0, "value": line});
        }
    }
    fp.close();

    var dirSize = dirData.hexlength();
    var strData = "";
    var strSize = 0;

    var i;
    var j;
    for (i = 0; i < dllNames.length; i++)
    {
        var name = dllNames[i].value;
        dllNames[i].offset = strSize;
        strData = strData + name.toHex() + " 00";
        strSize = strSize + name.length + 1;
        dirSize += 20;

        for (j = 0; j < fnNames[i].length; j++)
        {
            name = fnNames[i][j].value;

            if (name.charAt(0) === ":")
            {
                fnNames[i][j].offset = 0x80000000 | parseInt(name.substr(1));
            }
            else
            {
                fnNames[i][j].offset = strSize;
                strData = strData + j.packToHex(2) + name.toHex() + " 00";
                strSize = strSize + 2 + name.length + 1;

                if (name.length % 2 != 0)
                {
                    strData += " 00";
                    strSize++;
                }
            }

            dirSize += 4;
        }
        dirSize += 4;
    }
    dirSize += 20;

    var free = alloc.find(strSize + dirSize);
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    var baseAddr = pe.rawToVa(free) - pe.getImageBase();
    var prefix = " 00".repeat(12);
    var dirEntryData = "";
    var dirTableData = "";

    dptr = 0;
    for (i = 0; i < dllNames.length; i++)
    {
        if (fnNames[i].length == 0) continue;
        dirTableData = dirTableData + prefix + (baseAddr + dllNames[i].offset).packToHex(4) + (baseAddr + strSize + dptr).packToHex(4);

        for (j = 0; j < fnNames[i].length; j++)
        {
            if ((fnNames[i][j].offset & 0x80000000) === 0)
            {
                dirEntryData += (baseAddr + fnNames[i][j].offset).packToHex(4);
            }
            else
            {
                dirEntryData += fnNames[i][j].offset.packToHex(4);
            }

            dptr += 4;
        }
        dirEntryData += " 00 00 00 00";
        dptr += 4;
    }
    dirTableData = dirData + dirTableData + finalValue;

    pe.insertHexAt(free, strSize + dirSize, strData + dirEntryData + dirTableData);

    var PEoffset = pe.find("50 45 00 00");
    pe.replaceDWord(PEoffset + 0x18 + 0x60 + 0x8, baseAddr + strSize + dirEntryData.hexlength());
    pe.replaceDWord(PEoffset + 0x18 + 0x60 + 0xC, dirTableData.hexlength() - 20);

    Import_Info = {
        "offset": free,
        "valuePre": strData + dirEntryData,
        "valueSuf": dirTableData,
        "tblAddr": baseAddr + strSize + dirEntryData.hexlength(),
        "tblSize": dirTableData.hexlength() - 20,
    };

    return true;
}

function _UseCustomDLL()
{
    if (getActivePatches().indexOf(15) !== -1)
    {
        exe.setCurrentPatch(15);
        exe.emptyPatch(15);
        DisableHShield();
    }
    dllFile = false;
}
