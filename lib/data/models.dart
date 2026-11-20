class Member {
  const Member({
    required this.id,
    required this.email,
    required this.name,
    required this.qrCode,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final String qrCode;
  final DateTime createdAt;

  Member copyWith({String? name}) {
    return Member(
      id: id,
      email: email,
      name: name ?? this.name,
      qrCode: qrCode,
      createdAt: createdAt,
    );
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      email: (json['email'] ?? json['phone']) as String,
      name: (json['name'] as String?) ?? '',
      qrCode: (json['qr_code'] ?? json['qrCode']) as String,
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt']) as String,
      ).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'qr_code': qrCode,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}

class Visit {
  const Visit({
    required this.id,
    required this.kind,
    required this.children,
    required this.freeChildren,
    required this.amount,
    required this.createdAt,
    required this.voided,
  });

  final String id;
  final String kind;
  final int children;
  final int freeChildren;
  final int amount;
  final DateTime createdAt;
  final bool voided;

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as String,
      kind: json['kind'] as String,
      children: (json['children'] as num).toInt(),
      freeChildren: ((json['free_children'] ?? json['freeChildren'] ?? 0) as num)
          .toInt(),
      amount: (json['amount'] as num).toInt(),
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt']) as String,
      ).toLocal(),
      voided: json['voided'] == true || json['voided_at'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind,
      'children': children,
      'free_children': freeChildren,
      'amount': amount,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voided': voided,
    };
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.slotId,
    required this.startsAt,
    required this.endsAt,
    required this.children,
    this.adults = 0,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String slotId;
  final DateTime startsAt;
  final DateTime endsAt;
  final int children;
  final int adults;
  final String status;
  final DateTime createdAt;

  int get people => children + adults;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      slotId: (json['slot_id'] ?? json['slotId']) as String,
      startsAt: DateTime.parse(
        (json['starts_at'] ?? json['startsAt']) as String,
      ).toLocal(),
      endsAt: DateTime.parse(
        (json['ends_at'] ?? json['endsAt']) as String,
      ).toLocal(),
      children: (json['children'] as num).toInt(),
      adults: ((json['adults'] ?? 0) as num).toInt(),
      status: json['status'] as String,
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt']) as String,
      ).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slot_id': slotId,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': endsAt.toUtc().toIso8601String(),
      'children': children,
      'adults': adults,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  Booking copyWith({String? status}) {
    return Booking(
      id: id,
      slotId: slotId,
      startsAt: startsAt,
      endsAt: endsAt,
      children: children,
      adults: adults,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

class TimeSlot {
  const TimeSlot({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.bookedChildren,
  });

  final String id;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final int bookedChildren;

  int get remaining {
    final left = capacity - bookedChildren;
    return left < 0 ? 0 : left;
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
      endsAt: DateTime.parse(json['ends_at'] as String).toLocal(),
      capacity: (json['capacity'] as num).toInt(),
      bookedChildren: (json['booked_children'] as num).toInt(),
    );
  }
}

class Promotion {
  const Promotion({
    required this.id,
    required this.title,
    required this.body,
    required this.discountLabel,
    required this.endsAt,
    this.imageAsset,
    this.imageUrl,
    this.likeCount = 0,
    this.liked = false,
    this.likesKnown = false,
  });

  final String id;
  final String title;
  final String body;
  final String discountLabel;
  final DateTime? endsAt;
  final String? imageAsset;
  final String? imageUrl;
  final int likeCount;
  final bool liked;
  final bool likesKnown;

  Promotion copyWith({int? likeCount, bool? liked, bool? likesKnown}) {
    return Promotion(
      id: id,
      title: title,
      body: body,
      discountLabel: discountLabel,
      endsAt: endsAt,
      imageAsset: imageAsset,
      imageUrl: imageUrl,
      likeCount: likeCount ?? this.likeCount,
      liked: liked ?? this.liked,
      likesKnown: likesKnown ?? this.likesKnown,
    );
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    final ends = json['ends_at'] ?? json['endsAt'];
    final image = json['image_url'] ?? json['imageUrl'];
    return Promotion(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      discountLabel: (json['discount_label'] ?? json['discountLabel'] ?? '') as String,
      endsAt: ends == null ? null : DateTime.parse(ends as String).toLocal(),
      imageUrl: image == null || '$image'.isEmpty ? null : '$image',
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      liked: json['liked'] == true,
      likesKnown: json['likes_known'] == true || json.containsKey('like_count'),
    );
  }
}

class LikeUpdate {
  const LikeUpdate({required this.likeCount, required this.liked});

  final int likeCount;
  final bool liked;
}

class VenueSettings {
  const VenueSettings({
    required this.pricePerChild,
    required this.cancelHours,
    required this.capacity,
    required this.openHour,
    required this.closeHour,
    required this.slotMinutes,
  });

  final int pricePerChild;
  final int cancelHours;
  final int capacity;
  final int openHour;
  final int closeHour;
  final int slotMinutes;

  static const defaults = VenueSettings(
    pricePerChild: 25000,
    cancelHours: 2,
    capacity: 30,
    openHour: 9,
    closeHour: 18,
    slotMinutes: 60,
  );

  factory VenueSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return defaults;
    }
    return VenueSettings(
      pricePerChild: (json['price_per_child'] as num?)?.toInt() ?? defaults.pricePerChild,
      cancelHours: (json['cancel_hours'] as num?)?.toInt() ?? defaults.cancelHours,
      capacity: (json['capacity'] as num?)?.toInt() ?? defaults.capacity,
      openHour: (json['open_hour'] as num?)?.toInt() ?? defaults.openHour,
      closeHour: (json['close_hour'] as num?)?.toInt() ?? defaults.closeHour,
      slotMinutes: (json['slot_minutes'] as num?)?.toInt() ?? defaults.slotMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price_per_child': pricePerChild,
      'cancel_hours': cancelHours,
      'capacity': capacity,
      'open_hour': openHour,
      'close_hour': closeHour,
      'slot_minutes': slotMinutes,
    };
  }
}

class HomeData {
  const HomeData({
    required this.member,
    required this.stamp,
    required this.bookings,
    required this.promotions,
    required this.visits,
    required this.settings,
  });

  final Member member;
  final StampStatus stamp;
  final List<Booking> bookings;
  final List<Promotion> promotions;
  final List<Visit> visits;
  final VenueSettings settings;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      member: Member.fromJson(_map(json['member'])),
      stamp: StampStatus.fromJson(_map(json['stamp'])),
      bookings: _list(json['bookings']).map(Booking.fromJson).toList(),
      promotions: _list(json['promotions']).map(Promotion.fromJson).toList(),
      visits: _list(json['visits']).map(Visit.fromJson).toList(),
      settings: VenueSettings.fromJson(
        json['settings'] == null ? null : _map(json['settings']),
      ),
    );
  }
}

class StampStatus {
  const StampStatus({
    required this.filled,
    required this.rewardReady,
    required this.paidVisits,
    required this.freeUsed,
  });

  static const goal = 10;

  final int filled;
  final bool rewardReady;
  final int paidVisits;
  final int freeUsed;

  static const empty = StampStatus(
    filled: 0,
    rewardReady: false,
    paidVisits: 0,
    freeUsed: 0,
  );

  factory StampStatus.fromJson(Map<String, dynamic> json) {
    final filled = (json['filled'] as num?)?.toInt() ?? 0;
    return StampStatus(
      filled: filled,
      rewardReady: json['reward_ready'] as bool? ?? filled >= goal,
      paidVisits: (json['paid_visits'] as num?)?.toInt() ?? 0,
      freeUsed: (json['free_used'] as num?)?.toInt() ?? 0,
    );
  }

  static StampStatus fromVisits(List<Visit> visits) {
    final ordered = visits.where((visit) => !visit.voided).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    var balance = 0;
    var paid = 0;
    var freed = 0;
    for (final visit in ordered) {
      if (visit.kind == 'paid') {
        paid += 1;
        if (balance < goal) {
          balance += 1;
        }
      } else if (visit.kind == 'free') {
        balance = 0;
        freed += 1;
      }
    }
    return StampStatus(
      filled: balance,
      rewardReady: balance >= goal,
      paidVisits: paid,
      freeUsed: freed,
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return {};
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.map(_map).toList();
}
