

"""
Comparison of reconstruction errors of OtrisymNMF, ONMF et SymNMF on CBCL dataset 

"""


using MAT
using Printf
using Random
using LightGraphs # Charger le package LightGraphs pour manipuler les graphes
using Plots # Charger le package Plots pour les tracés
using LinearAlgebra
using GraphPlot
using Images

include("../algo/OtrisymNMF.jl")
include("../algo/ONMF.jl")
include("../algo/symNMF.jl")
include("utils/affichage.jl")
Random.seed!(123)



function test()
    # Charger le fichier karate.mat
    file_path = "dataset/CBCL.mat"
    mat = matread(file_path)
    A = mat["X"]

    X=A*A'
    ###########OPTIONS##################################################
    r =50
    init="sspa"
    maxiter=10000
    timelimit=30
    epsi=10e-7
    nbr_tests=5
    nbr_algo=4

    # Initialisation des tableaux pour stocker les temps et les erreurs
    n=size(X)[1]
    Wb=zeros(n,r)
    temps_execution = zeros(nbr_algo,nbr_tests)
    erreurs = zeros(nbr_algo,nbr_tests)
    # Boucle pour effectuer les tests
    for i in 1:nbr_tests
        temps_execution[1,i] = @elapsed begin
            Wb, S, erreur = OtrisymNMF_CD(X, r, maxiter, epsi,init, timelimit)
        end
        erreurs[1,i] = erreur

        temps_execution[2,i] = @elapsed begin
            W, H, erreur = alternatingONMF(X, r, maxiter, epsi,init)
        end
        erreurs[2,i] = erreur

        temps_execution[3,i] = @elapsed begin
            A, erreur = SymNMF(X, r; max_iter=maxiter, max_time=timelimit, tol=epsi, A_init=init)
        end
        erreurs[3,i] = erreur
        temps_execution[4,i] = @elapsed begin
            W,S, erreur = OtrisymNMF_MU(X, r, maxiter, epsi, init,timelimit)
        end
        erreurs[4,i] = erreur
    end

    # Calcul de la moyenne et de l'écart type des temps et des erreurs
    moyenne_temps = mean(temps_execution, dims=2)
    ecart_type_temps = std(temps_execution, dims=2)
    moyenne_erreurs = mean(erreurs, dims=2)
    ecart_type_erreurs = std(erreurs, dims=2)
    # Création du graphique
    methods = ["symTriONMF", "ONMF", "SymNMF","MU"]
    # Affichage des résultats
    for j in 1:nbr_algo
        println("Temps d'exécution pour la méthode ", methods[j], " : ", @sprintf("%.3g", moyenne_temps[j, 1])," +_ ", @sprintf("%.3g", ecart_type_temps[j, 1]), " secondes")
    
        println("l'erreur % pour la méthode ", methods[j], " : ", @sprintf("%.3g", moyenne_erreurs[j, 1]*100)," +_  ",@sprintf("%.3g", ecart_type_erreurs[j, 1]*100)," %")
    end   
    # Création du graphique

    # Enregistrement des résultats dans un fichier texte
    nom_fichier_resultats = "resultats_CBCL.txt"
    # Enregistrement des résultats dans un fichier texte
    open(nom_fichier_resultats, "w") do io
        write(io, "Paramètres :\n")
        write(io, "maxiter = $maxiter\n")
        write(io, "timelimit = $timelimit\n")
        write(io, "epsi = $epsi\n")
        write(io, "nbr_tests = $nbr_tests\n\n")
        write(io, "Moyennes des temps d'exécution :\n")
        write(io, "$methods\n")
        write(io, join(@sprintf("%.3g", x) for x in vec(moyenne_temps)) * "\n\n")
        write(io, "Écart types des temps d'exécution :\n")
        write(io, "$methods\n")
        write(io, join(@sprintf("%.3g", x) for x in vec(ecart_type_temps)) * "\n\n")
        write(io, "Moyennes des erreurs :\n")
        write(io, "$methods\n")
        write(io, join(@sprintf("%.3g", x) for x in vec(moyenne_erreurs)) * "\n\n")
        write(io, "Écart types des erreurs :\n")
        write(io, "$methods\n")
        write(io, join(@sprintf("%.3g", x) for x in vec(ecart_type_erreurs)) * "\n")
    end

    scatter_plot_temps=scatter(methods, moyenne_temps[:, 1], yerr=ecart_type_temps[:, 1], label="Temps d'exécution moyen ± écart-type", xlabel="Méthode", ylabel="Temps d'exécution (s)", title="Comparaison des méthodes sur KARATE")
    scatter_plot_erreurs=scatter(methods, moyenne_erreurs[:, 1], yerr=ecart_type_erreurs[:, 1], label="Erreur moyenne ± écart-type", xlabel="Méthode", ylabel="Erreur", title="Comparaison des méthodes sur KARATE")
    savefig(scatter_plot_temps, "CBCL_temps.png")
    savefig(scatter_plot_erreurs, "CBCL_erreur.png")
    return Wb
end 
# # Créer un dictionnaire contenant la matrice W
Wb=test()
variables = Dict("W" => Wb)

# Enregistrer le fichier .mat
matwrite("WCBCL.mat", variables)
# # Créer un dictionnaire contenant la matrice W
# variableS= Dict("S" => S)


# # Enregistrer le fichier .mat
# matwrite("Sc.mat", variableS)
# # Afficher la heatmap
# # Afficher la heatmap


# display(affichage(W))

# # Convertir l'affichage en une image
