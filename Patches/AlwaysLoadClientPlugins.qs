//
// Copyright (C) 2017  Secret
// Copyright (C) 2022  Andrei Karas (4144)
//
// This script is free software: you can redistribute it and/or modify
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
// Purpose: To make the client load client plug-in libraries regardless of its sound settings.
// Author: Secret <secret@rathena.org>
// To-do: See if it has any undesirable side effect

function AlwaysLoadClientPlugins()
{
    // Step 1a - Find SOUNDMODE
    var soundModeHex = pe.stringHex4("SOUNDMODE");

    // Step 2a - Fetch soundMode variable location
    var code =
        " 68 ?? ?? ?? ??" +    // PUSH g_soundMode
        " 8D 45 ??" +          // LEA EAX, [EBP+Type]
        " 50" +                // PUSH EAX
        " 6A 00" +             // PUSH 0
        " 68 " + soundModeHex; // PUSH "soundModeHex"
    var soundModeOffset = 1;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 68 ?? ?? ?? ??" +    // PUSH g_soundMode
            " 8D 45 ??" +          // LEA EAX, [EBP+Type]
            " C7 45 ?? 04 00 00 00 " +  // mov dword ptr [eax-X], 0
            " 50" +                // PUSH EAX
            " 6A 00" +             // PUSH 0
            " 68 " + soundModeHex; // PUSH "soundModeHex"
        soundModeOffset = 1;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "68 ?? ?? ?? ?? " +           // 0 push offset g_soundMode
            "8D 4D ?? " +                 // 5 lea ecx, [ebp+Type]
            "51 " +                       // 8 push ecx
            "6A 00 " +                    // 9 push 0
            "68 " + soundModeHex          // 11 push offset aSoundmode
        soundModeOffset = 1;
        offset = pe.findCode(code);
    }

    if (offset === -1)
        return "Failed in Step 2 - Argument pushes for call to RegQueryValueEx not found";

    var soundMode = pe.fetchHex(offset + soundModeOffset, 4);

    // Step 3a - Find soundMode comparison
    code =
        " 8D 40 04" +            // LEA EAX, [EAX+4]
        " 49" +                  // DEC ECX
        " 75 ??" +               // JNZ _loop
        " 39 0D" + soundMode +   // CMP soundMode, ECX
        " 0F 84";                // jz addr
    var jmpOffset = 12;
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 8D 40 04" +            // LEA EAX, [EAX+4]
            " C7 40 FC 00 00 00 00" + //mov dword ptr [eax-4], 0
            " 83 E9 01" + // sub ecx,1
            " 75 ??" +               // JNZ _loop
            " 39 0D" + soundMode +   // CMP g_soundMode, ECX
            " 0F 84";                // jz addr
        jmpOffset = 21;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "83 C0 04 " +                 // 0 add eax, 4
            "49 " +                       // 3 dec ecx
            "75 ?? " +                    // 4 jnz short loc_431D10
            "33 FF " +                    // 6 xor edi, edi
            "39 3D " + soundMode +        // 8 cmp g_soundMode, edi
            "0F 84 "                      // 14 jz loc_432070
        jmpOffset = 14;
        offset = pe.findCode(code);
    }

    if (offset === -1)
        return "Failed in Step 3 - soundMode comparison not found";

    pe.replaceHex(offset + jmpOffset, " 90".repeat(6));

    return true;
}
