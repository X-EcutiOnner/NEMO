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

function FixedCharJobCreate()
{
    var code =
        "B8 39 0A 00 00" +
        "66 89 85 ?? ?? ?? ??" +
        "0F B7 05 ?? ?? ?? ??" +
        "66 89 85 ?? ?? ?? ??" +
        "0F B7 05 ?? ?? ?? ??" +
        "66 89 85 ?? ?? ?? ??" +
        "A0 ?? ?? ?? ??" +
        "88 85 ?? ?? ?? ??" +
        "0F BF 05 ?? ?? ?? ??" +
        "89 85 ?? ?? ?? ??";
    var patchOffset = 51;
    var offsets = pe.findCodes(code);
    if (offsets.length === 0)
    {
        return "Search packet 0xA39 error";
    }
    if (offsets.length != 1)
    {
        return "Found too many 0xA39 packets";
    }
    var offset = offsets[0];
    var newJob = exe.getUserInput("$newJobVal", XTYPE_DWORD, _("Number Input"), _("Enter fixe job id"), 1);
    pe.replaceHex(offset + patchOffset, "B8 " + newJob.packToHex(4) + " 90 90");
    return true;
}
