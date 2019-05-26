include("Constant.jl")
include("Core.jl")


function spProxActn(layer::Layer, inp)
    activatedCols::Vector{Int} = []
    activations = proxActn(layer, inp)
    colactn = mcolActnStatus(activations, layer.dims[1])
    sortedCol = sort(colactn, rev=true)

    for i in 1:layer.params.sparsity
        colind = findin(colactn, sortedCol[1])[1]
        push!(activatedCols, colind)
        shift!(sortedCol)
        colactn[colind] = 0
    end
    
    return activatedCols
end


function spOutput(spOut::Vector{Int}, neuronsPerMinicol::Int)
    out::Vector{Tuple{Int,Int}} = []

    for i in spOut
        for j in 1:neuronsPerMinicol
            push!(out, (i,j))
        end
    end

    return out
end


function spBoolOutput(spOut::Vector{Int}, minicols::Int)
    out = falses(minicols)

    for i in spOut
        out[i] = true
    end

    return out
end
    
