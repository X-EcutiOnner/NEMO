//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2017-2023 Andrei Karas (4144)
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

function IgnoreLuaErrors()
{
    var code =
        "FF ?? ?? ?? ?? 00 " +
        "83 ?? ?? " +
        "8D ?? ?? ?? FF FF " +
        "6A 00 " +
        "?? " +
        "?? " +
        "6A 00 " +
        "FF 15 ?? ?? ?? 00 ";

    var repLoc = 9;
    var hCode = "33 C0 90 90 90 90 90 90 90 ";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "FF ?? ?? ?? ?? 00 " +
            "83 ?? ?? " +
            "6A 00 " +
            "?? " +
            "8D ?? ?? ?? FF FF " +
            "?? " +
            "6A 00 " +
            "FF 15 ?? ?? ?? 00 ";

        repLoc = 9;
        hCode = "90 90 90 33 C0 90 90 90 90 ";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "FF ?? ?? ?? ?? 00 " +
            "83 ?? ?? " +
            "6A 00 " +
            "?? " +
            "8D ?? ?? ?? " +
            "?? " +
            "6A 00 " +
            "FF 15 ?? ?? ?? 00 ";

        repLoc = 9;
        hCode = "90 90 90 33 C0 90 90 ";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? 00 " +
            "8B ?? ?? " +
            "83 ?? ?? " +
            "8D ?? ?? ?? FF FF " +
            "6A 00 " +
            "?? " +
            "?? " +
            "6A 00 " +
            "FF 15 ?? ?? ?? 00 ";

        repLoc = 11;
        hCode = "90 90 90 90 90 90 33 C0 90 ";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

    var newCode =
        hCode +
        "90 " +
        "90 90 " +
        "90 90 90 90 90 90 ";

    pe.replaceHex(offset + repLoc, newCode);

    return true;
}

function IgnoreLuaErrors_()
{
    return pe.getDate() >= 20100000;
}
