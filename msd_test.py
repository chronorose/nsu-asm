import os

task = "java -jar ~/Downloads/rars/rars.jar task16.asm pa "
test = "1-input"

os.system(task + test)
with open(test) as input:
    file = input.readlines()
    file.sort()
    with open(test + ".sorted") as sorted:
        for inp, srtd in zip(file, sorted):
            assert inp == srtd
