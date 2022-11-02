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

function FixCharsetForFonts()
{
    var code =
        "89 56 ?? " +
        "89 4E ?? " +
        "85 FF " +
        "75 0A " +
        "A1 ?? ?? ?? ?? " +
        "83 FA 14 " +
        "7D 07 ";
    var gfontCharSetOfsset = 11;

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "85 FF " +
            "0F 85 ?? 00 00 00 " +
            "83 FA 14 " +
            "0F 8C ?? 00 00 00 " +
            "89 56 ?? " +
            "89 4E ?? " +
            "A1 ?? ?? ?? ?? ";
        gfontCharSetOfsset = 24;

        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var cTable = pe.fetchHex(offset + gfontCharSetOfsset, 4);

    offset = pe.findCode(" 8B 04 95" + cTable);

    if (offset === -1)
    {
        return "Failed in Step 1b";
    }

    var retAdd = offset + 7;

    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 2 - " + LANGTYPE[0];
    }

    var ins = " 81 00 80 86 88 DE 00 00 00 00 00 00 00 00 CC A3 00 00 00 B2 00";

    code =
        " 83 FA 14" +
        " 7C 0F" +
        " 8B 3D" + LANGTYPE +
        " 0F B6 87" + GenVarHex(1) +
        " EB 07" +
        " 8B 04 95" + cTable +
        " 68" + pe.rawToVa(retAdd).packToHex(4) +
        " C3";

    ins += code;

    var size = ins.hexlength();
    var free = alloc.find(size + 4);
    if (free === -1)
    {
        return "Failed in Step 3 - No enough free space";
    }

    var freeRva = pe.rawToVa(free);

    ins = ReplaceVarHex(ins, 1, freeRva);

    var jump = pe.rawToVa(free + 21) - pe.rawToVa(offset + 5);

    code = " E9" + jump.packToHex(4) + " 90 90";

    pe.insertHexAt(free, size + 4, ins);
    pe.replaceHex(offset, code);

    return true;
}
