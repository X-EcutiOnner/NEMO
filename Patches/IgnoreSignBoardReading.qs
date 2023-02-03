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

function IgnoreSignBoardReading()
{
    var offset = pe.stringVa("Lua Files\\SignBoardList_F");

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var strHex = offset.packToHex(4);

    offset = pe.stringVa("Lua Files\\SignBoardList");

    if (offset === -1)
    {
        return "Failed in Step 2 - String not found";
    }

    var strHex2 = offset.packToHex(4);

    var code =
        "8B 8E ?? ?? 00 00 " +
        "6A 00 " +
        "6A 01 " +
        "68 " + strHex +
        "E8 ?? ?? ?? ?? " +
        "8B 8E ?? ?? 00 00 " +
        "6A 00 " +
        "6A 01 " +
        "68 " + strHex2 +
        "E8 ";
    var repLoc = 26;

    offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    code =
        "33 C0 " +
        "90 90 " +
        "90 90 90 90 90 " +
        "90 90 90 90 90 ";

    pe.replaceHex(offset + repLoc, code);

    return true;
}

function IgnoreSignBoardReading_()
{
    return pe.stringVa("Lua Files\\SignBoardList_F") !== -1;
}
