j actual_testing
.include "testLib.asm"
.include "str_lib.asm"
.include "strstrTestLib.asm"
actual_testing:
FUNC strstr, "strstr"
OK 0 "abcde" "a"
OK 0 "done" "on"
OK 0 "kek" "ek"
NONE "Kek" "e"
NONE "kek" "kek"
DONE
exit 0
