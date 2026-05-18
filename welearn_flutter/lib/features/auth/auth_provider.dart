import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/models/user_model.dart';
import '../../core/services/storage_service.dart';

// ── Auth State ────────────────────────────────────────────────────────────────
class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    String? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        error: error,
      );
}

// ── Auth Notifier ─────────────────────────────────────────────────────────────
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return _loadPersistedSession();
  }

  Future<AuthState> _loadPersistedSession() async {
    final token = await StorageService.getToken();
    final cachedUser = StorageService.getCachedUser();
    if (token != null && cachedUser != null) {
      final user = UserModel.fromJsonString(cachedUser);
      // Verify token is still valid
      try {
        final client = ref.read(apiClientProvider);
        final res = await client.get(ApiEndpoints.myProfile);
        final freshUser = UserModel.fromJson(
            (res.data['data'] ?? res.data['user'] ?? res.data)
                as Map<String, dynamic>);
        await StorageService.cacheUser(freshUser.toJsonString());
        return AuthState(user: freshUser, isAuthenticated: true);
      } catch (_) {
        return AuthState(user: user, isAuthenticated: true);
      }
    }
    return const AuthState(isAuthenticated: false);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await StorageService.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }
      await StorageService.cacheUser(authResponse.user.toJsonString());
      state = AsyncData(AuthState(
        user: authResponse.user,
        isAuthenticated: true,
      ));
    } catch (e) {
      state = AsyncData(AuthState(
        isAuthenticated: false,
        error: handleDioError(e).message,
      ));
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.post(ApiEndpoints.register, data: data);
      final authResponse = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await StorageService.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }
      await StorageService.cacheUser(authResponse.user.toJsonString());
      state = AsyncData(AuthState(
        user: authResponse.user,
        isAuthenticated: true,
      ));
    } catch (e) {
      state = AsyncData(AuthState(
        isAuthenticated: false,
        error: handleDioError(e).message,
      ));
    }
  }

  Future<void> logout() async {
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.logout);
    } catch (_) {}
    await StorageService.clear();
    state = const AsyncData(AuthState(isAuthenticated: false));
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.patch(ApiEndpoints.updateProfile, data: data);
      final updatedUser = UserModel.fromJson(
          (res.data['data'] ?? res.data['user'] ?? res.data)
              as Map<String, dynamic>);
      await StorageService.cacheUser(updatedUser.toJsonString());
      state = AsyncData(
          state.value!.copyWith(user: updatedUser));
    } catch (e) {
      // Don't clear state on profile update error
    }
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Convenience provider
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.user;
});
