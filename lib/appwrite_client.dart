import 'package:appwrite/appwrite.dart';
import 'package:my_app/environment.dart';

class AppwriteClient {
  Client get client => Client()
    ..setEndpoint(Environment.appwritePublicEndpoint)
    ..setProject(Environment.appwriteProjectId);

  Account get account => Account(client);
  Databases get databases => Databases(client);
  Storage get storage => Storage(client);
}
