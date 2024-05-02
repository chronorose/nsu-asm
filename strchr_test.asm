j actual_testing
.include "testLib.asm"
.include "str_lib.asm"
.include "strchrTestLib.asm"
actual_testing:
FUNC strchr, "strchr"
OK 0 "abcde" 'a'
OK 0 "done" 'o'
OK 0 "kek" 'a'
NONE "Kek" 'e'
NONE "kek" 'a'
DONE
exit 0
