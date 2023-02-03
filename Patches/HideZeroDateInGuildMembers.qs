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

function HideZeroDateInGuildMembers()
{
    var code =
        "8D 47 ?? " +
        "50 " +
        "C7 85 ?? ?? ?? ?? 0F 00 00 00 " +
        "C7 85 ?? ?? ?? ?? 00 00 00 00 " +
        "C6 85 ?? ?? ?? ?? 00 " +
        "FF 15 ?? ?? ?? ?? " +
        "83 C4 04 " +
        "50 " +
        "68 C3 0B 00 00 " +
        "E8 ?? ?? ?? ?? " +
        "83 C4 04 " +
        "50 " +
        "8D 85 ?? ?? ?? ?? " +
        "68 ?? 00 00 00 " +
        "50 " +
        "FF 15 ?? ?? ?? ?? " +
        "83 C4 10 " +
        "8D 85 ?? ?? ?? ?? " +
        "50 " +
        "68 C4 0B 00 00 " +
        "E8 ";
    var msgStrOffset1 = 47;
    var msgStrOffset2 = 89;
    var timeStrOffset1 = 57;
    var timeStrOffset2 = 78;
    var patchOffset = 31;
    var localTimeOffset = 33;
    var jmp1Offset = 37;
    var jmp2Offset = 82;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "8D 47 ?? " +
            "50 " +
            "C6 85 ?? ?? ?? ?? 00 " +
            "C7 85 ?? ?? ?? ?? 00 00 00 00 " +
            "C7 85 ?? ?? ?? ?? 0F 00 00 00 " +
            "FF 15 ?? ?? ?? ?? " +
            "83 C4 04 " +
            "50 " +
            "68 C3 0B 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "83 C4 04 " +
            "50 " +
            "8D 85 ?? ?? ?? ?? " +
            "68 ?? 00 00 00 " +
            "50 " +
            "FF 15 ?? ?? ?? ?? " +
            "83 C4 10 " +
            "8D 85 ?? ?? ?? ?? " +
            "50 " +
            "68 C4 0B 00 00 " +
            "E8 ";
        msgStrOffset1 = 47;
        msgStrOffset2 = 89;
        timeStrOffset1 = 57;
        timeStrOffset2 = 78;
        patchOffset = 31;
        localTimeOffset = 33;
        jmp1Offset = 37;
        jmp2Offset = 82;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in step 1 - pattern not found";
    }

    var msgStr1 = pe.rawToVa(pe.fetchDWord(offset + msgStrOffset1) + offset + msgStrOffset1 + 4);
    var msgStr2 = pe.rawToVa(pe.fetchDWord(offset + msgStrOffset2) + offset + msgStrOffset2 + 4);
    var localTime = pe.fetchDWord(offset + localTimeOffset).packToHex(4);
    var timeStr1 = pe.fetchDWord(offset + timeStrOffset1);
    var timeStr2 = pe.fetchDWord(offset + timeStrOffset2);
    if (msgStr1 !== msgStr2)
    {
        return "Failed in step 1 - found different MsgStr";
    }
    if (timeStr1 != timeStr2)
    {
        return "Failed in step 1 - found different timeStr";
    }

    var timeStr = timeStr1.packToHex(4);
    var jmp1Addr = pe.rawToVa(offset + jmp1Offset).packToHex(4);
    var jmp2Addr = pe.rawToVa(offset + jmp2Offset).packToHex(4);

    var newCode =
        "83 38 00 " +
        "74 0C " +
        "FF 15 " + localTime +
        "68 " + jmp1Addr +
        "C3" +
        "58 " +
        "8D 85 " + timeStr +
        "C7 00 00 00 00 00 " +
        "68 " + jmp2Addr +
        "C3";

    var codeLen = newCode.hexlength();
    var free = alloc.find(codeLen);
    var freeRva = pe.rawToVa(free).packToHex(4);
    pe.insertHexAt(free, codeLen, newCode);

    var patchAddr = offset + patchOffset;

    code =
        "68 " + freeRva +
        "C3";
    pe.replaceHex(patchAddr, code);
    return true;
}
