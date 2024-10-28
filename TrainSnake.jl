module TrainSnake

include("Qtable.jl")
include("PlayGame.jl")

using .PlayGame
using .Qtable

using Random
using Statistics

#Exports from HyperParameters.jl
export EPSILON, ALPHA, GAMMA
export EMPTY, APPLE, WALL, SNAKE_BODY, SNAKE_HEAD, PADDING, GRID_SIZE, VIEW_RANGE
export UP, RIGHT, DOWN, LEFT
export APPLE_EATEN, VACANT, HURDLE

#Exports from InitGame
export init_world, init_snake, place_snake!, place_apple!
export update_vision!, update_state!, init_game, StateGame

#Exports from PlayGame
export action_to_direction, step!, print_world, state_to_key, get_q_values, check_haskey!, play_trained_game!

#Exports from TrainSnake
export update_q_table!, egreedy, train_q_learning

#Exports from Qtable
export save_q_table, load_q_table

function update_q_table!(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, 
    current_key, action::Int, reward::Any, next_key)

    check_haskey!(q_table, current_key)
    check_haskey!(q_table, next_key)

    current_q = q_table[current_key][1][action]
    next_max_q = maximum(q_table[next_key][1])

    q_table[current_key][1][action] = current_q + ALPHA * (reward + GAMMA * next_max_q - current_q)
    q_table[current_key][2][action] += 1
end

function egreedy(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, game::StateGame)
    if rand() < EPSILON 
        return rand(1:4)
    else
        q_values = get_q_values(q_table, game)
        return argmax(q_values)
    end
end

function train_q_learning(episodes::Int; max_steps=1000)
    q_table = load_q_table()
    episode_rewards = zeros(episodes)
    episode_lengths = zeros(Int, episodes)

    for episode in 1:episodes
        game = init_game()
        total_reward = 0
        steps = 0

        for step in 1:max_steps
            action = egreedy(q_table, game)
            current_key = state_to_key(game)

            game_over, reward, new_apple_pos = step!(game, action)
            apple_pos = new_apple_pos

            next_key = state_to_key(game)

            q_reward = reward

            if game_over
                q_reward = HURDLE
            end

            update_q_table!(q_table, current_key, action, q_reward, next_key)

            total_reward += reward
            steps += 1

            if game_over
                break
            end

        end

        episode_rewards[episode] = total_reward
        episode_lengths[episode] = steps

        if episode % 50000 == 0
            println("Episode $episode: Reward = $total_reward, Steps = $steps")
            save_q_table(q_table)
        end
    end

    save_q_table(q_table)

    return q_table, episode_rewards, episode_lengths
    
end

end