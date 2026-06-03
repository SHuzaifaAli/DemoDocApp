import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hospital_booking_management/features/auth/domain/entities/user_entity.dart';
import 'package:hospital_booking_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:hospital_booking_management/features/auth/domain/usecases/sign_in_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  final tEmail = 'test@example.com';
  final tPassword = 'password123';
  final tUser = UserEntity(id: '1', email: tEmail, role: 'patient');

  test('should sign in user using the repository', () async {
    // arrange
    when(() => mockRepository.signIn(any(), any()))
        .thenAnswer((_) async => tUser);

    // act
    final result = await useCase.execute(tEmail, tPassword);

    // assert
    expect(result, tUser);
    verify(() => mockRepository.signIn(tEmail, tPassword));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw an exception when sign in fails', () async {
    // arrange
    when(() => mockRepository.signIn(any(), any()))
        .thenThrow(Exception('Sign in failed'));

    // act
    final call = useCase.execute(tEmail, tPassword);

    // assert
    expect(() => call, throwsA(isA<Exception>()));
  });
}
