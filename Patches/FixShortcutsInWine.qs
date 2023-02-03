//
// Copyright (C) 2018-2023 Andrei Karas (4144)
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

function FixShortcutsInWine()
{
    var code =
        "0F 57 C0 " +
        "66 0F 13 45 ?? " +
        "8B 55 ?? " +
        "85 D2 " +
        "0F 8F ?? ?? ?? 00 " +
        "83 BE ?? ?? ?? 00 00 " +
        "0F 85 ?? ?? ?? 00 " +
        "81 FF ?? ?? 00 00 " +
        "0F 87 ?? ?? ?? 00 " +
        "0F B6 87 ";
    var patchOffset = 13;
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in step 1 - pattern not found";
    }

    pe.replaceHex(offset + patchOffset, "90 90 90 90 90 90");
    return true;
}

function FixShortcutsInWine_()
{
    return (pe.getDate() > 20190306 && IsSakray()) || pe.getDate() >= 20190401;
}
