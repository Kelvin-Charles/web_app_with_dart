import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';

// Database connection settings
final settings = ConnectionSettings(
  host: 'localhost',
  port: 3306,
  user: 'root',
  // password: 'JustT3st1ng',
  db: 'try_web_app',
);

// Handler for user authentication
Future<Response> authenticateUser(Request request) async {
  var body = await request.readAsString();
  var data = jsonDecode(body);
//   print(body);
//   print(data);

  var username = data['username'];
  var password = data['password'];

  final conn = await MySqlConnection.connect(settings);
  var result = await conn.query(
    'SELECT * FROM users WHERE username = ? AND password = ?',
    [username.toString(), password.toString()],
  );

  if (result.isNotEmpty) {
    var db_usernames = await conn.query("SELECT username FROM users");
    var userList = [];
    for (var user in db_usernames) {
      userList.add(user.first.toString());
    }
    // for (var username in userList) {
    //   username = username.toString();
    var names = [];
    var u_username;
    if (userList.contains(username)) {
      {
        u_username = username;
      }

      var db_names = await conn
          .query("select * from users where username=?", [u_username]);

      await conn.close();

      for (var name in db_names.toList()) {
        names.add(name[1].toString());
        names.add(name[2].toString());
      }
    }
    // return Response.ok(body: jsonEncode({'message': 'User authenticated'}));
    return Response.ok(jsonEncode({'status': 'success', "userdata": names}));
    // return Response.ok([names,status]);
  } else {
    return Response.ok(jsonEncode({'status': 'failed'}));
  }
}

void main() async {
  var router = Router();

  // Enable CORS for frontend communication
  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  // Define the routes
  router.post('/authenticate', authenticateUser);

  // Start the server
  var server = await io.serve(handler, 'localhost', 8081);
  print('Server running on localhost:${server.port}');
}
