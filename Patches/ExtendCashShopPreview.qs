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

function ExtendCashShopPreview()
{
    var offset1 = table.getRawValidated(table.cashShopPreviewPatch1);
    var offset2 = table.getRawValidated(table.cashShopPreviewPatch2);
    var offset3 = table.getRaw(table.cashShopPreviewPatch3);

    var flag = table.get(table.cashShopPreviewFlag);

    var code =
        "8D 8D ?? ?? ?? FF ";
    var itemInfoOffset = [2, 4];
    var stolenCodeSize = 6;

    var found = pe.match(code, offset1);
    if (found !== true)
    {
        return "Error: first pattern not found";
    }

    code =
        "83 C6 ?? ";
    var blockSizeOffset = [2, 1];
    var register = "esi";
    found = pe.match(code, offset2);

    if (found !== true)
    {
        code =
            "83 C7 ?? ";
        blockSizeOffset = [2, 1];
        register = "edi";
        found = pe.match(code, offset2);
    }

    if (found !== true)
    {
        code =
            "83 C1 ?? ";
        blockSizeOffset = [2, 1];
        register = "ecx";
        found = pe.match(code, offset2);
    }

    if (found !== true)
    {
        return "Error: second pattern not found";
    }

    var blockSize = pe.fetchValue(offset2, blockSizeOffset);

    var next;
    if (flag == 0)
    {
        code = "89 8D";
        var nextOffset = [2, 4];
        found = pe.match(code, offset3);

        if (found !== true)
        {
            return "Error: third pattern not found";
        }
        next = pe.fetchValue(offset3, nextOffset);
    }
    else
    {
        next = 0;
    }

    var stolenCode = pe.fetchHex(offset1, stolenCodeSize);
    var name;

    if (flag === 1)
    {
        name = "1";
    }
    else
    {
        name = "0";
    }
    var vars = {
        "continueItemAddr": pe.rawToVa(offset1 + stolenCodeSize),
        "itemInfo": pe.fetchValue(offset1, itemInfoOffset),
        "next": next,
        "block_size": blockSize,
        "register": register,
        "stolenCode": stolenCode,
    };

    var data = pe.insertAsmFile("ExtendCashShopPreview_" + name, vars);

    pe.setJmpRaw(offset1, data.free);

    pe.setValue(offset2, blockSizeOffset, blockSize + 4 + 2);

    storage.ExtendCashShop = true;

    return true;
}

function ExtendCashShopPreview_cancel()
{
    storage.ExtendCashShop = false;
    return true;
}

function ExtendCashShopPreview_()
{
    return pe.stringRaw(".?AVUIPreviewEquipWnd@@") !== -1;
}
