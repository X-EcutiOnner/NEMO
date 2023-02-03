//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2020-2023 Andrei Karas (4144)
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

function DisableMapInfo()
{
    var iiName;
    if (IsSakray())
    {
        iiName = "system\\mapInfo_sak.lub";
    }
    else
    {
        iiName = "system\\mapInfo_true.lub";
    }

    var offset = pe.stringRaw(iiName);

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    pe.replaceByte(offset, 0);

    var code =
        "0F 84 B4 00 00 00 " +
        "FF 75 ?? " +
        "E8 ?? ?? ?? ?? " +
        "6A 00 " +
        "68 ?? ?? ?? ?? " +
        "FF 75 ?? " +
        "E8 ";
    var l1Offset = 8;
    var l2Offset = 23;

    offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in Step 3 - Pattern not found";
    }

    if (pe.fetchUByte(offset + l1Offset) !== pe.fetchUByte(offset + l2Offset))
    {
        return "Faile in Step 3 - found wrong lua offsets";
    }

    pe.replaceHex(offset, "90 E9 ");

    return true;
}

function DisableMapInfo_()
{
    var iiName;
    if (IsSakray())
    {
        iiName = "system\\mapInfo_sak.lub";
    }
    else
    {
        iiName = "system\\mapInfo_true.lub";
    }

    return pe.stringRaw(iiName) !== -1;
}
