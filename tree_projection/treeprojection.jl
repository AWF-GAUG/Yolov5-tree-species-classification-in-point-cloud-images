using Distributed
@everywhere begin
	using Pkg; Pkg.activate(@__DIR__)
	Pkg.instantiate(); Pkg.precompile()
end

@everywhere using FileIO
@everywhere using LasIO
@everywhere using Plots
@everywhere using LinearAlgebra
@everywhere using Base.Threads
@everywhere using GLMakie
@everywhere using Makie
@everywhere using Distributed
@everywhere using StaticArrays

@everywhere begin
	las2jl(p, header) = @SVector [xcoord(p, header), ycoord(p, header), zcoord(p, header)]

	findhighestpoint(points) = points[argmax(getindex.(points, 3))]

	function hist2d(points, xbins, ybins)
		output = zeros(Int32, length(ybins), length(xbins))
		for p in points
			x = floor(Int, (p[1] - minimum(xbins)) / step(xbins)) + 1
			y = floor(Int, (p[2] - minimum(ybins)) / step(ybins)) + 1
			output[y, x] += 1
		end
		return output
	end

	function offset(points)
		highestpoint = findhighestpoint(points)
		return @SVector [highestpoint[1], highestpoint[2], 0]
	end

	function get_plane(angle)
		u = @SVector [cos(angle), sin(angle), 0]
		v = @SVector [0., 0., 1.]
		n = @SVector [-sin(angle), cos(angle), 0]
		return u, v, n
	end

	function project_to_plane(p, u, v)
    	return @SVector [dot(p, u), dot(p,v)]
	end

	function process_tree(input_file, output_folder)
	
		header, laspoints = load(input_file)
	
		jlpoints = [las2jl(p, header) for p in laspoints]
		o = offset(jlpoints)
		global shifted_points = [p - o for p in jlpoints]
	
		for angle in (0, 45, 90, 135)
			filename = split(basename(input_file), '.')[1]
			filepath = joinpath(output_folder, "$(filename)_$angle.png")

			u,v,n = get_plane(deg2rad(angle))
		
			selected_points = shifted_points#[scalar_prod .> 0]
		
			projected_points = [project_to_plane(p, u, v) for p in selected_points]
		
			xext = extrema(getindex.(projected_points, 1))
			yext = extrema(getindex.(projected_points, 2))
			xl = xext[2] - xext[1]
			yl = yext[2] - yext[1]
			ypx = 1000
			xpx = round(Int, (ypx/(yl/xl)))
			pd = sqrt((xl*yl) / length(projected_points))
			xr = range(;start=xext[1], step=pd, stop=xext[2])
			yr = range(;start=yext[1], step=pd, stop=yext[2])
		
			arr = hist2d(projected_points, xr, yr)
			larr = log.(arr)

			fig = Figure(resolution = (600,800))
			ax = Axis(fig[1, 1], aspect = xpx/ypx)
			hidedecorations!(ax)
			hidespines!(ax)
			Makie.heatmap!(ax, larr'; colormap=:binary, colorrange=(-1, maximum(larr)*0.5))
			save(filepath, fig)

		end
		return nothing
	end
end #everywhere

function main(args)
	path = args[1]
	species_folders = filter(isdir, readdir(path, join=true))
	output_folder = args[2]
	nfolder = length(species_folders)
 	@sync pmap(1:nfolder) do i
		output_folder_name = basename(species_folders[i])
		println("processing $output_folder_name")
		files = readdir(species_folders[i], join=true)
		for file in files
			println("processing $file")
			process_tree(file, joinpath(output_folder, output_folder_name))
		end
	end
end

@time main(ARGS)
