//
// Copyright (C) 2018  CH.C
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

function DefaultBrowserInCashshop()
{
    var offset = pe.stringRaw("iexplore.exe");

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found.";
    }

    var offsets = pe.findCodes(" 50 68" + pe.rawToVa(offset).packToHex(4));

    if (offsets.length === 0)
    {
        return "Failed in Step 2 - String reference missing.";
    }

    var code =
        " 6A 00" +
        " 50" +
        " 90 90 90";

    for (var i = 0; i < offsets.length; i++)
    {
        offset = offsets[i];
        pe.replaceHex(offset, code);
    }

    return true;
}

function DefaultBrowserInCashshop_()
{
    return pe.stringVa("iexplore.exe") !== -1;
}
