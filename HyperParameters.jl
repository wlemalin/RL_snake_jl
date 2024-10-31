module HyperParameters

export EPSILON, ALPHA, GAMMA
export EMPTY, APPLE, WALL, SNAKE_BODY, SNAKE_HEAD, PADDING, GRID_SIZE, VIEW_RANGE
export UP, RIGHT, DOWN, LEFT
export APPLE_EATEN, VACANT, HURDLE
export INVERSE, CONSTSTEPSIZE, FILENAME

# RL hyperparameters
const EPSILON = 0.03  
const ALPHA = 0.04 
const GAMMA = 0.825

# Game parameters
const EMPTY = 0
const APPLE = 1
const WALL = -1
const SNAKE_BODY = 2
const SNAKE_HEAD = 3
const PADDING = 3
const GRID_SIZE = 10 + 2* PADDING 
const VIEW_RANGE = 2

# Movements
const UP = 1
const RIGHT = 2
const DOWN = 3
const LEFT = 4

# Rewards 
const APPLE_EATEN = 1
const VACANT = 0
const HURDLE = -1

#chepa
const INVERSE = false
const CONSTSTEPSIZE = false

function file_name()
    filename = join([EPSILON, ALPHA, GAMMA, APPLE_EATEN, VACANT, HURDLE, INVERSE, CONSTSTEPSIZE], "_")
    return     replace(filename, "." => "f")
end

const FILENAME = file_name()

end