require 'parser/current'
require 'json'
require 'ast'

$nodes = []
$edges = []

def freshNode(node)
    $nodes.append node
    return $nodes.length - 1
end

def getNode(node)
    idx = $nodes.find_index(node)
    if idx != nil
        return idx
    end
    return freshNode(node)
end

def addEdge(u, v)
    e = [u, v]
    unless $edges.include? e
        $edges.append e
    end
end

def traverse(node, context)
    if node.is_a? AST::Node
        if node.type == :def
            context = node.children[0]
        end
        if node.type == :send
            addEdge(getNode(context), getNode(node.children[1]))
        end
        node.children.each do |child|
            unless child.nil?
                traverse(child, context)
            end
        end
    end
end

file = File.open(ARGV[0])

code = file.read

parsed = Parser::CurrentRuby.parse(code)

traverse(parsed, :root)
dict = { "nodes" => $nodes, "edges" => $edges }
s = JSON.dump dict
open(ARGV[1], 'w') { |f|
    f.puts s
}