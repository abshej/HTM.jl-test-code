include("Core.jl")

function layer(n::Int, w::Int)
    #no of minicolumns, no of neurons per minicolumn
    Layer(n, w, falses(n, w), falses(n, w), [], [], [], []
          )
end

function displayLayer(layer::Layer)
    print_with_color(:green, "Layer INFO:\n")
    println("Layer Minicolumns:      ", layer.minicols)
    println("Neurons per minicolumn: ", layer.neuronsper)
    print_with_color(:green, "Layer INFO: Active states:\n")
    println("Active minicolumns: ", length(activeMinicols(layer)), " / layer.minicols")
    println("Active neurons: ")
    display(activeNeurons(layer))
    print_with_color(:green, "Layer INFO: Predictive states:\n")
    display(predictiveNeurons(layer))
    println()
end

function setSparsity(n::Int)
    SPARSITY = n
end

function setDistalThres(n::Int)
    DISTAL_THRES = n
end
