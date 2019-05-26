include("Minicols.jl")

function actionPotential!(lyr::LYR, inpVec::Vector{Bool})
    for i in eachindex(lyr.mncs)
        actionPotential!(lyr.mncs[i], inpVec)
    end
end

function depolarize!(lyr::LYR)
    for i in eachindex(lyr.mncs)
        depolarize!(lyr.mncs[i], lyr)
    end
end

function poolActiveNeurons(lyr::LYR)
    activeNeurons::Vector{Tuple} = []
    for i in eachindex(lyr.mncs)
        for j in eachindex(lyr.mncs[i].nrns)
            if lyr.mncs[i].nrns[j].axon == true
                push!(activeNeurons, (i,j))
            end
        end
    end
    return activeNeurons
end

function semiRest!(lyr::LYR)
    for i in eachindex(lyr.mncs)
        semiRest!(lyr.mncs[i])
    end
end

function growDistalSyns!(lyr::LYR, activeNeurons::Vector{Tuple})
    for i in eachindex(lyr.mncs)
        growDistalSyns!(lyr.mncs[i], activeNeurons)
    end
end

function rest!(lyr::LYR)
    for i in eachindex(lyr.mncs)
        rest!(lyr.mncs[i])
    end
end

function poolPredictiveNeurons(lyr::LYR)
    predictiveNeurons::Vector{Tuple} = []
    for i in eachindex(lyr.mncs)
        for j in eachindex(lyr.mncs[i].nrns)
            if lyr.mncs[i].nrns[j].depol == true
                push!(predictiveNeurons, (i,j))
            end
        end
    end
    return predictiveNeurons
end
