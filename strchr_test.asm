j actual_testing
.include "str_lib.asm"
.include "testLib.asm"

actual_testing:
FUNC strchr "strchr"
OK 0 "abcde" 'a'
OK 0 "done" 'o'
OK 0 "kek" 'a'
#NONE "Kek" 'e'
exit 0
