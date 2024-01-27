// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:violence_detector/core/network/dio_client.dart' as _i3;
import 'package:violence_detector/core/services/location_service.dart' as _i8;
import 'package:violence_detector/domain/repositories/i_friends.dart' as _i4;
import 'package:violence_detector/domain/repositories/i_sos.dart' as _i6;
import 'package:violence_detector/infrastructure/repositories/friends_repository.dart'
    as _i5;
import 'package:violence_detector/infrastructure/repositories/sos_repository.dart'
    as _i7;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.DioClient>(() => _i3.DioClient());
    gh.lazySingleton<_i4.IFriends>(
        () => _i5.FriendsRepository(gh<_i3.DioClient>()));
    gh.lazySingleton<_i6.ISOS>(() => _i7.SOSRepository(gh<_i3.DioClient>()));
    gh.lazySingleton<_i8.LocationService>(() => _i8.LocationService());
    return this;
  }
}
