//
// Copyright (C) 2020  CH.C
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

function InsensitiveStorageSearch()
{
    var GetModuleHandleA = imports.ptrValidated("GetModuleHandleA", "KERNEL32.dll");
    var GetProcAddress = imports.ptrValidated("GetProcAddress", "KERNEL32.dll");

    var code =
        " 51" +
        " 50" +
        " FF 15 ?? ?? ?? ??" +
        " 83 C4 08" +
        " 85 C0" +
        " 74 04" +
        " 8B 36" +
        " EB";
    var calloffset = 2;

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        code = code.replace(" 51 50", " 51 0F 43 45 ?? 50");
        offset = pe.findCode(code);
        calloffset += 4;
    }
    if (offset === -1)
    {
        return "Failed in Step 2 - String compair not found";
    }

    var varcode = pe.fetchHex(offset + calloffset, 9);
    var retAddr = pe.rawToVa(offset + calloffset + 9);

    code =
        " 83 3D" + GenVarHex(1) + " 00" +
        " 75 2F" +
        " 68" + GenVarHex(4) +
        " FF 15" + GetModuleHandleA.packToHex(4) +
        " 68" + GenVarHex(5) +
        " 50" +
        " FF 15" + GetProcAddress.packToHex(4) +
        " 85 C0" +
        " 75 0F" +
        varcode +

        " 68" + retAddr.packToHex(4) +
        " C3" +
        " A3" + GenVarHex(2) +
        " FF 15" + GenVarHex(3) +
        " 68" + retAddr.packToHex(4) +
        " C3";

    var strings = ["Shlwapi.dll", "StrStrIA"];

    var size = code.hexlength() + 4;
    size = size + strings[0].length + 1;
    size = size + strings[1].length + 1;

    var free = alloc.find(size + 8);
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);

    var memPosition = freeRva + code.hexlength();
    for (var i = 1; i < 4; i++)
    {
        code = ReplaceVarHex(code, i, memPosition);
    }

    memPosition += 4;
    code = ReplaceVarHex(code, 4, memPosition);

    memPosition = memPosition + strings[0].length + 1;
    code = ReplaceVarHex(code, 5, memPosition);

    code += " 00 00 00 00";
    code = code + strings[0].toHex() + " 00";
    code = code + strings[1].toHex() + " 00";
    code += " 90 90 90 90";

    pe.insertHexAt(free, code.hexlength(), code);

    code =
    " E9" + (freeRva - pe.rawToVa(offset + calloffset + 5)).packToHex(4) +
  " 90 90 90 90";

    pe.replaceHex(offset + calloffset, code);

    return true;
}
