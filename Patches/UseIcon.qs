

function UseCustomIcon(nomod)
{
    var offset = pe.getSubSection(2).offset;
    if (offset === -1)
    {
        throw "found wrong offset in GetDataDirectory";
    }

    var rsrcTree = new resource.dir(offset, 0, 0);

    var entry = resource.getEntry(rsrcTree, [0xE]);
    if (entry === -1)
    {
        return "Failed in Step 2 - Unable to find icongrp";
    }

    offset = entry.addr + 0x10;
    var id = pe.fetchDWord(offset);

    var newvalue;
    if (id === 119)
    {
        newvalue = pe.fetchDWord(offset + 0x4);
        pe.replaceDWord(offset + 0x8 + 0x4, newvalue);
    }
    else
    {
        newvalue = pe.fetchDWord(offset + 0x8 + 0x4);
        pe.replaceDWord(offset + 0x4, newvalue);
    }

    if (nomod)
    {
        return true;
    }

    entry = resource.getEntry(rsrcTree, [0xE, 0x77, 0x412]);
    switch (entry)
    {
        case -2:
            return "Failed in Step 4 - Unable to find icongrp/lang";
        case -3:
            return "Failed in Step 4 - Unable to find icongrp/lang/bundle";
        default:
            break;
    }

    var icogrpOff = entry.dataAddr;

    var icondir = resource.selectIconFile("$inpIconFile", APP_PATH + "/Input/NEMO.ico");

    var i;
    for (i = 0; i < icondir.idCount; i++)
    {
        entry = icondir.idEntries[i];
        if (entry.bHeight == 32 && entry.bWidth == 32 && entry.wBitCount == 8 && entry.bColorCount == 0)
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

        if (memicondirentry.bColorCount == 0 && memicondirentry.wBitCount == 8 && memicondirentry.bWidth == 32 && memicondirentry.bWidth == 32)
        {
            entry = resource.getEntry(rsrcTree, [0x3, memicondirentry.nID, 0x412]);
            if (entry < 0) continue;
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

    pe.replaceWord(pos - 14 + 4, icondirentry.wPlanes);
    pe.replaceWord(pos - 14 + 8, icondirentry.dwBytesInRes);

    pe.replaceDWord(entry.addr + 4, icondirentry.dwBytesInRes);
    pe.replaceHex(entry.dataAddr, icondirentry.iconimage);

    return true;
}

function UseRagnarokIcon()
{
    return UseCustomIcon(true);
}
