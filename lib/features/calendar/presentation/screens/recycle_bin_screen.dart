import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/recycle_bin_bloc.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';

class RecycleBinScreen extends StatelessWidget {
  const RecycleBinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final fs = settingsState.settings.fontSize;
        return BlocBuilder<RecycleBinBloc, RecycleBinState>(
          builder: (context, state) {
            final deletedEvents = state.deletedEvents;

            return Scaffold(
              appBar: AppBar(
                title: Text('Recycle Bin', style: TextStyle(fontSize: 18 * fs)),
                actions: [
                  if (deletedEvents.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () => _confirmEmptyBin(context, fs),
                    ),
                ],
              ),
              body: deletedEvents.isEmpty
                  ? Center(
                      child: Text(
                        'Recycle bin is empty',
                        style: TextStyle(fontSize: 16 * fs),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: deletedEvents.length,
                      itemBuilder: (context, index) {
                        final event = deletedEvents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: event.color.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.event,
                                color: event.color.color,
                              ),
                            ),
                            title: Text(
                              event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16 * fs,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Deleted: ${DateFormat.yMMMd().add_jm().format(event.deletedAt ?? DateTime.now())}',
                                  style: TextStyle(
                                    fontSize: 12 * fs,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.restore,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    context.read<CalendarBloc>().add(
                                      RestoreEvent(
                                        event.copyWith(
                                          isDeleted: false,
                                          deletedAt: null,
                                        ),
                                      ),
                                    );
                                    context.read<RecycleBinBloc>().add(
                                      PermanentlyDeleteEvent(event.id),
                                    ); // Remove from bin after restore
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Event restored'),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => context
                                      .read<RecycleBinBloc>()
                                      .add(PermanentlyDeleteEvent(event.id)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  void _confirmEmptyBin(BuildContext context, double fs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Empty Bin?', style: TextStyle(fontSize: 18 * fs)),
        content: Text(
          'All events in the recycle bin will be permanently deleted.',
          style: TextStyle(fontSize: 14 * fs),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RecycleBinBloc>().add(EmptyBin());
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
