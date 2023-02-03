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

function RestoreAutoFollow()
{
    var CGameMode_ProcessAutoFollow = table.get(table.CGameMode_ProcessAutoFollow);
    var onUpdateOffset = table.getRaw(table.CGameMode_OnUpdate);
    if (onUpdateOffset === 0)
    {
        return "CGameMode_OnUpdate address not found";
    }
    if (CGameMode_ProcessAutoFollow === 0)
    {
        return "CGameMode_ProcessAutoFollow not found";
    }

    var code =
        "8B 0D ?? ?? ?? ?? " +
        "68 E8 03 00 00 " +
        "8B 01 " +
        "FF 10 " +
        "8B CB " +
        "E8 ?? ?? ?? ?? " +
        "8B B3 ?? ?? ?? 00 " +
        "3B B3 ?? ?? ?? 00 " +
        "0F 84 ?? ?? ?? 00 " +
        "FF D7 " +
        "FF D7 ";
    var patchOffset = 17;
    var inputOffset = [18, 4];
    var gameModeReg = "ebx";

    var offset = pe.find(code, onUpdateOffset, onUpdateOffset + 0x150);
    if (offset === -1)
    {
        code =
            "8B 0D ?? ?? ?? ?? " +
            "68 E8 03 00 00 " +
            "8B 01 " +
            "FF 10 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B 0D ?? ?? ?? ?? " +
            "E8 ?? ?? ?? ?? " +
            "84 C0 " +
            "0F 84 ?? ?? ?? 00 ";
        patchOffset = 17;
        inputOffset = [18, 4];
        gameModeReg = "esi";

        offset = pe.find(code, onUpdateOffset, onUpdateOffset + 0x150);
    }

    if (offset === -1)
    {
        code =
            "8B 0D ?? ?? ?? ?? " +
            "68 E8 03 00 00 " +
            "8B 01 " +
            "FF 10 " +
            "8B CB " +
            "E8 ?? ?? ?? ?? " +
            "8B B3 ?? ?? ?? 00 " +
            "3B B3 ?? ?? ?? 00 " +
            "0F 84 ?? ?? ?? 00 " +
            "?? ?? ?? ?? " +
            "FF D7 " +
            "FF D7 ";
        patchOffset = 17;
        inputOffset = [18, 4];
        gameModeReg = "ebx";

        offset = pe.find(code, onUpdateOffset, onUpdateOffset + 0x150);
    }

    if (offset === -1)
    {
        code =
            "83 7E 14 00 " +
            "0F 84 ?? ?? ?? 00 " +
            "8B 0D ?? ?? ?? ?? " +
            "E8 ?? ?? ?? ?? " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B 0D ?? ?? ?? ?? " +
            "E8 ?? ?? ?? ?? " +
            "84 C0 " +
            "0F 84 ?? ?? ?? 00 ";
        patchOffset = 23;
        inputOffset = [24, 4];
        gameModeReg = "esi";

        offset = pe.find(code, onUpdateOffset, onUpdateOffset + 0x150);
    }

    if (offset === -1)
    {
        return "Pattern not found";
    }

    var CGameMode_ProcessInput = pe.fetchRelativeValue(offset, inputOffset);

    var vars = {
        "gameModeReg": gameModeReg,
        "CGameMode_ProcessInput": CGameMode_ProcessInput,
    };

    var data = pe.insertAsmFile("", vars);

    pe.setJmpRaw(offset + patchOffset, data.free, "call");

    return true;
}

function RestoreAutoFollow_()
{
    return IsZero();
}
