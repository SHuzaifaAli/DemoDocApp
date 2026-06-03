import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hospital_booking_management/features/auth/presentation/screens/login_screen.dart';
import 'package:hospital_booking_management/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hospital_booking_management/features/auth/domain/usecases/sign_in_usecase.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}
class MockSignUpUseCase extends Mock implements SignUpUseCase {}
class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

void main() {
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late AuthController controller;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    controller = AuthController(
      signInUseCase: mockSignInUseCase,
      signUpUseCase: mockSignUpUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
    );
    Get.put(controller);
  });

  tearDown(() {
    Get.delete<AuthController>();
  });

  Widget createWidgetUnderTest() {
    return GetMaterialApp(
      home: LoginScreen(),
    );
  }

  testWidgets('should display login form elements', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('should show error when email is empty', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter email'), findsOneWidget);
  });
}
