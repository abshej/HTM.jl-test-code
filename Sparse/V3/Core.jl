include("Constant.jl")


function proxActn(layer::Layer, inp)
    #= Proximal Activation returning active neurons and updating proximal
    proximal synapses depending on input =#
    
    actstates::Vector{Tuple} = []
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        for i in layer.proximal[m, n].nzind
            if inp[i] == true && layer.proximal[m, n][i] >= layer.params.syn_thres
                push!(actstates, (m,n))
                layer.proximal[m, n][i] += layer.params.syn_inc
                if layer.proximal[m, n][i] > 100
                    layer.proximal[m, n][i] = 100
                end
            elseif inp[i] == true && layer.proximal[m, n][i] < layer.params.syn_thres
                layer.proximal[m, n][i] += layer.params.syn_inc
            else
                layer.proximal[m, n][i] -= layer.params.syn_dec
                if layer.proximal[m, n][i] < 0
                    layer.proximal[m, n][i] = 0
                end
            end
        end
    end
    return actstates
end


function distActn(layer::Layer, actStates)
    #= Distal Activation based on the active states of layer
    Determine predictive states based on distal synapses =#

    predstates::Vector{Tuple{Int, Int}} = []

    #for each neuron
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        #for each dendrite on neuron
        for d in eachindex(layer.distal[m, n])
            count::Int = 0
            #check for connected synapses with active neurons
            for i in actStates
                if (m, n) != i
                    #=layer.distal[m,n][d][a,b]
                    syn perm of neuron(m,n) on dendrite(d) with neuron(a,b)=#
                    if layer.distal[m,n][d][i...] >= layer.params.syn_thres
                        count += 1
                    end
                end
            end
            #check if total active connected synapses exceed dendritic thres
            if count >= layer.params.den_syn_thres
                #add neuron as predicted
                push!(predstates, (m, n))
            end
        end
    end
    
    return predstates
end


function distUpd!(layer::Layer, currentStates, previousStates, predictions)

    for c in eachindex(currentStates)
        if contains(==, predictions, currentStates[c])
            filter!(x -> x != currentStates[c], predictions)
        end
        for act in previousStates
            if currentStates[c] != act
                for d in eachindex(layer.distal[currentStates[c]...])
                    if layer.distal[currentStates[c]...][d][act...] != 0
                        if layer.distal[currentStates[c]...][d][act...] < 100-layer.params.syn_inc
                            layer.distal[currentStates[c]...][d][act...] += layer.params.syn_inc
                        else
                            layer.distal[currentStates[c]...][d][act...] = 100
                        end
                    else
                        layer.distal[currentStates[c]...][d][act...] = layer.params.def_syn_perm
                    end
                end
            end
        end
    end

    for rem in predictions #incorrectly predicted neurons
        for act in previousStates
            if rem != act
                for d in eachindex(layer.distal[rem...])
                    if layer.params.syn_dec <= layer.distal[rem...][d][act...]
                        layer.distal[rem...][d][act...] -= layer.params.syn_dec
                    else
                        layer.distal[rem...][d][act...] = 0
                    end
                end
            end
        end
    end

end


function colActn(actStates, n::Int)
    #= Vector with total active neurons for each minicol
    active states, no of minicols =#
    
    cols::Vector{Int} = zeros(Int, n)
    for act in actStates
        cols[act[1]] += 1
    end
    return cols
end
