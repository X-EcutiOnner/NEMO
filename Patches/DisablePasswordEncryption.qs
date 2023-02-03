//
// Copyright (C) 2017-2023 Andrei Karas (4144)
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

function DisablePasswordEncryption()
{
    var obj = LoginPacketSend_match();
    var offset = obj.offset;

    var code =
        "83 F9 07 " +
        "75 ";
    var jmpOffset = 3;
    var offset2 = pe.find(code, offset, offset + 0xFF);
    if (offset2 === -1)
    {
        return "Failed in disable encryption for lang type 7";
    }
    pe.replaceByte(offset2 + jmpOffset, 0xEB);

    code =
        "83 F9 04 " +
        "75 ";
    jmpOffset = 3;
    offset2 = pe.find(code, offset, offset + 0xFF);
    if (offset2 === -1)
    {
        return "Failed in disable encryption for lang type 4";
    }
    pe.replaceByte(offset2 + jmpOffset, 0xEB);

    return true;
}

function DisablePasswordEncryption_()
{
    return (pe.getDate() > 20171019 && IsZero()) || pe.getDate() >= 20181114;
}
