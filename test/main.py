from collections import defaultdict

def test():
    mydic = defaultdict(list)

    for i in range(100):
        mydic[i].append(i)

    print(mydic)
