import 'package:flutter_bloc/flutter_bloc.dart';

/// Which tab the shell is showing. Lives outside the shell widget so
/// any screen can request a tab change (e.g. Home's "See all").
class ShellCubit extends Cubit<int> {
  ShellCubit() : super(0);

  void goTo(int index) => emit(index);
}