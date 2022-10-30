//
// Copyright (C) 2019  CH.C
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

function ChangeMaxPartyValue()
{
    var code =
        "68 9F 0C 00 00 ";
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    code =
        getEcxSessionHex() +
        "6A 0C " +
        "E8";
    var patchOffset = 6;
    offset = pe.find(code, offset, offset + 0x60);
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    var value = exe.getUserInput("$max_party_value", XTYPE_BYTE, _("Max Party"), _("Set Max Party Value: (Max:127, Default:12)"), "12", 1, 127);

    pe.replaceByte(offset + patchOffset, value);

    return true;
}
