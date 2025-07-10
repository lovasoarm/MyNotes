import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/foundation.dart';

class GraphQLConfig {
  static String get uri {
    if (kDebugMode) {
      // Pour Flutter Web et mobile, on utilise 127.0.0.1 pour éviter les problèmes CORS // hoan'ny test fotsiny
      return 'http://127.0.0.1:3001/graphql';
    }
      return 'https://your-production-url.com/graphql';
  }

  static GraphQLClient createClient({String? token}) {
          final HttpLink httpLink = HttpLink(uri);
          
          AuthLink? authLink;
          if (token != null) {
            authLink = AuthLink(getToken: () => 'Bearer $token');
          }

          Link link = authLink != null ? authLink.concat(httpLink) : httpLink;

          return GraphQLClient(
            link: link,
            cache: GraphQLCache(store: InMemoryStore()),
          );
  }

  static ValueNotifier<GraphQLClient> createNotifier({String? token}) {
           return ValueNotifier<GraphQLClient>(createClient(token: token));
  }
}
