// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShiftsTableTable extends ShiftsTable
    with TableInfo<$ShiftsTableTable, ShiftsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashierIdMeta = const VerificationMeta(
    'cashierId',
  );
  @override
  late final GeneratedColumn<String> cashierId = GeneratedColumn<String>(
    'cashier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingFloatCentsMeta = const VerificationMeta(
    'openingFloatCents',
  );
  @override
  late final GeneratedColumn<int> openingFloatCents = GeneratedColumn<int>(
    'opening_float_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closingCountedCentsMeta =
      const VerificationMeta('closingCountedCents');
  @override
  late final GeneratedColumn<int> closingCountedCents = GeneratedColumn<int>(
    'closing_counted_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closingNoteMeta = const VerificationMeta(
    'closingNote',
  );
  @override
  late final GeneratedColumn<String> closingNote = GeneratedColumn<String>(
    'closing_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<bool> syncError = GeneratedColumn<bool>(
    'sync_error',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_error" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncErrorMessageMeta = const VerificationMeta(
    'syncErrorMessage',
  );
  @override
  late final GeneratedColumn<String> syncErrorMessage = GeneratedColumn<String>(
    'sync_error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cashierId,
    status,
    openingFloatCents,
    closingCountedCents,
    closingNote,
    idempotencyKey,
    openedAt,
    closedAt,
    synced,
    syncError,
    syncErrorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cashier_id')) {
      context.handle(
        _cashierIdMeta,
        cashierId.isAcceptableOrUnknown(data['cashier_id']!, _cashierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashierIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('opening_float_cents')) {
      context.handle(
        _openingFloatCentsMeta,
        openingFloatCents.isAcceptableOrUnknown(
          data['opening_float_cents']!,
          _openingFloatCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingFloatCentsMeta);
    }
    if (data.containsKey('closing_counted_cents')) {
      context.handle(
        _closingCountedCentsMeta,
        closingCountedCents.isAcceptableOrUnknown(
          data['closing_counted_cents']!,
          _closingCountedCentsMeta,
        ),
      );
    }
    if (data.containsKey('closing_note')) {
      context.handle(
        _closingNoteMeta,
        closingNote.isAcceptableOrUnknown(
          data['closing_note']!,
          _closingNoteMeta,
        ),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('sync_error_message')) {
      context.handle(
        _syncErrorMessageMeta,
        syncErrorMessage.isAcceptableOrUnknown(
          data['sync_error_message']!,
          _syncErrorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cashierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      openingFloatCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_float_cents'],
      )!,
      closingCountedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_counted_cents'],
      ),
      closingNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closing_note'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_error'],
      )!,
      syncErrorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error_message'],
      ),
    );
  }

  @override
  $ShiftsTableTable createAlias(String alias) {
    return $ShiftsTableTable(attachedDatabase, alias);
  }
}

class ShiftsTableData extends DataClass implements Insertable<ShiftsTableData> {
  final String id;
  final String cashierId;
  final String status;
  final int openingFloatCents;
  final int? closingCountedCents;
  final String? closingNote;
  final String idempotencyKey;
  final DateTime openedAt;
  final DateTime? closedAt;
  final bool synced;
  final bool syncError;
  final String? syncErrorMessage;
  const ShiftsTableData({
    required this.id,
    required this.cashierId,
    required this.status,
    required this.openingFloatCents,
    this.closingCountedCents,
    this.closingNote,
    required this.idempotencyKey,
    required this.openedAt,
    this.closedAt,
    required this.synced,
    required this.syncError,
    this.syncErrorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cashier_id'] = Variable<String>(cashierId);
    map['status'] = Variable<String>(status);
    map['opening_float_cents'] = Variable<int>(openingFloatCents);
    if (!nullToAbsent || closingCountedCents != null) {
      map['closing_counted_cents'] = Variable<int>(closingCountedCents);
    }
    if (!nullToAbsent || closingNote != null) {
      map['closing_note'] = Variable<String>(closingNote);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['synced'] = Variable<bool>(synced);
    map['sync_error'] = Variable<bool>(syncError);
    if (!nullToAbsent || syncErrorMessage != null) {
      map['sync_error_message'] = Variable<String>(syncErrorMessage);
    }
    return map;
  }

  ShiftsTableCompanion toCompanion(bool nullToAbsent) {
    return ShiftsTableCompanion(
      id: Value(id),
      cashierId: Value(cashierId),
      status: Value(status),
      openingFloatCents: Value(openingFloatCents),
      closingCountedCents: closingCountedCents == null && nullToAbsent
          ? const Value.absent()
          : Value(closingCountedCents),
      closingNote: closingNote == null && nullToAbsent
          ? const Value.absent()
          : Value(closingNote),
      idempotencyKey: Value(idempotencyKey),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      synced: Value(synced),
      syncError: Value(syncError),
      syncErrorMessage: syncErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(syncErrorMessage),
    );
  }

  factory ShiftsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftsTableData(
      id: serializer.fromJson<String>(json['id']),
      cashierId: serializer.fromJson<String>(json['cashierId']),
      status: serializer.fromJson<String>(json['status']),
      openingFloatCents: serializer.fromJson<int>(json['openingFloatCents']),
      closingCountedCents: serializer.fromJson<int?>(
        json['closingCountedCents'],
      ),
      closingNote: serializer.fromJson<String?>(json['closingNote']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncError: serializer.fromJson<bool>(json['syncError']),
      syncErrorMessage: serializer.fromJson<String?>(json['syncErrorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cashierId': serializer.toJson<String>(cashierId),
      'status': serializer.toJson<String>(status),
      'openingFloatCents': serializer.toJson<int>(openingFloatCents),
      'closingCountedCents': serializer.toJson<int?>(closingCountedCents),
      'closingNote': serializer.toJson<String?>(closingNote),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'synced': serializer.toJson<bool>(synced),
      'syncError': serializer.toJson<bool>(syncError),
      'syncErrorMessage': serializer.toJson<String?>(syncErrorMessage),
    };
  }

  ShiftsTableData copyWith({
    String? id,
    String? cashierId,
    String? status,
    int? openingFloatCents,
    Value<int?> closingCountedCents = const Value.absent(),
    Value<String?> closingNote = const Value.absent(),
    String? idempotencyKey,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    bool? synced,
    bool? syncError,
    Value<String?> syncErrorMessage = const Value.absent(),
  }) => ShiftsTableData(
    id: id ?? this.id,
    cashierId: cashierId ?? this.cashierId,
    status: status ?? this.status,
    openingFloatCents: openingFloatCents ?? this.openingFloatCents,
    closingCountedCents: closingCountedCents.present
        ? closingCountedCents.value
        : this.closingCountedCents,
    closingNote: closingNote.present ? closingNote.value : this.closingNote,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    synced: synced ?? this.synced,
    syncError: syncError ?? this.syncError,
    syncErrorMessage: syncErrorMessage.present
        ? syncErrorMessage.value
        : this.syncErrorMessage,
  );
  ShiftsTableData copyWithCompanion(ShiftsTableCompanion data) {
    return ShiftsTableData(
      id: data.id.present ? data.id.value : this.id,
      cashierId: data.cashierId.present ? data.cashierId.value : this.cashierId,
      status: data.status.present ? data.status.value : this.status,
      openingFloatCents: data.openingFloatCents.present
          ? data.openingFloatCents.value
          : this.openingFloatCents,
      closingCountedCents: data.closingCountedCents.present
          ? data.closingCountedCents.value
          : this.closingCountedCents,
      closingNote: data.closingNote.present
          ? data.closingNote.value
          : this.closingNote,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      syncErrorMessage: data.syncErrorMessage.present
          ? data.syncErrorMessage.value
          : this.syncErrorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsTableData(')
          ..write('id: $id, ')
          ..write('cashierId: $cashierId, ')
          ..write('status: $status, ')
          ..write('openingFloatCents: $openingFloatCents, ')
          ..write('closingCountedCents: $closingCountedCents, ')
          ..write('closingNote: $closingNote, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('synced: $synced, ')
          ..write('syncError: $syncError, ')
          ..write('syncErrorMessage: $syncErrorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cashierId,
    status,
    openingFloatCents,
    closingCountedCents,
    closingNote,
    idempotencyKey,
    openedAt,
    closedAt,
    synced,
    syncError,
    syncErrorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftsTableData &&
          other.id == this.id &&
          other.cashierId == this.cashierId &&
          other.status == this.status &&
          other.openingFloatCents == this.openingFloatCents &&
          other.closingCountedCents == this.closingCountedCents &&
          other.closingNote == this.closingNote &&
          other.idempotencyKey == this.idempotencyKey &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.synced == this.synced &&
          other.syncError == this.syncError &&
          other.syncErrorMessage == this.syncErrorMessage);
}

class ShiftsTableCompanion extends UpdateCompanion<ShiftsTableData> {
  final Value<String> id;
  final Value<String> cashierId;
  final Value<String> status;
  final Value<int> openingFloatCents;
  final Value<int?> closingCountedCents;
  final Value<String?> closingNote;
  final Value<String> idempotencyKey;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<bool> synced;
  final Value<bool> syncError;
  final Value<String?> syncErrorMessage;
  final Value<int> rowid;
  const ShiftsTableCompanion({
    this.id = const Value.absent(),
    this.cashierId = const Value.absent(),
    this.status = const Value.absent(),
    this.openingFloatCents = const Value.absent(),
    this.closingCountedCents = const Value.absent(),
    this.closingNote = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncErrorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsTableCompanion.insert({
    required String id,
    required String cashierId,
    required String status,
    required int openingFloatCents,
    this.closingCountedCents = const Value.absent(),
    this.closingNote = const Value.absent(),
    required String idempotencyKey,
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncErrorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cashierId = Value(cashierId),
       status = Value(status),
       openingFloatCents = Value(openingFloatCents),
       idempotencyKey = Value(idempotencyKey),
       openedAt = Value(openedAt);
  static Insertable<ShiftsTableData> custom({
    Expression<String>? id,
    Expression<String>? cashierId,
    Expression<String>? status,
    Expression<int>? openingFloatCents,
    Expression<int>? closingCountedCents,
    Expression<String>? closingNote,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<bool>? synced,
    Expression<bool>? syncError,
    Expression<String>? syncErrorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cashierId != null) 'cashier_id': cashierId,
      if (status != null) 'status': status,
      if (openingFloatCents != null) 'opening_float_cents': openingFloatCents,
      if (closingCountedCents != null)
        'closing_counted_cents': closingCountedCents,
      if (closingNote != null) 'closing_note': closingNote,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (synced != null) 'synced': synced,
      if (syncError != null) 'sync_error': syncError,
      if (syncErrorMessage != null) 'sync_error_message': syncErrorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? cashierId,
    Value<String>? status,
    Value<int>? openingFloatCents,
    Value<int?>? closingCountedCents,
    Value<String?>? closingNote,
    Value<String>? idempotencyKey,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<bool>? synced,
    Value<bool>? syncError,
    Value<String?>? syncErrorMessage,
    Value<int>? rowid,
  }) {
    return ShiftsTableCompanion(
      id: id ?? this.id,
      cashierId: cashierId ?? this.cashierId,
      status: status ?? this.status,
      openingFloatCents: openingFloatCents ?? this.openingFloatCents,
      closingCountedCents: closingCountedCents ?? this.closingCountedCents,
      closingNote: closingNote ?? this.closingNote,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      synced: synced ?? this.synced,
      syncError: syncError ?? this.syncError,
      syncErrorMessage: syncErrorMessage ?? this.syncErrorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cashierId.present) {
      map['cashier_id'] = Variable<String>(cashierId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (openingFloatCents.present) {
      map['opening_float_cents'] = Variable<int>(openingFloatCents.value);
    }
    if (closingCountedCents.present) {
      map['closing_counted_cents'] = Variable<int>(closingCountedCents.value);
    }
    if (closingNote.present) {
      map['closing_note'] = Variable<String>(closingNote.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<bool>(syncError.value);
    }
    if (syncErrorMessage.present) {
      map['sync_error_message'] = Variable<String>(syncErrorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsTableCompanion(')
          ..write('id: $id, ')
          ..write('cashierId: $cashierId, ')
          ..write('status: $status, ')
          ..write('openingFloatCents: $openingFloatCents, ')
          ..write('closingCountedCents: $closingCountedCents, ')
          ..write('closingNote: $closingNote, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('synced: $synced, ')
          ..write('syncError: $syncError, ')
          ..write('syncErrorMessage: $syncErrorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTableTable extends SalesTable
    with TableInfo<$SalesTableTable, SalesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenderedCentsMeta = const VerificationMeta(
    'tenderedCents',
  );
  @override
  late final GeneratedColumn<int> tenderedCents = GeneratedColumn<int>(
    'tendered_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<bool> syncError = GeneratedColumn<bool>(
    'sync_error',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_error" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncErrorMessageMeta = const VerificationMeta(
    'syncErrorMessage',
  );
  @override
  late final GeneratedColumn<String> syncErrorMessage = GeneratedColumn<String>(
    'sync_error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftId,
    paymentMethod,
    totalCents,
    tenderedCents,
    idempotencyKey,
    createdAt,
    synced,
    syncError,
    syncErrorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('tendered_cents')) {
      context.handle(
        _tenderedCentsMeta,
        tenderedCents.isAcceptableOrUnknown(
          data['tendered_cents']!,
          _tenderedCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tenderedCentsMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('sync_error_message')) {
      context.handle(
        _syncErrorMessageMeta,
        syncErrorMessage.isAcceptableOrUnknown(
          data['sync_error_message']!,
          _syncErrorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      tenderedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tendered_cents'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_error'],
      )!,
      syncErrorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error_message'],
      ),
    );
  }

  @override
  $SalesTableTable createAlias(String alias) {
    return $SalesTableTable(attachedDatabase, alias);
  }
}

class SalesTableData extends DataClass implements Insertable<SalesTableData> {
  final String id;
  final String shiftId;
  final String paymentMethod;
  final int totalCents;
  final int tenderedCents;
  final String idempotencyKey;
  final DateTime createdAt;
  final bool synced;
  final bool syncError;
  final String? syncErrorMessage;
  const SalesTableData({
    required this.id,
    required this.shiftId,
    required this.paymentMethod,
    required this.totalCents,
    required this.tenderedCents,
    required this.idempotencyKey,
    required this.createdAt,
    required this.synced,
    required this.syncError,
    this.syncErrorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_id'] = Variable<String>(shiftId);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['total_cents'] = Variable<int>(totalCents);
    map['tendered_cents'] = Variable<int>(tenderedCents);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    map['sync_error'] = Variable<bool>(syncError);
    if (!nullToAbsent || syncErrorMessage != null) {
      map['sync_error_message'] = Variable<String>(syncErrorMessage);
    }
    return map;
  }

  SalesTableCompanion toCompanion(bool nullToAbsent) {
    return SalesTableCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      paymentMethod: Value(paymentMethod),
      totalCents: Value(totalCents),
      tenderedCents: Value(tenderedCents),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
      synced: Value(synced),
      syncError: Value(syncError),
      syncErrorMessage: syncErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(syncErrorMessage),
    );
  }

  factory SalesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalesTableData(
      id: serializer.fromJson<String>(json['id']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      tenderedCents: serializer.fromJson<int>(json['tenderedCents']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncError: serializer.fromJson<bool>(json['syncError']),
      syncErrorMessage: serializer.fromJson<String?>(json['syncErrorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftId': serializer.toJson<String>(shiftId),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'totalCents': serializer.toJson<int>(totalCents),
      'tenderedCents': serializer.toJson<int>(tenderedCents),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
      'syncError': serializer.toJson<bool>(syncError),
      'syncErrorMessage': serializer.toJson<String?>(syncErrorMessage),
    };
  }

  SalesTableData copyWith({
    String? id,
    String? shiftId,
    String? paymentMethod,
    int? totalCents,
    int? tenderedCents,
    String? idempotencyKey,
    DateTime? createdAt,
    bool? synced,
    bool? syncError,
    Value<String?> syncErrorMessage = const Value.absent(),
  }) => SalesTableData(
    id: id ?? this.id,
    shiftId: shiftId ?? this.shiftId,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    totalCents: totalCents ?? this.totalCents,
    tenderedCents: tenderedCents ?? this.tenderedCents,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
    syncError: syncError ?? this.syncError,
    syncErrorMessage: syncErrorMessage.present
        ? syncErrorMessage.value
        : this.syncErrorMessage,
  );
  SalesTableData copyWithCompanion(SalesTableCompanion data) {
    return SalesTableData(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      tenderedCents: data.tenderedCents.present
          ? data.tenderedCents.value
          : this.tenderedCents,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      syncErrorMessage: data.syncErrorMessage.present
          ? data.syncErrorMessage.value
          : this.syncErrorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalesTableData(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('totalCents: $totalCents, ')
          ..write('tenderedCents: $tenderedCents, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('syncError: $syncError, ')
          ..write('syncErrorMessage: $syncErrorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shiftId,
    paymentMethod,
    totalCents,
    tenderedCents,
    idempotencyKey,
    createdAt,
    synced,
    syncError,
    syncErrorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalesTableData &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.paymentMethod == this.paymentMethod &&
          other.totalCents == this.totalCents &&
          other.tenderedCents == this.tenderedCents &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced &&
          other.syncError == this.syncError &&
          other.syncErrorMessage == this.syncErrorMessage);
}

class SalesTableCompanion extends UpdateCompanion<SalesTableData> {
  final Value<String> id;
  final Value<String> shiftId;
  final Value<String> paymentMethod;
  final Value<int> totalCents;
  final Value<int> tenderedCents;
  final Value<String> idempotencyKey;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<bool> syncError;
  final Value<String?> syncErrorMessage;
  final Value<int> rowid;
  const SalesTableCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.tenderedCents = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncErrorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesTableCompanion.insert({
    required String id,
    required String shiftId,
    required String paymentMethod,
    required int totalCents,
    required int tenderedCents,
    required String idempotencyKey,
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncErrorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shiftId = Value(shiftId),
       paymentMethod = Value(paymentMethod),
       totalCents = Value(totalCents),
       tenderedCents = Value(tenderedCents),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt);
  static Insertable<SalesTableData> custom({
    Expression<String>? id,
    Expression<String>? shiftId,
    Expression<String>? paymentMethod,
    Expression<int>? totalCents,
    Expression<int>? tenderedCents,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<bool>? syncError,
    Expression<String>? syncErrorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (totalCents != null) 'total_cents': totalCents,
      if (tenderedCents != null) 'tendered_cents': tenderedCents,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (syncError != null) 'sync_error': syncError,
      if (syncErrorMessage != null) 'sync_error_message': syncErrorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? shiftId,
    Value<String>? paymentMethod,
    Value<int>? totalCents,
    Value<int>? tenderedCents,
    Value<String>? idempotencyKey,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<bool>? syncError,
    Value<String?>? syncErrorMessage,
    Value<int>? rowid,
  }) {
    return SalesTableCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalCents: totalCents ?? this.totalCents,
      tenderedCents: tenderedCents ?? this.tenderedCents,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      syncError: syncError ?? this.syncError,
      syncErrorMessage: syncErrorMessage ?? this.syncErrorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (tenderedCents.present) {
      map['tendered_cents'] = Variable<int>(tenderedCents.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<bool>(syncError.value);
    }
    if (syncErrorMessage.present) {
      map['sync_error_message'] = Variable<String>(syncErrorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesTableCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('totalCents: $totalCents, ')
          ..write('tenderedCents: $tenderedCents, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('syncError: $syncError, ')
          ..write('syncErrorMessage: $syncErrorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleLinesTableTable extends SaleLinesTable
    with TableInfo<$SaleLinesTableTable, SaleLinesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleLinesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    variantId,
    quantity,
    unitPriceCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleLinesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleLinesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleLinesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
    );
  }

  @override
  $SaleLinesTableTable createAlias(String alias) {
    return $SaleLinesTableTable(attachedDatabase, alias);
  }
}

class SaleLinesTableData extends DataClass
    implements Insertable<SaleLinesTableData> {
  final String id;
  final String saleId;
  final String variantId;
  final int quantity;
  final int unitPriceCents;
  const SaleLinesTableData({
    required this.id,
    required this.saleId,
    required this.variantId,
    required this.quantity,
    required this.unitPriceCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['variant_id'] = Variable<String>(variantId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    return map;
  }

  SaleLinesTableCompanion toCompanion(bool nullToAbsent) {
    return SaleLinesTableCompanion(
      id: Value(id),
      saleId: Value(saleId),
      variantId: Value(variantId),
      quantity: Value(quantity),
      unitPriceCents: Value(unitPriceCents),
    );
  }

  factory SaleLinesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleLinesTableData(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      variantId: serializer.fromJson<String>(json['variantId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'variantId': serializer.toJson<String>(variantId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
    };
  }

  SaleLinesTableData copyWith({
    String? id,
    String? saleId,
    String? variantId,
    int? quantity,
    int? unitPriceCents,
  }) => SaleLinesTableData(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    variantId: variantId ?? this.variantId,
    quantity: quantity ?? this.quantity,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
  );
  SaleLinesTableData copyWithCompanion(SaleLinesTableCompanion data) {
    return SaleLinesTableData(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleLinesTableData(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('variantId: $variantId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, saleId, variantId, quantity, unitPriceCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleLinesTableData &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.variantId == this.variantId &&
          other.quantity == this.quantity &&
          other.unitPriceCents == this.unitPriceCents);
}

class SaleLinesTableCompanion extends UpdateCompanion<SaleLinesTableData> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> variantId;
  final Value<int> quantity;
  final Value<int> unitPriceCents;
  final Value<int> rowid;
  const SaleLinesTableCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleLinesTableCompanion.insert({
    required String id,
    required String saleId,
    required String variantId,
    required int quantity,
    required int unitPriceCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       variantId = Value(variantId),
       quantity = Value(quantity),
       unitPriceCents = Value(unitPriceCents);
  static Insertable<SaleLinesTableData> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? variantId,
    Expression<int>? quantity,
    Expression<int>? unitPriceCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (variantId != null) 'variant_id': variantId,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleLinesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? variantId,
    Value<int>? quantity,
    Value<int>? unitPriceCents,
    Value<int>? rowid,
  }) {
    return SaleLinesTableCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleLinesTableCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('variantId: $variantId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogueTableTable extends CatalogueTable
    with TableInfo<$CatalogueTableTable, CatalogueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
    'colour',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceCentsMeta = const VerificationMeta(
    'priceCents',
  );
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
    'price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockOnHandMeta = const VerificationMeta(
    'stockOnHand',
  );
  @override
  late final GeneratedColumn<int> stockOnHand = GeneratedColumn<int>(
    'stock_on_hand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    variantId,
    productId,
    productName,
    categoryId,
    categoryName,
    sku,
    size,
    colour,
    description,
    priceCents,
    stockOnHand,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalogue';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('colour')) {
      context.handle(
        _colourMeta,
        colour.isAcceptableOrUnknown(data['colour']!, _colourMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price_cents')) {
      context.handle(
        _priceCentsMeta,
        priceCents.isAcceptableOrUnknown(data['price_cents']!, _priceCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_priceCentsMeta);
    }
    if (data.containsKey('stock_on_hand')) {
      context.handle(
        _stockOnHandMeta,
        stockOnHand.isAcceptableOrUnknown(
          data['stock_on_hand']!,
          _stockOnHandMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockOnHandMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {variantId};
  @override
  CatalogueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueTableData(
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      ),
      colour: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colour'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      priceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_cents'],
      )!,
      stockOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_on_hand'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CatalogueTableTable createAlias(String alias) {
    return $CatalogueTableTable(attachedDatabase, alias);
  }
}

class CatalogueTableData extends DataClass
    implements Insertable<CatalogueTableData> {
  final String variantId;
  final String productId;
  final String productName;
  final String? categoryId;
  final String? categoryName;
  final String? sku;
  final String? size;
  final String? colour;
  final String? description;
  final int priceCents;
  final int stockOnHand;
  final DateTime cachedAt;
  const CatalogueTableData({
    required this.variantId,
    required this.productId,
    required this.productName,
    this.categoryId,
    this.categoryName,
    this.sku,
    this.size,
    this.colour,
    this.description,
    required this.priceCents,
    required this.stockOnHand,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['variant_id'] = Variable<String>(variantId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price_cents'] = Variable<int>(priceCents);
    map['stock_on_hand'] = Variable<int>(stockOnHand);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CatalogueTableCompanion toCompanion(bool nullToAbsent) {
    return CatalogueTableCompanion(
      variantId: Value(variantId),
      productId: Value(productId),
      productName: Value(productName),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      colour: colour == null && nullToAbsent
          ? const Value.absent()
          : Value(colour),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      priceCents: Value(priceCents),
      stockOnHand: Value(stockOnHand),
      cachedAt: Value(cachedAt),
    );
  }

  factory CatalogueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueTableData(
      variantId: serializer.fromJson<String>(json['variantId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      sku: serializer.fromJson<String?>(json['sku']),
      size: serializer.fromJson<String?>(json['size']),
      colour: serializer.fromJson<String?>(json['colour']),
      description: serializer.fromJson<String?>(json['description']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
      stockOnHand: serializer.fromJson<int>(json['stockOnHand']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'variantId': serializer.toJson<String>(variantId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'categoryId': serializer.toJson<String?>(categoryId),
      'categoryName': serializer.toJson<String?>(categoryName),
      'sku': serializer.toJson<String?>(sku),
      'size': serializer.toJson<String?>(size),
      'colour': serializer.toJson<String?>(colour),
      'description': serializer.toJson<String?>(description),
      'priceCents': serializer.toJson<int>(priceCents),
      'stockOnHand': serializer.toJson<int>(stockOnHand),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CatalogueTableData copyWith({
    String? variantId,
    String? productId,
    String? productName,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> categoryName = const Value.absent(),
    Value<String?> sku = const Value.absent(),
    Value<String?> size = const Value.absent(),
    Value<String?> colour = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? priceCents,
    int? stockOnHand,
    DateTime? cachedAt,
  }) => CatalogueTableData(
    variantId: variantId ?? this.variantId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
    sku: sku.present ? sku.value : this.sku,
    size: size.present ? size.value : this.size,
    colour: colour.present ? colour.value : this.colour,
    description: description.present ? description.value : this.description,
    priceCents: priceCents ?? this.priceCents,
    stockOnHand: stockOnHand ?? this.stockOnHand,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CatalogueTableData copyWithCompanion(CatalogueTableCompanion data) {
    return CatalogueTableData(
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      sku: data.sku.present ? data.sku.value : this.sku,
      size: data.size.present ? data.size.value : this.size,
      colour: data.colour.present ? data.colour.value : this.colour,
      description: data.description.present
          ? data.description.value
          : this.description,
      priceCents: data.priceCents.present
          ? data.priceCents.value
          : this.priceCents,
      stockOnHand: data.stockOnHand.present
          ? data.stockOnHand.value
          : this.stockOnHand,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueTableData(')
          ..write('variantId: $variantId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('sku: $sku, ')
          ..write('size: $size, ')
          ..write('colour: $colour, ')
          ..write('description: $description, ')
          ..write('priceCents: $priceCents, ')
          ..write('stockOnHand: $stockOnHand, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    variantId,
    productId,
    productName,
    categoryId,
    categoryName,
    sku,
    size,
    colour,
    description,
    priceCents,
    stockOnHand,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueTableData &&
          other.variantId == this.variantId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.sku == this.sku &&
          other.size == this.size &&
          other.colour == this.colour &&
          other.description == this.description &&
          other.priceCents == this.priceCents &&
          other.stockOnHand == this.stockOnHand &&
          other.cachedAt == this.cachedAt);
}

class CatalogueTableCompanion extends UpdateCompanion<CatalogueTableData> {
  final Value<String> variantId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<String?> categoryId;
  final Value<String?> categoryName;
  final Value<String?> sku;
  final Value<String?> size;
  final Value<String?> colour;
  final Value<String?> description;
  final Value<int> priceCents;
  final Value<int> stockOnHand;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CatalogueTableCompanion({
    this.variantId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.sku = const Value.absent(),
    this.size = const Value.absent(),
    this.colour = const Value.absent(),
    this.description = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.stockOnHand = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogueTableCompanion.insert({
    required String variantId,
    required String productId,
    required String productName,
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.sku = const Value.absent(),
    this.size = const Value.absent(),
    this.colour = const Value.absent(),
    this.description = const Value.absent(),
    required int priceCents,
    required int stockOnHand,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : variantId = Value(variantId),
       productId = Value(productId),
       productName = Value(productName),
       priceCents = Value(priceCents),
       stockOnHand = Value(stockOnHand),
       cachedAt = Value(cachedAt);
  static Insertable<CatalogueTableData> custom({
    Expression<String>? variantId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? categoryId,
    Expression<String>? categoryName,
    Expression<String>? sku,
    Expression<String>? size,
    Expression<String>? colour,
    Expression<String>? description,
    Expression<int>? priceCents,
    Expression<int>? stockOnHand,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (variantId != null) 'variant_id': variantId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (sku != null) 'sku': sku,
      if (size != null) 'size': size,
      if (colour != null) 'colour': colour,
      if (description != null) 'description': description,
      if (priceCents != null) 'price_cents': priceCents,
      if (stockOnHand != null) 'stock_on_hand': stockOnHand,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogueTableCompanion copyWith({
    Value<String>? variantId,
    Value<String>? productId,
    Value<String>? productName,
    Value<String?>? categoryId,
    Value<String?>? categoryName,
    Value<String?>? sku,
    Value<String?>? size,
    Value<String?>? colour,
    Value<String?>? description,
    Value<int>? priceCents,
    Value<int>? stockOnHand,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CatalogueTableCompanion(
      variantId: variantId ?? this.variantId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      sku: sku ?? this.sku,
      size: size ?? this.size,
      colour: colour ?? this.colour,
      description: description ?? this.description,
      priceCents: priceCents ?? this.priceCents,
      stockOnHand: stockOnHand ?? this.stockOnHand,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (stockOnHand.present) {
      map['stock_on_hand'] = Variable<int>(stockOnHand.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueTableCompanion(')
          ..write('variantId: $variantId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('sku: $sku, ')
          ..write('size: $size, ')
          ..write('colour: $colour, ')
          ..write('description: $description, ')
          ..write('priceCents: $priceCents, ')
          ..write('stockOnHand: $stockOnHand, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockReceiptsTableTable extends StockReceiptsTable
    with TableInfo<$StockReceiptsTableTable, StockReceiptsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockReceiptsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<bool> syncError = GeneratedColumn<bool>(
    'sync_error',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_error" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncErrorMessageMeta = const VerificationMeta(
    'syncErrorMessage',
  );
  @override
  late final GeneratedColumn<String> syncErrorMessage = GeneratedColumn<String>(
    'sync_error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    variantId,
    quantity,
    note,
    reference,
    idempotencyKey,
    createdAt,
    synced,
    syncError,
    syncErrorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockReceiptsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('sync_error_message')) {
      context.handle(
        _syncErrorMessageMeta,
        syncErrorMessage.isAcceptableOrUnknown(
          data['sync_error_message']!,
          _syncErrorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockReceiptsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockReceiptsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_error'],
      )!,
      syncErrorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error_message'],
      ),
    );
  }

  @override
  $StockReceiptsTableTable createAlias(String alias) {
    return $StockReceiptsTableTable(attachedDatabase, alias);
  }
}

class StockReceiptsTableData extends DataClass
    implements Insertable<StockReceiptsTableData> {
  final String id;
  final String variantId;
  final int quantity;
  final String note;
  final String? reference;
  final String idempotencyKey;
  final DateTime createdAt;
  final bool synced;
  final bool syncError;
  final String? syncErrorMessage;
  const StockReceiptsTableData({
    required this.id,
    required this.variantId,
    required this.quantity,
    required this.note,
    this.reference,
    required this.idempotencyKey,
    required this.createdAt,
    required this.synced,
    required this.syncError,
    this.syncErrorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['variant_id'] = Variable<String>(variantId);
    map['quantity'] = Variable<int>(quantity);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    map['sync_error'] = Variable<bool>(syncError);
    if (!nullToAbsent || syncErrorMessage != null) {
      map['sync_error_message'] = Variable<String>(syncErrorMessage);
    }
    return map;
  }

  StockReceiptsTableCompanion toCompanion(bool nullToAbsent) {
    return StockReceiptsTableCompanion(
      id: Value(id),
      variantId: Value(variantId),
      quantity: Value(quantity),
      note: Value(note),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
      synced: Value(synced),
      syncError: Value(syncError),
      syncErrorMessage: syncErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(syncErrorMessage),
    );
  }

  factory StockReceiptsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockReceiptsTableData(
      id: serializer.fromJson<String>(json['id']),
      variantId: serializer.fromJson<String>(json['variantId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      note: serializer.fromJson<String>(json['note']),
      reference: serializer.fromJson<String?>(json['reference']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncError: serializer.fromJson<bool>(json['syncError']),
      syncErrorMessage: serializer.fromJson<String?>(json['syncErrorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'variantId': serializer.toJson<String>(variantId),
      'quantity': serializer.toJson<int>(quantity),
      'note': serializer.toJson<String>(note),
      'reference': serializer.toJson<String?>(reference),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
      'syncError': serializer.toJson<bool>(syncError),
      'syncErrorMessage': serializer.toJson<String?>(syncErrorMessage),
    };
  }

  StockReceiptsTableData copyWith({
    String? id,
    String? variantId,
    int? quantity,
    String? note,
    Value<String?> reference = const Value.absent(),
    String? idempotencyKey,
    DateTime? createdAt,
    bool? synced,
    bool? syncError,
    Value<String?> syncErrorMessage = const Value.absent(),
  }) => StockReceiptsTableData(
    id: id ?? this.id,
    variantId: variantId ?? this.variantId,
    quantity: quantity ?? this.quantity,
    note: note ?? this.note,
    reference: reference.present ? reference.value : this.reference,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
    syncError: syncError ?? this.syncError,
    syncErrorMessage: syncErrorMessage.present
        ? syncErrorMessage.value
        : this.syncErrorMessage,
  );
  StockReceiptsTableData copyWithCompanion(StockReceiptsTableCompanion data) {
    return StockReceiptsTableData(
      id: data.id.present ? data.id.value : this.id,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      note: data.note.present ? data.note.value : this.note,
      reference: data.reference.present ? data.reference.value : this.reference,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      syncErrorMessage: data.syncErrorMessage.present
          ? data.syncErrorMessage.value
          : this.syncErrorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockReceiptsTableData(')
          ..write('id: $id, ')
          ..write('variantId: $variantId, ')
          ..write('quantity: $quantity, ')
          ..write('note: $note, ')
          ..write('reference: $reference, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('syncError: $syncError, ')
          ..write('syncErrorMessage: $syncErrorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    variantId,
    quantity,
    note,
    reference,
    idempotencyKey,
    createdAt,
    synced,
    syncError,
    syncErrorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockReceiptsTableData &&
          other.id == this.id &&
          other.variantId == this.variantId &&
          other.quantity == this.quantity &&
          other.note == this.note &&
          other.reference == this.reference &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced &&
          other.syncError == this.syncError &&
          other.syncErrorMessage == this.syncErrorMessage);
}

class StockReceiptsTableCompanion
    extends UpdateCompanion<StockReceiptsTableData> {
  final Value<String> id;
  final Value<String> variantId;
  final Value<int> quantity;
  final Value<String> note;
  final Value<String?> reference;
  final Value<String> idempotencyKey;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<bool> syncError;
  final Value<String?> syncErrorMessage;
  final Value<int> rowid;
  const StockReceiptsTableCompanion({
    this.id = const Value.absent(),
    this.variantId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.note = const Value.absent(),
    this.reference = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncErrorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockReceiptsTableCompanion.insert({
    required String id,
    required String variantId,
    required int quantity,
    required String note,
    this.reference = const Value.absent(),
    required String idempotencyKey,
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncErrorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       variantId = Value(variantId),
       quantity = Value(quantity),
       note = Value(note),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt);
  static Insertable<StockReceiptsTableData> custom({
    Expression<String>? id,
    Expression<String>? variantId,
    Expression<int>? quantity,
    Expression<String>? note,
    Expression<String>? reference,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<bool>? syncError,
    Expression<String>? syncErrorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (variantId != null) 'variant_id': variantId,
      if (quantity != null) 'quantity': quantity,
      if (note != null) 'note': note,
      if (reference != null) 'reference': reference,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (syncError != null) 'sync_error': syncError,
      if (syncErrorMessage != null) 'sync_error_message': syncErrorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockReceiptsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? variantId,
    Value<int>? quantity,
    Value<String>? note,
    Value<String?>? reference,
    Value<String>? idempotencyKey,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<bool>? syncError,
    Value<String?>? syncErrorMessage,
    Value<int>? rowid,
  }) {
    return StockReceiptsTableCompanion(
      id: id ?? this.id,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      reference: reference ?? this.reference,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      syncError: syncError ?? this.syncError,
      syncErrorMessage: syncErrorMessage ?? this.syncErrorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<bool>(syncError.value);
    }
    if (syncErrorMessage.present) {
      map['sync_error_message'] = Variable<String>(syncErrorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockReceiptsTableCompanion(')
          ..write('id: $id, ')
          ..write('variantId: $variantId, ')
          ..write('quantity: $quantity, ')
          ..write('note: $note, ')
          ..write('reference: $reference, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('syncError: $syncError, ')
          ..write('syncErrorMessage: $syncErrorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShiftsTableTable shiftsTable = $ShiftsTableTable(this);
  late final $SalesTableTable salesTable = $SalesTableTable(this);
  late final $SaleLinesTableTable saleLinesTable = $SaleLinesTableTable(this);
  late final $CatalogueTableTable catalogueTable = $CatalogueTableTable(this);
  late final $StockReceiptsTableTable stockReceiptsTable =
      $StockReceiptsTableTable(this);
  late final ShiftsDao shiftsDao = ShiftsDao(this as AppDatabase);
  late final SalesDao salesDao = SalesDao(this as AppDatabase);
  late final CatalogueDao catalogueDao = CatalogueDao(this as AppDatabase);
  late final StockReceiptsDao stockReceiptsDao = StockReceiptsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shiftsTable,
    salesTable,
    saleLinesTable,
    catalogueTable,
    stockReceiptsTable,
  ];
}

typedef $$ShiftsTableTableCreateCompanionBuilder =
    ShiftsTableCompanion Function({
      required String id,
      required String cashierId,
      required String status,
      required int openingFloatCents,
      Value<int?> closingCountedCents,
      Value<String?> closingNote,
      required String idempotencyKey,
      required DateTime openedAt,
      Value<DateTime?> closedAt,
      Value<bool> synced,
      Value<bool> syncError,
      Value<String?> syncErrorMessage,
      Value<int> rowid,
    });
typedef $$ShiftsTableTableUpdateCompanionBuilder =
    ShiftsTableCompanion Function({
      Value<String> id,
      Value<String> cashierId,
      Value<String> status,
      Value<int> openingFloatCents,
      Value<int?> closingCountedCents,
      Value<String?> closingNote,
      Value<String> idempotencyKey,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<bool> synced,
      Value<bool> syncError,
      Value<String?> syncErrorMessage,
      Value<int> rowid,
    });

class $$ShiftsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingFloatCents => $composableBuilder(
    column: $table.openingFloatCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingCountedCents => $composableBuilder(
    column: $table.closingCountedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closingNote => $composableBuilder(
    column: $table.closingNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingFloatCents => $composableBuilder(
    column: $table.openingFloatCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingCountedCents => $composableBuilder(
    column: $table.closingCountedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closingNote => $composableBuilder(
    column: $table.closingNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cashierId =>
      $composableBuilder(column: $table.cashierId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get openingFloatCents => $composableBuilder(
    column: $table.openingFloatCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closingCountedCents => $composableBuilder(
    column: $table.closingCountedCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closingNote => $composableBuilder(
    column: $table.closingNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => column,
  );
}

class $$ShiftsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTableTable,
          ShiftsTableData,
          $$ShiftsTableTableFilterComposer,
          $$ShiftsTableTableOrderingComposer,
          $$ShiftsTableTableAnnotationComposer,
          $$ShiftsTableTableCreateCompanionBuilder,
          $$ShiftsTableTableUpdateCompanionBuilder,
          (
            ShiftsTableData,
            BaseReferences<_$AppDatabase, $ShiftsTableTable, ShiftsTableData>,
          ),
          ShiftsTableData,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableTableManager(_$AppDatabase db, $ShiftsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cashierId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> openingFloatCents = const Value.absent(),
                Value<int?> closingCountedCents = const Value.absent(),
                Value<String?> closingNote = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> syncError = const Value.absent(),
                Value<String?> syncErrorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsTableCompanion(
                id: id,
                cashierId: cashierId,
                status: status,
                openingFloatCents: openingFloatCents,
                closingCountedCents: closingCountedCents,
                closingNote: closingNote,
                idempotencyKey: idempotencyKey,
                openedAt: openedAt,
                closedAt: closedAt,
                synced: synced,
                syncError: syncError,
                syncErrorMessage: syncErrorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cashierId,
                required String status,
                required int openingFloatCents,
                Value<int?> closingCountedCents = const Value.absent(),
                Value<String?> closingNote = const Value.absent(),
                required String idempotencyKey,
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> syncError = const Value.absent(),
                Value<String?> syncErrorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsTableCompanion.insert(
                id: id,
                cashierId: cashierId,
                status: status,
                openingFloatCents: openingFloatCents,
                closingCountedCents: closingCountedCents,
                closingNote: closingNote,
                idempotencyKey: idempotencyKey,
                openedAt: openedAt,
                closedAt: closedAt,
                synced: synced,
                syncError: syncError,
                syncErrorMessage: syncErrorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShiftsTableTable, ShiftsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ShiftsTableTable,
                    ShiftsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTableTable,
      ShiftsTableData,
      $$ShiftsTableTableFilterComposer,
      $$ShiftsTableTableOrderingComposer,
      $$ShiftsTableTableAnnotationComposer,
      $$ShiftsTableTableCreateCompanionBuilder,
      $$ShiftsTableTableUpdateCompanionBuilder,
      (
        ShiftsTableData,
        BaseReferences<_$AppDatabase, $ShiftsTableTable, ShiftsTableData>,
      ),
      ShiftsTableData,
      PrefetchHooks Function()
    >;
typedef $$SalesTableTableCreateCompanionBuilder = SalesTableCompanion Function({
  required String id,
  required String shiftId,
  required String paymentMethod,
  required int totalCents,
  required int tenderedCents,
  required String idempotencyKey,
  required DateTime createdAt,
  Value<bool> synced,
  Value<bool> syncError,
  Value<String?> syncErrorMessage,
  Value<int> rowid,
});
typedef $$SalesTableTableUpdateCompanionBuilder = SalesTableCompanion Function({
  Value<String> id,
  Value<String> shiftId,
  Value<String> paymentMethod,
  Value<int> totalCents,
  Value<int> tenderedCents,
  Value<String> idempotencyKey,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<bool> syncError,
  Value<String?> syncErrorMessage,
  Value<int> rowid,
});

class $$SalesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tenderedCents => $composableBuilder(
    column: $table.tenderedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tenderedCents => $composableBuilder(
    column: $table.tenderedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tenderedCents => $composableBuilder(
    column: $table.tenderedCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => column,
  );
}

class $$SalesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTableTable,
          SalesTableData,
          $$SalesTableTableFilterComposer,
          $$SalesTableTableOrderingComposer,
          $$SalesTableTableAnnotationComposer,
          $$SalesTableTableCreateCompanionBuilder,
          $$SalesTableTableUpdateCompanionBuilder,
          (
            SalesTableData,
            BaseReferences<_$AppDatabase, $SalesTableTable, SalesTableData>,
          ),
          SalesTableData,
          PrefetchHooks Function()
        > {
  $$SalesTableTableTableManager(_$AppDatabase db, $SalesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> tenderedCents = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> syncError = const Value.absent(),
                Value<String?> syncErrorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesTableCompanion(
                id: id,
                shiftId: shiftId,
                paymentMethod: paymentMethod,
                totalCents: totalCents,
                tenderedCents: tenderedCents,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                synced: synced,
                syncError: syncError,
                syncErrorMessage: syncErrorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shiftId,
                required String paymentMethod,
                required int totalCents,
                required int tenderedCents,
                required String idempotencyKey,
                required DateTime createdAt,
                Value<bool> synced = const Value.absent(),
                Value<bool> syncError = const Value.absent(),
                Value<String?> syncErrorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesTableCompanion.insert(
                id: id,
                shiftId: shiftId,
                paymentMethod: paymentMethod,
                totalCents: totalCents,
                tenderedCents: tenderedCents,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                synced: synced,
                syncError: syncError,
                syncErrorMessage: syncErrorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesTableTable, SalesTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SalesTableTable,
                    SalesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTableTable,
      SalesTableData,
      $$SalesTableTableFilterComposer,
      $$SalesTableTableOrderingComposer,
      $$SalesTableTableAnnotationComposer,
      $$SalesTableTableCreateCompanionBuilder,
      $$SalesTableTableUpdateCompanionBuilder,
      (
        SalesTableData,
        BaseReferences<_$AppDatabase, $SalesTableTable, SalesTableData>,
      ),
      SalesTableData,
      PrefetchHooks Function()
    >;
typedef $$SaleLinesTableTableCreateCompanionBuilder =
    SaleLinesTableCompanion Function({
      required String id,
      required String saleId,
      required String variantId,
      required int quantity,
      required int unitPriceCents,
      Value<int> rowid,
    });
typedef $$SaleLinesTableTableUpdateCompanionBuilder =
    SaleLinesTableCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<String> variantId,
      Value<int> quantity,
      Value<int> unitPriceCents,
      Value<int> rowid,
    });

class $$SaleLinesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SaleLinesTableTable> {
  $$SaleLinesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleLinesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleLinesTableTable> {
  $$SaleLinesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleLinesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleLinesTableTable> {
  $$SaleLinesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );
}

class $$SaleLinesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleLinesTableTable,
          SaleLinesTableData,
          $$SaleLinesTableTableFilterComposer,
          $$SaleLinesTableTableOrderingComposer,
          $$SaleLinesTableTableAnnotationComposer,
          $$SaleLinesTableTableCreateCompanionBuilder,
          $$SaleLinesTableTableUpdateCompanionBuilder,
          (
            SaleLinesTableData,
            BaseReferences<
              _$AppDatabase,
              $SaleLinesTableTable,
              SaleLinesTableData
            >,
          ),
          SaleLinesTableData,
          PrefetchHooks Function()
        > {
  $$SaleLinesTableTableTableManager(
    _$AppDatabase db,
    $SaleLinesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleLinesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleLinesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleLinesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> variantId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesTableCompanion(
                id: id,
                saleId: saleId,
                variantId: variantId,
                quantity: quantity,
                unitPriceCents: unitPriceCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String variantId,
                required int quantity,
                required int unitPriceCents,
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesTableCompanion.insert(
                id: id,
                saleId: saleId,
                variantId: variantId,
                quantity: quantity,
                unitPriceCents: unitPriceCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleLinesTableTable, SaleLinesTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SaleLinesTableTable,
                    SaleLinesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleLinesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleLinesTableTable,
      SaleLinesTableData,
      $$SaleLinesTableTableFilterComposer,
      $$SaleLinesTableTableOrderingComposer,
      $$SaleLinesTableTableAnnotationComposer,
      $$SaleLinesTableTableCreateCompanionBuilder,
      $$SaleLinesTableTableUpdateCompanionBuilder,
      (
        SaleLinesTableData,
        BaseReferences<_$AppDatabase, $SaleLinesTableTable, SaleLinesTableData>,
      ),
      SaleLinesTableData,
      PrefetchHooks Function()
    >;
typedef $$CatalogueTableTableCreateCompanionBuilder =
    CatalogueTableCompanion Function({
      required String variantId,
      required String productId,
      required String productName,
      Value<String?> categoryId,
      Value<String?> categoryName,
      Value<String?> sku,
      Value<String?> size,
      Value<String?> colour,
      Value<String?> description,
      required int priceCents,
      required int stockOnHand,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CatalogueTableTableUpdateCompanionBuilder =
    CatalogueTableCompanion Function({
      Value<String> variantId,
      Value<String> productId,
      Value<String> productName,
      Value<String?> categoryId,
      Value<String?> categoryName,
      Value<String?> sku,
      Value<String?> size,
      Value<String?> colour,
      Value<String?> description,
      Value<int> priceCents,
      Value<int> stockOnHand,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CatalogueTableTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogueTableTable> {
  $$CatalogueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockOnHand => $composableBuilder(
    column: $table.stockOnHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogueTableTable> {
  $$CatalogueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockOnHand => $composableBuilder(
    column: $table.stockOnHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogueTableTable> {
  $$CatalogueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get colour =>
      $composableBuilder(column: $table.colour, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockOnHand => $composableBuilder(
    column: $table.stockOnHand,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CatalogueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogueTableTable,
          CatalogueTableData,
          $$CatalogueTableTableFilterComposer,
          $$CatalogueTableTableOrderingComposer,
          $$CatalogueTableTableAnnotationComposer,
          $$CatalogueTableTableCreateCompanionBuilder,
          $$CatalogueTableTableUpdateCompanionBuilder,
          (
            CatalogueTableData,
            BaseReferences<
              _$AppDatabase,
              $CatalogueTableTable,
              CatalogueTableData
            >,
          ),
          CatalogueTableData,
          PrefetchHooks Function()
        > {
  $$CatalogueTableTableTableManager(
    _$AppDatabase db,
    $CatalogueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> variantId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> priceCents = const Value.absent(),
                Value<int> stockOnHand = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogueTableCompanion(
                variantId: variantId,
                productId: productId,
                productName: productName,
                categoryId: categoryId,
                categoryName: categoryName,
                sku: sku,
                size: size,
                colour: colour,
                description: description,
                priceCents: priceCents,
                stockOnHand: stockOnHand,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String variantId,
                required String productId,
                required String productName,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required int priceCents,
                required int stockOnHand,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CatalogueTableCompanion.insert(
                variantId: variantId,
                productId: productId,
                productName: productName,
                categoryId: categoryId,
                categoryName: categoryName,
                sku: sku,
                size: size,
                colour: colour,
                description: description,
                priceCents: priceCents,
                stockOnHand: stockOnHand,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogueTableTable, CatalogueTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogueTableTable,
                    CatalogueTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogueTableTable,
      CatalogueTableData,
      $$CatalogueTableTableFilterComposer,
      $$CatalogueTableTableOrderingComposer,
      $$CatalogueTableTableAnnotationComposer,
      $$CatalogueTableTableCreateCompanionBuilder,
      $$CatalogueTableTableUpdateCompanionBuilder,
      (
        CatalogueTableData,
        BaseReferences<_$AppDatabase, $CatalogueTableTable, CatalogueTableData>,
      ),
      CatalogueTableData,
      PrefetchHooks Function()
    >;
typedef $$StockReceiptsTableTableCreateCompanionBuilder =
    StockReceiptsTableCompanion Function({
      required String id,
      required String variantId,
      required int quantity,
      required String note,
      Value<String?> reference,
      required String idempotencyKey,
      required DateTime createdAt,
      Value<bool> synced,
      Value<bool> syncError,
      Value<String?> syncErrorMessage,
      Value<int> rowid,
    });
typedef $$StockReceiptsTableTableUpdateCompanionBuilder =
    StockReceiptsTableCompanion Function({
      Value<String> id,
      Value<String> variantId,
      Value<int> quantity,
      Value<String> note,
      Value<String?> reference,
      Value<String> idempotencyKey,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<bool> syncError,
      Value<String?> syncErrorMessage,
      Value<int> rowid,
    });

class $$StockReceiptsTableTableFilterComposer
    extends Composer<_$AppDatabase, $StockReceiptsTableTable> {
  $$StockReceiptsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockReceiptsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StockReceiptsTableTable> {
  $$StockReceiptsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockReceiptsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockReceiptsTableTable> {
  $$StockReceiptsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get syncErrorMessage => $composableBuilder(
    column: $table.syncErrorMessage,
    builder: (column) => column,
  );
}

class $$StockReceiptsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockReceiptsTableTable,
          StockReceiptsTableData,
          $$StockReceiptsTableTableFilterComposer,
          $$StockReceiptsTableTableOrderingComposer,
          $$StockReceiptsTableTableAnnotationComposer,
          $$StockReceiptsTableTableCreateCompanionBuilder,
          $$StockReceiptsTableTableUpdateCompanionBuilder,
          (
            StockReceiptsTableData,
            BaseReferences<
              _$AppDatabase,
              $StockReceiptsTableTable,
              StockReceiptsTableData
            >,
          ),
          StockReceiptsTableData,
          PrefetchHooks Function()
        > {
  $$StockReceiptsTableTableTableManager(
    _$AppDatabase db,
    $StockReceiptsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockReceiptsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockReceiptsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockReceiptsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> variantId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> syncError = const Value.absent(),
                Value<String?> syncErrorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockReceiptsTableCompanion(
                id: id,
                variantId: variantId,
                quantity: quantity,
                note: note,
                reference: reference,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                synced: synced,
                syncError: syncError,
                syncErrorMessage: syncErrorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String variantId,
                required int quantity,
                required String note,
                Value<String?> reference = const Value.absent(),
                required String idempotencyKey,
                required DateTime createdAt,
                Value<bool> synced = const Value.absent(),
                Value<bool> syncError = const Value.absent(),
                Value<String?> syncErrorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockReceiptsTableCompanion.insert(
                id: id,
                variantId: variantId,
                quantity: quantity,
                note: note,
                reference: reference,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                synced: synced,
                syncError: syncError,
                syncErrorMessage: syncErrorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockReceiptsTableTable, StockReceiptsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $StockReceiptsTableTable,
                    StockReceiptsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockReceiptsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockReceiptsTableTable,
      StockReceiptsTableData,
      $$StockReceiptsTableTableFilterComposer,
      $$StockReceiptsTableTableOrderingComposer,
      $$StockReceiptsTableTableAnnotationComposer,
      $$StockReceiptsTableTableCreateCompanionBuilder,
      $$StockReceiptsTableTableUpdateCompanionBuilder,
      (
        StockReceiptsTableData,
        BaseReferences<
          _$AppDatabase,
          $StockReceiptsTableTable,
          StockReceiptsTableData
        >,
      ),
      StockReceiptsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShiftsTableTableTableManager get shiftsTable =>
      $$ShiftsTableTableTableManager(_db, _db.shiftsTable);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db, _db.salesTable);
  $$SaleLinesTableTableTableManager get saleLinesTable =>
      $$SaleLinesTableTableTableManager(_db, _db.saleLinesTable);
  $$CatalogueTableTableTableManager get catalogueTable =>
      $$CatalogueTableTableTableManager(_db, _db.catalogueTable);
  $$StockReceiptsTableTableTableManager get stockReceiptsTable =>
      $$StockReceiptsTableTableTableManager(_db, _db.stockReceiptsTable);
}
