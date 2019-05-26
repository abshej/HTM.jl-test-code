include("Constant.jl")


function staticProxActn(layer::Layer, inp) #for static proximal connections(no permanence change)
    actstates::Vector{Tuple} = []
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        for i in layer.proximal[m, n].nzind
            if inp[i] == true && layer.proximal[m, n][i] >= layer.params.syn_thres
                push!(actstates, (m,n))
            end
        end
    end
    return actstates
end
