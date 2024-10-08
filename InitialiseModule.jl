module InitialiseModule


export init_game, place_snake!, place_apple!
export GameState

include("Constantes.jl")
using .Constantes


struct GameState
    vision::Matrix{Int}  # The 5x5 grid around the snake's head
    apple_relative_pos::Tuple{Int, Int}  # Relative position of apple to head
    length::Int  # Current length of snake
end


# Initialize the game world
function init_world()
    # Create grid with walls
    world = fill(WALL, (GRID_SIZE, GRID_SIZE))
    
    # Create playable area
    for i in PADDING+1:GRID_SIZE-PADDING
        for j in PADDING+1:GRID_SIZE-PADDING
            world[i, j] = EMPTY
        end
    end
    
    return world
end

# Initialize snake
function init_snake()
    # Start at the center of the playable area
    head_pos = [GRID_SIZE ÷ 2, GRID_SIZE ÷ 2]
    # Snake starts horizontally, length 3
    body_positions = [
        [head_pos[1], head_pos[2] - 1],
        [head_pos[1], head_pos[2] - 2]
    ]
    
    return head_pos, body_positions
end

# Place snake in the world
function place_snake!(world, head_pos, body_positions)
    world[head_pos[1], head_pos[2]] = SNAKE_HEAD
    for pos in body_positions
        world[pos[1], pos[2]] = SNAKE_BODY
    end
end

# Place apple in the world and return its position
function place_apple!(world)
    empty_positions = [(i, j) for i in 1:GRID_SIZE, j in 1:GRID_SIZE if world[i, j] == EMPTY]
    if !isempty(empty_positions)
        apple_pos = rand(empty_positions)
        world[apple_pos[1], apple_pos[2]] = APPLE
        return apple_pos
    end
    return nothing
end


# Initialize game
function init_game()
    world = init_world()
    head_pos, body_positions = init_snake()
    place_snake!(world, head_pos, body_positions)
    apple_pos = place_apple!(world)
    
    return world, head_pos, body_positions, apple_pos
end


end

