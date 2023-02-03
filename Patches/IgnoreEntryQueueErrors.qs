//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2020-2023 Andrei Karas (4144)
// Copyright (C) 2020-2021 X-EcutiOnner (xex.ecutionner@gmail.com)
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

function IgnoreEntryQueueErrors()
{
    var offset = pe.stringVa("Data\\Table\\EntryQueue.bex");

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var strHex = offset.packToHex(4);

    var code =
        "68 " + strHex +
        "FF 15 ?? ?? ?? ?? " +
        "8B F8 " +
        "83 FF FF " +
        "75 ?? " +
        "6A 30 " +
        "68 ?? ?? ?? ?? " +
        "68 " + strHex +
        "?? " +
        "FF 15 ?? ?? ?? ?? ";

    var replaceStartOffset = 18;
    var replaceEndOffset = 31 + 6;

    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "68 " + strHex +
            "FF 15 ?? ?? ?? ?? " +
            "8B D8 " +
            "83 FB FF " +
            "75 ?? " +
            "6A 30 " +
            "68 ?? ?? ?? ?? " +
            "68 " + strHex +
            "6A 00 " +
            "FF 15 ?? ?? ?? ?? ";

        replaceStartOffset = 18;
        replaceEndOffset = 32 + 6;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    pe.setNopsRange(offset + replaceStartOffset, offset + replaceEndOffset);

    return true;
}

function IgnoreEntryQueueErrors_()
{
    return pe.stringRaw("Load Failed") !== -1;
}
