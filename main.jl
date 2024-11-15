include("TrainSnake.jl")

using .TrainSnake

function main(; episodes=1000, train=true)
    if train
        println("Starting/Continuing training...")
        train_q_learning(episodes)
    else
        println("Loading existing Q-table for play...")
        q_table = load_q_table()
        play_trained_game!(q_table)
    end
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
    main(episodes=episodes, train=train)
end

Main.run_program()

