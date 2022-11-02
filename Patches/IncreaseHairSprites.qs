//
// Copyright (C) 2018-2022  Andrei Karas (4144)
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

function str2Hex(val, sz)
{
    var str = val.toString();
    var hex = "";
    for (var i = 0; i < str.length; i++)
    {
        hex += (parseInt(str[i]) + 0x30).packToHex(1);
    }
    while (hex.length < sz * 3)
    {
        hex += " 00";
    }
    return hex;
}

function IncreaseHairSprites()
{
    var maxHairs = 100;
    var bytesPerString = 4;
    var bufSize = maxHairs * bytesPerString;

    var code = "\\\xB8\xD3\xB8\xAE\xC5\xEB\\%s\\%s_%s.%s";
    var offset = pe.stringRaw(code);

    if (offset === -1)
    {
        return "Failed in step 1 - string not found";
    }

    offset = pe.findCode("68" + pe.rawToVa(offset).packToHex(4));
    if (offset === -1)
    {
        return "Failed in step 1 - string reference missing";
    }

    var refOffset = offset;

    code =
        "85 C0" +
        "78 05" +
        "83 F8 ??" +
        "7E 06" +
        "C7 06 ?? 00 00 00";
    var addNops = "";
    var assignOffset = 9;
    var newclient = 0;

    offset = pe.find(code, refOffset - 0x200, refOffset);
    if (offset === -1)
    {
        code =
            "85 C9" +
            "78 05" +
            "83 F9 ??" +
            "?? ??" +
            "C7 00 ?? 00 00 00 " +
            "B9 ?? 00 00 00";
        addNops = " 90 90 90 90 90";
        assignOffset = 9;
        newclient = 1;

        offset = pe.find(code, refOffset - 0x200, refOffset);
    }
    if (offset === -1)
    {
        return "Failed in step 2 - hair limit missing";
    }

    pe.replaceHex(offset + assignOffset, "90 90 90 90 90 90" + addNops);

    if (!newclient)
    {
        code =
            "8B 06 " +
            "75 ?? " +
            "83 F8 01 " +
            "7C 05 " +
            "83 F8 ?? " +
            "7C 06 " +
            "C7 06 ?? 00 00 00 ";
        assignOffset = 14;
    }
    else
    {
        code =
            "8B 08 " +
            "75 ?? " +
            "83 F9 01 " +
            "7C 05 " +
            "83 F9 ?? " +
            "7C ?? " +
            "C7 00 ?? 00 00 00 " +
            "B9 ?? 00 00 00";
        assignOffset = 14;
    }

    offset = pe.find(code, refOffset - 0x200, refOffset);
    if (offset === -1)
    {
        return "Failed in step 3 - doram hair limit missing";
    }

    pe.replaceHex(offset + assignOffset, "90 90 90 90 90 90" + addNops);

    code =
        "32 00" +
        "00 00" +
        "33 00" +
        "00 00" +
        "34 00" +
        "00 00";
    offset = pe.find(code);
    if (offset === -1)
    {
        return "Failed in step 4 - string '2' missing";
    }

    var str2Offset = pe.rawToVa(offset);

    var patchOffset;
    var callOffset;
    var fetchOffset;
    var fetchSize;
    if (!newclient)
    {
        code =
            "50 " +
            "6A ?? " +
            "C7 45 F0 " + str2Offset.packToHex(4) + " " +
            "E8 ?? ?? ?? ?? " +
            "8B 06 " +
            "C7 00 " + str2Offset.packToHex(4);
        patchOffset = 0;
        callOffset = [11, 4];
        fetchOffset = 3;
        fetchSize = 7;
    }
    else
    {
        code =
            "50 " +
            "56 " +
            "6A ?? " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B 06 " +
            "C7 45 F0 " + str2Offset.packToHex(4) + " " +
            "C7 00 " + str2Offset.packToHex(4);
        patchOffset = 0;
        callOffset = [7, 4];
        fetchOffset = 13;
        fetchSize = 7;
    }

    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        return "Failed in step 5 - hair table not found";
    }
    if (offsets.length !== 1)
    {
        return "Failed in step 5 - found wrong number of hair tables: " + offsets.length;
    }

    var tableCodeOffset = offsets[0];
    var vectorCallAddr = pe.fetchRelativeValue(tableCodeOffset, callOffset);
    var varCode = pe.fetchHex(tableCodeOffset + fetchOffset, fetchSize);
    patchOffset = tableCodeOffset + patchOffset;

    var free = alloc.find(bufSize);
    if (free === -1)
    {
        return "Failed in step 6 - not enough free space";
    }
    var data = "";
    for (var i = 0; i < maxHairs; i++)
    {
        data += str2Hex(i, bytesPerString);
    }
    if (data.hexlength() !== bufSize)
    {
        return "Failed in step 6 - wrong allocated buffer";
    }

    pe.insertHexAt(free, bufSize, data);
    var tableStrings = pe.rawToVa(free);

    var patchOffset2;
    var callOffset2;
    var pushReg;

    if (!newclient)
    {
        code =
            "8B 06" +
            "8D B7 ?? ?? 00 00" +
            "C7 40 ?? ?? ?? ?? ??" +
            "8D 45 ??" +
            "50" +
            "6A ?? " +
            "8B CE " +
            "E8 ?? ?? ?? ?? ";
        patchOffset2 = 18;
        callOffset2 = [24, 4];
        pushReg = "";

        offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);
    }
    else
    {
        code =
            "8B 06" +
            "8D B7 ?? ?? 00 00" +
            "8B CE " +
            "C7 80 ?? ?? ?? ?? ?? ?? ?? ??" +
            "8D 45 ??" +
            "50" +
            "56 " +
            "6A ?? " +
            "E8 ?? ?? ?? ?? ";
        patchOffset2 = 23;
        callOffset2 = [28, 4];
        pushReg = "push esi";

        offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);

        if (offset === -1)
        {
            code =
                "8B 06" +
                "8D B7 ?? ?? 00 00" +
                "8B CE " +
                "C7 40 ?? ?? ?? ?? ??" +
                "8D 45 ??" +
                "50" +
                "56 " +
                "6A ?? " +
                "E8 ?? ?? ?? ?? ";
            patchOffset2 = 20;
            callOffset2 = [25, 4];
            pushReg = "push esi";

            offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);
        }
    }

    if (offset === -1)
    {
        return "Failed in step 7 - jump location not found";
    }

    var tableCodeOffset2 = offset;
    var vectorCallAddr2 = pe.fetchRelativeValue(tableCodeOffset2, callOffset2);
    patchOffset2 = tableCodeOffset2 + patchOffset2;

    if (vectorCallAddr !== vectorCallAddr2)
    {
        return "Failed in step 7 - vector call functions different";
    }

    var vars = {
        "pushReg": pushReg,
        "maxHairs": maxHairs,
        "varCode": varCode,
        "varCode2": "",
        "vectorCall": vectorCallAddr,
        "tableStrings": tableStrings,
        "jmpAddr": pe.rawToVa(offset),
    };
    pe.replaceAsmFile(patchOffset, "", vars);

    var str1Offset;

    if (!newclient)
    {
        code =
            "8B 06 " +
            "8D B7 ?? ?? ?? ?? " +
            "C7 40 ?? ?? ?? ?? ?? " +
            "8D 45 ?? " +
            "50 " +
            "6A 07 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B 06 " +
            "C7 45 ";
        str1Offset = 33;
        patchOffset = 18;
        callOffset = [24, 4];

        offsets = pe.findCodes(code);
    }
    else
    {
        code =
            "8B 06 " +
            "8D B7 ?? ?? ?? ?? " +
            "8B CE " +
            "C7 80 ?? ?? ?? ?? ?? ?? ?? ?? " +
            "8D 45 ?? " +
            "50 " +
            "56 " +
            "6A ?? " +
            "E8 ?? ?? ?? ?? " +
            "8B 06 " +
            "C7 40 ";
        str1Offset = 37;
        patchOffset = 23;
        callOffset = [28, 4];

        offsets = pe.findCodes(code);

        if (offsets.length === 0)
        {
            code =
                "8B 06 " +
                "8D B7 ?? ?? ?? ?? " +
                "8B CE " +
                "C7 40 ?? ?? ?? ?? ??" +
                "8D 45 ?? " +
                "50 " +
                "56 " +
                "6A ?? " +
                "E8 ?? ?? ?? ?? " +
                "8B 06 " +
                "C7 40 ";

            str1Offset = 34;
            patchOffset = 20;
            callOffset = [25, 4];

            offsets = pe.findCodes(code);
        }
    }
    if (offsets.length === 0)
    {
        return "Failed in step 8 - doram hair table not found";
    }
    if (offsets.length !== 1)
    {
        return "Failed in step 8 - found wrong number of doram hair tables: " + offsets.length;
    }

    var str1Addr = pe.vaToRaw(pe.fetchDWord(offsets[0] + str1Offset));
    if (pe.fetchUByte(str1Addr) != 0x31 || pe.fetchUByte(str1Addr + 1) != 0)
    {
        return "Failed in step 8 - wrong constant 1 found";
    }

    tableCodeOffset = offsets[0];
    vectorCallAddr = pe.fetchRelativeValue(tableCodeOffset, callOffset);
    varCode = "";
    patchOffset = tableCodeOffset + patchOffset;

    offset = offsets[0];

    vars = {
        "pushReg": pushReg,
        "maxHairs": maxHairs,
        "varCode": "",
        "varCode2": "",
        "vectorCall": vectorCallAddr2,
        "tableStrings": tableStrings,
        "jmpAddr": pe.rawToVa(offset),
    };
    pe.replaceAsmFile(patchOffset2, "", vars);

    if (!newclient)
    {
        code =
            "8B 06 " +
            "8D B7 ?? ?? 00 00 " +
            "C7 40 ?? ?? ?? ?? ?? " +
            "8D 45 ?? " +
            "50 " +
            "6A 07 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B 06 " +
            "C7 40 ?? ?? ?? ?? ?? " +
            "8B 06 " +
            "8D 8F ?? ?? ?? ?? " +
            "C7 40 ?? ?? ?? ?? ?? " +
            "8B 06 " +
            "C7 45 ?? ?? ?? ?? ?? " +
            "C7 40 ";
        str1Offset = 33;
        patchOffset2 = 18;
        callOffset2 = [24, 4];
        fetchOffset = 37;
        fetchSize = 24;
    }
    else
    {
        code =
            "8B 06 " +
            "8D B7 ?? ?? 00 00 " +
            "8B CE " +
            "C7 40 ?? ?? ?? ?? ?? " +
            "8D 45 ?? " +
            "50 " +
            "56 " +
            "6A ?? " +
            "E8 ?? ?? ?? ?? " +
            "8B 06 " +
            "8D 9F ?? ?? ?? ?? " +
            "8B CB " +
            "C7 45 ?? ?? ?? ?? ??" +
            "C7 40 ";

        str1Offset = 49;
        patchOffset2 = 20;
        callOffset2 = [25, 4];
        fetchOffset = 31;
        fetchSize = 15;
    }

    offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);
    if (offset === -1)
    {
        return "Failed in step 9 - jump location not found";
    }

    tableCodeOffset2 = offset;
    vectorCallAddr2 = pe.fetchRelativeValue(tableCodeOffset2, callOffset2);
    patchOffset2 = tableCodeOffset2 + patchOffset2;
    varCode = pe.fetchHex(tableCodeOffset2 + fetchOffset, fetchSize);

    if (vectorCallAddr !== vectorCallAddr2)
    {
        return "Failed in step 9 - vector call functions different";
    }

    vars = {
        "pushReg": pushReg,
        "maxHairs": maxHairs,
        "varCode": "",
        "varCode2": "",
        "vectorCall": vectorCallAddr,
        "tableStrings": tableStrings,
        "jmpAddr": pe.rawToVa(offset),
    };
    pe.replaceAsmFile(patchOffset, "", vars);

    var viewID;
    if (pe.getDate() > 20200325)
    {
        viewID = 3000;
    }
    else
    {
        viewID = 2000;
    }
    var jumpOffset;

    if (!newclient)
    {
        code =
            "8B 06 " +
            "C7 40 ?? ?? ?? ?? ?? " +
            "8D 45 ?? " +
            "50 " +
            "68 " + viewID.packToHex(4) + " " +
            "E8 ";
        jumpOffset = 9;
    }
    else
    {
        code =
            "8B 06 " +
            "C7 40 ?? ?? ?? ?? ?? " +
            "8D 45 ?? " +
            "50 " +
            "53 " +
            "68 " + viewID.packToHex(4) + " " +
            "E8 ";
        jumpOffset = 9;
    }

    offset = pe.find(code, tableCodeOffset2 + 5, tableCodeOffset2 + 0x150);
    if (offset === -1)
    {
        return "Failed in step 10 - jump location not found";
    }

    vars = {
        "pushReg": pushReg,
        "maxHairs": maxHairs,
        "varCode": "",
        "varCode2": varCode,
        "vectorCall": vectorCallAddr2,
        "tableStrings": tableStrings,
        "jmpAddr": pe.rawToVa(offset) + jumpOffset,
    };
    pe.replaceAsmFile(patchOffset2, "", vars);

    return true;
}
