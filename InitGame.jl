module InitGame

include("HyperParameters.jl")

using .HyperParameters

#Exports from HyperParameters.jl
export EPSILON, ALPHA, GAMMA
export EMPTY, APPLE, WALL, SNAKE_BODY, SNAKE_HEAD, PADDING, GRID_SIZE, VIEW_RANGE
export UP, RIGHT, DOWN, LEFT
export APPLE_EATEN, VACANT, HURDLE

#Exports from InitGame
export init_world, init_snake, place_snake!, place_apple!
export update_vision!, update_state!, init_game, StateGame

mutable struct StateGame

    vision::Matrix{Int}
    apple_pos::CartesianIndex
    apple_relative_pos::CartesianIndex
    length::Int
    head_pos::CartesianIndex
    body_positions::Vector{CartesianIndex}
    body_relative_pos::Vector{CartesianIndex}
    world::Matrix{Int}

    function StateGame(world::Matrix{Int})

        length = count(x -> x == SNAKE_BODY, world)
        apple_pos = findfirst(x -> x == APPLE, world)
        head_pos = findfirst(x -> x == SNAKE_HEAD, world)
        apple_relative_pos = CartesianIndex(apple_pos[1] - head_pos[1], apple_pos[2] - head_pos[2])
        vision = zeros(Int, 2*VIEW_RANGE+1, 2*VIEW_RANGE+1)
        body_positions = reverse(collect(findall(x -> x == SNAKE_BODY, world)))
        body_relative_pos = [CartesianIndex(body[1] - head_pos[1], body[2] - head_pos[2]) for body in body_positions]

        new(vision, apple_pos, apple_relative_pos, length, head_pos, body_positions, body_relative_pos, world)

    end

end

function init_world()
    world = fill(WALL, (GRID_SIZE, GRID_SIZE))
    
    for i in PADDING+1:GRID_SIZE-PADDING
        for j in PADDING+1:GRID_SIZE-PADDING
            world[i, j] = EMPTY
        end
    end
    
    return world
end

function init_snake()
    head_pos = CartesianIndex(GRID_SIZE ÷ 2, GRID_SIZE ÷ 2)
    body_positions = [
        CartesianIndex(head_pos[1], head_pos[2] - 1),
        CartesianIndex(head_pos[1], head_pos[2] - 2)
    ]
    
    return head_pos, body_positions
end

function place_snake!(world, head_pos, body_positions)
    world[head_pos] = SNAKE_HEAD
    for pos in body_positions
        world[pos] = SNAKE_BODY
    end
end

function place_apple!(world)
    empty_positions = [CartesianIndex(i, j) for i in 1:GRID_SIZE, j in 1:GRID_SIZE if world[i, j] == EMPTY]
    if !isempty(empty_positions)
        apple_pos = rand(empty_positions)
        world[apple_pos] = APPLE
    end
end

function update_vision!(game::StateGame)

    for i in -VIEW_RANGE:VIEW_RANGE
        for j in -VIEW_RANGE:VIEW_RANGE
            y, x = game.head_pos[1] + i, game.head_pos[2] + j
            game.vision[i+VIEW_RANGE+1, j+VIEW_RANGE+1] = game.world[y, x]
        end
    end

end

function update_state!(game::StateGame)
    game.length = count(x -> x == SNAKE_BODY, game.world)
    game.apple_pos = findfirst(x -> x == APPLE, game.world)
    game.apple_relative_pos = CartesianIndex(game.apple_pos[1] - game.head_pos[1], 
                                            game.apple_pos[2] - game.head_pos[2])
    game.body_relative_pos = [CartesianIndex(body[1] - game.head_pos[1], body[2] - game.head_pos[2]) for body in game.body_positions]
    update_vision!(game)
    
end

function init_game()
    world = init_world()
    head_pos, body_positions = init_snake()
    place_snake!(world, head_pos, body_positions)
    place_apple!(world)
    game = StateGame(world)
    update_vision!(game)
    return game
end

end