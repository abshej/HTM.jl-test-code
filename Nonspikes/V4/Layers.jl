include("Units.jl")
include("Minicolumns.jl")
include("SpecialBackend.jl")


function totalSyns(layer::Layer)
    count::Int = 0
    for col in layer.minicols
        count += totalSyns(col)
    end
    return count
end


function totalNeurons(layer::Layer)
    length(layer.minicols) * length(layer.minicols[1].neurons)
end


function layer(noOfMinicols::Int, noOfNeuronsPerMinicol::Int)
    Layer([minicol(noOfNeuronsPerMinicol) for i in 1:noOfMinicols])
end


function proximalOut(layer::Layer, inpSDR)
    ffActivation::AbstractArray = []
    for col in layer.minicols
        push!(ffActivation, proximalOut(col, inpSDR))
    end
    return ffActivation
end


function predictions(layer::Layer, outSDR)
    predictive::AbstractArray = []
    for col in eachindex(layer.minicols)
        push!(predictive, predictions(layer.minicols[col], outSDR))
    end
    return predictive
end


function distal!(layer::Layer, predictions, outSDR)
    cmpMatrix = compareMatrix(predictions, outSDR)
    for col in eachindex(layer.minicols)
        distal!(layer.minicols[col], cmpMatrix)
    end
end
