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

function FixActDelay()
{
    var code =
        "D9 5D ?? " +
        "F3 0F 10 45 ?? " +
        "0F 57 C9 " +
        "0F 2F C8 " +
        "F3 0F 11 45 ?? " +
        "72 ?? " +
        "57 " +
        "8B CB " +
        "E8 ";
    var actIndexOffset1 = 2;
    var actIndexOffset2 = 7;
    var actIndexOffset3 = 18;
    var patchOffset = 19;

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in step 1 - pattern not found";
    }

    var index1 = pe.fetchUByte(offset + actIndexOffset1);
    var index2 = pe.fetchUByte(offset + actIndexOffset2);
    var index3 = pe.fetchUByte(offset + actIndexOffset3);

    if (index1 != index2 || index2 != index3)
    {
        return "Failed in step 1 - found different act indexes";
    }

    pe.replaceHex(offset + patchOffset, "90 90");
    return true;
}
