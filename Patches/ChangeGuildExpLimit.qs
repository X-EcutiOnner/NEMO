//
// Copyright (C) 2018-2022  Andrei Karas (4144)
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
// ##############################################################
// # Purpose: Change exp guild limit from 50 to custom value in #
// # UIGuildPositionManageWnd_virt136                           #
// ##############################################################

function ChangeGuildExpLimit()
{
    var code =
        "85 C0 " +
        "78 09 " +
        "83 F8 32 " +
        "0F 8E ?? ?? 00 00 " +
        "6A 00 " +
        "6A 32 " +
        "68 9E 0D 00 00 " +
        "E8 ";
    var limitOffset = 6;

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace("78 09 ", "78 05 ");
        code = code.replace("0F 8E ?? ?? 00 00 ", " 7E ?? ");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in step 1 - check limit pattern not found";
    }

    var limit = exe.getUserInput("$guildExpLimit", XTYPE_BYTE, _("Number Input"), _("Enter new guild exp limit (0-100, default is 50):"), 50, 0, 100);
    if (limit === 50)
    {
        return "Patch Cancelled - New value is same as old";
    }

    pe.replaceByte(offset + limitOffset, limit);

    return true;
}
