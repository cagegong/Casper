angular.module('ghost', []).constant('configs', {
  session: window.localStorage['ghost:session'] ? JSON.parse(window.localStorage['ghost:session']) : void 0,
  baseUrl: '/ghost/api/v0.1/'
}).config(function($interpolateProvider) {
  $interpolateProvider.startSymbol('{[{');
  return $interpolateProvider.endSymbol('}]}');
}).config(function($httpProvider, configs) {
  $httpProvider.interceptors.push('authInterceptor');
  return $httpProvider.interceptors.push('urlInterceptor');
}).factory('authInterceptor', function($q, $location, configs) {
  return {
    request: function(config) {
      var _ref;
      if (config.withCredentials === false) {
        return config;
      }
      if (config.headers == null) {
        config.headers = {};
      }
      config.headers.Authorization = 'Bearer ' + ((_ref = configs.session) != null ? _ref.access_token : void 0);
      return config;
    },
    responseError: function(response) {
      if (response.status === 401) {
        $location.url('');
        return $q.reject(response);
      } else {
        return $q.reject(response);
      }
    }
  };
}).factory('urlInterceptor', function($location, configs) {
  return {
    request: function(config) {
      if (!/^(\/\/|\/|http:|https:)/.test(config.url)) {
        config.url = configs.baseUrl + config.url;
      }
      return config;
    }
  };
}).run(function(configs, $http, $rootScope) {
  console.log(configs.session);
  if (configs.session && configs.session.expires_at > (new Date()).valueOf()) {
    return $http.get('users/me/?include=roles&status=all').then(function(result) {
      console.log(result.status, result);
      if (result.status === 200) {
        return $rootScope.me = result.data.users[0];
      }
    });
  }
}).controller('index', function($scope, $rootScope) {
  return console.log('hello');
});
