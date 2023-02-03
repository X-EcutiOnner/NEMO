; Copyright (C) 2018-2023 Andrei Karas (4144)
;
; Patch is licensed under a
; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
;
; You should have received a copy of the license along with this
; work. If not, see <http://creativecommons.org/licenses/by-nc-nd/4.0/>.
;

push eax
%insasm pushReg
push maxHairs
%inshex varCode
mov ecx, esi

call vectorCall

push esi
push edi
push ebx
push ecx

mov ecx, maxHairs
mov eax, [esi]
mov edi, tableStrings

loop:
mov [eax], edi
add eax, 4
add edi, 4
dec ecx
jnz loop

pop ecx
pop ebx
pop edi
pop esi

%inshex varCode2

jmp jmpAddr
