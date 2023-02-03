//
// Copyright (C) 2020 CH.C (jchcc)
// Copyright (C) 2021-2023 Andrei Karas (4144)
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

function MvpItemIdenfifyName()
{
    var code =
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "6A 03 " +
        getEcxWindowMgrHex() +
        "C7 85 ?? FF FF FF 00 00 00 00 " +
        "C6 85 ?? FF FF FF 00 " +
        "E8 ";
    var patchOffset = 31;

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offset + patchOffset, 1);

    return true;
}
