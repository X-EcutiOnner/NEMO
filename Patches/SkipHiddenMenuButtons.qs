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

function SkipHiddenMenuButtons()
{
    var strHex = pe.stringHex4("status_doram");

    var code =
        "8D B5 ?? ?? ?? ??" +
        "89 8D ?? ?? ?? ??" +
        "8B 18" +
        "81 FB ?? ?? 00 00" +
        "75 ??" +
        "FF 35 ?? ?? ?? ??" +
        getEcxSessionHex() +
        "E8 ?? ?? ?? ??" +
        "3C 01" +
        "75 0E" +
        "6A 0C" +
        "68 " + strHex +
        "8B CE" +
        "E8";
    var nonA9Offset = 21;
    var a9Offset = 22;
    var stoleOffset = 14;
    var stoleSize = 6;
    var regName = "esi";
    var noSwitch = false;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "8D BD ?? ?? ?? ?? " +
            "C7 85 ?? ?? ?? ?? 00 00 00 00 " +
            "89 B5 ?? ?? ?? ?? " +
            "81 3E ?? ?? 00 00 " +
            "75 ?? " +
            "FF 35 ?? ?? ?? ?? " +
            getEcxSessionHex() +
            "E8 ?? ?? ?? ?? " +
            "3C 01 " +
            "75 ?? " +
            "6A 0C " +
            "68 " + strHex +
            "8B CF " +
            "E8";

        nonA9Offset = 29;
        a9Offset = 30;
        stoleOffset = 22;
        stoleSize = 6;
        regName = "edi";
        noSwitch = false;
        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        code =
            "8D BD ?? ?? ?? ?? " +
            "C7 85 ?? ?? ?? ?? 00 00 00 00 " +
            "89 9D ?? ?? ?? ?? " +
            "81 3B ?? ?? 00 00 " +
            "75 ?? " +
            "FF 35 ?? ?? ?? ?? " +
            getEcxSessionHex() +
            "E8 ?? ?? ?? ?? " +
            "3C 01 " +
            "75 ?? " +
            "6A 0C " +
            "68 " + strHex +
            "8B CF " +
            "E8";

        nonA9Offset = 29;
        a9Offset = 30;
        stoleOffset = 22;
        stoleSize = 6;
        regName = "edi";
        noSwitch = false;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "8D B5 ?? ?? ?? FF " +
            "8B 18 " +
            "81 FB ?? ?? 00 00 " +
            "75 ?? " +
            "FF 35 ?? ?? ?? ?? " +
            "B9 ?? ?? ?? ?? " +
            "E8 ?? ?? ?? ?? " +
            "3C 01 " +
            "75 0E " +
            "6A 0C " +
            "68 " + strHex +
            "8B CE " +
            "E8 ";
        nonA9Offset = 15;
        a9Offset = 16;
        stoleOffset = 8;
        stoleSize = 6;
        regName = "esi";
        noSwitch = false;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in step 2 - pattern not found";
    }
    var offset1 = offset;

    var nonA9JmpAddr = pe.rawToVa(pe.fetchByte(offset + nonA9Offset) + offset + nonA9Offset + 1);
    var a9JmpAddr = pe.rawToVa(offset + a9Offset);
    var patchAddr = offset + stoleOffset;

    code =
        "8D 83 ?? ?? ?? ??" +
        "3D ?? ?? 00 00" +
        "77 0E" +
        "0F B6 80 ?? ?? ?? ??" +
        "FF 24 85 ?? ?? ?? ??";
    var switch1Offset = 16;
    var switch2Offset = 23;
    offset = pe.find(code, offset1, offset1 + 0x50);

    if (offset === -1)
    {
        code =
            "8B 06 " +
            "05 ?? ?? ?? FF " +
            "3D ?? ?? 00 00 " +
            "77 0E " +
            "0F B6 80 ?? ?? ?? ?? " +
            "FF 24 85 ?? ?? ?? ?? ";
        switch1Offset = 17;
        switch2Offset = 24;
        noSwitch = false;
        offset = pe.find(code, offset1, offset1 + 0x50);
    }

    var jmpOffset1 = 0;
    var jmpOffset2 = 0;

    if (offset === -1)
    {
        code =
            " 2D ?? ?? 00 00" +
            " 0F 84 ?? ?? 00 00" +
            " 83 E8 ??" +
            " 0F 84 ?? ?? 00 00";
        noSwitch = true;
        jmpOffset1 = 7;
        jmpOffset2 = 16;
        offset = pe.find(code, offset1, offset1 + 0x50);
    }

    if (offset === -1)
    {
        code =
            " 2D ?? ?? 00 00" +
            " 0F 84 ?? ?? 00 00" +
            " 2D ?? ?? 00 00" +
            " 0F 84 ?? ?? 00 00";
        noSwitch = true;
        jmpOffset1 = 7;
        jmpOffset2 = 18;
        offset = pe.find(code, offset1, offset1 + 0x50);
    }

    if (offset === -1)
    {
        code =
            " 81 FB ?? ?? 00 00" +
            " 0F 84 ?? ?? 00 00" +
            " 81 FB ?? ?? 00 00" +
            " 0F 84 ?? ?? 00 00";
        noSwitch = true;
        jmpOffset1 = 8;
        jmpOffset2 = 20;
        offset = pe.find(code, offset1, offset1 + 0x50);
    }

    if (offset === -1)
    {
        code =
            " 81 FB ?? ?? 00 00" +
            " 0F 84 ?? ?? 00 00" +
            " 81 FB ?? ?? 00 00" +
            " 7E ??" +
            " 81 FB ?? ?? 00 00" +
            " 0F 8E ?? ?? 00 00";
        noSwitch = true;
        jmpOffset1 = 8;
        jmpOffset2 = 28;
        offset = pe.find(code, offset1, offset1 + 0x50);
    }

    if (offset === -1)
    {
        code =
            "81 FB ?? ?? 00 00 " +
            "0F 84 ?? ?? 00 00 " +
            "68 ?? ?? ?? 00 " +
            "E8 ?? ?? ?? ?? " +
            "8B F8 " +
            "83 C4 04 ";
        noSwitch = true;
        jmpOffset1 = 8;
        jmpOffset2 = 0;
        offset = pe.find(code, offset1, offset1 + 0x50);
    }

    if (offset === -1)
    {
        return "Failed in Step 3 - switch not found";
    }

    var continueAddr;
    if (noSwitch)
    {
        var jmpAdd1 = pe.fetchDWord(offset + jmpOffset1);
        continueAddr = pe.rawToVa(offset + jmpOffset1 + 4) + jmpAdd1;
        if (jmpOffset2 !== 0)
        {
            var jmpAdd2 = pe.fetchDWord(offset + jmpOffset2);
            var continueAddr2 = pe.rawToVa(offset + jmpOffset2 + 4) + jmpAdd2;
            if (continueAddr !== continueAddr2)
            {
                return "Failed in Step 3.1 - Found wrong continueAddr";
            }
        }
    }
    else
    {
        var addr1 = pe.vaToRaw(pe.fetchDWord(offset + switch1Offset));
        var addr2 = pe.vaToRaw(pe.fetchDWord(offset + switch2Offset));
        offset1 = pe.fetchUByte(addr1);
        continueAddr = pe.fetchDWord(addr2 + 4 * offset1);
    }

    var vars = {
        "continueAddr": continueAddr,
        "a9JmpAddr": a9JmpAddr,
        "nonA9JmpAddr": nonA9JmpAddr,
        "regName": regName,
        "stolenCode": pe.fetchHex(patchAddr, stoleSize),
    };
    var data = pe.insertAsmFile("", vars);

    pe.setJmpRaw(patchAddr, data.free);

    return true;
}

function SkipHiddenMenuButtons_()
{
    return pe.stringRaw("status_doram") !== -1;
}
