class Dashing.Bravotext extends Dashing.Widget



  refreshWidgetState: =>
    node = $(@node)
    node.removeClass('dead alive fade envTitle')

    node.addClass(@get('text'))
    node.addClass(@get('moreinfo'))
    if @get('title')=="congo"&&@get('title')=="ganges"&&@get('title')=="mekong"&&@get('title')=="thames"&&@get('title')=="danube"&&@get('title')=="zambeze"&&@get('title')=="murray"&&@get('title')=="yarra"&&@get('title')=="nile"&&@get('title')=="tste"&&@get('title')=="tstf"&&@get('title')=="tstg"
      node.addClass("envTitle")



  ready: ->

  onData: (data) ->
    @refreshWidgetState()