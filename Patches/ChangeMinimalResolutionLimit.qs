//
// Copyright (C) 2018-2023 Andrei Karas (4144)
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

function ChangeMinimalResolutionLimit()
{
    var code =
        "8B 0D ?? ?? ?? ?? " +
        "A3 ?? ?? ?? ?? " +
        "81 F9 00 04 00 00 " +
        "72 0C " +
        "A1 ?? ?? ?? ?? " +
        "3D 00 03 00 00 " +
        "73 15 " +
        "B9 00 04 00 00 " +
        "B8 00 03 00 00 " +
        "89 0D ?? ?? ?? ?? " +
        "A3 ";
    var widthOffset1 = 13;
    var widthOffset2 = 32;
    var heightOffset1 = 25;
    var heightOffset2 = 37;
    var screenWidth1Offset = 2;
    var screenWidth2Offset = 43;
    var screenHeight1Offset = 20;
    var screenHeight2Offset = 48;
    var widthLimit = 1024;
    var heightLimit1 = 768;
    var heightLimit2 = 768;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "A3 ?? ?? ?? ?? " +
            "A1 ?? ?? ?? ?? " +
            "3D 98 02 00 00 " +
            "73 17 " +
            "B9 00 04 00 00 " +
            "B8 00 03 00 00 " +
            "89 0D ?? ?? ?? ?? " +
            "A3 ";
        widthOffset1 = -1;
        widthOffset2 = 18;
        heightOffset1 = 11;
        heightOffset2 = 23;
        screenWidth1Offset = 29;
        screenWidth2Offset = -1;
        screenHeight1Offset = 6;
        screenHeight2Offset = 34;
        widthLimit = 1024;
        heightLimit1 = 664;
        heightLimit2 = 768;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in step 1 - resolution limit not found";
    }

    if (widthOffset1 !== -1 && pe.fetchDWord(offset + widthOffset1) !== widthLimit)
    {
        return "Failed in step 1 - wrong width limit found";
    }
    if (pe.fetchDWord(offset + widthOffset2) !== widthLimit)
    {
        return "Failed in step 1 - wrong width limit found";
    }
    if (pe.fetchDWord(offset + heightOffset1) !== heightLimit1 || pe.fetchDWord(offset + heightOffset2) !== heightLimit2)
    {
        return "Failed in step 1 - wrong height limit found";
    }
    if (screenWidth2Offset !== -1 && pe.fetchDWord(offset + screenWidth1Offset) !== pe.fetchDWord(offset + screenWidth2Offset))
    {
        return "Failed in step 1 - wrong width found";
    }
    if (pe.fetchDWord(offset + screenHeight1Offset) !== pe.fetchDWord(offset + screenHeight2Offset))
    {
        return "Failed in step 1 - wrong height found";
    }

    var width = exe.getUserInput("$newScreenWidth", XTYPE_DWORD, _("Number Input"), _("Enter new minimal width:"), widthLimit, 0, 100000);
    var height = exe.getUserInput("$newScreenHeight", XTYPE_DWORD, _("Number Input"), _("Enter new minimal height:"), heightLimit2, 0, 100000);
    if (width === widthLimit && (height === heightLimit1 || height === heightLimit2))
    {
        return "Patch Cancelled - New width and height is same as old";
    }

    if (widthOffset1 !== -1)
    {
        pe.replaceDWord(offset + widthOffset1, width);
    }
    pe.replaceDWord(offset + widthOffset2, width);
    pe.replaceDWord(offset + heightOffset1, height);
    pe.replaceDWord(offset + heightOffset2, height);

    var screenWidthAdd = pe.fetchHex(offset + screenWidth1Offset, 4);
    var screenHeightAdd = pe.fetchHex(offset + screenHeight1Offset, 4);

    code =
        "3B 3D " + screenWidthAdd +
        "8B BD ?? ?? ?? ?? " +
        "75 ?? " +
        "3B 35 " + screenHeightAdd +
        "75 ?? ";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        code =
            "3B ?? " + screenWidthAdd +
            "75 ?? " +
            "3B 35 " + screenHeightAdd +
            "75 ?? " +
            "3B ";

        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in step 2a";
    }

    code =
        "A3 ?? ?? ?? ?? " +
        "89 ?? ?? 00 00 00 ";
    var retAdd = 5;

    offset = pe.find(code, offset, offset + 0x80);
    if (offset === -1)
    {
        return "Failed in step 2b";
    }

    var codeIns = pe.fetchHex(offset, retAdd);

    var vars = {
        "retAddr": pe.rawToVa(offset + retAdd),
        "codeIns": codeIns,
    };

    var data = pe.insertAsmFile("", vars);
    pe.setJmpRaw(offset, data.free);

    return true;
}

function ChangeMinimalResolutionLimit_()
{
    return pe.stringRaw("WIDTH") !== -1;
}
