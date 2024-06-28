def winding(osp, decoration):
    n = osp.base_set_cardinality()
    m = len(osp)
    w = osp.to_packed_word()
    wind = []
    k = decoration.size()
    for i in range(n):
        if w[i] == w[(i+1)%n]:
            wind.append(0)
        if w[i] < w[(i+1)%n]:
            wind.append(sum([decoration[j] for j in range(w[i], w[(i+1)%n])]))
        if w[i] > w[(i+1)%n]:
            l = list(range(w[i],m))+list(range(w[(i+1)%n]))
            wind.append(sum([decoration[j] for j in l]))
    return wind, sum(wind) // k

def CyclicOrderedSetPartitions(n):
    temp = []
    for c in OrderedSetPartitions(n):
        if 1 in c[0]:
            temp.append(c)
    return temp

def decorated_osp(n,k):
    temp = {}
    for osp in CyclicOrderedSetPartitions(n):
        m = len(osp)
        for c in Compositions(k):
            if len(c) == m:
                temp.setdefault(winding(osp,c)[1], [])
                temp[winding(osp,c)[1]].append([osp, c])
    return temp

def no_decorated_osp(n,k):
    return {key: len(value) for (key, value) in decorated_osp(n,k).items()}

def hypersimplicial_dosp(n,k):
    temp = {}
    for osp in CyclicOrderedSetPartitions(n):
        m = len(osp)
        for c in Compositions(k):
            if len(c) != m:
                continue
            hypersimplicial = True
            for i in range(m):
                if c[i] > len(osp[i])-1:
                    hypersimplicial = False
                    break
            if hypersimplicial:
                temp.setdefault(winding(osp,c)[1], [])
                temp[winding(osp,c)[1]].append([osp, c])
    return temp

def no_hypersimplicial_dosp(n,k):
    return {key: len(value) for (key, value) in hypersimplicial_dosp(n,k).items()}

# rewrite everything in class language. object oriented!

class Family:
    def __init__(self, *args):
        if len(args) == 1:
            self.colored_sequence = list(args[0])
        if len(args) == 2:
            t = sorted(args[0])
            self.colored_sequence = t[args[1]:]+list(reversed(t[0:args[1]]))

    def __str__(self):
        return str(self.colored_sequence)

    def underlying_set(self):
        return set(self.colored_sequence)
    
    def maximum(self):
        return max(self.underlying_set())
    
    def decoration(self):
        l = len(self.colored_sequence)-1
        if l == 0:
            return 1
        m = self.maximum()
        return l - self.colored_sequence.index(self.maximum())

    def __repr__(self):
        return str(self.underlying_set()) + '_' + str(self.decoration())
    
    def anchor(self):
        return min(self.underlying_set())
    
    def sorted_list(self):
        return sorted(self.underlying_set())
    
    def lowest_red(self):
        return self.colored_sequence[0]
    
    def highest_blue(self):
        return self.sorted_list()[self.decoration()-1]

    def regular_insert(self, x):
        if x < self.highest_blue():
            return Family(self.underlying_set()|{x}, self.decoration()+1)
        else:
            return Family(self.underlying_set()|{x}, self.decoration())

    def is_singlet(self):
        if len(self.underlying_set) == 1:
            if self.decoration != 0:
                raise Exception('singlet has no descent or ascent')
            return True
        else:
            return False

    def remove(self,x):
        self.colored_sequence.remove(x)

class FamilyRegistry:
    def __init__(self, listOfFamilies):
        self.registry = listOfFamilies

    def __repr__(self):
        return 'Registry '+ str(self.registry)

    def __str__(self):
        return str(self.registry)

    def underlying_set(self):
        foo = [f.underlying_set() for f in self.registry]
        return set().union(*foo)



def permutation_to_registry(w):
    if len(w) == 1:
        return FamilyRegistry([Family(w)])
    n = max(w)
    max_index = w.index(n)
    if max_index == len(w)-1:
        # Case A
        w = list(w)
        w.remove(n)
        w = Permutation(w)
        R = permutation_to_registry(w)
        return FamilyRegistry(R.registry+[Family([n])])
    m = w[max_index+1] # friend of n
    w = list(w)
    w.remove(n)
    w = Permutation(w)
    R = permutation_to_registry(w).registry
    for i in range(len(R)):
        if m in R[i].underlying_set():
            index_of_m = i
            break
    F = R[index_of_m]
    # Case B and C
    if m == F.highest_blue():
        F = F.regular_insert(n)
        R[index_of_m] = F
    else:
        N = Family([n,m])
        # Case D
        if m == F.anchor():
            R[index_of_m] = N
            slid_left = index_of_m
            while slid_left > 0:
                if m < min(R[slid_left-1].colored_sequence):
                    slid_left -= 1
                else:
                    break
            F.remove(m)
            R.insert(slid_left, F)
        # Case E
        else:
            F.remove(m)
            R[index_of_m] = F
            slid_left = index_of_m
            while slid_left > 0:
                if m < min(R[slid_left-1].colored_sequence):
                    slid_left -= 1
                else:
                    break
            R.insert(slid_left, N)

    return FamilyRegistry(R)

