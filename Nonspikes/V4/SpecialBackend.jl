function compareUnit(prediction, output)
    if prediction == true && output == true
        return 1
    elseif prediction == true && output == false
        return -1
    elseif prediction == false && output == true
        return 2
    elseif prediction == false && output == false
        return 0
    end
end


function compareMatrix(predictions, outSDR)
    cmpMatrix::AbstractArray = []
    for col in eachindex(predictions)
        push!(cmpMatrix, compareUnit.(predictions[col], outSDR[col]))
    end
    return cmpMatrix
end

