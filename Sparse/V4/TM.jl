include("Constant.jl")
include("Core.jl")


function tmActn(layer::Layer, predStates, inp)

    activeStates::Vector{Tuple{Int, Int}} = []
    
    #active = proxActn(layer, inp)
    activecols = sparsevec(colActn(inp, layer.dims[1])).nzind

    for i in activecols
        states = filter(x -> x[1]==i, predStates)
        if states != []
            for p in states
                push!(activeStates, p)
            end
        else
            for j in 1:layer.dims[2]
                push!(activeStates, (i, j))
            end
        end
    end

    return activeStates
end

