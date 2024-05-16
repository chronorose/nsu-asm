import collections

def char_at(string, d):
    if len(string) <= d:
        return -1
    else:
        return ord(string[d])

def msd(string_list, lo, hi, d):
    if hi <= lo:
        return
    count = [0] * (256 + 1)
    temp = collections.defaultdict(str)
    for i in range(lo, hi + 1):
        c = char_at(string_list[i], d)
        count[c + 2] += 1
    for r in range(256):
        count[r + 1] += count[r]
    for i in range(lo, hi + 1):
        c = char_at(string_list[i], d)
        temp[count[c + 1]] = string_list[i]
        count[c + 1] += 1
    for i in range(lo, hi + 1):
        string_list[i] = temp[i - lo]

    for r in range(256):
        msd(string_list, lo + count[r], lo + count[r + 1] - 1, d + 1)

string_list = ["ok", "aaa", "abaaaaaaaaaa", "ac", "hohohihi"]
msd(string_list, 0, len(string_list) - 1, 0)
print(string_list)
