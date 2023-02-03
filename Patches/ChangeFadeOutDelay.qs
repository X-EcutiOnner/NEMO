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

function ChangeFadeOutDelay()
{
    if (table.get(table.g_renderer) === 0)
    {
        return "g_renderer not set";
    }
    var g_rendererHex = table.getHex4(table.g_renderer);

    var code =
        "8B 35 ?? ?? ?? ?? " +
        "FF D6 " +
        "8B 0D " + g_rendererHex +
        "A3 ?? ?? ?? ?? " +
        "E8 ?? ?? ?? ?? " +
        "FF D6 " +
        "2B 05 ?? ?? ?? ?? " +
        "3D ?? 00 00 00 " +
        "0F 83 ?? ?? 00 00 ";
    var dwFadeStartOffset1 = 15;
    var dwFadeStartOffset2 = 28;
    var fadeOutDelayOffset1 = 33;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "8B 35 ?? ?? ?? ?? " +
            "83 C4 ?? " +
            "FF D6 " +
            "8B 0D " + g_rendererHex +
            "A3 ?? ?? ?? ?? " +
            "E8 ?? ?? ?? ?? " +
            "FF D6 " +
            "2B 05 ?? ?? ?? ?? " +
            "3D ?? 00 00 00 " +
            "0F 83 ?? ?? 00 00 ";
        dwFadeStartOffset1 = 18;
        dwFadeStartOffset2 = 31;
        fadeOutDelayOffset1 = 36;
        offset = pe.findCode(code);
    }

    var addr1 = offset;
    if (offset === -1)
    {
        return "Failed in step 1 - pattern not found";
    }

    var dwFadeStart = pe.fetchDWord(offset + dwFadeStartOffset1);
    if (dwFadeStart !== pe.fetchDWord(offset + dwFadeStartOffset2))
    {
        return "Failed in step 1 - found different dwFadeStart";
    }
    var fadeOutDelay = pe.fetchDWord(offset + fadeOutDelayOffset1);
    if (fadeOutDelay !== 0xff)
    {
        return "Failed in step 1 - found wrong fade out delay: " + fadeOutDelay;
    }

    code =
        "8B 0D " + g_rendererHex +
        "E8 ?? ?? ?? ?? " +
        "FF D6 " +
        "2B 05 " + dwFadeStart.packToHex(4) +
        "3D ?? 00 00 00 " +
        "0F 82 ?? ?? FF FF ";
    var fadeOutDelayOffset2 = 20;

    offset = pe.find(code, addr1, addr1 + 0xc0);
    if (offset === -1)
    {
        return "Failed in step 2 - pattern not found";
    }
    var addr2 = offset;

    code =
        "FF 15 ?? ?? ?? ?? " +
        "2B 05 " + dwFadeStart.packToHex(4) +
        "5E " +
        "3D ?? 00 00 00 " +
        "73 ?? " +
        "B9 ?? 00 00 00 " +
        "2B C8 " +
        "A1 " + g_rendererHex +
        "C1 E1 18 " +
        "51 ";
    var fadeOutDelayOffset3 = 14;
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "FF D7 " +
            "2B 05 " + dwFadeStart.packToHex(4) +
            "5F " +
            "5E " +
            "3D ?? 00 00 00 " +
            "73 ?? " +
            "BA ?? 00 00 00 " +
            "2B D0 " +
            "A1 " + g_rendererHex +
            "8B 48 ?? " +
            "C1 E2 18 " +
            "52 ";
        fadeOutDelayOffset3 = 11;
        offset = pe.findCode(code);
    }

    var addr3 = offset;
    if (offset === -1)
    {
        return "Failed in step 3 - pattern not found";
    }

    var delay = exe.getUserInput("$warpFadeOutDelay", XTYPE_DWORD, _("Number Input"), _("Enter new fadeout delay in ms (0-255, 0 - disable, default is 255):"), 255, 0, 255);
    if (delay === 255)
    {
        return "Patch Cancelled - New value is same as old";
    }

    pe.replaceHex(addr1 + fadeOutDelayOffset1, delay.packToHex(4));

    pe.replaceHex(addr2 + fadeOutDelayOffset2, delay.packToHex(4));

    pe.replaceHex(addr3 + fadeOutDelayOffset3, delay.packToHex(4));

    return true;
}
