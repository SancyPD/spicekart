# Dart JSON Parsing & Null Safety Troubleshooting Guide

## Overview
This document summarizes the recent model parsing issues encountered in the SpiceKart application and the standardized fixes implemented across all model classes. The issues primarily involved runtime exceptions caused by missing null checks and implicit type mismatches during JSON deserialization.

---

## 1. Null-Safety for Primitive Types (`String` and `int`)

### The Problem
When the backend API omits a field or explicitly sends `null`, Dart's `json["key"]` evaluates to `null`. Attempting to assign `null` to a non-nullable property (e.g., `String` or `int`) throws a runtime exception. This breaks the deserialization process and causes data fetches to fail silently, resulting in blank screens or empty lists.

### The Solution
We systematically updated the `fromJson` factory methods across all model classes (`lib/model/*.dart`) to include null-coalescing operators (`??`) with default fallback values.

**Implementation Standard:**
- **Strings**: Added `?? ""` to ensure the property falls back to an empty string.
- **Integers**: Added `?? 0` to ensure the property falls back to zero.
- **Booleans**: Added `?? false` for properties like `isFavourite` or `isActive`.

**Example (Before):**
```dart
factory Datum.fromJson(Map<String, dynamic> json) => Datum(
  id: json["id"], // Throws error if "id" is null
  productName: json["product_name"], // Throws error if "product_name" is null
);
```

**Example (After):**
```dart
factory Datum.fromJson(Map<String, dynamic> json) => Datum(
  id: json["id"] ?? 0, 
  productName: json["product_name"] ?? "", 
);
```

---

## 2. Type Mismatch: `type 'double' is not a subtype of type 'int'`

### The Problem
In financial and cart models like `TotalAmountSummary` (found in `checkout_preview_response.dart` and `checkout_preview_food_response.dart`), some fields were declared as `int` (e.g., `tipAmount`, `discount`). However, the API occasionally returns these values with decimal points (e.g., `10.0` or `10.5`). 

Because Dart natively treats numbers with decimals as `double` types, attempting to assign `10.5` directly to an `int` property throws a `type 'double' is not a subtype of type 'int'` exception. 

### The Solution
In Dart, both `int` and `double` inherit from the `num` class. To safely handle cases where an API might send either an integer (`10`) or a floating-point number (`10.5`) for an `int` property, we parse the value and explicitly invoke `.toInt()`. Conversely, for `double` properties, we invoke `.toDouble()`. 

To do this safely alongside null checking, we first provide a numeric default (like `0`), and then apply the type conversion function.

**Example (Before):**
```dart
factory TotalAmountSummary.fromJson(Map<String, dynamic> json) => TotalAmountSummary(
  tipAmount: json["tip_amount"] ?? 0, // CRASHES if API returns 10.5
  tax: json["tax"].toDouble(), // CRASHES (NoSuchMethodError) if "tax" is null
);
```

**Example (After):**
```dart
factory TotalAmountSummary.fromJson(Map<String, dynamic> json) => TotalAmountSummary(
  tipAmount: (json["tip_amount"] ?? 0).toInt(), 
  tax: (json["tax"] ?? 0).toDouble(), 
);
```

**Why this logic is foolproof:**
1. If the JSON value is `10.5` (double), `(10.5 ?? 0)` evaluates to `10.5`. Calling `.toInt()` safely truncates it to `10`.
2. If the JSON value is `10` (int), `(10 ?? 0)` evaluates to `10`. Calling `.toInt()` yields `10`.
3. If the JSON value is `null`, `(null ?? 0)` evaluates to `0`. Calling `.toInt()` safely yields `0`.

---

## Summary of Affected Files
A script was used to ensure widespread coverage of these fixes across 28 models, catching edge cases in files including but not limited to:
- `cart_list_response.dart`
- `checkout_preview_response.dart`
- `checkout_preview_food_response.dart`
- `wishlist_response.dart`
- `weekly_deals.dart`
- `products_list_response.dart`

All models are now resilient to missing fields and numeric type ambiguity.
