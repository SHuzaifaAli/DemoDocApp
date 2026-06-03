import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, {String? fullName, String? role});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<String?> getUserRole(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) throw Exception('Login failed');
    
    final role = await getUserRole(response.user!.id);
    final profile = await _getProfile(response.user!.id);
    
    return UserModel.fromJson({
      'id': response.user!.id,
      'email': response.user!.email,
      ...profile,
    }, role: role);
  }

  @override
  Future<UserModel> signUp(String email, String password, {String? fullName, String? role}) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user == null) throw Exception('Registration failed');

    // Create profile entry
    await supabase.from('profiles').upsert({
      'id': response.user!.id,
      'full_name': fullName,
    });

    // Assign role if provided
    if (role != null) {
      final roleData = await supabase.from('roles').select('id').eq('name', role).single();
      await supabase.from('user_roles').insert({
        'user_id': response.user!.id,
        'role_id': roleData['id'],
      });
    }

    return UserModel(
      id: response.user!.id,
      email: response.user!.email!,
      fullName: fullName,
      role: role,
    );
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final role = await getUserRole(user.id);
    final profile = await _getProfile(user.id);

    return UserModel.fromJson({
      'id': user.id,
      'email': user.email,
      ...profile,
    }, role: role);
  }

  @override
  Future<String?> getUserRole(String userId) async {
    try {
      final response = await supabase
          .from('user_roles')
          .select('roles(name)')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null && response['roles'] != null) {
        return response['roles']['name'];
      }
    } catch (e) {
      // Handle error or return null
    }
    return null;
  }

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    try {
      return await supabase.from('profiles').select().eq('id', userId).single();
    } catch (e) {
      return {};
    }
  }
}
