include("Units.jl")
include("Dendrites.jl")
include("Neurons.jl")
include("Minicolumns.jl")
include("Layers.jl")
include("Inputs.jl")


function SP(layer::Layer, inpSpace, spThres::Int, ovrSpr::Int)
#= Perform SP on layer using inpSpace and simple column activaton thresholding =#

    if layer.minicols[1].neurons[1].proximal.synapses == []
        print_with_color(:red, "INFO: Missing proximal connections\n")

        randInpSynapses!(layer, length(inpSpace))
        print_with_color(:green, "INFO: Proximal connections made\n")
    end
    
    proximalOutput = computeLayerFF(layer, inpSpace)

    activeCols::Int = 0
    colActivity = []
    spOut = []
    
    for col in eachindex(proximalOutput)

        if sum(proximalOutput[col]) > spThres

            push!(colActivity, sum(proximalOutput[col]))
            activeCols += 1
            
            push!(spOut, trues(length(proximalOutput[col])))

        else
            push!(spOut, falses(length(proximalOutput[col])))
        end
    end

    cookedOut = []
    
    if activeCols > ovrSpr
        sort!(colActivity, rev=true)
        
    end
    
    
    print_with_color(:green, "INFO: Simple SPATIAL POOLING computed\n")
    return spOut, activeCols
end
