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

function IgnoreTownInfoReading()
{
    var offset = pe.stringVa("TownInfo file Init");

    if (offset === -1)
    {
        return "Failed in Step 1a - String not found";
    }

    var strHex = offset.packToHex(4);

    var code =
        "E8 ?? ?? ?? ?? " +
        "8B ?? ?? ?? ?? 00 " +
        "84 C0 " +
        "75 ?? " +
        "6A 00 " +
        "68 ?? ?? ?? 00 " +
        "68 " + strHex +
        "6A 00 " +
        "FF ?? " +
        "E8 ?? ?? ?? ?? ";

    var hloc = 15;
    var head = "90 90 ";
    var foot = "90 90 ";
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? ?? " +
            "84 C0 " +
            "75 ?? " +
            "6A 00 " +
            "68 ?? ?? ?? 00 " +
            "68 " + strHex +
            "6A 00 " +
            "FF 15 ?? ?? ?? 00 " +
            "E8 ?? ?? ?? FF ";

        hloc = 9;
        head = "90 90 ";
        foot = "90 90 90 90 90 90 ";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? ?? " +
            "8B 35 ?? ?? ?? 00 " +
            "84 C0 " +
            "75 ?? " +
            "53 " +
            "68 ?? ?? ?? 00 " +
            "68 " + strHex +
            "53 " +
            "FF D6 " +
            "E8 ?? ?? ?? FF ";

        hloc = 15;
        head = "90 ";
        foot = "90 90 ";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? ?? " +
            "84 C0 " +
            "75 ?? " +
            "53 " +
            "68 ?? ?? ?? 00 " +
            "68 " + strHex +
            "53 " +
            "FF 15 ?? ?? ?? 00 " +
            "E8 ?? ?? ?? FF ";

        hloc = 9;
        head = "90 ";
        foot = "90 90 90 90 90 90 ";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1b - Pattern not found";
    }

    pe.replaceHex(offset, "33 C0 90 90 90 ");

    var hcode =
        head +
        "33 C0 90 90 90 " +
        "33 C0 90 90 90 " +
        head +
        foot +
        "E8 ";

    pe.replaceHex(offset + hloc, hcode);

    return true;
}

function IgnoreTownInfoReading_()
{
    return pe.stringVa("System/Towninfo.lub") !== -1;
}
