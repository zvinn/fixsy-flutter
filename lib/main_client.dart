import 'main_shared.dart';

void main() {
  SharedAppRunner.run(
    FixsyAppConfig(
      flavor: AppFlavor.client,
      appTitle: 'Fixsy - صيانة منازل',
    ),
  );
}
