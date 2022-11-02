//
// Copyright (C) 2018  CH.C
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

function UseDefaultBrowser()
{
    var code =
        " 50" +
        " FF D6" +
        " 83 C4 04" +
        " 8B D8";

    var foffset = pe.findCode(code);
    if (foffset === -1)
    {
        return "Failed in Step 1a - Function not found.";
    }

    code =
        " 6A 00" +
        " 8D 45 ??" +
        " 50" +
        " 8B CF"  +
        " E8 ?? ?? ?? ??";

    var offset = pe.find(code, foffset - 0x80, foffset);
    if (offset === -1)
    {
        return "Failed in Step 1b - Function not found.";
    }

    var coffset = offset + code.hexlength();
    if (pe.fetchUByte(coffset) !== 0xC7)
    {
        return "Failed in Step 1c - Unknown instruction after reference.";
    }

    var store1 = pe.fetchHex(coffset, 7);

    var seoffset = imports.ptrHexValidated("ShellExecuteA", "SHELL32.dll");

    var opoffset = pe.stringHex4("open");

    code =
        " 50" +
        " 8B 00" +
        " 6A 0A" +
        " 6A 00" +
        " 6A 00" +
        " 50" +
        " 68" + opoffset +
        " 6A 00" +
        " FF 15" + seoffset +
        " 58" +
        store1 +
        " C3";

    var size = code.hexlength();
    var free = alloc.find(size + 4);
    if (free === -1)
    {
        return "Failed in Step 2d - Not enough free space.";
    }

    var freeRva = pe.rawToVa(free);
    var joffset = (freeRva - pe.rawToVa(coffset + 5)).packToHex(4);
    var call =
        " E8" + joffset +
        " 90 90";

    pe.replaceHex(coffset, call);
    pe.insertHexAt(free, size + 4, code);

    code =
        " 53" +
        " FF B5 ?? ?? FF FF";

    var roffset = pe.find(code, foffset, foffset + 0x50);
    if (roffset === -1)
    {
        return "Failed in Step 3a - Pattern missing.";
    }

    code =
        " 8B F0" +
        " 85 F6" +
        " 74 ??";

    var doffset = pe.find(code, roffset, roffset + 0x20);
    if (doffset === -1)
    {
        return "Failed in Step 3b - Pattern missing.";
    }

    doffset += 4;
    var dist = pe.fetchByte(doffset + 1);
    dist = (dist + doffset - roffset).packToHex(1);

    code =
        " EB" + dist +
        " 90 90 90 90 90";

    pe.replaceHex(roffset, code);

    return true;
}
