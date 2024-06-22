def GenerateMatrix(equsys, vars):
    A=matrix([[equ.rhs()]+[equ.lhs().coefficient(v) for v in vars] for equ in equsys])
    return A

def h_star_vector(P):
    d = P.dim()
    E = P.ehrhart_polynomial()
    return [sum(E(t)*binomial(d+1,j-t)*(-1)^(j-t) for t in (0..j)) for j in (0..d)]

def hypercube(d):
    return Polyhedron(vertices = list(product([0,1],repeat=d)))

def Hmatrix(P):
    pH = p.Hrepresentation()
    return (pH.b().transpose() + pH.A().transpose()).transpose()

def h_star_of_hypersimplex(n,k):
    return h_star_vector(polytopes.hypersimplex(n,k))

def n_choose_2(n):
    return Subsets(list(range(n), 2))