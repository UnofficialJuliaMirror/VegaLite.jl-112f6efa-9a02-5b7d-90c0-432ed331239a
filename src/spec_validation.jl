####################################################################
#  JSON plot spec validation
####################################################################

function _conforms(x, ps::String, t::Type)
  isa(x, t) && return
  throw("expected '$t' got '$(typeof(x))' in $ps")
end

conforms(x, ps::String, d::IntDef)    = _conforms(x, ps, Int)
conforms(x, ps::String, d::NumberDef) = _conforms(x, ps, Number)
conforms(x, ps::String, d::BoolDef)   = _conforms(x, ps, Bool)
conforms(x, ps::String, d::RefDef)    = conforms(x, ps, defs[d.ref])
conforms(x, ps::String, d::VoidDef)   = nothing

function conforms(x, ps::String, d::StringDef)
  x = isa(x,Symbol) ? string(x) : x
  _conforms(x, ps, String)
  if length(d.enum) > 0
    if ! (x in d.enum)
      svalid = "[" * join(collect(d.enum),",") * "]"
      throw("'$x' is not one of $svalid in $ps")
    end
  end
  nothing
end

function conforms(x, ps::String, d::ArrayDef)
  _conforms(x, ps, Vector)
  for e in x
    conforms(e, ps, d.items)
  end
  nothing
end

function conforms(d, ps::String, spec::ObjDef)
  isa(d, Dict) || throw("expected object got '$d' in $ps")
  for (k,v) in d
    haskey(spec.props, k) || throw("unexpected param '$k' in $ps")
    conforms(v, ps * k * "(..", spec.props[k])
  end
  for k in spec.required
    haskey(d, k) || throw("required param '$k' missing in $ps")
  end
end

function tryconform(d, ps::String, spec::SpecDef)
  try
    conforms(d, ps, spec)
  catch e
    return false
  end
  true
end

function conforms(d, ps::String, spec::UnionDef)
  causes = String[]
  for s in spec.items
    tryconform(d, ps, s) && return
    try
      conforms(d, ps, s)
    catch e
      isa(e, String) && push!(causes, e)
    end
  end
  scauses = join(unique(causes), ", ")
  throw("no matching specification found for $ps , possibles causes : $scauses")
end