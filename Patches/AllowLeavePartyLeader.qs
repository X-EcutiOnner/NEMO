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

function AllowLeavelPartyLeader()
{
    var code =
        "84 C0" +
        "74 34" +
        "C7 45 ?? FF FF FF FF" +
        "8D 8D ?? ?? ?? ??" +
        "E8 ?? ?? ?? ??" +
        "46" +
        "3B F3" +
        "7C ??" +
        "8A 85 ?? ?? ?? ??" +
        "84 C0" +
        "74 ??" +
        "6A 00" +
        "6A 00" +
        "68 FF 00 00 00" +
        "68 C9 0C 00 00" +
        "E9";
    var jzOffset = 2;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in step 1 - pattern not found";
    }

    if (pe.fetchUByte(offset + jzOffset) !== 0x74)
    {
        return "Failed in step 1 - wrong jz offset";
    }

    pe.replaceByte(offset + jzOffset, 0xEB);

    return true;
}
