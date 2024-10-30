module TrainDat

using CSV
using DataFrames

export add_data

function add_data(snake_length::Int, steps::Int, total_reward::Int; folder="visualisation/data", file="data.csv")
    mkpath(folder)
    file = joinpath(folder, file)

    if isfile(file)
        data = CSV.read(file, DataFrame)
        
        last_episode = data[!, :episode][end]
        new_episode = last_episode + 1
    else
        data = DataFrame(episode=Int[], snake_length=Int[], steps=[], total_reward=[])
        new_episode = 1
    end

    new_row = DataFrame(episode=[new_episode], snake_length=[snake_length], steps=[steps], total_reward=[total_reward])
    append!(data, new_row)

    CSV.write(file, data)
    
    #println("Added episode $new_episode with snake length $snake_length to $file")
end

end
