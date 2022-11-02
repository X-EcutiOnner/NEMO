

function CancelToLoginWindow()
{
    if (getActivePatches().indexOf(40) === -1)
    {
        return "Patch Cancelled - Restore Login Window patch is necessary but not enabled";
    }

    var code =
        " 8D ?? ?? ?? ?? ?? 00" +
        " ??" +
        " 68 37 03 00 00" +
        " E8";
    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        code =
            " 8D ?? ?? ?? ?? ?? 01" +
            " ??" +
            " 68 37 03 00 00" +
            " E8";
        offsets = pe.findCodes(code);
    }

    if (offsets.length === 0)
    {
        return "Failed in Step 1 - Reference case missing";
    }

    var csize = code.hexlength() + 4;

    code =
        " 83 C4 08" +
        " E8 ?? ?? ?? 00" +
        " 8B C8" +
        " E8 ?? ?? ?? 00" +
        " B9 ?? ?? ?? 00";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 83 C4 08" +
            " E8 ?? ?? ?? FF" +
            " 8B C8" +
            " E8 ?? ?? ?? FF" +
            " B9 ?? ?? ?? 00";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 2 - connection functions missing";
    }

    var crag = (offset +  8) + pe.fetchDWord(offset + 4);
    var ccon = (offset + 15) + pe.fetchDWord(offset + 11);

    offset = pe.stringVa("\xB8\xDE\xBD\xC3\xC1\xF6");
    if (offset === -1)
    {
        return "Failed in Step 2 - Message not found";
    }

    var canceller =
        " 68" + offset.packToHex(4) +
        " ??" +
        " ??" +
        " 6A 01" +
        " 6A 02" +
        " 6A 11";

    var cansize = canceller.hexlength();
    var matchcount = 0;

    for (var i = 0; i < offsets.length; i++)
    {
        offsets[i] += csize;
        offset = pe.find(canceller, offsets[i], offsets[i] + 0x80);
        var zeroPush;

        if (offset === -1)
        {
            zeroPush = " 6A 00";
            offset = pe.find(canceller.replace(" ?? ??", " 6A 00 6A 00"), offsets[i], offsets[i] + 0x80);
        }
        else
        {
            zeroPush = pe.fetchHex(offset + 5, 1);
        }

        if (offset === -1)
        {
            continue;
        }

        if (pe.fetchHex(offset - 5, 5) === " 68 18 01 00 00")
        {
            offset -= 7;
        }

        if (pe.fetchHex(offset - 2, 2) === " 6a 00")
        {
            if (pe.getDate() > 20170000)
            {
                offset -= 2;
            }
        }

        code =
            " 3D ?? 00 00 00" +
            " 0F 85 ?? ?? 00 00";
        var offset2 = pe.find(code, offset + cansize, offset + cansize + 40);

        if (offset2 === -1)
        {
            code = code.replace(" 3D ?? 00 00 00", " 83 F8 ??");
            offset2 = pe.find(code, offset + cansize, offset + cansize + 40);
        }

        if (offset2 === -1)
        {
            continue;
        }

        offset2 += code.hexlength();

        code =
            zeroPush.repeat(3) +
            " 6A 02";

        var offset3 = pe.find(code, offset2, offset2 + 0x20);
        if (offset3 === -1)
        {
            continue;
        }

        offset3 += zeroPush.hexlength() * 3;

        code =
            " E8" + GenVarHex(1) +
            " 8B C8" +
            " E8" + GenVarHex(2);

        code += pe.fetchHex(offset2, offset3 - offset2);

        code +=
            " 68 23 27 00 00" +
            " EB XX";

        code = ReplaceVarHex(code, 1, crag - (offset + 5));
        code = ReplaceVarHex(code, 2, ccon - (offset + 12));
        code = code.replace(" XX", ((offset3 + 2) - (offset + code.hexlength())).packToHex(1));

        pe.replaceHex(offset, code);

        matchcount++;
    }

    if (matchcount === 0)
    {
        return "Failed in Step 3 - No references matched";
    }

    return true;
}

function CancelToLoginWindow_()
{
    return pe.getDate() > 20100803;
}
