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

function ChangeMaxItemCount(value)
{
    var newString = "/" + value;

    var free = alloc.find(newString.length);
    if (free === -1)
    {
        return "Failed in Step 1 - Not enough free space";
    }

    pe.insertAt(free, newString.length, newString);

    var code =
        " 6A 64" +
        " 8D 45 ??" +
        " 68 ?? ?? ?? ??";

    var offsets = pe.findAll(code);

    if (offsets.length === 0)
    {
        code =
            " 83 C1 64" +
            " 51" +
            " 68 ?? ?? ?? 00";
        offsets = pe.findAll(code);
    }

    if (offsets.length === 0)
    {
        return "Failed in Step 2 - function missing";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        var offset2 = offsets[i] + code.hexlength();
        pe.replaceDWord(offset2 - 4, pe.rawToVa(free));
    }

    return true;
}

function SetMaxItemCount()
{
    return ChangeMaxItemCount(input.getString(
        "$MaxItemCount",
        _("Number Input"),
        _("Enter the max item count (0-999)"),
        100,
        3
    ));
}
