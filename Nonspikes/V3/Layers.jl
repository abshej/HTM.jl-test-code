include("Units.jl")
include("Minicolumns.jl")


function layerUnits(layer::Layer)
    #= Returns total number of neurons in layer =#

    length(layer.minicols) * length(layer.minicols[1].neurons)
end


function layer(noOfMinicols::Int, noOfNeuronsPerMinicol::Int)

    Layer([minicol(noOfNeuronsPerMinicol) for i in 1:noOfMinicols])
end


function proximalAct(layer::Layer, inpSpace)
    #= Returns FF output for layer using proximal connections =#
    ffActivation::AbstractArray = []

    for col in layer.minicols
        push!(ffActivation, proximalAct(col, inpSpace))
    end

    return ffActivation
end


function predictions(layer::Layer, preState)
    #= Returns predictive neurons in all minicolumns of layer =#

    predictive::AbstractArray = []

    for col in eachindex(layer.minicols)
        push!(predictive, predictions(layer.minicols[col], preState))
    end

    return predictive
end


function diffMat(preState, latState)
    # obtain difference matrix between new state and previous state =#

    return latState - preState
end


function synIncrement!(layer::Layer, preState, latState)
    #= Increment synapses for correctly predicted neurons =#

    preStatePreds = predictions(layer, preState)
    difftrix = diffMat(preStatePreds, latState)

    for col in eachindex(layer.minicols)
        synIncrement!(layer.minicols[col], preState[col], latState[col], difftrix[col])
    end
end


function synDecrement!(layer::Layer, preState, latState)
    #= Decrement synapses for falsely predicted neurons =#

    preStatePreds = predictions(layer, preState)
    difftrix = latState - preStatePreds

    for col in eachindex(layer.minicols)
        synDecrement!(layer.minicols[col], preState[col], difftrix)
    end
end


function distalConnections!(layer::Layer, preState, latState)
    #= Grow distal synapses for all neuron in layer for prior activation =#

    for col in eachindex(layer.minicols)
        distalConnections!(layer.minicols[col], preState, latState[col])
    end

end
