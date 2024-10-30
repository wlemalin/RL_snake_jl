module TrainDat

using CSV
using DataFrames

export add_data

function add_data(snake_length::Vector{Int}, steps::Vector{Int}, total_reward::Vector{Float64}; folder="visualisation/data", file="data.csv")
    mkpath(folder)
    file = joinpath(folder, file)

    if isfile(file)
        data = CSV.read(file, DataFrame)       
        last_episode = data[!, :episode][end]
    else
        data = DataFrame(episode=Int[], snake_length=Int[], steps=Int[], total_reward=Int[])
        last_episode = 0
    end

    new_episodes = last_episode .+ (1:length(snake_length))
    new_row = DataFrame(episode=new_episodes, snake_length=snake_length, steps=steps, total_reward=total_reward)
    append!(data, new_row)

    CSV.write(file, data)
    
    println("Added $(length(snake_length)) episodes to $file")
end

end
