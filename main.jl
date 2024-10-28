include("Qtable.jl")
include("TrainSnake.jl")

using .Qtable
using .TrainSnake

function main(; episodes=1000, train=true)
    if train
        println("Starting/Continuing training...")
        q_table, rewards, lengths = train_q_learning(episodes)
    else
        println("Loading existing Q-table for play...")
        q_table = load_q_table()
        rewards = []
        lengths = []
    end

    return q_table, rewards, lengths
end

function parse_arguments()
    if length(ARGS) > 0
        if ARGS[1] == "train"
            episodes = length(ARGS) > 1 ? parse(Int, ARGS[2]) : 1000
            return true, episodes
        elseif ARGS[1] == "play"
            return false, 0
        end
    end
    return true, 1000  
end

function run_program()
    train, episodes = parse_arguments()
    q_table, rewards, lengths = main(episodes=episodes, train=train)
    return q_table, rewards, lengths
end

q_table, rewards, lengths = Main.run_program()
println(rewards, lengths)
