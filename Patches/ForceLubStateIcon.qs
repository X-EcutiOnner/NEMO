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
//

function ForceLubStateIcon()
{
    var offset = pe.stringVa("GetEFSTImgFileName");
    if (offset === -1)
    {
        return "Failed in Step 1 - Reference String Missing";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    var code =
        "83 FB 04 " +
        "0F 87 ?? ?? ?? ?? " +
        "FF 24 9D ";
    var patchOffset = 3;

    offset = pe.find(code, offset, offset + 0x80);
    if (offset === -1)
    {
        return "Failed in Step 3";
    }

    pe.replaceHex(offset + patchOffset, " 90 E9");

    return true;
}
