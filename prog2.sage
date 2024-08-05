# author: Manfred Scheucher <scheucher@math.tu-berlin.de>

from itertools import *
from sys import *
from random import *
import scipy.optimize
import numpy as np
load("ipetools.sage")

input_file = argv[1]
print ("read input_file",input_file)
G = read_graph_from_ipe(input_file)

print ("vertices:",G.vertices())
print ("edges:",G.edges(labels=False))

assert(G.is_planar())
assert(G.vertex_connectivity() >= 3)


#G.set_planar_positions()
G.set_pos(G.layout_planar())


a1,a2 = e0 = G.edges(labels=False)[0]
e0r = tuple(reversed(e0))

H = Graph() # angle graph
for v in G.vertices():
	H.add_vertex(v)

for f in G.faces():
	v = len(H.vertices())
	for (u,_) in f: 
		H.add_edge(u,v)
	if e0  in f: a3 = v
	if e0r in f: a4 = v

#H.set_planar_positions()
H.set_pos(H.layout_planar())
H.is_planar(set_embedding=True)
H_embedding = H.get_embedding()
assert(H.vertex_connectivity() >= 3)
print ("H_embedding:", H_embedding)

#H.plot().save("H.png")

U = H.vertices()
A = [a1,a2,a3,a4]
B = [u for u in H.vertices() if u not in A]
N = {u:H.neighbors(u) for u in H}

print ("A",A)
print ("B",B)

pi = RR(pi) # round pi

def quality(R): 

	def alpha2(u,x): 
		assert(not (u in A and x in A))
#		if u in A and x in A: return pi/2
		if u in A: return 0.
		if x in A: return np.pi
		return 2.*np.arctan(R[x]/R[u])

	def alpha1(u): 
		return np.sum(alpha2(u,x) for x in N[u])

	q = np.sum((alpha1(u)-2*np.pi)^2 for u in B)
	print ("\rgot",q,end="")
	stdout.flush()

	return q 


R0 = np.array([1.0 for u in U])

def quality_der(x):
	return scipy.optimize.approx_fprime(x, quality, 1e-9)

res = scipy.optimize.minimize(quality,R0,jac=quality_der,method="BFGS")#,method="Nelder-Mead")
R = res.x


radius = {u:R[u] for u in U}
#print "solution:",R
print()

a5 = None
i = 0 
while True:
	if H_embedding[a3][i-1] == a1:
		if H_embedding[a3][i-2] == a2:
			a5 = H_embedding[a3][i]
			sign = +1
		else:
			assert(H_embedding[a3][i] == a2)
			a5 = H_embedding[a3][i-2]
			sign = -1
		break # found
	i += 1
assert(a5 != None)
print ("a5",a5)

a6 = None
i = 0 
while True:
	if H_embedding[a1][i-1] == a3:
		if H_embedding[a1][i-2] == a4:
			a6 = H_embedding[a1][i]
		else:
			assert(H_embedding[a1][i] == a4)
			a6 = H_embedding[a1][i-2]
		break # found
	i += 1
assert(a6 != None)
assert(H.has_edge(a5,a6))
print ("a6",a6)

centers = dict()
centers[a5] = vector([0,radius[a5]])
centers[a6] = vector([radius[a6],0])

#print "place",a5,"->",centers[a5]
#print "place",a6,"->",centers[a6]

TODO = [a5,a6]
while TODO:
	u = TODO.pop()
	i = 0
	while True:
		if H_embedding[u][0] in centers: break
		H_embedding[u] = H_embedding[u][1:]+H_embedding[u][:1] 
		# rotate until first element is actually placed...
		i += 1
		assert(i <= len(H)) #3

	for i in range(1,len(H_embedding[u])):
		v = H_embedding[u][i-1]
		w = H_embedding[u][i]
		assert(v in centers)

		if w in A: break
	
		if w not in centers:
			angle = sign*(arctan(R[v]/R[u]) + arctan(R[w]/R[u]))
			direction_uv = (centers[v]-centers[u]).normalized()
			rotation = matrix([[cos(angle),-sin(angle)],[sin(angle),cos(angle)]])
			direction_uw = rotation * direction_uv
			length = sqrt(radius[w]*radius[w] + radius[u]*radius[u])
			centers[w] = centers[u] + length * direction_uw
			TODO.append(w)
			#print "place",w,"because of",u,v,"angle",angle,"->",centers[w]





svg_file = input_file+".svg"
print ("write svgfile to:",svg_file)
plot = sum(circle(centers[u],radius[u],edgecolor="blue" if u in G.vertices() else "red") for u in B)
#plot += sum(text(str(u),centers[u]) for u in B)
plot += line([[0,0],[3,0]],color="blue")
plot += line([[0,0],[0,3]],color="red")
plot.save(svg_file)




ipe_file = input_file+".ipe"
print ("write ipefile to:",ipe_file)
with open(ipe_file,'w') as g:

	# normalize
	P = [centers[u] for u in B]
	x0 = min(x for (x,y) in P)
	y0 = min(y for (x,y) in P)
	P = [(x-x0,y-y0) for (x,y) in P]
	x1 = max(x for (x,y) in P)
	y1 = max(y for (x,y) in P)
	dx = x1-x0
	dy = y1-y0

	#scale 
	c_boundary = 100
	width = 600
	height = 2*c_boundary + ceil((width-2*c_boundary) * dy / dx)
	
	g.write(IPE_HEADER(width,height))
	g.write('<page>\n')
	g.write('<layer name="centers_blue"/>\n')
	g.write('<layer name="centers_red"/>\n')
	g.write('<layer name="circles_blue"/>\n')
	g.write('<layer name="circles_red"/>\n')
	g.write('<layer name="lines_blue"/>\n')
	g.write('<layer name="lines_red"/>\n')
	g.write('<layer name="edges"/>\n')
	#g.write('<layer name="kites_blue"/>\n')
	#g.write('<layer name="kites_red"/>\n')
	g.write('<layer name="kites"/>\n')
	g.write('<view layers="circles_blue circles_red kites" active="centers_blue"/>\n')
	#g.write('<view layers="centers_blue centers_red circles_blue circles_red edges" active="centers_blue"/>\n')

	M = width-2*c_boundary
	scale = M/dx
	offset1 = vector([x0,y0])
	offset2 = vector([c_boundary,c_boundary])
	centers = {u:scale*(centers[u]-offset1)+offset2 for u in centers}

	# write edges	
	for i,j in H.edges(labels=False):
		if i in B and j in B:
			(xi,yi) = centers[i]
			(xj,yj) = centers[j]
			g.write('<path layer="edges" stroke="black" pen="heavier">\n')
			g.write(str(xi)+' '+str(yi)+' m\n')
			g.write(str(xj)+' '+str(yj)+' l\n')
			g.write('</path>\n')
	
	# write surrounding box
	p00 = offset2 
	p10 = offset2 + scale*vector([dx,0])
	p01 = offset2 + scale*vector([0,dy])
	p11 = offset2 + scale*vector([dx,dy])

	boxScale = 2
	for pi,pj,color in [(p00,p01,'red'),(p00,p10,'blue'),(p11,p01,'blue'),(p11,p10,'red')]:
		c = (pj+pi)/2
		d = (pj-pi)/2
		(xi,yi) = c-d*boxScale
		(xj,yj) = c+d*boxScale
		g.write('<path layer="lines_'+color+'" stroke="'+color+'" pen="heavier">\n')
		g.write(str(xi)+' '+str(yi)+' m\n')
		g.write(str(xj)+' '+str(yj)+' l\n')
		g.write('</path>\n')

	# write kites
	drawn_kites = set()
	for f in H.faces():
		f = [u for (u,v) in f]
		assert(len(f) == 4)
		for k in range(4):
			i = f[k]
			j = f[k-2]
			assert((i in G.vertices()) == (j in G.vertices()))

			if i in A and j in A: 
				continue # draw nothing

			if i in B and j in B:
				(xi,yi) = centers[i]
				(xj,yj) = centers[j]

			if i in A and j in B:
				i,j = j,i

			if i in B and j in A:
				(xi,yi) = centers[i]
				if j == a1: direction = vector([0,-1])
				if j == a2: direction = vector([0,+1])
				if j == a3: direction = vector([-1,0])
				if j == a4: direction = vector([+1,0])
				(xj,yj) = centers[i] + (radius[i]*scale + c_boundary)*direction

			if i > j: i,j = j,i
			if (i,j) in drawn_kites: continue
			drawn_kites.add((i,j))

			#color = "blue" if not i in G.vertices() else "red"
			#g.write('<path layer="kites_'+color+'" stroke="'+color+'">\n')
			g.write('<path layer="kites" stroke="seagreen" pen="heavier">\n')
			g.write(str(xi)+' '+str(yi)+' m\n')
			g.write(str(xj)+' '+str(yj)+' l\n')
			g.write('</path>\n')

	# write points
	for i in B:
		(xi,yi) = centers[i]
		ri = scale*radius[i]
		color = "blue" if i in G.vertices() else "red"
		g.write('<use layer="centers_'+color+'" name="mark/disk(sx)" pos="'+str(xi)+' '+str(yi)+'" size="normal" stroke="'+color+'"/>\n')
		g.write('<path layer="circles_'+color+'" stroke="'+color+'" pen="heavier">'+str(ri)+' 0 0 '+str(ri)+' '+str(xi)+' '+str(yi)+' e</path>')
	
	g.write("""</page>\n</ipe>""")



