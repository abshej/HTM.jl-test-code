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
