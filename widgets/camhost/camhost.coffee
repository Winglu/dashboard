class Dashing.Camhost extends Dashing.Widget
  @accessor 'quote', ->
    "“#{@get('current_status')?.body}”"

  ready: ->
    @currentIndex = 0
    @commentElem = $(@node).find('.status-container')
    @nextComment()
    @startCarousel()

  onData: (data) ->
    @currentIndex = 0

  startCarousel: ->
    setInterval(@nextComment, 10000)

  nextComment: =>
    comments = @get('cam_host_status')
    if comments
      @commentElem.fadeOut =>
        @currentIndex = (@currentIndex + 1) % comments.length
        @set 'current_status', comments[@currentIndex]
        if comments[@currentIndex].cam=="Missing"||comments[@currentIndex].spin=="Missing"||comments[@currentIndex].cosmos=="Missing"
          $(@node).addClass("red");
        else if comments[@currentIndex].cam=="Troubled"||comments[@currentIndex].spin=="Troubled"||comments[@currentIndex].cosmos=="Troubled"
          $(@node).addClass("yellow");
        else
          $(@node).addClass("green");

        @commentElem.fadeIn()