include("Constant.jl")

function proximalactivation!(layer::Layer, input::RawInput)    

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


function distalActivation(layer::Layer, activeStates)
    predictiveStates = zeros(Int8, layer.dims)
    activeStates = sparse(activeStates)*layer.params.syn_thres

    for n in eachindex(layer.distal)

        for d in eachindex(layer.distal[n])
            diff = layer.distal[n][d] - activeStates
            for i in eachindex(diff)
                if diff[i] > 0
                    count += 1
                    if count >= layer.params.den_syn_thres
                        predictiveStates[n] = 1
                        break
                    end
                end
            end
            if count >= layer.params.den_syn_thres
                break
            end
        end
    end

    return predictiveStates
end
            
