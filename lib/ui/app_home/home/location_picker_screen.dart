import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/services/country_city_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/utils/localized_font.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';

class CountryPickerScreen extends ConsumerStatefulWidget {
  const CountryPickerScreen({
    super.key,
    this.selectedCountryCode,
    this.selectedCountryName,
  });

  final String? selectedCountryCode;
  final String? selectedCountryName;

  @override
  ConsumerState<CountryPickerScreen> createState() =>
      _CountryPickerScreenState();
}

class _CountryPickerScreenState extends ConsumerState<CountryPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final countries = ref.watch(countriesProvider);
    final bottomPadding = quranPlayerAwareBottomPadding(
      context,
      playerVisible: QuranPlayerVisibility.of(context),
    );

    return LocationPickerScaffold(
      title: context.loc.selectCountry,
      searchHint: context.loc.search,
      palette: palette,
      onQueryChanged: (value) => setState(() => _query = value),
      child: countries.when(
        data: (values) {
          final filtered = values.where(_matchesQuery).toList();
          if (filtered.isEmpty) {
            return LocationPickerEmptyState(
              message: context.loc.noResultsFound,
              palette: palette,
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final country = filtered[index];
              return LocationPickerRow(
                title: country.name,
                selected: _isSelected(country),
                palette: palette,
                onTap: () => Navigator.of(context).pop(country),
              );
            },
          );
        },
        loading: () => LocationPickerLoadingState(palette: palette),
        error: (error, stackTrace) => LocationPickerErrorState(
          palette: palette,
          message: context.loc.locationDataLoadError,
          retryLabel: context.loc.retry,
          onRetry: () => ref.invalidate(countriesProvider),
        ),
      ),
    );
  }

  bool _matchesQuery(CountryOption country) {
    final query = _query.trim().toLowerCase();
    return query.isEmpty || country.name.toLowerCase().contains(query);
  }

  bool _isSelected(CountryOption country) {
    final selectedCode = widget.selectedCountryCode?.trim().toUpperCase();
    if (selectedCode != null && selectedCode.isNotEmpty) {
      return country.code == selectedCode;
    }

    final selectedName = widget.selectedCountryName?.trim().toLowerCase();
    return selectedName != null &&
        selectedName.isNotEmpty &&
        country.name.toLowerCase() == selectedName;
  }
}

class CityPickerScreen extends ConsumerStatefulWidget {
  const CityPickerScreen({super.key, required this.country, this.selectedCity});

  final CountryOption country;
  final String? selectedCity;

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final cities = ref.watch(citiesProvider(widget.country.code));
    final bottomPadding = quranPlayerAwareBottomPadding(
      context,
      playerVisible: QuranPlayerVisibility.of(context),
    );

    return LocationPickerScaffold(
      title: context.loc.selectCity,
      searchHint: context.loc.search,
      palette: palette,
      onQueryChanged: (value) => setState(() => _query = value),
      child: cities.when(
        data: (values) {
          final availableCities = _includeSelectedCity(values);
          final filtered = availableCities.where(_matchesQuery).toList();
          if (filtered.isEmpty) {
            return LocationPickerEmptyState(
              message: context.loc.noResultsFound,
              palette: palette,
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final city = filtered[index];
              return LocationPickerRow(
                title: city,
                selected:
                    city.toLowerCase() == widget.selectedCity?.toLowerCase(),
                palette: palette,
                onTap: () => Navigator.of(context).pop(city),
              );
            },
          );
        },
        loading: () => LocationPickerLoadingState(palette: palette),
        error: (error, stackTrace) => LocationPickerErrorState(
          palette: palette,
          message: context.loc.locationDataLoadError,
          retryLabel: context.loc.retry,
          onRetry: () => ref.invalidate(citiesProvider(widget.country.code)),
        ),
      ),
    );
  }

  List<String> _includeSelectedCity(List<String> cities) {
    final selectedCity = widget.selectedCity?.trim();
    if (selectedCity == null || selectedCity.isEmpty) return cities;
    final containsSelected = cities.any(
      (city) => city.toLowerCase() == selectedCity.toLowerCase(),
    );
    return containsSelected ? cities : [selectedCity, ...cities];
  }

  bool _matchesQuery(String city) {
    final query = _query.trim().toLowerCase();
    return query.isEmpty || city.toLowerCase().contains(query);
  }
}

class LocationPickerScaffold extends StatelessWidget {
  const LocationPickerScaffold({
    super.key,
    required this.title,
    required this.searchHint,
    required this.palette,
    required this.onQueryChanged,
    required this.child,
  });

  final String title;
  final String searchHint;
  final SettingsPalette palette;
  final ValueChanged<String> onQueryChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(title: title, palette: palette),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: SizedBox(
                height: 52,
                child: TextField(
                  onChanged: onQueryChanged,
                  cursorColor: palette.accent,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    color: palette.title,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: searchHint,
                    hintStyle: TextStyle(color: palette.subtitle),
                    suffixIcon: Icon(
                      Icons.search_rounded,
                      color: palette.subtitle,
                    ),
                    border: _searchBorder(palette.divider),
                    enabledBorder: _searchBorder(palette.divider),
                    focusedBorder: _searchBorder(palette.accent, width: 1.5),
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: 16,
                      end: 8,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _searchBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class LocationPickerRow extends StatelessWidget {
  const LocationPickerRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.palette,
    required this.onTap,
    this.fontFamily = 'GoogleSans',
    this.disableTextScaling = true,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final SettingsPalette palette;
  final VoidCallback onTap;
  final String fontFamily;
  final bool disableTextScaling;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: subtitle == null ? 56 : 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _LocationPickerTextScaling(
                      disableTextScaling: disableTextScaling,
                      child: subtitle == null
                          ? Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.title,
                                fontFamily: fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.title,
                                    fontFamily: fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.subtitle,
                                    fontFamily: 'GoogleSans',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: palette.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.check_mark,
                        size: 15,
                        color: palette.checkForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPickerTextScaling extends StatelessWidget {
  const _LocationPickerTextScaling({
    required this.disableTextScaling,
    required this.child,
  });

  final bool disableTextScaling;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      disableTextScaling ? MediaQuery.withNoTextScaling(child: child) : child;
}

class LocationPickerLoadingState extends StatelessWidget {
  const LocationPickerLoadingState({super.key, required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: palette.accent));
  }
}

class LocationPickerEmptyState extends StatelessWidget {
  const LocationPickerEmptyState({
    super.key,
    required this.message,
    required this.palette,
  });

  final String message;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: palette.subtitle, fontFamily: 'GoogleSans'),
      ),
    );
  }
}

class LocationPickerErrorState extends StatelessWidget {
  const LocationPickerErrorState({
    super.key,
    required this.palette,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final SettingsPalette palette;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, color: palette.subtitle, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.subtitle,
                fontFamily: 'GoogleSans',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.checkForeground,
              ),
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
