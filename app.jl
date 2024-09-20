module App
using Revise
if ENV["GENIE_ENV"] == "prod"
  include("Contracts.jl")
  include("Yelt.jl")
else
  includet("Contracts.jl")
  includet("Yelt.jl")
end
end
