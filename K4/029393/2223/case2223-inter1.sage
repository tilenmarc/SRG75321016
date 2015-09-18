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

    # assuming x_0,x_1 have one common neighbor in X_2.
    G.add_edge(7, 8)

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
for G in graphs.nauty_geng("-t 7"):
    G.add_vertex(7)

    for nbr1 in subsets([0..6]):
        H = G.copy()
        H.add_edges( (7, el) for el in nbr1)
        if not H.is_triangle_free():
            continue

        s = H.canonical_label(partition = [ [7], [0..6] ]).graph6_string()
        if s not in cann:
            cann[s] = True
            L += [H]

print 'got' , len(L), 'right graphs'

p = Pool(8)
for el in p.imap(extend, L):
    if el:
        print 'we got some graphs!'