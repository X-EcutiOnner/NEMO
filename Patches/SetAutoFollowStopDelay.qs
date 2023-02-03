//
// Copyright (C) 2018  CH.C
// Copyright (C) 2021-2023 Andrei Karas (4144)
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

function SetAutoFollowStopDelay()
{
    var value = exe.getUserInput("$followStopDelay", XTYPE_DWORD, _("Number Input"), _("Enter the new autofollow stop delay in ms."), 10000, 0, 0x7fffffff);
    if (value === 10000)
    {
        return "New delay is same with old value";
    }

    var oldDisappearTime = table.getHex4(table.m_oldDisappearTime);

    var code =
        "FF ?? " +
        "2B 05 " + oldDisappearTime +
        "3D 10 27 00 00 ";
    var delayOffset = [9, 4];
    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        return "Auto follow delay code not found.";
    }

    if (offsets.length > 2)
    {
        return "Found too much auto follow delay code.";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        pe.setValue(offsets[i], delayOffset, value);
    }

    return true;
}
