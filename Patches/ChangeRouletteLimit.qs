//
// Copyright (C) 2021-2023 Andrei Karas (4144)
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

function RouletteLimitChanger(tableId, varName, text, def)
{
    function convertJmp(jmpType)
    {
        if (jmpType === "jl" || jmpType === "jge")
        {
            return jmpType;
        }
        else if (jmpType === "jg")
        {
            return "jge";
        }
        else if (jmpType === "jle")
        {
            return "jl";
        }

        throw "Unknown jmp type: " + jmpType;
    }

    function setValue(tableId2, newValue, flag)
    {
        var offset = table.getRaw(tableId2);
        if (offset <= 0)
        {
            if (flag === false)
            {
                return;
            }
            throw "Table variable missing: " + tableId2;
        }
        var code = [

            [
                "83 B8 ?? ?? ?? 00 ?? " +
                "7C ?? ",
                {
                    "reg": "eax",
                    "fieldOffset": [2, 4],
                    "jmpType": "jl",
                    "jmpAddrOffset": [8, 1],
                },
            ],
            [
                "83 BA ?? ?? ?? 00 ?? " +
                "7C ?? ",
                {
                    "reg": "edx",
                    "fieldOffset": [2, 4],
                    "jmpType": "jl",
                    "jmpAddrOffset": [8, 1],
                },
            ],
            [
                "83 B9 ?? ?? ?? 00 ?? " +
                "7C ?? ",
                {
                    "reg": "ecx",
                    "fieldOffset": [2, 4],
                    "jmpType": "jl",
                    "jmpAddrOffset": [8, 1],
                },
            ],
            [
                "83 BA ?? ?? ?? 00 ?? " +
                "7D ?? ",
                {
                    "reg": "edx",
                    "fieldOffset": [2, 4],
                    "jmpType": "jge",
                    "jmpAddrOffset": [8, 1],
                },
            ],
            [
                "83 B8 ?? ?? ?? 00 ?? " +
                "7D ?? ",
                {
                    "reg": "eax",
                    "fieldOffset": [2, 4],
                    "jmpType": "jge",
                    "jmpAddrOffset": [8, 1],
                },
            ],
            [
                "83 BA ?? ?? ?? 00 ?? " +
                "7F ?? ",
                {
                    "reg": "edx",
                    "fieldOffset": [2, 4],
                    "jmpType": "jg",
                    "jmpAddrOffset": [8, 1],
                },
            ],
            [
                "83 B8 ?? ?? ?? 00 ?? " +
                "7F ?? ",
                {
                    "reg": "eax",
                    "fieldOffset": [2, 4],
                    "jmpType": "jg",
                    "jmpAddrOffset": [8, 1],
                },
            ],
            [
                "39 81 ?? ?? ?? 00 " +
                "7E ?? ",
                {
                    "reg": "ecx",
                    "fieldOffset": [2, 4],
                    "jmpType": "jle",
                    "jmpAddrOffset": [7, 1],
                },
            ],
            [
                "39 91 ?? ?? ?? 00 " +
                "7C ?? ",
                {
                    "reg": "ecx",
                    "fieldOffset": [2, 4],
                    "jmpType": "jl",
                    "jmpAddrOffset": [7, 1],
                },
            ],
            [
                "39 88 ?? ?? ?? 00 " +
                "7C ?? ",
                {
                    "reg": "eax",
                    "fieldOffset": [2, 4],
                    "jmpType": "jl",
                    "jmpAddrOffset": [7, 1],
                },
            ],
            [
                "39 88 ?? ?? ?? 00 " +
                "7D ?? ",
                {
                    "reg": "eax",
                    "fieldOffset": [2, 4],
                    "jmpType": "jge",
                    "jmpAddrOffset": [7, 1],
                },
            ],

            [
                "83 B9 ?? ?? ?? 00 ?? " +
                "BA ?? ?? ?? 00 " +
                "0F 4D C2 ",
                {
                    "reg": "ecx",
                    "fieldOffset": [2, 4],
                    "jmpType": "custom",
                    "stolenCode": [7, 8],
                },
            ],
        ];
        var obj = pe.matchAny(code, offset);
        if (obj === false)
        {
            throw "Pattern not matched";
        }
        var field = pe.fetchValue(offset, obj.fieldOffset);
        var continueAddr = pe.rawToVa(offset) + obj.code.hexlength();
        var vars;
        var data;
        if (obj.jmpType == "custom")
        {
            vars = {
                "reg": obj.reg,
                "field": field,
                "stolenCode": pe.fetchHexBytes(offset, obj.stolenCode),
                "continueAddr": continueAddr,
                "value": newValue,
            };
            data = pe.insertAsmFile("RoulletteLimit2", vars);
        }
        else
        {
            vars = {
                "reg": obj.reg,
                "field": field,
                "jmp": convertJmp(obj.jmpType),
                "continueAddr": continueAddr,
                "jmpAddr": pe.fetchRelativeValue(offset, obj.jmpAddrOffset),
                "value": newValue,
            };
            data = pe.insertAsmFile("RoulletteLimit1", vars);
        }

        pe.setJmpRaw(offset, data.free, "jmp");
    }

    var newValue = exe.getUserInput(varName, XTYPE_DWORD, _("Number Input"), text, def);
    if (newValue === def)
    {
        throw "New roulette limit is same with default value";
    }
    setValue(tableId, newValue, true);
    setValue(tableId + 1, newValue, false);
    setValue(tableId + 2, newValue, false);
    return true;
}

function ChangeRouletteGoldLimit()
{
    return RouletteLimitChanger(
        table.roulette_gold_step,
        "$rouletteGoldStep",
        _("Enter minimal gold amount for start roulette"),
        10
    );
}

function ChangeRouletteSilverLimit()
{
    return RouletteLimitChanger(
        table.roulette_silver_step,
        "$rouletteSilverStep",
        _("Enter minimal silver amount for start roulette"),
        10
    );
}

function ChangeRouletteBronzeLimit()
{
    return RouletteLimitChanger(
        table.roulette_bronze_step,
        "$rouletteBronzeStep",
        _("Enter minimal bronze amount for start roulette"),
        1
    );
}

function ChangeRouletteGoldLimit_()
{
    return pe.stringRaw("\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\\basic_interface\\roullette\\RoulletteIcon.bmp") !== -1;
}

function ChangeRouletteSilverLimit_()
{
    return pe.stringRaw("\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\\basic_interface\\roullette\\RoulletteIcon.bmp") !== -1;
}

function ChangeRouletteBronzeLimit_()
{
    return pe.stringRaw("\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\\basic_interface\\roullette\\RoulletteIcon.bmp") !== -1;
}
