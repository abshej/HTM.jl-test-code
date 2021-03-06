include("Units.jl")
include("Minicolumns.jl")


function layerUnits(layer::Layer)
#= Returns total number of neurons in layer =#

    length(layer.minicols) * length(layer.minicols[1].neurons)
end


function layer(noOfMinicols::Int, noOfNeuronsPerMinicol::Int)

    Layer([minicol(noOfNeuronsPerMinicol) for i in 1:noOfMinicols])
end


function computeLayerFF(layer::Layer, inpSpace)
#= Returns FF output for layer using proximal connections =#
    ffActivation::AbstractArray = []

    for col in layer.minicols
        push!(ffActivation, computeMinicolFF(col, inpSpace))
    end

    return ffActivation
end


function predictions(layer::Layer, preState) # preState is FF output for previous timestep
#= Returns predictive neurons in all minicolumns of layer =#
    
    predictive::AbstractArray = []

    for col in eachindex(layer.minicols)
        push!(predictive, predictions(layer.minicols[col], preState))
    end

    return predictive
end


function distalConnections!(layer::Layer, preState, latState)
#= Grow distal synapses for all neuron in layer for prior activation =#
    
    for col in eachindex(layer.minicols)
        distalConnections!(layer.minicols[col], preState, latState[col])
    end

end
    
