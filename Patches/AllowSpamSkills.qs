//
// Copyright (C) 2019-2023 Andrei Karas (4144)
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

function AllowSpamSkills()
{
    var code =
        "A1 ?? ?? ?? ?? " +
        "81 FB F4 07 00 00 " +
        "0F 44 05 ?? ?? ?? ?? " +
        "A3 ";
    var patchOffset = 5;
    var key1Offset1 = 1;
    var key1Offset2 = 19;
    var key2Offset = 14;
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in step 1 - pattern not found";
    }

    var key1 = pe.fetchDWord(offset + key1Offset1);
    if (key1 !== pe.fetchDWord(offset + key1Offset2))
    {
        return "Failed in step 1 - found different virtual key offsets";
    }
    var key2 = pe.fetchDWord(offset + key2Offset);
    if (key1 + 4 !== key2)
    {
        return "Failed in step 1 - found wrong virtual key offset";
    }

    code =
        "3B DB" +
        "90 " +
        "90 " +
        "90 " +
        "90 ";

    pe.replaceHex(offset + patchOffset, code);
    return true;
}
