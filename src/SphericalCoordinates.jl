
module SphericalCoordinates

	export spherical2cartesian, rand_hypersphere, hypersphere
	# TODO: There is CoordinateTransforms.jl

	"""
		Φ ∈ [0, 2π] × [0, 2π] × ...[0, π]
		Order of coordinates is changed towards
		[here](https://en.wikipedia.org/wiki/N-sphere),
		reversing the order of it and switching N and N+1.
		This means for 2D and 3D coordinates come out as expected.
	"""
	@generated function spherical2cartesian(Φ::NTuple{N, Real}) where N
		expr = quote end
		retval = join(("x_2", "x_1", ntuple(i -> "x_$(i+2)", N-1)...), ", ")
		for i in N:-1:1
			expr = quote
				$expr
				sine, cosine = sincos(Φ[$i])
				$(Symbol("x_$(i+1)")) = cosine * prod_sines
				prod_sines *= sine
			end
		end
		return quote
			local prod_sines = 1.0
			$expr
			$(Symbol("x_1")) = prod_sines
			return $(Meta.parse(retval))
		end
	end

	"""
		Sample random angles from the hypersphere
	"""
	rand_hypersphere(dim::Val{2}) = (2π * rand(),)
	rand_hypersphere(dim::Val{N}) where N = (ntuple(_ -> 2π * rand(), N-2)..., π * rand())

	"""
		Sample the hypersphere regularly (in spherical coordinates)
	"""
	function hypersphere(dim::Val{2}, num::Tuple{Integer})
		return Base.Iterators.product(range(0, 2π * (1 - 1/num[1]); length=num[1]))
	end
	function hypersphere(dim::Val{N}, num::NTuple{M, Integer}) where {N, M}
		@assert N > 2
		@assert M == N - 1
		offset = π / (num[M] + 2)
		return Base.Iterators.product(
			(range(0, 2π * (1 - 1/num[i]); length=num[i]) for i = 1:M-1)...,
			range(offset, π - offset; length=num[M])
		)
	end

end

