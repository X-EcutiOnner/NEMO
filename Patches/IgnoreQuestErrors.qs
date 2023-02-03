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

function IgnoreQuestErrors()
{
    var offset = pe.stringVa("Not found Quest Info = %lu");

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var strHex = offset.packToHex(4);
    var hwndHex = table.getHex4(table.g_hMainWnd);

    var code =
        "68 " + strHex +
        "50 " +
        "E8 ?? ?? ?? ?? " +
        "83 C4 0C " +
        "C7 45 ?? 01 00 00 00 " +
        "83 78 14 10 " +
        "72 02 " +
        "8B 00 " +
        "6A 00 " +
        "68 ?? ?? ?? ?? " +
        "50 " +
        "FF 35 " + hwndHex +
        "FF 15 ?? ?? ?? ?? ";
    var replaceOffset = 29;

    offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    var newCode =
        "90 90 " +
        "33 C0 90 90 90 " +
        "90 " +
        "90 90 90 90 90 90 " +
        "90 90 90 90 90 90 ";

    pe.replaceHex(offset + replaceOffset, newCode);

    return true;
}

function IgnoreQuestErrors_()
{
    return (
        pe.getDate() >= 20180319 ||
        (pe.getDate() >= 20180300 && IsSakray()) ||
        (pe.getDate() >= 20171115 && IsZero()));
}
