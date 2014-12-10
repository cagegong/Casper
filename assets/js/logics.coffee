angular.module 'ghost',[]
.constant 'configs', {
  session: JSON.parse(window.localStorage['ghost:session']) if window.localStorage['ghost:session']
  baseUrl: '/ghost/api/v0.1/'
}
.config ($interpolateProvider)->
  $interpolateProvider.startSymbol('{[{')
  $interpolateProvider.endSymbol('}]}')


.config ($httpProvider, configs)->
  $httpProvider.interceptors.push 'authInterceptor'
  $httpProvider.interceptors.push 'urlInterceptor'

.factory 'authInterceptor', ($q, $location, configs) ->

  # Add authorization token to headers
  request: (config) ->
    # When not withCredentials, should not carry Authorization header either
    if config.withCredentials is false
      return config
    config.headers ?= {}
    config.headers.Authorization = 'Bearer ' + configs.session?.access_token
    config

  # Intercept 401s and redirect you to login
  responseError: (response) ->
    if response.status is 401
      $location.url('')
      $q.reject response
    else
      $q.reject response

.factory 'urlInterceptor', ($location, configs) ->
  # Add authorization token to headers
  request: (config) ->
    config.url = configs.baseUrl + config.url if not /^(\/\/|\/|http:|https:)/.test config.url
    config

.run (configs, $http, $rootScope)->
  console.log configs.session
  if configs.session and configs.session.expires_at > (new Date()).valueOf()
    $http.get 'users/me/?include=roles&status=all'
    .then (result)->
      console.log result.status, result
      if result.status is 200
        $rootScope.me = result.data.users[0]

.controller 'index', ($scope, $rootScope)->
  console.log 'hello world'

