import json
import sys
from pygraphviz import AGraph

json_in = sys.argv[1]

type_to_color = {
    "control": "blue",
    "data": "red"
}

g = json.load(open(json_in, "r"))

G = AGraph()
for i, node in enumerate(g["nodes"]):
    G.add_node(i, label=node)
for e in g["edges"]:
    G.add_edge(e["u"], e["v"], color=type_to_color[e["type"]])

G.layout(prog='dot')
G.draw(json_in + ".png")