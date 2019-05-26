include("Constant.jl")


function getProxActn(layer::Layer, inp)
    actstates::Vector{Tuple} = []
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        for i in layer.proximal[m, n].nzind
            if inp[i] == true && layer.proximal[m, n][i] >= layer.params.syn_thres
                push!(actstates, (m,n))
                #layer.proximal[m, n][i] += syn_inc
                break
            end
        end
    end
    return actstates
end

function getDistActn(layer::Layer, actStates)
    predstates::Vector{Tuple} = []
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        count::Int = 0
        for i in actStates
            if layer.distal[i...] > layer.params.syn_thres
                count += 1
            end
        end
        if count >= layer.params.den_syn_thres
            push!(predstates, (m, n))
        end
    end
end

