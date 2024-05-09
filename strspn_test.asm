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
FUNC strcspn "strcspn"
OK 0 " " " "
OK 1 "s " " "
OK 3 "keks" " st"
DONE
exit 0
