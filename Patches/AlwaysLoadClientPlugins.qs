//
// Copyright (C) 2017  Secret
// Copyright (C) 2022-2023 Andrei Karas (4144)
//
// This script is free software: you can redistribute it and/or modify
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
// Purpose: To make the client load client plug-in libraries regardless of its sound settings.
// Author: Secret <secret@rathena.org>
// To-do: See if it has any undesirable side effect

function AlwaysLoadClientPlugins()
{
    var soundModeHex = pe.stringHex4("SOUNDMODE");

    var code =
        " 68 ?? ?? ?? ??" +
        " 8D 45 ??" +
        " 50" +
        " 6A 00" +
        " 68 " + soundModeHex;
    var soundModeOffset = 1;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 68 ?? ?? ?? ??" +
            " 8D 45 ??" +
            " C7 45 ?? 04 00 00 00 " +
            " 50" +
            " 6A 00" +
            " 68 " + soundModeHex;
        soundModeOffset = 1;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "68 ?? ?? ?? ?? " +
            "8D 4D ?? " +
            "51 " +
            "6A 00 " +
            "68 " + soundModeHex;
        soundModeOffset = 1;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 2 - Argument pushes for call to RegQueryValueEx not found";
    }

    var soundMode = pe.fetchHex(offset + soundModeOffset, 4);

    code =
        " 8D 40 04" +
        " 49" +
        " 75 ??" +
        " 39 0D" + soundMode +
        " 0F 84";
    var jmpOffset = 12;
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 8D 40 04" +
            " C7 40 FC 00 00 00 00" +
            " 83 E9 01" +
            " 75 ??" +
            " 39 0D" + soundMode +
            " 0F 84";
        jmpOffset = 21;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "83 C0 04 " +
            "49 " +
            "75 ?? " +
            "33 FF " +
            "39 3D " + soundMode +
            "0F 84 ";
        jmpOffset = 14;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 3 - soundMode comparison not found";
    }

    pe.replaceHex(offset + jmpOffset, " 90".repeat(6));

    return true;
}
