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

function RemoveWrongCharFromCashShop()
{
    var offset = pe.stringVa("%d C");
    if (offset === -1)
    {
        return "Failed in Step 1 - format string not found";
    }
    var strHex = offset.packToHex(4);

    var code =
        "8B CE " +
        "50 " +
        "68 C2 01 00 00 " +
        "68 26 02 00 00 " +
        "E8 ?? ?? ?? ?? " +
        "FF B6 ?? ?? 00 00 " +
        "8D 45 ?? " +
        "68 " + strHex +
        "50 " +
        "E8 ";
    var pushOffset = 18;
    offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in step 2 - pattern not found";
    }

    code =
        "6A 00" +
        "90" +
        "90" +
        "90" +
        "90";
    pe.replaceHex(offset + pushOffset, code);

    return true;
}

function RemoveWrongCharFromCashShop_()
{
    return pe.stringRaw(".?AVUICashShopWnd@@") !== -1;
}
