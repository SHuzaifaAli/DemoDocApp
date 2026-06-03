import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hospital_booking_management/features/patients/domain/entities/patient_entity.dart';
import 'package:hospital_booking_management/features/patients/domain/repositories/patient_repository.dart';
import 'package:hospital_booking_management/features/patients/domain/usecases/patient_usecases.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late GetPatientProfileUseCase getProfileUseCase;
  late MockPatientRepository mockRepository;

  setUp(() {
    mockRepository = MockPatientRepository();
    getProfileUseCase = GetPatientProfileUseCase(mockRepository);
  });

  final tPatient = PatientEntity(id: '1', fullName: 'John Doe', email: 'john@example.com');

  test('should get patient profile from repository', () async {
    // arrange
    when(() => mockRepository.getProfile(any()))
        .thenAnswer((_) async => tPatient);

    // act
    final result = await getProfileUseCase.execute('1');

    // assert
    expect(result, tPatient);
    verify(() => mockRepository.getProfile('1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
