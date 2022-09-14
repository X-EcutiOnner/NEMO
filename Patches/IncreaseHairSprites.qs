//
// Copyright (C) 2018-2022  Andrei Karas (4144)
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
//####################################################
//# Purpose: Extend hard-coded hair style table and  #
//#          change limit to hair styles             #
//####################################################

function IncreaseHairSprites()
{
    var maxHairs = 100;
    var bytesPerString = 4;
    var bufSize = maxHairs * bytesPerString;

    consoleLog("Search for spr/act string");
    var code = "\\\xB8\xD3\xB8\xAE\xC5\xEB\\%s\\%s_%s.%s"; // "\머리통\%s\%s_%s.%s"
    var offset = pe.stringRaw(code);

    if (offset === -1)
        return "Failed in step 1 - string not found";

    consoleLog("Search string reference");
    offset = pe.findCode("68" + pe.rawToVa(offset).packToHex(4));
    if (offset === -1)
        return "Failed in step 1 - string reference missing";

    consoleLog("Search normal jobs hair limit");
    // offset bit after hair checks
    var refOffset = offset;

    code =
        "85 C0" +             // 0 test eax, eax
        "78 05" +             // 2 js short A
        "83 F8 ??" +          // 4 cmp eax, 1Dh
        "7E 06" +             // 7 jle short B
        "C7 06 ?? 00 00 00";  // 9 mov dword ptr [esi], 0Dh
    var addNops = "";
    var valueOffset = 6;
    var assignOffset = 9;
    var newclient = 0;

    offset = pe.find(code, refOffset - 0x200, refOffset);
    if (offset === -1)
    {
        code =
            "85 C9" +              // 0 test ecx, ecx
            "78 05" +              // 2 js short A
            "83 F9 ??" +           // 4 cmp ecx, 21h
            "?? ??" +              // 7 jle short B
            "C7 00 ?? 00 00 00 " + // 9 mov dword ptr [eax], 21h
            "B9 ?? 00 00 00";      // 15 mov ecx, 21h
        addNops = " 90 90 90 90 90"
        valueOffset = 6;
        assignOffset = 9;
        newclient = 1;

        offset = pe.find(code, refOffset - 0x200, refOffset);
    }
    if (offset === -1)
        return "Failed in step 2 - hair limit missing";

    pe.replaceHex(offset + assignOffset, "90 90 90 90 90 90" + addNops);  // removing hair style limit assign

    consoleLog("Search doram jobs hair limit");
    if (!newclient)
    {
        code =
            "8B 06 " +                    // 0 mov eax, [esi]
            "75 ?? " +                    // 2 jnz short loc_8D08A9
            "83 F8 01 " +                 // 4 cmp eax, 1
            "7C 05 " +                    // 7 jl short loc_8D0840
            "83 F8 ?? " +                 // 9 cmp eax, 7
            "7C 06 " +                    // 12 jl short loc_8D0846
            "C7 06 ?? 00 00 00 ";         // 14 mov dword ptr [esi], 6
        var assignOffset = 14;
        var valueOffset = 11;
    }
    else
    {
        code =
            "8B 08 " +                    // 0 mov ecx, [eax]
            "75 ?? " +                    // 2 jnz short loc_8D08A9
            "83 F9 01 " +                 // 4 cmp ecx, 1
            "7C 05 " +                    // 7 jl short loc_8D0840
            "83 F9 ?? " +                 // 9 cmp ecx, 0Bh
            "7C ?? " +                    // 12 jl short loc_8D0846
            "C7 00 ?? 00 00 00 " +        // 14 mov dword ptr [eax], 0A
            "B9 ?? 00 00 00";             // 20 mov ecx, 0Ah
        var assignOffset = 14;
        var valueOffset = 11;
    }

    offset = pe.find(code, refOffset - 0x200, refOffset);
    if (offset === -1)
        return "Failed in step 3 - doram hair limit missing";

    pe.replaceHex(offset + assignOffset, "90 90 90 90 90 90" + addNops);  // removing hair style limit assign

    consoleLog("Search string \"2\" \"3\" \"4\"");
    code =
        "32 00" + // "2"
        "00 00" + //
        "33 00" + // "3"
        "00 00" + //
        "34 00" + // "4"
        "00 00";  //
    offset = pe.find(code);
    if (offset === -1)
        return "Failed in step 4 - string '2' missing";

    var str2Offset = pe.rawToVa(offset);

    consoleLog("Search male hair table allocations in CSession::InitPcNameTable");
    if (!newclient)
    {
        code =
            "50 " +                                        // 0 push eax
            "6A ?? " +                                     // 1 push 1Eh
            "C7 45 F0 " + str2Offset.packToHex(4) + " " +  // 3 mov dword ptr [ebp+A], offset "2"
            "E8 ?? ?? ?? ?? " +                            // 10 call vector__alloc_mem_and_set_pointer
            "8B 06 " +                                     // 15 mov eax, [esi]
            "C7 00 " + str2Offset.packToHex(4);            // 17 mov dword ptr [eax], offset "2"
        var patchOffset = 0;  // from this offset code will be patched
        var callOffset = [11, 4];  // in this offset relative call address
        var fetchOffset = 3;  // copy into own code from this address
        var fetchSize = 7;    // copy this N bytes into own code
    }
    else
    {
        code =
            "50 " +                                        // 0 push eax
            "56 " +                                        // 1 push esi
            "6A ?? " +                                     // 2 push 21h
            "8B CE " +                                     // 4 mov ecx,esi
            "E8 ?? ?? ?? ?? " +                            // 6 call vector__alloc_mem_and_set_pointer
            "8B 06 " +                                     // 11 mov eax, [esi]
            "C7 45 F0 " + str2Offset.packToHex(4) + " " +  // 13 mov dword ptr [ebp+A], offset "2"
            "C7 00 " + str2Offset.packToHex(4);            // 20 mov dword ptr [eax], offset "2"
        var patchOffset = 0;  // from this offset code will be patched
        var callOffset = [7, 4];  // in this offset relative call address
        var fetchOffset = 13;  // copy into own code from this address
        var fetchSize = 7;    // copy this N bytes into own code
    }

    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
        return "Failed in step 5 - hair table not found";
    if (offsets.length !== 1)
        return "Failed in step 5 - found wrong number of hair tables: " + offsets.length;

    var tableCodeOffset = offsets[0];
    var vectorCallAddr = pe.fetchRelativeValue(tableCodeOffset, callOffset);
    var varCode = pe.fetchHex(tableCodeOffset + fetchOffset, fetchSize);
    patchOffset = tableCodeOffset + patchOffset;

    consoleLog("Allocate strings with hair id");
    var free = alloc.find(bufSize);
    if (free === -1)
        return "Failed in step 6 - not enough free space";
    var data = "";
    for (var i = 0; i < maxHairs; i++)
    {
        data = data + str2Hex(i, bytesPerString);
    }
    if (data.hexlength() !== bufSize)
        return "Failed in step 6 - wrong allocated buffer";

    pe.insertHexAt(free, bufSize, data);
    var tableStrings = pe.rawToVa(free);  // index = id * bytesPerString

    consoleLog("Search female hair table and location for jump");
    if (!newclient)
    {
        code =
            "8B 06" +                 // 0 mov eax, [esi]
            "8D B7 ?? ?? 00 00" +     // 2 lea esi, [edi+CSession.normal_job_hair_sprite_array_F]
            "C7 40 ?? ?? ?? ?? ??" +  // 8 mov dword ptr [eax+74h], offset a29
            "8D 45 ??" +              // 15 lea eax, [ebp+var_10]
            "50" +                    // 18 push eax
            "6A ?? " +                // 19 push 1Eh
            "8B CE " +                // 21 mov ecx, esi
            "E8 ?? ?? ?? ?? ";        // 23 call vector__alloc_mem_and_set_pointer
        var patchOffset2 = 18;   // from this offset code will be patched
        var callOffset2 = [24, 4];    // in this offset relative call address
        var pushReg = "";

        offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);
    }
    else
    {
        code =
            "8B 06" +                          // 0 mov eax, [esi]
            "8D B7 ?? ?? 00 00" +              // 2 lea esi, [edi+CSession.normal_job_hair_sprite_array_F]
            "8B CE " +                         // 8 mov ecx, esi
            "C7 80 ?? ?? ?? ?? ?? ?? ?? ??" +  // 10 mov dword ptr [eax+80h], offset a32
            "8D 45 ??" +                       // 20 lea eax, [ebp+var_10]
            "50" +                             // 23 push eax
            "56 " +                            // 24 push esi
            "6A ?? " +                         // 25 push 1Eh
            "E8 ?? ?? ?? ?? ";                 // 27 call vector__alloc_mem_and_set_pointer
        var patchOffset2 = 23;   // from this offset code will be patched
        var callOffset2 = [28, 4];    // in this offset relative call address
        var pushReg = "push esi";

        offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);

        if (offset === -1) //newer clients
        {
            code =
                "8B 06" +                          // 0 mov eax, [esi]
                "8D B7 ?? ?? 00 00" +              // 2 lea esi, [edi+CSession.normal_job_hair_sprite_array_F]
                "8B CE " +                         // 8 mov ecx, esi
                "C7 40 ?? ?? ?? ?? ??" +           // 10 mov dword ptr [eax+7Ch], offset a31
                "8D 45 ??" +                       // 17 lea eax, [ebp+var_10]
                "50" +                             // 20 push eax
                "56 " +                            // 21 push esi
                "6A ?? " +                         // 22 push 1Eh
                "E8 ?? ?? ?? ?? ";                 // 24 call vector__alloc_mem_and_set_pointer
            patchOffset2 = 20;   // from this offset code will be patched
            callOffset2 = [25, 4];    // in this offset relative call address
            pushReg = "push esi";

            offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);
        }
    }

    if (offset === -1)
        return "Failed in step 7 - jump location not found";

    var tableCodeOffset2 = offset;
    var vectorCallAddr2 = pe.fetchRelativeValue(tableCodeOffset2, callOffset2);
    patchOffset2 = tableCodeOffset2 + patchOffset2;

    if (vectorCallAddr !== vectorCallAddr2)
        return "Failed in step 7 - vector call functions different";

    consoleLog("Normal job male hair style table loader patch");
    var vars = {
        "pushReg": pushReg,
        "maxHairs": maxHairs,
        "varCode": varCode,
        "varCode2": "",
        "vectorCall": vectorCallAddr,
        "tableStrings": tableStrings,
        "jmpAddr": pe.rawToVa(offset)
    }
    pe.replaceAsmFile(patchOffset, "", vars);

    consoleLog("Search male doram hair table allocations in CSession::InitPcNameTable");
    if (!newclient)
    {
        code =
            "8B 06 " +                    // 0 mov eax, [esi]
            "8D B7 ?? ?? ?? ?? " +        // 2 lea esi, [edi+CSession.doram_job_hair_sprite_array_M]
            "C7 40 ?? ?? ?? ?? ?? " +     // 8 mov dword ptr [eax+7Ch], offset a31
            "8D 45 ?? " +                 // 15 lea eax, [ebp+a3]
            "50 " +                       // 18 push eax
            "6A 07 " +                    // 19 push 7
            "8B CE " +                    // 21 mov ecx, esi
            "E8 ?? ?? ?? ?? " +           // 23 call std_vector_char_ptr_resize
            "8B 06 " +                    // 28 mov eax, [esi]
            "C7 45 ";                     // 30 mov [ebp+a3], offset a1_1
        var str1Offset = 33;
        var patchOffset = 18;  // from this offset code will be patched
        var callOffset = [24, 4];  // in this offset relative call address
        // no fetch code

        var offsets = pe.findCodes(code);
    }
    else
    {
        code =
            "8B 06 " +                             // 0 mov eax, [esi]
            "8D B7 ?? ?? ?? ?? " +                 // 2 lea esi, [edi+CSession.doram_job_hair_sprite_array_M]
            "8B CE " +                             // 8 mov ecx, esi
            "C7 80 ?? ?? ?? ?? ?? ?? ?? ?? " +     // 10 mov dword ptr [eax+80h], offset a31
            "8D 45 ?? " +                          // 20 lea eax, [ebp+a3]
            "50 " +                                // 23 push eax
            "56 " +                                // 24 push esi
            "6A ?? " +                             // 25 push 7
            "E8 ?? ?? ?? ?? " +                    // 27 call std_vector_char_ptr_resize
            "8B 06 " +                             // 32 mov eax, [esi]
            "C7 40 ";                              // 34 mov dword ptr [eax+4], offset a1
        var str1Offset = 37;
        var patchOffset = 23;  // from this offset code will be patched
        var callOffset = [28, 4];  // in this offset relative call address
        // no fetch code

        var offsets = pe.findCodes(code);

        if (offsets.length === 0)
        {
            code =
                "8B 06 " +                             // 0 mov eax, [esi]
                "8D B7 ?? ?? ?? ?? " +                 // 2 lea esi, [edi+CSession.doram_job_hair_sprite_array_M]
                "8B CE " +                             // 8 mov ecx, esi
                "C7 40 ?? ?? ?? ?? ??" +               // 10 mov dword ptr [eax+7Ch], offset a31
                "8D 45 ?? " +                          // 17 lea eax, [ebp+a3]
                "50 " +                                // 20 push eax
                "56 " +                                // 21 push esi
                "6A ?? " +                             // 22 push 7
                "E8 ?? ?? ?? ?? " +                    // 24 call std_vector_char_ptr_resize
                "8B 06 " +                             // 29 mov eax, [esi]
                "C7 40 ";                              // 31 mov dword ptr [eax+4], offset a1

            str1Offset = 34;
            patchOffset = 20;
            callOffset = [25, 4];

            offsets = pe.findCodes(code);
        }
    }
    if (offsets.length === 0)
        return "Failed in step 8 - doram hair table not found";
    if (offsets.length !== 1)
        return "Failed in step 8 - found wrong number of doram hair tables: " + offsets.length;

    var str1Addr = pe.vaToRaw(pe.fetchDWord(offsets[0] + str1Offset));
    if (pe.fetchUByte(str1Addr) != 0x31 || pe.fetchUByte(str1Addr + 1) != 0)
        return "Failed in step 8 - wrong constant 1 found";

    var tableCodeOffset = offsets[0];
    var vectorCallAddr = pe.fetchRelativeValue(tableCodeOffset, callOffset);
    var varCode = "";
    patchOffset = tableCodeOffset + patchOffset;

    offset = offsets[0];

    consoleLog("Normal job female hair style table loader patch");
    var vars = {
        "pushReg": pushReg,
        "maxHairs": maxHairs,
        "varCode": "",
        "varCode2": "",
        "vectorCall": vectorCallAddr2,
        "tableStrings": tableStrings,
        "jmpAddr": pe.rawToVa(offset)
    }
    pe.replaceAsmFile(patchOffset2, "", vars);

    consoleLog("Search female doram hair table and location for jump");

    if (!newclient)
    {
        code =
            "8B 06 " +                    // 0 mov eax, [esi]
            "8D B7 ?? ?? 00 00 " +        // 2 lea esi, [edi+CSession.doram_job_hair_sprite_array_F]
            "C7 40 ?? ?? ?? ?? ?? " +     // 8 mov dword ptr [eax+18h], offset a6
            "8D 45 ?? " +                 // 15 lea eax, [ebp+var_10]
            "50 " +                       // 18 push eax
            "6A 07 " +                    // 19 push 7
            "8B CE " +                    // 21 mov ecx, esi
            "E8 ?? ?? ?? ?? " +           // 23 call std_vector_char_ptr_resize
            "8B 06 " +                    // 28 mov eax, [esi]
            "C7 40 ?? ?? ?? ?? ?? " +     // 30 mov dword ptr [eax+4], offset a1
            "8B 06 " +                    // 37 mov eax, [esi]
            "8D 8F ?? ?? ?? ?? " +        // 39 lea ecx, [edi+CSession.ViewID_sprite_array]
            "C7 40 ?? ?? ?? ?? ?? " +     // 45 mov dword ptr [eax+8], offset a2
            "8B 06 " +                    // 52 mov eax, [esi]
            "C7 45 ?? ?? ?? ?? ?? " +     // 54 mov [ebp+var_10], offset "_병아리모자"
            "C7 40 ";                     // 61 mov dword ptr [eax+C], offset a3
            var str1Offset = 33;
            var patchOffset2 = 18;   // from this offset code will be patched
            var callOffset2 = [24, 4];    // in this offset relative call address
            var fetchOffset = 37;  // copy into own code from this address
            var fetchSize = 24;    // copy this N bytes into own code
    }
    else
    {
        code =
            "8B 06 " +                    // 0 mov eax, [esi]
            "8D B7 ?? ?? 00 00 " +        // 2 lea esi, [edi+CSession.doram_job_hair_sprite_array_F]
            "8B CE " +                    // 8 mov ecx, esi
            "C7 40 ?? ?? ?? ?? ?? " +     // 10 mov dword ptr [eax+18h], offset a6
            "8D 45 ?? " +                 // 17 lea eax, [ebp+var_10]
            "50 " +                       // 20 push eax
            "56 " +                       // 21 push esi
            "6A ?? " +                    // 22 push 7
            "E8 ?? ?? ?? ?? " +           // 24 call std_vector_char_ptr_resize
            "8B 06 " +                    // 29 mov eax, [esi]
            "8D 9F ?? ?? ?? ?? " +        // 31 lea ebx, [edi+CSession.ViewID_sprite_array]
            "8B CB " +                    // 37 mov ecx,ebx
            "C7 45 ?? ?? ?? ?? ??" +      // 39 mov [ebp+var_10], offset "_병아리모자"
            "C7 40 ";                     // 46 mov dword ptr [eax+4], offset a1

        var str1Offset = 49;
        var patchOffset2 = 20;   // from this offset code will be patched
        var callOffset2 = [25, 4];    // in this offset relative call address
        var fetchOffset = 31;  // copy into own code from this address
        var fetchSize = 15;    // copy this N bytes into own code
    }

    offset = pe.find(code, tableCodeOffset, tableCodeOffset + 0x150);
    if (offset === -1)
        return "Failed in step 9 - jump location not found";

    var tableCodeOffset2 = offset;
    var vectorCallAddr2 = pe.fetchRelativeValue(tableCodeOffset2, callOffset2);
    patchOffset2 = tableCodeOffset2 + patchOffset2;
    var varCode = pe.fetchHex(tableCodeOffset2 + fetchOffset, fetchSize);

    if (vectorCallAddr !== vectorCallAddr2)
        return "Failed in step 9 - vector call functions different";

    consoleLog("Doram job male hair style table loader patch");
    var vars = {
        "pushReg": pushReg,
        "maxHairs": maxHairs,
        "varCode": "",
        "varCode2": "",
        "vectorCall": vectorCallAddr,
        "tableStrings": tableStrings,
        "jmpAddr": pe.rawToVa(offset)
    }
    pe.replaceAsmFile(patchOffset, "", vars);

    consoleLog("Search location for jump");

    if (pe.getDate() > 20200325)
        var viewID = 3000;
    else
        var viewID = 2000;


    if (!newclient)
    {
        var code =
            "8B 06 " +                           // 0 mov eax, [esi]
            "C7 40 ?? ?? ?? ?? ?? " +            // 2 mov dword ptr [eax+28h], offset a10
            "8D 45 ?? " +                        // 9 lea eax, [ebp+var_10]
            "50 " +                              // 12 push eax
            "68 " + viewID.packToHex(4) + " " +  // 13 push viewID
            "E8 ";                               // 18 call std_vector_char_ptr_resize
        var jumpOffset = 9;
    }
    else
    {
        var code =
            "8B 06 " +                           // 0 mov eax, [esi]
            "C7 40 ?? ?? ?? ?? ?? " +            // 2 mov dword ptr [eax+28h], offset a10
            "8D 45 ?? " +                        // 9 lea eax, [ebp+var_10]
            "50 " +                              // 12 push eax
            "53 " +                              // 13 push ebx
            "68 " + viewID.packToHex(4) + " " +  // 14 push viewID
            "E8 ";                               // 19 call std_vector_char_ptr_resize
        var jumpOffset = 9;
    }

    offset = pe.find(code, tableCodeOffset2 + 5, tableCodeOffset2 + 0x150);
    if (offset === -1)
        return "Failed in step 10 - jump location not found";

    consoleLog("Doram job female hair style table loader patch");
    var vars = {
        "pushReg": pushReg,
        "maxHairs": maxHairs,
        "varCode": "",
        "varCode2": varCode,
        "vectorCall": vectorCallAddr2,
        "tableStrings": tableStrings,
        "jmpAddr": pe.rawToVa(offset) + jumpOffset
    }
    pe.replaceAsmFile(patchOffset2, "", vars);

    return true;
}

function str2Hex(val, sz)
{
    var str = val.toString();
    var hex = "";
    for (var i = 0; i < str.length; i++)
    {
        hex = hex + (parseInt(str[i]) + 0x30).packToHex(1);
    }
    while (hex.length < sz * 3)
        hex = hex + " 00";
    return hex;
}
