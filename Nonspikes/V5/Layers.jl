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


function distal!(layer::Layer, outSDR2, outSDR1=[])
    outSDR1preds = predictions(layer, outSDR1)
    cmpMatrix1 = compareMatrix1(outSDR1preds, outSDR2)
    cmpMatrix = compareMatrix2(outSDR1, cmpMatrix1)
    for col in eachindex(layer.minicols)
        distal!(layer.minicols[col], outSDR2[col], cmpMatrix, col)
    end
end

function distalConnections!(layer::Layer, outSDR2, outSDR1)
    for col in eachindex(layer.minicols)
        distalConnections!(layer.minicols[col], outSDR2[col], outSDR1, col)
    end
end
