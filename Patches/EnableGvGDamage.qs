//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2021-2023 Andrei Karas (4144)
// Copyright (C) 2018-2021 X-EcutiOnner (xex.ecutionner@gmail.com)
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

function EnableGvGDamage()
{
    var code =
        getEcxSessionHex() +
        "E8 ?? ?? ?? ?? " +
        "85 C0 " +
        "75 0E " +
        getEcxSessionHex() +
        "E8 ?? ?? ?? ?? " +
        "85 C0 " +
        "74 14 " +
        "6A 07 " +
        getEcxSessionHex() +
        "E8 ?? ?? ?? ?? " +
        "85 C0 " +
        "0F 84 ?? ?? 00 00 ";
    var nopsStart = 0;
    var nopsEnd = 48;

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

    pe.setNopsRange(offset + nopsStart, offset + nopsEnd);

    return true;
}

function EnableGvGDamage_()
{
    var code =
        getEcxSessionHex() +
        "E8 ?? ?? ?? ?? " +
        "85 C0 " +
        "75 0E " +
        getEcxSessionHex() +
        "E8 ?? ?? ?? ?? " +
        "85 C0 " +
        "74 14 " +
        "6A 07 " +
        getEcxSessionHex() +
        "E8 ?? ?? ?? ?? " +
        "85 C0 " +
        "0F 84 ?? ?? 00 00 ";

    return pe.findCode(code) !== -1;
}
