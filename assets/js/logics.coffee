$( ->
  console.log 'in'
  if window.localStorage and window.localStorage['ghost:session']
    session = JSON.parse(window.localStorage['ghost:session'])
    console.log session
    # get user info
    $.ajax
      url: '/ghost/api/v0.1/users/me/?include=roles&status=all'
    .then (result)->
      console.log result
      html = ''
      if session.user?.image
        html += "<div class=\"image\"><img src=\"#{session.user.image}\" /></div>"
      else
        html += "<div class=\"image\"><img src=\"#{session.user?.image}\" /></div>"
      $('.user-widget').html(html)
  else
    html = '<a class="subscribe-button" href="/signin">Login</a>'
    $('.user-widget').html(html)
)
