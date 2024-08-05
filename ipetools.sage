# author: Manfred Scheucher <scheucher@math.tu-berlin.de>

import xml.etree.ElementTree as ET

def read_graph_from_ipe(ipe_file):
	tree = ET.parse(ipe_file)
	root = tree.getroot()
	page = root.find('page')

	P = []
	for u in page.iterfind('use'):
		attr = u.attrib
		if attr['name']=='mark/disk(sx)':
			x,y = [int(t) for t in attr['pos'].split(" ")]

			if 'matrix' in attr:
				M = [int(t) for t in attr['matrix'].split(" ")]
				x0 = x
				y0 = y
				x = M[0]*x0+M[2]*y0+M[4]
				y = M[1]*x0+M[3]*y0+M[5]

			p = (x,y)
			assert(p not in P) # valid embedding
			P.append(p)

	E = []
	for u in page.iterfind('path'):
		attr = u.attrib
		if 'matrix' in attr:
			M = [int(t) for t in attr['matrix'].split(" ")]

		lines = u.text.split("\n")
		pts = []
		for l in lines:
			if l == '': continue
			x,y = [int(z) for z in l.split()[:2]]
			if 'matrix' in attr:
				x0 = x
				y0 = y
				x = M[0]*x0+M[2]*y0+M[4]
				y = M[1]*x0+M[3]*y0+M[5]
			p = (x,y)
			if p not in P: 
				continue
			i = P.index(p)
			pts.append(i)
		assert(len(pts) == 2) # no hypergraph
		pts.sort()
		e = tuple(pts)
		if e not in E:
			E.append(e)

	pos = {i:P[i] for i in range(len(P))}
	return Graph(E,pos=pos)


def write_graph_to_ipe(G,ipe_file):
	pos = G.get_pos()
	P = pos.values()
	#print "P",P
	E = G.edges(labels=False)

	print ("write ipefile to:",ipe_file)
	with open(ipe_file,'w') as g:
		g.write(IPE_HEADER)
		g.write('<page>\n')
		g.write('<layer name="alpha"/>\n')
		g.write('<layer name="beta"/>\n')
		g.write('<view layers="alpha beta" active="alpha"/>\n')
			
		# normalize
		x0 = min(x for (x,y) in P)
		y0 = min(y for (x,y) in P)
		P = [(x-x0,y-y0) for (x,y) in P]
		x1 = max(x for (x,y) in P)
		y1 = max(y for (x,y) in P)

		#scale 
		c = 100
		M = 600-2*c
		P = [(c+float(x*M)/x1,c+float(y*M)/y1) for (x,y) in P]
		
		# write edges	
		for i,j in E:
			(xi,yi) = P[i]
			(xj,yj) = P[j]
			g.write('<path layer="beta" stroke="black">\n')
			g.write(str(xi)+' '+str(yi)+' m\n')
			g.write(str(xj)+' '+str(yj)+' l\n')
			g.write('</path>\n')
		
		# write points
		for (x,y) in P:
			g.write('<use layer="alpha" name="mark/disk(sx)" pos="'+str(x)+' '+str(y)+'" size="normal" stroke="black"/>\n')
		
		g.write("""</page>\n</ipe>""")






# MS 2018.04.03 for readability, the following text was moved after the source code
def IPE_HEADER(width=600,height=600,): 
	return """<?xml version="1.0"?>
			<!DOCTYPE ipe SYSTEM "ipe.dtd">
			<ipe version="70005" creator="Ipe 7.1.4" media="0 0 1000 1000">
			<info created="D:20150825115823" modified="D:20150825115852"/>
<ipestyle name="basic">
<symbol name="arrow/arc(spx)">
<path stroke="sym-stroke" fill="sym-stroke" pen="sym-pen">
0 0 m
-1 0.333 l
-1 -0.333 l
h
</path>
</symbol>
<symbol name="arrow/farc(spx)">
<path stroke="sym-stroke" fill="white" pen="sym-pen">
0 0 m
-1 0.333 l
-1 -0.333 l
h
</path>
</symbol>
<symbol name="mark/circle(sx)" transformations="translations">
<path fill="sym-stroke">
0.6 0 0 0.6 0 0 e
0.4 0 0 0.4 0 0 e
</path>
</symbol>
<symbol name="mark/disk(sx)" transformations="translations">
<path fill="sym-stroke">
0.6 0 0 0.6 0 0 e
</path>
</symbol>
<symbol name="mark/fdisk(sfx)" transformations="translations">
<group>
<path fill="sym-fill">
0.5 0 0 0.5 0 0 e
</path>
<path fill="sym-stroke" fillrule="eofill">
0.6 0 0 0.6 0 0 e
0.4 0 0 0.4 0 0 e
</path>
</group>
</symbol>
<symbol name="mark/box(sx)" transformations="translations">
<path fill="sym-stroke" fillrule="eofill">
-0.6 -0.6 m
0.6 -0.6 l
0.6 0.6 l
-0.6 0.6 l
h
-0.4 -0.4 m
0.4 -0.4 l
0.4 0.4 l
-0.4 0.4 l
h
</path>
</symbol>
<symbol name="mark/square(sx)" transformations="translations">
<path fill="sym-stroke">
-0.6 -0.6 m
0.6 -0.6 l
0.6 0.6 l
-0.6 0.6 l
h
</path>
</symbol>
<symbol name="mark/fsquare(sfx)" transformations="translations">
<group>
<path fill="sym-fill">
-0.5 -0.5 m
0.5 -0.5 l
0.5 0.5 l
-0.5 0.5 l
h
</path>
<path fill="sym-stroke" fillrule="eofill">
-0.6 -0.6 m
0.6 -0.6 l
0.6 0.6 l
-0.6 0.6 l
h
-0.4 -0.4 m
0.4 -0.4 l
0.4 0.4 l
-0.4 0.4 l
h
</path>
</group>
</symbol>
<symbol name="mark/cross(sx)" transformations="translations">
<group>
<path fill="sym-stroke">
-0.43 -0.57 m
0.57 0.43 l
0.43 0.57 l
-0.57 -0.43 l
h
</path>
<path fill="sym-stroke">
-0.43 0.57 m
0.57 -0.43 l
0.43 -0.57 l
-0.57 0.43 l
h
</path>
</group>
</symbol>
<symbol name="arrow/fnormal(spx)">
<path stroke="sym-stroke" fill="white" pen="sym-pen">
0 0 m
-1 0.333 l
-1 -0.333 l
h
</path>
</symbol>
<symbol name="arrow/pointed(spx)">
<path stroke="sym-stroke" fill="sym-stroke" pen="sym-pen">
0 0 m
-1 0.333 l
-0.8 0 l
-1 -0.333 l
h
</path>
</symbol>
<symbol name="arrow/fpointed(spx)">
<path stroke="sym-stroke" fill="white" pen="sym-pen">
0 0 m
-1 0.333 l
-0.8 0 l
-1 -0.333 l
h
</path>
</symbol>
<symbol name="arrow/linear(spx)">
<path stroke="sym-stroke" pen="sym-pen">
-1 0.333 m
0 0 l
-1 -0.333 l
</path>
</symbol>
<symbol name="arrow/fdouble(spx)">
<path stroke="sym-stroke" fill="white" pen="sym-pen">
0 0 m
-1 0.333 l
-1 -0.333 l
h
-1 0 m
-2 0.333 l
-2 -0.333 l
h
</path>
</symbol>
<symbol name="arrow/double(spx)">
<path stroke="sym-stroke" fill="sym-stroke" pen="sym-pen">
0 0 m
-1 0.333 l
-1 -0.333 l
h
-1 0 m
-2 0.333 l
-2 -0.333 l
h
</path>
</symbol>
<pen name="heavier" value="0.8"/>
<pen name="fat" value="1.2"/>
<pen name="ultrafat" value="2"/>
<symbolsize name="large" value="5"/>
<symbolsize name="small" value="2"/>
<symbolsize name="tiny" value="1.1"/>
<arrowsize name="large" value="10"/>
<arrowsize name="small" value="5"/>
<arrowsize name="tiny" value="3"/>
<color name="red" value="1 0 0"/>
<color name="green" value="0 1 0"/>
<color name="blue" value="0 0 1"/>
<color name="yellow" value="1 1 0"/>
<color name="orange" value="1 0.647 0"/>
<color name="gold" value="1 0.843 0"/>
<color name="purple" value="0.627 0.125 0.941"/>
<color name="gray" value="0.745"/>
<color name="brown" value="0.647 0.165 0.165"/>
<color name="navy" value="0 0 0.502"/>
<color name="pink" value="1 0.753 0.796"/>
<color name="seagreen" value="0.18 0.545 0.341"/>
<color name="turquoise" value="0.251 0.878 0.816"/>
<color name="violet" value="0.933 0.51 0.933"/>
<color name="darkblue" value="0 0 0.545"/>
<color name="darkcyan" value="0 0.545 0.545"/>
<color name="darkgray" value="0.663"/>
<color name="darkgreen" value="0 0.392 0"/>
<color name="darkmagenta" value="0.545 0 0.545"/>
<color name="darkorange" value="1 0.549 0"/>
<color name="darkred" value="0.545 0 0"/>
<color name="lightblue" value="0.678 0.847 0.902"/>
<color name="lightcyan" value="0.878 1 1"/>
<color name="lightgray" value="0.827"/>
<color name="lightgreen" value="0.565 0.933 0.565"/>
<color name="lightyellow" value="1 1 0.878"/>
<dashstyle name="dashed" value="[4] 0"/>
<dashstyle name="dotted" value="[1 3] 0"/>
<dashstyle name="dash dotted" value="[4 2 1 2] 0"/>
<dashstyle name="dash dot dotted" value="[4 2 1 2 1 2] 0"/>
<textsize name="large" value="\large"/>
<textsize name="Large" value="\Large"/>
<textsize name="LARGE" value="\LARGE"/>
<textsize name="huge" value="\huge"/>
<textsize name="Huge" value="\Huge"/>
<textsize name="small" value="\small"/>
<textsize name="footnote" value="\footnotesize"/>
<textsize name="tiny" value="\tiny"/>
<textstyle name="center" begin="\begin{center}" end="\end{center}"/>
<textstyle name="itemize" begin="\begin{itemize}" end="\end{itemize}"/>
<textstyle name="item" begin="\begin{itemize}\item{}" end="\end{itemize}"/>
<gridsize name="4 pts" value="4"/>
<gridsize name="8 pts (~3 mm)" value="8"/>
<gridsize name="16 pts (~6 mm)" value="16"/>
<gridsize name="32 pts (~12 mm)" value="32"/>
<gridsize name="10 pts (~3.5 mm)" value="10"/>
<gridsize name="20 pts (~7 mm)" value="20"/>
<gridsize name="14 pts (~5 mm)" value="14"/>
<gridsize name="28 pts (~10 mm)" value="28"/>
<gridsize name="56 pts (~20 mm)" value="56"/>
<anglesize name="90 deg" value="90"/>
<anglesize name="60 deg" value="60"/>
<anglesize name="45 deg" value="45"/>
<anglesize name="30 deg" value="30"/>
<anglesize name="22.5 deg" value="22.5"/>
<tiling name="falling" angle="-60" step="4" width="1"/>
<tiling name="rising" angle="30" step="4" width="1"/>
<layout paper=" """+str(width)+" "+str(height)+""" " origin="0 0"/>
</ipestyle>
"""

