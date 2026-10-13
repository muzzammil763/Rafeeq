import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/data/services/country_city_service.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/location_picker_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:rafeeq/utils/localized_font.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  bool _manualExpanded = false;
  bool _updatingAutomatic = false;
  bool _updatingManual = false;
  String? _country;
  String? _countryCode;
  String? _city;

  @override
  void initState() {
    super.initState();
    final location = ref.read(userLocationNotifierProvider);
    _country = location?.country;
    _countryCode = location?.countryCode;
    _city = location?.city;
    if (location?.source == UserLocationSource.manual) {
      _manualExpanded = true;
    }
  }

  Future<void> _useAutomaticLocation() async {
    if (_updatingAutomatic) return;
    setState(() => _updatingAutomatic = true);

    var updated = false;
    try {
      updated = await ref
          .read(userLocationNotifierProvider.notifier)
          .updateUserLocation();
    } catch (_) {
      updated = false;
    }

    if (!mounted) return;
    setState(() => _updatingAutomatic = false);
    if (updated) {
      final location = ref.read(userLocationNotifierProvider);
      setState(() {
        _country = location?.country;
        _countryCode = location?.countryCode;
        _city = location?.city;
      });
      ref
          .read(analyticsServiceProvider)
          .logSettingsLocationChangedToAutomatic();
      _showMessage(context.loc.locationUpdated);
    } else {
      _showMessage(context.loc.locationPermissionDenied);
    }
  }

  Future<void> _chooseCountry() async {
    final country = await Navigator.of(context).push<CountryOption>(
      MaterialPageRoute<CountryOption>(
        settings: const RouteSettings(name: AnalyticsScreenNames.countryPicker),
        builder: (context) => CountryPickerScreen(
          selectedCountryCode: _countryCode,
          selectedCountryName: _country,
        ),
      ),
    );
    if (!mounted || country == null) return;

    final countryChanged = country.code != _countryCode;
    setState(() {
      _country = country.name;
      _countryCode = country.code;
      if (countryChanged) _city = null;
      _manualExpanded = true;
    });
  }

  Future<void> _chooseCity() async {
    if (_country == null || _updatingManual) return;
    final country = await _resolveSelectedCountry();
    if (!mounted || country == null) return;

    final city = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        settings: const RouteSettings(name: AnalyticsScreenNames.cityPicker),
        builder: (context) =>
            CityPickerScreen(country: country, selectedCity: _city),
      ),
    );
    if (!mounted || city == null) return;

    setState(() {
      _city = city;
      _country = country.name;
      _countryCode = country.code;
      _updatingManual = true;
    });

    final updated = await ref
        .read(userLocationNotifierProvider.notifier)
        .setManualLocation(
          country: country.name,
          countryCode: country.code,
          city: city,
        );
    if (!mounted) return;

    setState(() => _updatingManual = false);
    if (updated) {
      ref.read(analyticsServiceProvider).logSettingsLocationChangedToManual();
      _showMessage(context.loc.locationUpdated);
    } else {
      _showMessage(context.loc.locationNotFound);
    }
  }

  Future<CountryOption?> _resolveSelectedCountry() async {
    final countryName = _country;
    if (countryName == null) return null;

    final countryCode = _countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      return CountryOption(name: countryName, code: countryCode, emoji: '');
    }

    setState(() => _updatingManual = true);
    try {
      final countries = await ref.read(countriesProvider.future);
      final normalizedName = countryName.trim().toLowerCase();
      for (final country in countries) {
        if (country.name.toLowerCase() == normalizedName) {
          if (mounted) {
            setState(() {
              _country = country.name;
              _countryCode = country.code;
            });
          }
          return country;
        }
      }
    } catch (_) {
      if (mounted) _showMessage(context.loc.locationDataLoadError);
      return null;
    } finally {
      if (mounted) setState(() => _updatingManual = false);
    }

    if (mounted) await _chooseCountry();
    final resolvedCode = _countryCode;
    final resolvedName = _country;
    if (resolvedCode == null || resolvedName == null) return null;
    return CountryOption(name: resolvedName, code: resolvedCode, emoji: '');
  }

  void _showMessage(String message) {
    showRafeeqToast(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(userLocationNotifierProvider);
    final source = location?.source;

    return SettingsPickerScaffold(
      title: context.loc.location,
      itemCount: 2,
      itemBuilder: (context, index, palette) {
        if (index == 0) {
          return LocationOptionCard(
            icon: Icons.my_location_outlined,
            title: context.loc.allowLocation,
            description: context.loc.allowLocationDescription,
            selected:
                location != null && source == UserLocationSource.automatic,
            loading: _updatingAutomatic,
            palette: palette,
            onTap: _useAutomaticLocation,
          );
        }

        return LocationOptionCard(
          icon: CupertinoIcons.location_slash,
          title: context.loc.manualLocation,
          description: context.loc.manualLocationDescription,
          selected: source == UserLocationSource.manual,
          palette: palette,
          onTap: () => setState(() => _manualExpanded = !_manualExpanded),
          expandedContent: _manualExpanded
              ? ManualLocationSelector(
                  country: _country,
                  city: _city,
                  loading: _updatingManual,
                  onSelectedSurface: source == UserLocationSource.manual,
                  palette: palette,
                  title: context.loc.selectLocation,
                  countryPlaceholder: context.loc.selectCountry,
                  cityPlaceholder: context.loc.selectCity,
                  onCountryTap: _chooseCountry,
                  onCityTap: _chooseCity,
                )
              : null,
        );
      },
    );
  }
}

class LocationOptionCard extends StatelessWidget {
  const LocationOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.palette,
    required this.onTap,
    this.loading = false,
    this.expandedContent,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final bool loading;
  final SettingsPalette palette;
  final VoidCallback onTap;
  final Widget? expandedContent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: selected ? palette.selectedCard : palette.card,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? palette.selectedTitle
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: selected ? palette.selectedCard : palette.accent,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: selected
                                  ? palette.selectedTitle
                                  : palette.title,
                              fontFamily: localizedFontFamily(context),
                              fontSize: 15,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            description,
                            style: TextStyle(
                              color: selected
                                  ? palette.selectedSubtitle
                                  : palette.subtitle,
                              fontFamily: localizedFontFamily(context),
                              fontSize: 14,
                              height: 1.45,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (loading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: selected
                              ? palette.selectedTitle
                              : palette.accent,
                        ),
                      )
                    else if (selected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: palette.selectedTitle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: palette.selectedCard,
                        ),
                      ),
                  ],
                ),
                if (expandedContent != null) ...[
                  const SizedBox(height: 16),
                  expandedContent!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ManualLocationSelector extends StatelessWidget {
  const ManualLocationSelector({
    super.key,
    required this.country,
    required this.city,
    required this.loading,
    required this.onSelectedSurface,
    required this.palette,
    required this.title,
    required this.countryPlaceholder,
    required this.cityPlaceholder,
    required this.onCountryTap,
    required this.onCityTap,
  });

  final String? country;
  final String? city;
  final bool loading;
  final bool onSelectedSurface;
  final SettingsPalette palette;
  final String title;
  final String countryPlaceholder;
  final String cityPlaceholder;
  final VoidCallback onCountryTap;
  final VoidCallback onCityTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: onSelectedSurface ? palette.selectedTitle : palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ManualLocationField(
          value: country,
          placeholder: countryPlaceholder,
          palette: palette,
          onSelectedSurface: onSelectedSurface,
          onTap: onCountryTap,
        ),
        const SizedBox(height: 8),
        ManualLocationField(
          value: city,
          placeholder: cityPlaceholder,
          palette: palette,
          onSelectedSurface: onSelectedSurface,
          enabled: country != null && !loading,
          loading: loading,
          onTap: onCityTap,
        ),
      ],
    );
  }
}

class ManualLocationField extends StatelessWidget {
  const ManualLocationField({
    super.key,
    required this.value,
    required this.placeholder,
    required this.palette,
    required this.onSelectedSurface,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final String? value;
  final String placeholder;
  final SettingsPalette palette;
  final bool onSelectedSurface;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: onSelectedSurface
                  ? palette.selectedSubtitle
                  : palette.accent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: value == null
                      ? Text(
                          value ?? placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: value == null
                                ? onSelectedSurface
                                      ? palette.selectedSubtitle
                                      : palette.subtitle
                                : onSelectedSurface
                                ? palette.selectedTitle
                                : palette.title,
                            fontFamily: localizedFontFamily(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : MediaQuery.withNoTextScaling(
                          child: Text(
                            value!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: onSelectedSurface
                                  ? palette.selectedTitle
                                  : palette.title,
                              fontFamily: 'GoogleSans',
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
                if (loading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onSelectedSurface
                          ? palette.selectedTitle
                          : palette.accent,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: onSelectedSurface
                        ? palette.selectedSubtitle
                        : palette.subtitle,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(
  name: 'Location settings cards',
  group: 'Settings',
  size: Size(390, 620),
)
Widget locationSettingsCardsPreview() {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true, fontFamily: 'GoogleSans'),
    home: Builder(
      builder: (context) {
        final palette = SettingsPalette.of(context);
        return Scaffold(
          backgroundColor: palette.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LocationOptionCard(
                  icon: Icons.my_location_outlined,
                  title: 'Allow Location',
                  description: 'Automatically updates prayer times.',
                  selected: false,
                  palette: palette,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                LocationOptionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Manual Location',
                  description:
                      'Manually select the country and city. Update the location if you change city.',
                  selected: true,
                  palette: palette,
                  onTap: () {},
                  expandedContent: ManualLocationSelector(
                    country: 'Pakistan',
                    city: 'Jhelum',
                    loading: false,
                    onSelectedSurface: true,
                    palette: palette,
                    title: 'Select Location',
                    countryPlaceholder: 'Select Country',
                    cityPlaceholder: 'Select City',
                    onCountryTap: () {},
                    onCityTap: () {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
