util = require 'util'

{createClient} = require 'gremlin'

class BetterClient
  constructor: (opts...) ->
    @client = createClient opts...

  post: (q, values...) ->
    q = util.format q, values...
    console.log "Submitting query", q

    new Promise (resolve, reject) =>
      @client.execute q, (e, r) ->
        if e then reject e else resolve r

client = new BetterClient

{Vertex, Property} = (require 'janus-classes') client

module.exports =
  p: p = (promise) ->
    promise
      .then  (d) -> console.log util.inspect global.d = d, colors: true
      .catch (e) -> console.log "error", (global.e = e).response?.statusMessage or util.inspect e, colors: true

  englishList: englishList = (l, conjunction) ->
    [first..., last] = l

    (switch l.length
      when 0 then []
      when 1 then [l[0]]
      when 2 then [l[0], conjunction, last]
      else        [first.join(", "), conjunction, last]
    ).join " "

  expectOneOf: expectOneOf = (value, types...) ->
    if t = typeof value not in types
      throw new TypeError "Wanted one of #{englishList types, 'or'}, got #{t}"

  expectString: expectString = (value...) ->
    value.forEach (v) ->
      if 'string' isnt t = typeof v
        throw new TypeError "Wanted string, got #{t}"

  client: client
  makeQuery: makeQuery = (queryTemplate, staticValues...) ->
    if staticValues.length
      queryTemplate = util.format queryTemplate, staticValues...

    (dynamicValues...) -> client.post queryTemplate, dynamicValues...

  makeVertexQuery: makeVertexQuery = (args...) ->
    q = makeQuery args...
    (moreArgs...) ->
      q moreArgs...
        .then (vertexes) ->
          vertexes.map (v) -> new Vertex v

  getAll: getAll = makeVertexQuery "g.V()"

  has: has = (propName, propValue) ->
    ret = ".has(%j, %j)"

    if propName
      ret = util.format ret, propName
    if propValue
      ret = util.format ret, propValue

    ret

  lookup: lookup = makeQuery "g.V()" + has()

  property: property = (key, value) -> util.format '.property(%j, %j)', key, value

  named: named = (name) -> lookup 'name', name

  as: as = (alias) ->
    expectString alias
    util.format ".as(%j)", alias

  create: create = (subjects) ->
    for type, instances of subjects
      for name, properties of instances
        do (type, name, properties) ->
          client.post template, type
            .then (created) ->
              created = new Vertex created
              properties.name = name
              for key, value of properties
                created.property key, value

  connect: connect = (a, dir, type, b, props) ->
    expectString a, b
    q = "g" + named(a) + as('a') + named(b)
    q += util.format ".addE(%j).%s('a')", type, dir

    if props
      for key, value of props
        q += property key, value

    client.post q

  connectTo:   connectTo   = (a, type, b, props) -> connect a, 'to',   type, props
  connectFrom: connectFrom = (a, type, b, props) -> connect a, 'from', type, props

  list: list = (regex) ->
    select =
      if regex
        (v) -> v.properties.name.filter(({id, value}) -> value.match regex).length
      else
        -> true

    getAll()
      .then (data) ->
        data.filter select

Object.assign global, module.exports, {Vertex, Property}

