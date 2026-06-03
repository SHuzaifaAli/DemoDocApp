import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hospital_booking_management/features/doctors/domain/entities/doctor_profile_entity.dart';
import 'package:hospital_booking_management/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:hospital_booking_management/features/doctors/domain/usecases/doctor_usecases.dart';

class MockDoctorRepository extends Mock implements DoctorRepository {}

void main() {
  late GetDoctorProfileUseCase getProfileUseCase;
  late MockDoctorRepository mockRepository;

  setUp(() {
    mockRepository = MockDoctorRepository();
    getProfileUseCase = GetDoctorProfileUseCase(mockRepository);
  });

  final tDoctor = DoctorProfileEntity(
    id: '1',
    fullName: 'Dr. Smith',
    specialty: 'Cardiology',
    hospitalName: 'City Hospital',
  );

  test('should get doctor profile from repository', () async {
    // arrange
    when(() => mockRepository.getProfile(any()))
        .thenAnswer((_) async => tDoctor);

    // act
    final result = await getProfileUseCase.execute('1');

    // assert
    expect(result, tDoctor);
    verify(() => mockRepository.getProfile('1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
