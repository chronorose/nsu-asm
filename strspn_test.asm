j actual_testing
.include "testLib.asm"
.include "str_lib.asm"
.include "strspnTestLib.asm"
actual_testing:
FUNC strspn, "strspn"
OK 6  "strspn" "strpn"
OK 1 "abcde" "a"
OK 0 "done" "o"
OK 0 "kek" "a'"
DONE
exit 0