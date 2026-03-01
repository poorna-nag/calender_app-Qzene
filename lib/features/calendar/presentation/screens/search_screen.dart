import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_state.dart';
import '../../data/models/event_model.dart';
import 'event_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        List<EventModel> allEvents = [];
        if (state is CalendarLoaded) {
          allEvents = state.events.values.expand((element) => element).toList();
        }

        final results = _query.isEmpty
            ? <EventModel>[]
            : allEvents
                  .where(
                    (e) =>
                        e.title.toLowerCase().contains(_query.toLowerCase()) ||
                        (e.location?.toLowerCase().contains(
                              _query.toLowerCase(),
                            ) ??
                            false) ||
                        (e.notes?.toLowerCase().contains(
                              _query.toLowerCase(),
                            ) ??
                            false),
                  )
                  .toList();

        results.sort((a, b) => a.startTime.compareTo(b.startTime));

        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search events...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: theme.textTheme.titleLarge,
              onChanged: (val) {
                setState(() => _query = val);
              },
            ),
            actions: [
              if (_query.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
            ],
          ),
          body: _query.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 80,
                        color: theme.disabledColor.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search for events, locations, or notes',
                        style: TextStyle(color: theme.disabledColor),
                      ),
                    ],
                  ),
                )
              : results.isEmpty
              ? Center(
                  child: Text(
                    'No results found for "$_query"',
                    style: TextStyle(color: theme.disabledColor),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final event = results[index];
                    return ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      ),
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: (event.customColor ?? event.color.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${DateFormat('MMM d, yyyy').format(event.startTime)} • ${DateFormat('h:mm a').format(event.startTime)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: event.location != null
                          ? const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            )
                          : null,
                    );
                  },
                ),
        );
      },
    );
  }
}
