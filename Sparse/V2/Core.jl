include("Constant.jl")


function proxActn(layer::Layer, inp)
    actstates::Vector{Tuple} = []
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        for i in layer.proximal[m, n].nzind
            if inp[i] == true && layer.proximal[m, n][i] >= layer.params.syn_thres
                push!(actstates, (m,n))
                layer.proximal[m, n][i] += syn_inc
                if layer.proximal[m, n][i] > 100
                    layer.proximal[m, n][i] = 100
                end
            elseif inp[i] == true && layer.proximal[m, n][i] < layer.params.syn_thres
                layer.proximal[m, n][i] += syn_inc
            else
                layer.proximal[m, n][i] -= syn_dec
                if layer.proximal[m, n][i] < 0
                    layer.proximal[m, n][i] = 0
                end
            end
        end
    end
    return actstates
end


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


function getDistActn(layer::Layer, actStates)
    predstates::Vector{Tuple} = []
    preddens::Vector{Int} = []
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        for d in eachindex(layer.distal[m, n])
            count::Int = 0
            for i in actStates
                #layer.distal[m,n][d][a,b] ==> syn perm of neuron(m,n) on dendrite(d) with neuron(a,b)
                if layer.distal[m,n][d][i...] >= layer.params.syn_thres
                    count += 1
                end
            end
            if count >= layer.params.den_syn_thres
                push!(predstates, (m, n))
                push!(preddens, d)
            end
        end
    end
end


function getTotalSyns(den::SparseMatrixCSC{Int8})
    total::Int = 0
    for i in eachindex(den)
        total += sum(i)
    end
end


function distOvrlp(layer::Layer, actstates)
    scores::Vector{Int} = []
    for d in layer.distal
        score::Int = 0
        for m in 1:layer.dims[1], n in 1:layer.dims[2]
            semiscore::Int = 0
            for i in actstates
                if d[m, n][i...] >= layer.params.def_syn_perm
                    semiscore += 1
                end
            end
            if semiscore > layer.params.den_syn_thres
                score += 1
            end
        end
        push!(scores, score)
    end
    return scores
end  


function distalConnections(layer::Layer, currentStates, actStates, predStates)
    for cur in currentStates
        if contains(==, predStates, cur)
            filter!(x -> x!=cur, predStates)
        end
        for d in layer.distal[cur...]
            for act in actStates
                if layer.distal[cur...][d][act...] == 0
                    layer.distal[cur...][end][act...] = def_syn_perm
                else
                    layer.distal[cur...][d][act...] += syn_inc
                    if layer.distal[cur...][d][act...] > 100
                        layer.distal[cur...][d][act...] = 100
                    end
                end
            end
        end
    end
    for rem in predStates
        for act in actStates
            layer.distal[rem...][end][act...] -= syn_dec
        end
    end
end

            
