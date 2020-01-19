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

def addEdge(u, v, edge_type)
    e = {
        "u" => u,
        "v" => v,
        "type" => edge_type
    }
    unless $edges.include? e
        $edges.append e
    end
end

def traverse_call_children(callee, children)
    children.each do |child|
        puts "- #{child}"
        if child.type == :send
            child_callee = child.children[1]
            traverse_call_children(child_callee, child.children.drop(2))
            addEdge(getNode(child_callee), getNode(callee), "data")
        elsif child.type == :str
            s = child.children[0]
            addEdge(getNode(s), getNode(callee), "data")
        end
    end
end

def traverse(node, context)
    if node.is_a? AST::Node
        if node.type == :def
            context = node.children[0]
        end
        if node.type == :send
            callee = node.children[1]
            puts "---- Children of #{callee}---"
            traverse_call_children(callee, node.children.drop(2))
            addEdge(getNode(context), getNode(callee), "control")
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