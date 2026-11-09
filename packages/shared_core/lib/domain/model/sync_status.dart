enum SyncStatus { pending, synced, failed }

/// Synced wins; otherwise a recorded error means failed, else still pending.
SyncStatus syncStatusOf({required bool synced, required bool syncError}) {
  if (synced) return SyncStatus.synced;
  return syncError ? SyncStatus.failed : SyncStatus.pending;
}
