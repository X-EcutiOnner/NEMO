; Copyright (C) 2021-2023 Andrei Karas (4144)
;
; Patch is licensed under a
; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
;
; You should have received a copy of the license along with this
; work. If not, see <http://creativecommons.org/licenses/by-nc-nd/4.0/>.
;

simple_strcmp:
mov al, [esi]
inc esi
inc edi
cmp al, byte ptr [edi - 1]
je simple_strcmp_same

simple_strcmp_different:
mov eax, 1
ret

simple_strcmp_same:
cmp al, 0
jnz simple_strcmp
xor eax, eax
ret
