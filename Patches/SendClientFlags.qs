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

function SendClientFlagsSearch(offsets2, code, clientOffset)
{
    var offsets = pe.findAll(code);
    for (var i = 0; i < offsets.length; i ++)
    {
        offsets2.push(offsets[i] + clientOffset);
    }
    return offsets2;
}

function SendClientFlags()
{
    var flags = 0;

    if (table.get(table.g_client_version) === 0)
    {
        return "g_client_version not in table";
    }
    var g_client_versionHex = table.getHex4(table.g_client_version);

    var offsets = [];

    offsets = SendClientFlagsSearch(
        offsets,
        "A1 " + g_client_versionHex,
        1
    );
    offsets = SendClientFlagsSearch(
        offsets,
        "8B 0D " + g_client_versionHex,
        2
    );
    offsets = SendClientFlagsSearch(
        offsets,
        "8B 15 " + g_client_versionHex,
        2
    );

    if (offsets.length !== 6)
    {
        return "Found wrong number of g_client_version usage";
    }

    var free = alloc.find(4);
    if (free === -1)
    {
        return "Not enough free space";
    }

    pe.insertHexAt(free, 4, flags.packToHex(4));
    var freeVaHex = pe.rawToVa(free).packToHex(4);

    for (var i = 0; i < offsets.length; i ++)
    {
        pe.replaceHex(offsets[i], freeVaHex);
    }

    storage.g_client_version = free;

    return true;
}

function SendClientFlags_apply()
{
    var flags = 0x80000000;

    if (storage.ExtendCashShop === true)
    {
        flags |= 1;
    }
    if (storage.ExtendOldCashShop === true)
    {
        flags |= 2;
    }

    patch.removePatchData(storage.g_client_version);
    pe.replaceDWord(storage.g_client_version, flags);

    return true;
}
