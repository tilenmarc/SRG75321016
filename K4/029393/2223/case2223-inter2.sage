load ../../../genericSRG.sage
from multiprocessing import Pool 

global cann
cann = {}

def extendVertex(G,v,toFix):
    global cann 

    ret = []
    for x,y in Combinations( [11..14], 2):
        H = G.copy()
        H.add_edge(v,x)
        H.add_edge(v,y)
        s = H.canonical_label(partition=[[0..7],[8,9,10],[11..14]]).graph6_string()
        if s not in cann:
            X = H.subgraph(set(H)-toFix)               
            X.relabel()
            if isInterlacedFast(X):
                ret+= [H]
    return ret  

def extend(G):
    G.add_vertices([8,9,10])
    G.add_edges(Combinations( [11..14],2))

    G.add_edge(8,14)
    G.add_edge(8,12)
    G.add_edge(8,13)

    G.add_edge(9,14)
    G.add_edge(9,13)
    G.add_edge(9,11)

    G.add_edge(10,13)
    G.add_edge(10,12)
    G.add_edge(10,11)

    for v in  [0..7]: 
        G.add_edge(9,v)

    # assuming x_0,x_1 have one common neighbor in X_2 as well
    # as x_1,x_2
    G.add_edge(6, 8)
    G.add_edge(7, 10)


    toFix = set([0..7])
    generated = [G]
    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp= extendVertex(G,v,toFix)
        generated = generated_tmp
    return generated

L = []

for G in graphs.nauty_geng("-t 6"):
    G.add_vertices( [6,7] )
    for nbr1, nbr2 in Combinations( subsets([0..5]), 2):
        H = G.copy()
        H.add_edges( (6, el) for el in nbr1)
        H.add_edges( (7, el) for el in nbr2)
        if not H.subgraph([0..6]).is_triangle_free():
            continue
        if not H.subgraph([0..5]+[7]).is_triangle_free():
            continue
        s = H.canonical_label(partition = [ [6,7], [0..5] ]).graph6_string()
        if s not in cann:
            cann[s] = True
            L += [H]

        H2 = H.copy()
        H2.add_edge(6,7)
        s = H2.canonical_label(partition = [ [6,7], [0..5] ]).graph6_string()
        if s not in cann:
            cann[s] = True
            L += [H2]

print 'got' , len(L), 'right graphs'

p = Pool(8)
for el in p.imap(extend, L):
    if el:
        print 'we got some graphs!'