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

function AllowCloseCutinByEsc()
{
    var code =
        getEcxModeMgrHex() +
        "E8 ?? ?? ?? ??" +
        "8B 10" +
        "6A 00" +
        "6A ??" +
        "6A FF" +
        "68 ?? ?? ?? ??" +
        "6A 64" +
        "8B C8" +
        "FF 52";

    var gModeMgrOffset = 1;
    var getGameModeOffset = 6;
    var EmptyStrOffset = 19;
    var vptrOffset = 29;
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in step 1 - check pattern not found";
    }

    var gModeMgrHex = pe.fetchDWord(offset + gModeMgrOffset).packToHex(4);
    var getGameModeHex = pe.rawToVa(pe.fetchDWord(offset + getGameModeOffset) + offset + getGameModeOffset + 4).packToHex(4);
    var emptyStrHex = pe.fetchDWord(offset + EmptyStrOffset).packToHex(4);
    var vptrHex = pe.fetchUByte(offset + vptrOffset).packToHex(1);

    code =
        "56 " +
        "8B CF " +
        "E8 ?? ?? ?? ?? " +
        "84 C0 " +
        "0F 85 ?? ?? ?? ?? " +
        "83 FE FF " +
        "74 10 " +
        "56 " +
        "8B CF " +
        "E8 ?? ?? ?? ?? " +
        "3C 01 " +
        "0F 84 ";
    var checkFuncOffset = 4;
    var deleteFuncOffset = 25;
    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in step 2 - check esc pattern not found";
    }

    checkFuncOffset = offset + checkFuncOffset;
    var deleteFuncAddr = pe.fetchDWord(offset + deleteFuncOffset) + offset + deleteFuncOffset + 4;
    var checkFuncAddr = pe.fetchDWord(checkFuncOffset) + checkFuncOffset + 4;

    var deleteHex = pe.rawToVa(deleteFuncAddr).packToHex(4);
    var checkHex = pe.rawToVa(checkFuncAddr).packToHex(4);
    var retHex = pe.rawToVa(checkFuncOffset + 4).packToHex(4);
    var widHex = (78).packToHex(4);

    var newCode =
        "51" +
        "68" + widHex +
        "B8" + deleteHex +
        "FF D0" +
        "3C 00" +
        "75 0E" +
        "59" +
        "B8" + checkHex +
        "FF D0" +
        "68" + retHex +
        "C3" +
        "52" +
        "B9" + gModeMgrHex +
        "B8" + getGameModeHex +
        "FF D0" +
        "8B 10" +
        "6A 00" +
        "6A 01" +
        "6A FF" +
        "68 " + emptyStrHex +
        "6A 64" +
        "8B C8" +
        "FF 52" + vptrHex +
        "5A" +
        "59" +
        "58" +
        "68" + retHex +
        "C3";

    var codeLen = newCode.hexlength();
    var free = alloc.find(codeLen);
    var freeRva = pe.rawToVa(free);

    pe.insertHexAt(free, codeLen, newCode);

    pe.replaceHex(checkFuncOffset - 1, "E9" + (freeRva - pe.rawToVa(checkFuncOffset) - 4).packToHex(4));
    return true;
}
