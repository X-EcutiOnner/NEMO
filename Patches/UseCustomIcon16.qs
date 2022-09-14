// Original license unset, probably GPL

//
// Copyright (C) 2021-2022  Andrei Karas (4144)
//
// Hercules is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

function UseCustomIcon16()
{
    consoleLog("Find Resource Table");
    var offset = pe.getSubSection(2).offset;
    if (offset === -1)
        throw "found wrong offset in GetDataDirectory";

    consoleLog("Get the Resource Tree (Check the function in core)");
    var rsrcTree = new resource.dir(offset, 0, 0);
    var icondir = resource.selectIconFile("$inpIconFile", APP_PATH + "/Input/ro16.ico");

    consoleLog("Find the RT_GROUP_ICON , 114, 1042 resource entry address");
    var entry = resource.getEntry(rsrcTree, [0xE, 0x72, 0x412]);  // RT_GROUP_ICON , 114, 1042
    switch (entry)
    {
        case -2:
            return "Unable to find icongrp/lang";
        case -3:
            return "Unable to find icongrp/lang/bundle";
    }

    var icogrpOff = entry.dataAddr;

    consoleLog("Find the image that meets the spec = 8bpp 32x32");
    for (var i = 0; i < icondir.idCount; i++)
    {
        var entry = icondir.idEntries[i];
        if (entry.bHeight == 64 &&
            entry.bWidth == 32 &&
            entry.wBitCount == 4 &&
            entry.bColorCount == 0)
        {
            break;
        }
    }

    if (i === icondir.idCount)
        return "Invalid icon file specified";

    var icondirentry = icondir.idEntries[i];

    consoleLog("Find a valid RT_ICON - colorcount = 0, bpp = 8, and ofcourse the id will belong to valid resource");
    var idCount = pe.fetchWord(icogrpOff + 4);
    var pos = icogrpOff + 6;

    for (var i = 0; i < idCount; i++)
    {
        var memicondirentry = new Object();
        memicondirentry.bWidth       = pe.fetchByte(pos);
        memicondirentry.bHeight      = pe.fetchByte(pos+1);
        memicondirentry.bColorCount  = pe.fetchByte(pos+2);
        memicondirentry.bReserved    = pe.fetchByte(pos+3);
        memicondirentry.wPlanes      = pe.fetchWord(pos+4);
        memicondirentry.wBitCount    = pe.fetchWord(pos+6);
        memicondirentry.dwBytesInRes = pe.fetchDWord(pos+8);
        memicondirentry.nID          = pe.fetchWord(pos+12);

        if (memicondirentry.bColorCount == 16 && memicondirentry.wBitCount == 4 && memicondirentry.bWidth == 32 && memicondirentry.bHeight == 32)
        {
            //4bpp 32x32 image
            entry = resource.getEntry(rsrcTree, [0x3, memicondirentry.nID, 0x412]);//returns negative number on fail or ResourceEntry object on success
            if (entry < 0)
                continue;
            break;
        }

        pos += 14;
    }

    if (i === idCount)
        return "Failed in Step 6 - no suitable icon found in exe";

    if (memicondirentry.dwBytesInRes < icondirentry.dwBytesInRes)
        return "Failed in Step 6 - Icon wont fit";

    consoleLog("Update GRPICONDIRENTRY based on injected icon");
//    pe.replaceByte(pos, icondirentry.bWidth);
//    pe.replaceByte(pos + 1, icondirentry.bHeight);
    pe.replaceByte(pos, 32);
    pe.replaceByte(pos + 1, 32);
    pe.replaceByte(pos + 2, icondirentry.bColorCount);
    consoleLog("icondirentry.wPlanes: " + icondirentry.wPlanes + ", " + typeof(icondirentry.wPlanes));
    pe.replaceWord(pos + 4, icondirentry.wPlanes);
    pe.replaceWord(pos + 6, icondirentry.wBitCount);
    pe.replaceWord(pos + 8, icondirentry.dwBytesInRes);

    consoleLog("Finally update the icon image");
    pe.replaceDWord(entry.addr + 4, icondirentry.dwBytesInRes);
    pe.replaceHex(entry.dataAddr, icondirentry.iconimage);

    return true;
}
