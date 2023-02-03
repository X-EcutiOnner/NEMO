//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2021-2023 Andrei Karas (4144)
// Copyright (C) 2021 X-EcutiOnner (xex.ecutionner@gmail.com)
//
// Hercules is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

function FixArrowsCharset()
{
    var code =
        "A1 E7 00 " +
        "00 " +
        "A1 E8 00 " +
        "00 " +
        "A1 E6 00 " +
        "00 " +
        "A1 E9 00 " +
        "00 " +
        "A2 C7 00 " +
        "00 ";

    var offset = pe.find(code);

    if (offset === -1)
    {
        var code1 =
            "A1 E7 00 " +
            "00 " +
            "45 6E 74 65 72 00 " +
            "00 00 " +
            "53 68 69 66 74 00 " +
            "00 00 " +
            "43 74 72 6C 00    " +
            "00 00 00 ";

        var LeftLoc = 1;
        var offset1 = pe.find(code1);

        if (offset1 === -1)
        {
            return "Failed in Step 1-1 - Pattern not found";
        }

        var code2 =
            "A1 E8 00 " +
            "00 " +
            "A1 E6 00 " +
            "00 " +
            "A1 E9 00 " +
            "00 " +
            "50 72 74 53 63 00 " +
            "00 00 ";

        var UpLoc    = 1;
        var RightLoc = 5;
        var DownLoc  = 9;
        var offset2  = pe.find(code2);

        if (offset2 === -1)
        {
            return "Failed in Step 1-2b - Pattern not found";
        }

        var code3 =
            "58 00 " +
            "00 00 " +
            "59 00 " +
            "00 00 " +
            "5A 00 " +
            "00 00 " +
            "A2 C7 00 " +
            "00 ";

        var MenuLoc = 13;
        var offset3 = pe.find(code3);

        if (offset3 === -1)
        {
            return "Failed in Step 1-3b - Pattern not found";
        }

        pe.replaceHex(offset1 - 1 + LeftLoc,  "20 1B ");
        pe.replaceHex(offset2 - 1 + UpLoc,    "20 18 ");
        pe.replaceHex(offset2 - 1 + RightLoc, "20 1A ");
        pe.replaceHex(offset2 - 1 + DownLoc,  "20 95 ");
        pe.replaceHex(offset3 - 1 + MenuLoc,  "20 0F ");
    }
    else
    {
        pe.replaceHex(offset, "20 1B 00 00 20 18 00 00 20 1A 00 00 20 95 00 00 20 0F ");
    }

    return true;
}

function FixArrowsCharset_()
{
    var code =
        "A1 E8 00 " +
        "00 " +
        "A1 E6 00 " +
        "00 " +
        "A1 E9 00 " +
        "00 ";

    return pe.find(code) !== -1;
}
