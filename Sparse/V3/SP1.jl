include("Constant.jl")
include("Core.jl")


function spActn(layer::Layer, inp)
    activatedCols::Vector{Int} = []
    act = proxActn(layer, inp)
    colactn = colActn(act, layer.dims[1])
    sortedCol = sort(colactn, rev=true)

    for i in 1:layer.params.sparsity
        colind = findin(colactn, sortedCol[1])[1]
        push!(activatedCols, colind)
        shift!(sortedCol)
        colactn[colind] = 0
    end
    
    return activatedCols
end


function spActnOutput(spOut::Vector{Int}, n::Int)
    out::Vector{Tuple{Int,Int}} = []

    for i in spOut
        for j in 1:n
            push!(out, (i,j))
        end
    end

    return out
end


function spBoolOutput(spOut::Vector{Int}, n::Int)
    out = falses(n)

    for i in spOut
        out[i] = true
    end

    return out
end
    
