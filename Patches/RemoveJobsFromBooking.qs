

function RemoveJobsFromBooking()
{
    var code =
        " 8D ?? 5D 06 00 00" +
        " 03 ??" +
        " 89 ?? ??" +
        " 89 ?? ??" +
        " 8B ?? ??" +
        " 50" +
        " E8";
    var type = 1;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 8D 49 00" +
            " 8D ?? 5D 06 00 00" +
            " ??" +
            " E8";
        type = 2;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            " 8B ?? ??" +
            " 81 ?? 5D 06 00 00" +
            " ??" +
            " E8";
        type = 3;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1a - Loop Beginning missing";
    }

    offset += code.hexlength();

    var MsgStr = pe.rawToVa(offset + 4) + pe.fetchDWord(offset);

    var jmpOff;
    switch (type)
    {
        case 1:
        {
            code =
                " 83 C4 04" +
                " 8B ?? ??" +
                " 8B ?? ??" +
                " ??" +
                " ??" +
                " 89 ?? ??" +
                " 89 ?? ??" +
                " 89 ?? ??" +
                " 89 ?? ??" +
                " 89 ?? ??" +
                " 0F 85 ?? FF FF FF";
            jmpOff = 3;
            break;
        }

        case 2:
        {
            if (pe.getDate() < 20140000)
            {
                code =
                    " FF 15 ?? ?? ?? 00" +
                    " ??" +
                    " 83 6C 24 ?? 01" +
                    " 75";
                jmpOff = 6;
            }
            else
            {
                code =
                    " 83 C4 04" +
                    " ??" +
                    " C7 45 ?? 0F 00 00 00" +
                    " C7 45 ?? 00 00 00 00" +
                    " C6 45 ?? 00" +
                    " ??" +
                    " 0F 85 ?? FF FF FF";
                jmpOff = 3;
            }
            break;
        }
        case 3:
        {
            code =
                " ?? 01 00 00 00" +
                " 01 ?? ??" +
                " 29 ?? ??" +
                " C7 45 ?? ?? 00 00 00" +
                " 89 ?? ??" +
                " 88 ?? ??" +
                " 75";
            jmpOff = 0;
            break;
        }
        default:
            break;
    }

    var retAddr = pe.find(code, offset + 5, offset + 0x100);
    if (retAddr === -1)
    {
        return "Failed in Step 1b - Loop End missing";
    }

    retAddr = pe.rawToVa(retAddr + jmpOff);

    var fp = new TextFile();
    var inpFile = GetInputFile(fp, "$bookingList", _("File Input - Remove Jobs From Booking"), _("Enter the Booking Skip List file"), APP_PATH + "/Input/bookingSkipList.txt");
    if (!inpFile)
    {
        return "Patch Cancelled";
    }

    var idSet = [];
    while (!fp.eof())
    {
        var line = fp.readline().trim();
        if (line.match(/^\d+/))
        {
            var id = parseInt(line);
            if (id < 0x65D) continue;
            idSet.push(id.packToHex(2));
        }
    }
    fp.close();

    idSet.push(" 00 00");

    code =
        " 50" +
        " 51" +
        " 52" +
        " 8B 44 24 10" +
        " 40" +
        " B9" + GenVarHex(1) +
        " 0F B7 11" +
        " 85 D2" +
        " 74 08" +
        " 39 D0" +
        " 74 0C" +
        " 41" +
        " 41" +
        " EB F1" +
        " 5A" +
        " 59" +
        " 58" +
        " E9" + GenVarHex(2) +
        " 5A" +
        " 59" +
        " 58" +
        " 83 C4 08" +
        " 68" + GenVarHex(3) +
        " C3";

    var size = idSet.length * 2 + code.hexlength();
    var free = alloc.find(size);
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);

    code = ReplaceVarHex(code, 1, freeRva);
    code = ReplaceVarHex(code, 2, MsgStr - (freeRva + size - 12));
    code = ReplaceVarHex(code, 3, retAddr);

    pe.insertHexAt(free, size, idSet.join("") + code);

    pe.replaceDWord(offset, (freeRva + idSet.length * 2) - pe.rawToVa(offset + 4));

    return true;
}
