//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2021-2023 Andrei Karas (4144)
// Copyright (C) 2021 X-EcutiOnner (xex.ecutionner@gmail.com)
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

function DisableAdventureAgent()
{
    var btn_name = "\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\\basic_interface\\mesbtn_partymaster_01.bmp";
    var offses = pe.stringVa(btn_name);

    if (offses === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var strHex = offses.packToHex(4);

    var code =
        "C6 81 ?? ?? ?? 00 00 " +
        "FF 90 ?? ?? ?? 00 " +
        "8B 8F ?? ?? ?? 00 " +
        "6A 00 " +
        "68 " + strHex +
        "E8 ?? ?? ?? ?? " +
        "8B 8F ?? ?? ?? 00 " +
        "6A 01 " +
        "68 ?? ?? ?? ?? " +
        "E8 ?? ?? ?? ?? " +
        "8B 8F ?? ?? ?? 00 " +
        "6A 02 " +
        "68 ?? ?? ?? ?? " +
        "E8 ?? ?? ?? ?? " +
        "68 BA 0D 00 00 " +
        "E8 ?? ?? ?? ?? " +
        "8B 8F ?? ?? ?? 00 " +
        "83 C4 04 " +
        "50 " +
        "E8 ?? ?? ?? ?? " +
        "33 C0 " +
        "E9 ?? ?? ?? 00 ";
    var nopStart = 0;
    var nopEnd = 92;

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "C6 81 ?? ?? ?? 00 00 " +
            "FF 90 ?? ?? ?? 00 " +
            "8B 8F ?? ?? ?? 00 " +
            "6A 00 " +
            "6A 00 " +
            "68 " + strHex +
            "E8 ?? ?? ?? ?? " +
            "8B 8F ?? ?? ?? 00 " +
            "6A 00 " +
            "6A 01 " +
            "68 ?? ?? ?? ?? " +
            "E8 ?? ?? ?? ?? " +
            "8B 8F ?? ?? ?? 00 " +
            "6A 00 " +
            "6A 02 " +
            "68 ?? ?? ?? ?? " +
            "E8 ?? ?? ?? ?? " +
            "68 BA 0D 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "8B 8F ?? ?? ?? 00 " +
            "83 C4 04 " +
            "50 " +
            "E8 ?? ?? ?? ?? " +
            "33 C0 " +
            "E9 ?? ?? ?? 00 ";
        nopStart = 0;
        nopEnd = 98;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    pe.setNopsRange(offset + nopStart, offset + nopEnd);

    return true;
}

function DisableAdventureAgent_()
{
    var btn_name = "\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\\basic_interface\\mesbtn_partymaster_01.bmp";

    return pe.stringRaw(btn_name) !== -1;
}
