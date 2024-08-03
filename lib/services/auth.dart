import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getcurrentUser() async {
    return await auth.currentUser;
  }
}
