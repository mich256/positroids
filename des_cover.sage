def circular_descents(w):
	w = Permutation(w)
	n = len(w)
	foo = []
	for i in range(1,n):
		if w(i) > w(i+1):
			foo.append(i)
	if w(n) > w(1):
		foo.append(n)
	return foo

def inverse_circular_descents(w):
	return circular_descents(w.inverse())

def cdes(w):
	w = Permutation(w)
	return len(circular_descents(w))

def icdes(w):
	w = Permutation(w)
	return cdes(w.inverse())

def cover(w):
	w = Permutation(w)
	n = len(w)
	foo = [i for i in range(1,n) if w(i+1)>w(i)+1]
	temp = len(foo)
	if w(1) == 1:
		return temp
	else:
		return temp+1

def ncov(w):
	w = Permutation(w).inverse()
	n = len(w)
	foo = [i for i in range(1,n) if w(i+1)>w(i)+1]
	return len(foo)

def perm_ncov(n,k):
	temp = {}
	for w in perm_cdes(n,k):
		c = ncov(w)
		temp.setdefault(c, [])
		temp[c].append(w)
	return temp

def perm_icdes(n,k):
	cycle = list(range(2,n+1))
	cycle.append(1)
	cyclc = Permutation(cycle)
	return [Permutation(w).left_action_product(cycle) for w in CyclicPermutations(range(1,n+1)) if icdes(w) == k]

def perm_cdes(n,k):
	cycle = list(range(2,n+1))
	cycle.append(1)
	cyclc = Permutation(cycle)
	return [Permutation(w).left_action_product(cycle) for w in CyclicPermutations(range(1,n+1)) if cdes(w) == k]

def perm_ides(n,k):
	return [Permutation(w) for w in Permutations(n) if w.number_of_idescents() == k]

def perm_cover(n,k):
	temp = {}
	for w in perm_ides(n-1,k-1):
		c = cover(w)
		temp.setdefault(c, [])
		temp[c].append(w.inverse())
	return temp

def no_perm_cover(n,k):
	return {key: len(value) for (key, value) in perm_cover(n,k).items()}

def perm_cover_polynomial(n,k):
	R.<t> = PolynomialRing(QQ)
	temp = no_perm_cover(n,k)
	return sum([value*t^key for (key, value) in temp.items()])

load('hstar.sage')

def test_cover(n,k):
	R.<t> = PolynomialRing(QQ)
	return perm_cover_polynomial(n-1,k-1) + (1-t)*h_star_polynomial_of_hypersimplex(n-1,k-1) \
	== h_star_polynomial_of_hypersimplex(n,k)