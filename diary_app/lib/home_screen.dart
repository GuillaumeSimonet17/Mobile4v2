import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Demo',
      home: ProfilePage(
        title: FirebaseAuth.instance.currentUser!.displayName!,
        email: FirebaseAuth.instance.currentUser!.email!,
      ),
    );
  }
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  // @override
  // bool isAllDay(int index) {
  //   return _getMeetingData(index).isAllDay;
  // }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title, required this.email});

  final String title;
  final String email;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController moodController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  List<String> moods = ['Happy', 'Sad', 'Excited', 'Angry', 'Relaxed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void openEntryBox({
    String? docId,
    String? title,
    String? content,
    String? mood,
  }) {
    titleController.text = title ?? '';
    contentController.text = content ?? '';
    moodController.text = mood ?? 'Happy';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            scrollable: true,
            title: Text(
              docId == null ? "Create New Entry" : "Edit Entry",
              style: GoogleFonts.montserrat(),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  style: GoogleFonts.montserrat(),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  style: GoogleFonts.montserrat(),
                  maxLines: 5,
                ),
                DropdownButtonFormField<String>(
                  value: moodController.text,
                  hint: Text("Select a Mood"),
                  style: GoogleFonts.montserrat(),
                  items:
                      moods.map((String mood) {
                        return DropdownMenuItem<String>(
                          value: mood,
                          child: Text(mood, style: GoogleFonts.montserrat()),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      moodController.text = newValue ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Mood',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (docId == null) {
                    firestoreService.addEntry(
                      titleController.text,
                      contentController.text,
                      moodController.text,
                    );
                    // meetings.add(Meeting(
                    //     'Conference', startTime, endTime, const Color(0xFF0F8644), false));
                  } else {
                    firestoreService.updateEntry(
                      docId,
                      titleController.text,
                      contentController.text,
                      moodController.text,
                    );
                  }
                  titleController.clear();
                  contentController.clear();
                  moodController.clear();
                  Navigator.pop(context);
                },
                child: Text(
                  docId == null ? "Add" : "Update",
                  style: GoogleFonts.montserrat(),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTabEntries() {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getEntriesStream(widget.email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: GoogleFonts.montserrat(),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No entries found.',
                    style: GoogleFonts.montserrat(),
                  ),
                );
              }

              var lenOfEntries = snapshot.data!.docs.length;
              var entriesList = snapshot.data!.docs;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      height: 50,
                      child: Text(
                        'Number of entries: ${lenOfEntries.toString()}',
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'Your last 2 entries',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: entriesList.take(2).length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot document =
                                  entriesList.take(2).toList()[index];
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              String title = data['title'];
                              String content = data['content'];
                              String mood = data['mood'];
                              String docId = document.id;

                              return ListTile(
                                title: SizedBox(
                                  width: 250,
                                  child: Text(
                                    '$title - $mood',
                                    softWrap: true,
                                    maxLines: 2,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                subtitle: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${DateFormat('dd/MM/yyyy').format(data['timestamp'].toDate())}",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed:
                                          () => openEntryBox(
                                            docId: docId,
                                            title: title,
                                            content: content,
                                            mood: mood,
                                          ),
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed:
                                          () => firestoreService.deleteEntry(
                                            docId,
                                          ),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  String formattedDate = DateFormat(
                                    'yyyy-MM-dd – kk:mm',
                                  ).format(data['timestamp'].toDate());

                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text(
                                            title,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                          content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${formattedDate}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                '$mood',
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                '$content',
                                                style: GoogleFonts.montserrat(),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Close',
                                                style: GoogleFonts.montserrat(),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('diary_entries')
                    .where(
                      'email',
                      isEqualTo: FirebaseAuth.instance.currentUser?.email,
                    )
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: GoogleFonts.montserrat(),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No entries found.',
                    style: GoogleFonts.montserrat(),
                  ),
                );
              }

              // Récupère les humeurs de tous les documents
              var moodsList =
                  snapshot.data!.docs
                      .map((document) => document['mood'] as String)
                      .toList();

              // Calcul des pourcentages pour chaque humeur
              Map<String, int> moodCount = {};
              for (var mood in moodsList) {
                moodCount[mood] = (moodCount[mood] ?? 0) + 1;
              }

              double totalCount = moodsList.length.toDouble();
              Map<String, double> moodPercentages = {};
              moodCount.forEach((mood, count) {
                moodPercentages[mood] = (count / totalCount) * 100;
              });

              Map<String, Color> moodColors = {
                'Happy': Colors.green,
                'Sad': Colors.blue.shade900,
                'Excited': Colors.orange,
                'Angry': Colors.red,
                'Relaxed': Colors.blue.shade300,
              };

              return Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: moodPercentages.length,
                              itemBuilder: (context, index) {
                                String mood = moodPercentages.keys.elementAt(
                                  index,
                                );
                                double percentage = moodPercentages[mood]!;
                                Color moodColor =
                                    moodColors[mood] ?? Colors.black;

                                return ListTile(
                                  title: Text(
                                    "$mood - ${percentage.toStringAsFixed(2)}%",
                                    style: GoogleFonts.montserrat(
                                      color: moodColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabAgenda() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('diary_entries')
              .where(
                'email',
                isEqualTo: FirebaseAuth.instance.currentUser?.email,
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No meetings found.'));
        }

        List<Meeting> meetings =
            snapshot.data!.docs.map((document) {
              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final String title = data['title'] ?? '';
              final Timestamp timestamp = data['timestamp'];
              final DateTime startTime = timestamp.toDate();
              final DateTime endTime = startTime.add(
                const Duration(minutes: 15),
              );

              return Meeting(
                title,
                startTime,
                endTime,
                const Color(0xFF0F8644),
              );
            }).toList();

        return Column(
          children: [
            SfCalendar(
              view: CalendarView.month,
              dataSource: MeetingDataSource(meetings),

              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "${FirebaseAuth.instance.currentUser?.displayName}",
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                FirebaseAuth.instance.signOut();
              }
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEntryBox(),
        tooltip: 'Add New Entry',
        child: Icon(Icons.add),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [_buildTabEntries(), _buildTabAgenda()],
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.note), text: 'Note'),
            Tab(icon: Icon(Icons.view_agenda), text: 'Agenda'),
          ],
        ),
      ),
    );
  }
}
