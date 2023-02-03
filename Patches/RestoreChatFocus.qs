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

function RestoreChatFocus()
{
    var code =
        "83 3D ?? ?? ?? ?? 01 " +
        "75 ?? " +
        "6A 00 " +
        getEcxWindowMgrHex() +
        "E8 ?? ?? ?? ?? " +
        "EB ";

    var patchOffset = 9;

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in step 1 - pattern not found";
    }

    code =
        "90 90 " +
        "90 90 90 90 90" +
        "90 90 90 90 90";
    pe.replaceHex(offset + patchOffset, code);

    return true;
}
