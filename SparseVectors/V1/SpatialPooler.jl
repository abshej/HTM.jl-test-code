include("Constant.jl")

function proximalActivation!(layer::Layer, input::RawInput)    

    activeStates = zeros(Int8, layer.dims)
    upper_condition = 100 - layer.params.syn_inc

    for n in eachindex(layer.proximal)

        for i in layer.proximal[n].nzind

            if input[i] == true && layer.proximal[n][i] >= layer.params.syn_thres
                activeStates[n] = Int8(1)
                if layer.proximal[n][i] <= upper_condition
                    layer.proximal[n][i] += layer.params.syn_inc
                else
                    layer.proximal[n][i] = 100
                end

            elseif inp[i] == true && layer.proximal[n][i] < layer.params.syn_thres
                layer.proximal[n][i] += layer.params.syn_inc

            else
                if layer.proximal[n][i] >= layer.params.syn_dec
                    layer.proximal[n][i] -= layer.params.syn_dec
                else
                    layer.proximal[n][i] = 0
                end
            end
        end
        
    end
    
    return activeStates
end
