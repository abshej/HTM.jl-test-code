include("Units.jl")

function distalNDMA(den::DEN, layer::LYR)
    synSpikes::Int = 0
    for syn in den.syns
        if layer.mncs[syn.axnID[1]].nrns[syn.axnID[2]].axon == true
            if syn.perm > SYN_PERM_THRES
                synSpikes += 1
            end
        end
    end
    if synSpikes > DD_SYN_THRES
        return true
    else
        return false
    end
end

function proximalNMDA(den::DEN, inpVec::Vector{Bool})
    for syn in den.syns
        if inpVec[syn.axnID[1]] == true
            return true
        end
    end
    return false
end

