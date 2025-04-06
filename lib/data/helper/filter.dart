import 'package:ebroker/utils/Extensions/lib/map.dart';

abstract class Filter {
  Map<String, dynamic> filter();
}

class PropertyTypeFilter extends Filter {
  PropertyTypeFilter(this.type);
  final String type;

  @override
  Map<String, dynamic> filter() {
    return {'property_type': type};
  }
}

class MinMaxBudget extends Filter {
  MinMaxBudget({
    required this.min,
    required this.max,
  });
  final String? min;
  final String? max;

  @override
  Map<String, dynamic> filter() {
    return {
      'min_price': min,
      'max_price': max,
    }..removeEmptyKeys();
  }
}

class facilitiesFilter extends Filter {
  facilitiesFilter(this.facilities);
  final List<int>? facilities;

  @override
  Map<String, dynamic> filter() {
    return facilities != null && facilities!.isNotEmpty
        ? {'parameter_id': facilities}
        : {};
  }
}

class CategoryFilter extends Filter {
  CategoryFilter(this.categoryId);
  final String? categoryId;
  @override
  Map<String, dynamic> filter() {
    return {'category_id': categoryId};
  }
}

enum PostedSinceDuration {
  anytime(''),
  lastWeek('0'),
  yesterday('1');

  const PostedSinceDuration(this.value);

  final String value;
}

class PostedSince extends Filter {
  PostedSince(this.since);
  final PostedSinceDuration since;

  @override
  Map<String, dynamic> filter() {
    return {'posted_since': since.value}..removeEmptyKeys();
  }
}

class LocationFilter extends Filter {
  LocationFilter({
    this.city,
    // this.state,
    // this.country,
  });
  // final PostedSinceDuration since;
  final String? city;
  // final String? state;
  // final String? country;

  @override
  Map<String, dynamic> filter() {
    return {
      'city': city,
      // 'state': state,
      // 'country': country,
    }..removeEmptyKeys();
  }
}

///This will be used to apply filter
class FilterApply {
  final List<Filter> _filters = [];

  void add(Filter filter) {
    _filters.add(filter);
  }

  ///This will add or update existing filter
  void addOrUpdate(Filter filter) {
    final existingFilterIndex = _filters
        .indexWhere((element) => element.runtimeType == filter.runtimeType);
    if (existingFilterIndex != -1) {
      _filters[existingFilterIndex] = filter;
    } else {
      _filters.add(filter);
    }
  }

  ///This will be used to compare filters
  T check<T>() {
    return _filters.whereType<T>().first;
  }

  ////It will return data in Map format of combined filters so we can send it in API
  Map getFilter() {
    return _filters.fold(
      {},
      (previousValue, element) => previousValue..addAll(element.filter()),
    );
  }
}
