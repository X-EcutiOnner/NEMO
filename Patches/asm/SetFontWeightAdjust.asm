; Copyright (C) 2021-2022 Andrei Karas (4144)
;
; Patch is licensed under a
; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
;
; You should have received a copy of the license along with this
; work. If not, see <http://creativecommons.org/licenses/by-nc-nd/4.0/>.
;

%include CreateFontA_params

mov eax, dword ptr [esp + weight]
add eax, value
cmp eax, 0
js tooSmall
cmp eax, 1000
jle normal

tooBig:
mov eax, 1000
jmp normal

tooSmall:
mov eax, 1

normal:
mov dword ptr [esp + weight], eax
