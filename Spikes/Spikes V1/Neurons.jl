include("Dendrites.jl")

function actionPotential!(nrn::NRN, inpVec::Vector{Bool})
    for pden in nrn.proximal
        if proximalNMDA(pden, inpVec) == true
            nrn.axon = true
            break
        end
    end
end

function depolarize!(nrn::NRN, layer::LYR)
    for dden in nrn.distal
        if distalNMDA(dden, layer) == true
            nrn.depol = true
            break
        end
    end
end

function semiRest!(nrn::NRN)
    nrn.axon = false
end

function locateSyn(nrn::NRN, id::Tuple)
    synID = Nullable{Tuple}()
    for i in eachindex(nrn.distal)
        for j in eachindex(nrn.distal[i].syns)
            if nrn.distal[i].syns[j].axnID == id
                synID = (i,j)
                return synID
            end
        end
    end
    return synID
end


function growDistalSyns!(nrn::NRN, activeNeurons::Vector{Tuple})
    if nrn.axon == false && nrn.depol == true
        for nrnID in activeNeurons
            synID = locateSyn(nrn, nrnID)
            if isnull(synID) == false
                if nrn.distal[synID[1]].syns[synID[2]]perm <= 0.0
                    splice!(nrn.distal[synID[1]].syns, synID[2])
                else
                    nrn.distal[synID[1]].syns[synID[2]].perm -= Float16(SYN_PERM_INC)
                end
            end
        end
    elseif nrn.axon == true
        for nrnID in activeNeurons
            synID = locateSyn(nrn, nrnID)
            if isnull(synID) == false
                if nrn.distal[synID[1]].syns[synID[2]].perm >= 1.0
                    break
                else
                    nrn.distal[synID[1]].syns[synID[2]].perm += Float16(SYN_PERM_INC)
                end
            else
                if 0 < length(nrn.distal[end].syns) <= MAX_DD_SYNS
                    push!(nrn.distal[end].syns, SYN(nrnID, Float16(DEF_SYN_PERM)))
                else
                    push!(nrn.distal, DEN([]))
                    push!(nrn.distal[end].syns, SYN(nrnID, Float16(DEF_SYN_PERM)))
                end
            end
        end
    end
end

function rest!(nrn::NRN)
    nrn.depol = false
end
