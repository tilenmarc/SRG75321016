load ../genericSRG.sage
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
        s = H.canonical_label().graph6_string()
        if s not in cann:
            cann[s] = True
            X = H.subgraph(set(H)-toFix)               
            X.relabel()
            if isInterlacedFast(X):
                ret+= [H]
    return ret  

L = list(graphs.nauty_geng("8 -t"))


def extend(G):
    G.add_vertices([8,9,10])
    G.add_edges(Combinations( [11..14],2))

    G.add_edge(8,12)
    G.add_edge(8,13)
    G.add_edge(8,14)

    G.add_edge(9,12)
    G.add_edge(9,13)
    G.add_edge(9,14)

    G.add_edge(10,12)
    G.add_edge(10,11)
    G.add_edge(10,14)

    for v in  [0..7]: 
        G.add_edge(9,v)

    toFix = set([0..7])
    generated = [G]
    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp= extendVertex(G,v,toFix)
        generated = generated_tmp
    return generated

p = Pool(4)
for el in p.imap(extend, L):
    if el:
        print 'we got some graphs!'