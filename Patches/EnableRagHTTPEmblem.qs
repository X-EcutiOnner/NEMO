//
// Copyright (C) 2020  CH.C
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

function EnableRagHTTPEmblem()
{
    var code =
        " 55" +
        " 8B EC" +
        " 83 C1 6C" +
        " 5D" +
        " E9";

    var modPos = 5;
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offset + modPos, 0x3C);

    return true;
}

function EnableRagHTTPEmblem_()
{
    return (pe.halfStringVa(".?AVCEmblemDataDownloadAsyncWork@@") | pe.halfStringVa("CDClient.dll")) !== -1;
}
