module Symmetry

# include("HyperParameters.jl")

# using .HyperParameters

#Exports from Symmetry
export rotate90_clockwise, diag_symmetry_y_eq_x, rotations, transform_apple_position
export transform_indices, symmetries, run_transformations, apply_inverse_transform
export all_transformations_with_indices_and_apple, canonical_form_with_indices_and_apple, inverse_transformations

# Fonction pour effectuer une rotation de 90 degrés dans le sens des aiguilles d'une montre (clockwise)
function rotate90_clockwise(mat)
    return permutedims(mat, (2, 1))[end:-1:1,:]  # Transposer et inverser les lignes
end

# Fonction pour effectuer une symétrie selon la diagonale y = x (transposer la matrice)
function diag_symmetry_y_eq_x(mat)
    return permutedims(mat, (2, 1))
end

# Fonction pour générer toutes les rotations d'une matrice avec description (sens horaire)
function rotations(mat)
    return [(mat, "0"), 
            (rotate90_clockwise(mat), "1"), 
            (rotate90_clockwise(rotate90_clockwise(mat)), "2"), 
            (rotate90_clockwise(rotate90_clockwise(rotate90_clockwise(mat))), "3")]
end

# Fonction pour générer les symétries (par rapport à l'axe vertical, horizontal, et la diagonale y = x) avec description
function symmetries(mat)
    return [(mat, "N"), 
            (reverse(mat, dims=1), "V"),  # Symétrie verticale
            (reverse(mat, dims=2), "H"),  # Symétrie horizontale
            (diag_symmetry_y_eq_x(mat), "D")]  # Symétrie par rapport à la diagonale y = x
end

# Fonction pour appliquer une transformation sur une liste d'indices cartésiens
function transform_indices(indices, transformation, mat_size)
    transformed_indices = CartesianIndex[]
    for idx in indices
        new_idx = idx
        for t in transformation
            if t == '1'  # 90 degrés dans le sens des aiguilles d'une montre
                new_idx = CartesianIndex(new_idx[2], -new_idx[1])
            elseif t == '2'  # 180 degrés
                new_idx = CartesianIndex(-new_idx[1], -new_idx[2])
            elseif t == '3'  # 270 degrés
                new_idx = CartesianIndex(-new_idx[2], new_idx[1])
            elseif t == 'V'  # Symétrie verticale
                new_idx = CartesianIndex(new_idx[1], -new_idx[2])
            elseif t == 'H'  # Symétrie horizontale
                new_idx = CartesianIndex(-new_idx[1], new_idx[2])
            elseif t == 'D'  # Symétrie par rapport à la diagonale y = x
                new_idx = CartesianIndex(-new_idx[2], -new_idx[1])
            end
        end
        push!(transformed_indices, new_idx)
    end
    return transformed_indices
end

# Fonction pour appliquer une transformation sur une position de pomme (index cartésien unique)
function transform_apple_position(apple_pos, transformation, mat_size)
    new_pos = apple_pos
    for t in transformation
        if t == '1'  # 90 degrés dans le sens des aiguilles d'une montre
            new_pos = CartesianIndex(new_pos[2], -new_pos[1])
        elseif t == '2'  # 180 degrés
            new_pos = CartesianIndex(-new_pos[1], -new_pos[2])
        elseif t == '3'  # 270 degrés
            new_pos = CartesianIndex(-new_pos[2], new_pos[1])
        elseif t == 'V'  # Symétrie verticale
            new_pos = CartesianIndex(new_pos[1], -new_pos[2])
        elseif t == 'H'  # Symétrie horizontale
            new_pos = CartesianIndex(-new_pos[1], new_pos[2])
        elseif t == 'D'  # Symétrie par rapport à la diagonale y = x
            new_pos = CartesianIndex(-new_pos[2], -new_pos[1])
        end
    end
    return new_pos
end

# Fonction pour générer toutes les transformations possibles (rotations et symétries) avec descriptions, incluant les indices transformés et la position de la pomme transformée
function all_transformations_with_indices_and_apple(mat, indices, apple_pos)
    rot_mats = rotations(mat)
    transformations = [(matrix, sym_desc == "" ? rot_desc : "$sym_desc$rot_desc", transform_indices(indices, sym_desc * rot_desc, size(matrix)), transform_apple_position(apple_pos, sym_desc * rot_desc, size(matrix)))
                       for (rot, rot_desc) in rot_mats 
                       for (matrix, sym_desc) in symmetries(rot)]

    # Utiliser une fonction d'égalité sur les matrices, indices et position de la pomme pour ne garder que les transformations uniques
    unique_mats = Dict{Matrix{Int}, Tuple{String, Vector{CartesianIndex}, CartesianIndex}}()
    for (matrix, desc, transformed_indices, transformed_apple) in transformations
        if !haskey(unique_mats, matrix) || unique_mats[matrix][2] != transformed_indices || unique_mats[matrix][3] != transformed_apple
            unique_mats[matrix] = (desc, transformed_indices, transformed_apple)
        end
    end
    # Retourner les matrices uniques avec leurs descriptions, les indices transformés et la position de la pomme transformée
    return [(matrix, desc, transformed_indices, transformed_apple) for (matrix, (desc, transformed_indices, transformed_apple)) in unique_mats]
end

# Fonction pour trouver la forme canonique (la plus petite version lexicographiquement) avec la transformation appliquée
function canonical_form_with_indices_and_apple(mat, indices, apple_pos)
    transformed_matrices = all_transformations_with_indices_and_apple(mat, indices, apple_pos)
    # Convertir chaque matrice en chaîne de caractères pour comparaison lexicographique
    transformed_strings = map(x -> string(x[1]), transformed_matrices)
    min_index = argmin(transformed_strings)  # Trouve l'index de la matrice minimale
    min_mat, transformation, transformed_indices, transformed_apple = transformed_matrices[min_index]  # Récupère la matrice, la transformation, les indices et la position de la pomme correspondants
    return min_mat, transformation, transformed_indices, transformed_apple
end

# Fonction pour inverser les transformations
function inverse_transformations(applied_transformations::String)
    letter = filter(isletter, applied_transformations)  # Extraire les lettres
    number = parse(Int, filter(isdigit, applied_transformations))  # Extraire le nombre
    inverse_rota = mod(4 - number, 4)  # Calculer 4 - x
    return string(inverse_rota, letter)  # Retourner la nouvelle transformation
end

# Fonction principale pour exécuter le script
function run_transformations(game_state, indices, apple_pos)
    # Trouver la forme canonique et la transformation qui a été appliquée
    canonical_mat, applied_transformation, canonical_indices, canonical_apple_pos = canonical_form_with_indices_and_apple(game_state, indices, apple_pos)
    # Trouver la transformation inverse
    inverse_transform = inverse_transformations(applied_transformation)
    # Retourner les résultats

    return "$(canonical_mat)|$(canonical_apple_pos)|$(canonical_indices)", inverse_transform #|$(canonical_indices)
end

function apply_inverse_transform(inverse_transform::String, direction::Int)
    # Extraire la symétrie et la rotation
    symmetry = filter(isletter, inverse_transform)
    rotation = parse(Int, filter(isdigit, inverse_transform))
    
    # Appliquer la rotation dans le sens horaire
    direction = mod(direction - 1 + rotation, 4) + 1
    
    # Appliquer la symétrie en ajustant la direction
    if symmetry == "V"
        # Inversion gauche-droite : gauche <-> droite (1 <-> 3)
        direction = mod(direction + 1, 4) + 1
    elseif symmetry == "H"
        # Inversion haut-bas : haut <-> bas (0 <-> 2)
        direction = mod(direction + 1, 4) + 1
    elseif symmetry == "D"
        # Symétrie selon y = x : (haut <-> droite), (bas <-> gauche)
        direction = (direction == 1) ? 2 : (direction == 2) ? 1 : (direction == 3) ? 4 : 3
    end
    
    return direction
end

# # Exemple d'utilisation de la fonction principale
# game_state = [
#     4 1
#     3 2
# ]
# indices = [CartesianIndex(1, 0), CartesianIndex(1, 1)]
# apple_pos = CartesianIndex(3, 4)
# canonical_mat, canonical_indices, canonical_apple_pos, inverse_transform = run_transformations(game_state, indices, apple_pos)

# # Afficher les résultats
# println("Forme canonique de la matrice:")
# println(canonical_mat)
# println("Indices canoniques: $canonical_indices")
# println("Position canonique de la pomme: $canonical_apple_pos")
# println("Transformation inverse: $inverse_transform")

end
