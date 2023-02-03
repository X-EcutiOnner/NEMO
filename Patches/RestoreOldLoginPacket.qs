//
// Copyright (C) 2017-2023 Andrei Karas (4144)
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

function LoginPacketSend_match()
{
    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        throw "Failed in Step 1a - " + LANGTYPE[0];
    }

    var passwordEncryptHex = table.getHex4(table.g_passwordEncrypt);

    var code =
        "80 3D " + passwordEncryptHex + " 00 " +
        "0F 85 ?? ?? ?? 00 " +
        "8B ?? " + LANGTYPE +
        "?? ?? " +
        "0F 84 ?? ?? 00 00 " +
        "83 ?? 12 " +
        "0F 84 ?? ?? 00 00 " +
        "83 ?? 0C " +
        "0F 84 ?? ?? 00 00 ";
    var nopRangeOffset = [19, 45];
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        throw "Pattern not found";
    }

    var obj = hooks.createHookObj();

    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";
    obj.endHook = false;

    obj.offset = offset;
    obj.nopRangeOffset = nopRangeOffset;

    return obj;
}

function RestoreOldLoginPacket()
{
    var obj = LoginPacketSend_match();
    pe.setNopsRange(obj.offset + obj.nopRangeOffset[0], obj.offset + obj.nopRangeOffset[1]);

    return true;
}

function RestoreOldLoginPacket_()
{
    return (pe.getDate() > 20171019 && IsZero()) || pe.getDate() >= 20181114;
}
