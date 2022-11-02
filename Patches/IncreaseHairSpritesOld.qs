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

function IncreaseHairSpritesOld()
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
    var assignOffset = 9;

    offset = pe.find(code, refOffset - 0x200, refOffset);
    if (offset === -1)
    {
        return "Failed in step 2 - hair limit missing";
    }

    pe.replaceHex(offset + assignOffset, "90 90 90 90 90 90");

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
        return "Failed in step 3 - string '2' missing";
    }

    var str2Offset = pe.rawToVa(offset);

    code =
        "50 " +
        "6A ?? " +
        "C7 45 F0 " + str2Offset.packToHex(4) + " " +
        "E8 ?? ?? ?? ?? " +
        "8B 06 " +
        "C7 00 " + str2Offset.packToHex(4);
    var patchOffset = 0;
    var callOffset = 11;
    var fetchOffset = 3;
    var fetchSize = 7;

    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        return "Failed in step 4 - hair table not found";
    }
    if (offsets.length !== 1)
    {
        return "Failed in step 4 - found wrong number of hair tables: " + offsets.length;
    }

    var tableCodeOffset = offsets[0];
    var vectorCallAddr = pe.fetchDWord(tableCodeOffset + callOffset) + tableCodeOffset + callOffset + 4;
    var varCode = pe.fetchHex(tableCodeOffset + fetchOffset, fetchSize);
    patchOffset = tableCodeOffset + patchOffset;

    var free = alloc.find(bufSize);
    if (free === -1)
    {
        return "Failed in step 5 - not enough free space";
    }
    var data = "";
    for (var i = 0; i < maxHairs; i++)
    {
        data += str2Hex(i, bytesPerString);
    }
    if (data.hexlength() !== bufSize)
    {
        return "Failed in step 5 - wrong allocated buffer";
    }

    pe.insertHexAt(free, bufSize, data);
    var tableStrings = pe.rawToVa(free);

    code =
        "8B 06" +
        "8D B7 ?? ?? 00 00" +
        "C7 40 ?? ?? ?? ?? ??" +
        "8D 45 ??" +
        "50" +
        "6A ?? " +
        "8B CE " +
        "E8 ?? ?? ?? ?? ";
    var patchOffset2 = 18;
    var callOffset2 = 24;

    offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);
    if (offset === -1)
    {
        return "Failed in step 6 - jump location not found";
    }

    var tableCodeOffset2 = offset;
    var vectorCallAddr2 = pe.fetchDWord(tableCodeOffset2 + callOffset2) + tableCodeOffset2 + callOffset2 + 4;
    patchOffset2 = tableCodeOffset2 + patchOffset2;

    if (vectorCallAddr !== vectorCallAddr2)
    {
        return "Failed in step 6 - vector call functions different";
    }

    var jmpAddr = pe.rawToVa(offset);
    var vectorCallOffset = vectorCallAddr - (patchOffset + 1 + 5 + varCode.hexlength() + 5);

    code =
        "50 " +
        "68 " + maxHairs.packToHex(4) +
        varCode +
        "E8 " + vectorCallOffset.packToHex(4) +

        "56 " +
        "57 " +
        "53 " +
        "51 " +
        "B9 " + maxHairs.packToHex(4) +
        "8B 06 " +
        "BF " + tableStrings.packToHex(4) +
        "89 38" +
        "83 C0 04" +
        "83 C7 04" +
        "49" +
        "75 F5" +
        "59 " +
        "5B " +
        "5F " +
        "5E " +
        "E9 ";

    jmpAddr -= pe.rawToVa(patchOffset) + code.hexlength() + 4;
    code += jmpAddr.packToHex(4);

    pe.replaceHex(patchOffset, code);

    code =
        "8B 06" +
        "8D B7 ?? ?? 00 00" +
        "C7 40 ?? ?? ?? ?? ??" +
        "8D 45 F0" +
        "50" +
        "6A ??" +
        "8B CE" +
        "E8 ?? ?? ?? ??";

    offset = pe.find(code, tableCodeOffset2 + 5, tableCodeOffset2 + 0x150);
    if (offset === -1)
    {
        return "Failed in step 7 - jump location not found";
    }

    jmpAddr = pe.rawToVa(offset);
    var vectorCallOffset2 = vectorCallAddr2 - (patchOffset2 + 1 + 5 + 2 + 5);

    code =
        "50 " +
        "68 " + maxHairs.packToHex(4) +
        "8B CE " +
        "E8 " + vectorCallOffset2.packToHex(4) +

        "56 " +
        "57 " +
        "53 " +
        "51 " +
        "B9 " + maxHairs.packToHex(4) +
        "8B 06 " +
        "BF " + tableStrings.packToHex(4) +
        "89 38" +
        "83 C0 04" +
        "83 C7 04" +
        "49" +
        "75 F5" +
        "59 " +
        "5B " +
        "5F " +
        "5E " +
        "E9 ";

    jmpAddr -= pe.rawToVa(patchOffset2) + code.hexlength() + 4;
    code += jmpAddr.packToHex(4);

    pe.replaceHex(patchOffset2, code);

    return true;
}
