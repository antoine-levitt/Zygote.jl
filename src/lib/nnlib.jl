using NNlib
import NNlib: softmax, ∇softmax, logsoftmax, ∇logsoftmax, conv, maxpool, meanpool

@adjoint softmax(xs) = softmax(xs), Δ -> (∇softmax(Δ, xs),)

@adjoint logsoftmax(xs) = logsoftmax(xs), Δ -> (∇logsoftmax(Δ, xs),)

@nograd NNlib.DenseConvDims, NNlib.DepthwiseConvDims, NNlib.PoolDims
@adjoint NNlib.DenseConvDims(args...; kwargs...) = NNlib.DenseConvDims(args...; kwargs...), _ -> nothing

@adjoint conv(x, w, cdims; kw...) =
  conv(x, w, cdims; kw...),
    Δ -> begin
       return (
       NNlib.∇conv_data(Δ, w, cdims; kw...),
       NNlib.∇conv_filter(x, Δ, cdims; kw...),
       nothing,
    )
   end

@adjoint ∇conv_data(x, w, cdims; kw...) =
  ∇conv_data(x, w, cdims; kw...),
    Δ -> begin
       return (
       NNlib.conv(Δ, w, cdims; kw...),
       NNlib.∇conv_filter(x, Δ, cdims; kw...),
       nothing,
    )
   end

@adjoint function maxpool(x, pdims; kw...)
  y = maxpool(x, pdims; kw...)
  y, Δ -> (NNlib.∇maxpool(Δ, y, x, pdims; kw...), nothing)
end

@adjoint function meanpool(x, pdims; kw...)
  y = meanpool(x, pdims; kw...)
  y, Δ -> (NNlib.∇meanpool(Δ, y, x, pdims; kw...), nothing)
end
