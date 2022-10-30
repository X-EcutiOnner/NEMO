// Original license unset, probably GPL

function UseCustomIcon16()
{
    var offset = pe.getSubSection(2).offset;
    if (offset === -1)
    {
        throw "found wrong offset in GetDataDirectory";
    }

    var rsrcTree = new resource.dir(offset, 0, 0);
    var icondir = resource.selectIconFile("$inpIconFile", APP_PATH + "/Input/ro16.ico");

    var entry = resource.getEntry(rsrcTree, [0xE, 0x72, 0x412]);
    switch (entry)
    {
        case -2:
            return "Unable to find icongrp/lang";
        case -3:
            return "Unable to find icongrp/lang/bundle";
        default:
            break;
    }

    var icogrpOff = entry.dataAddr;

    for (var i = 0; i < icondir.idCount; i++)
    {
        entry = icondir.idEntries[i];
        if (entry.bHeight == 64 &&
            entry.bWidth == 32 &&
            entry.wBitCount == 4 &&
            entry.bColorCount == 0)
        {
            break;
        }
    }

    if (i === icondir.idCount)
    {
        return "Invalid icon file specified";
    }

    var icondirentry = icondir.idEntries[i];

    var idCount = pe.fetchWord(icogrpOff + 4);
    var pos = icogrpOff + 6;

    for (i = 0; i < idCount; i++)
    {
        var memicondirentry = {};
        memicondirentry.bWidth       = pe.fetchByte(pos);
        memicondirentry.bHeight      = pe.fetchByte(pos + 1);
        memicondirentry.bColorCount  = pe.fetchByte(pos + 2);
        memicondirentry.bReserved    = pe.fetchByte(pos + 3);
        memicondirentry.wPlanes      = pe.fetchWord(pos + 4);
        memicondirentry.wBitCount    = pe.fetchWord(pos + 6);
        memicondirentry.dwBytesInRes = pe.fetchDWord(pos + 8);
        memicondirentry.nID          = pe.fetchWord(pos + 12);

        if (memicondirentry.bColorCount == 16 && memicondirentry.wBitCount == 4 && memicondirentry.bWidth == 32 && memicondirentry.bHeight == 32)
        {
            entry = resource.getEntry(rsrcTree, [0x3, memicondirentry.nID, 0x412]);
            if (entry < 0)
            {
                continue;
            }
            break;
        }

        pos += 14;
    }

    if (i === idCount)
    {
        return "Failed in Step 6 - no suitable icon found in exe";
    }

    if (memicondirentry.dwBytesInRes < icondirentry.dwBytesInRes)
    {
        return "Failed in Step 6 - Icon wont fit";
    }

    pe.replaceByte(pos, 32);
    pe.replaceByte(pos + 1, 32);
    pe.replaceByte(pos + 2, icondirentry.bColorCount);
    pe.replaceWord(pos + 4, icondirentry.wPlanes);
    pe.replaceWord(pos + 6, icondirentry.wBitCount);
    pe.replaceWord(pos + 8, icondirentry.dwBytesInRes);

    pe.replaceDWord(entry.addr + 4, icondirentry.dwBytesInRes);
    pe.replaceHex(entry.dataAddr, icondirentry.iconimage);

    return true;
}
