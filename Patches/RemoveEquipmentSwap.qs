//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2018-2023 Andrei Karas (4144)
// Copyright (C) 2020-2021 X-EcutiOnner (xex.ecutionner@gmail.com)
//
// Hercules is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

function RemoveEquipmentSwap()
{
    var code =
        "E8 ?? ?? ?? FF " +
        "8B 47 18 " +
        "8B 8F ?? ?? ?? 00 " +
        "83 E8 14 " +
        "8B 11 " +
        "50 ";
    var repLoc = 15;
    var onlyOne = false;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? FF " +
            "8B 47 18 " +
            "8B 8F ?? ?? 00 00 " +
            "83 E8 14 " +
            "50 ";
        repLoc = 15;
        onlyOne = false;
        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? 00 " +
            "8B ?? ?? ?? ?? 00 " +
            "68 A7 00 00 00 " +
            "68 C1 00 00 00 " +
            "8B 01 " +
            "FF 50 10 ";
        repLoc = 15;
        onlyOne = true;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

    pe.replaceByte(offset + repLoc, 0xC0);

    if (onlyOne === true)
    {
        return true;
    }

    code =
        "8B 8E ?? ?? 00 00 " +
        "85 C9 " +
        "74 6F " +
        "8B 86 ?? 00 00 00 " +
        "8B 11 " +
        "05 93 00 00 00 " +
        "50 ";

    repLoc = 19;
    offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    pe.replaceByte(offset + repLoc, 0xFF);

    return true;
}

function RemoveEquipmentSwap_()
{
    return pe.getDate() >= 20170208;
}
