class Dashing.Bravolist extends Dashing.Widget
  @accessor 'quote', ->
    "“#{@get('current_comment')?.body}”"

  ready: ->
    @currentIndex = 0
    @commentElem = $(@node).find('.comment-container')
    @nextComment()
    @startCarousel()

  onData: (data) ->
    @currentIndex = 0

  startCarousel: ->
    setInterval(@nextComment, 3000)

  nextComment: =>
    comments = @get('comments')
    if comments
      @commentElem.fadeOut =>
        @currentIndex = (@currentIndex + 1) % comments.length
        @set 'current_comment', comments[@currentIndex]
        if comments[@currentIndex].status=="alive"

          $(@node).css('background-color', 'green');
        else if comments[@currentIndex].status=="dead"
          $(@node).css('background-color', 'red');

        @commentElem.fadeIn()