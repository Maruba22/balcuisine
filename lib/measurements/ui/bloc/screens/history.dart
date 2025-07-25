import 'package:balcuisine/measurements/domain/repositories/measurement_repository.dart';
import 'package:balcuisine/measurements/ui/bloc/measurement_bloc.dart';
import 'package:balcuisine/measurements/ui/bloc/measurement_event.dart';
import 'package:balcuisine/measurements/ui/bloc/measurement_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../auth/ui/pages/login_page.dart';

class MeasurementHistoryScreen extends StatelessWidget {
  const MeasurementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Historique des Mesures",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paramètres non implémentés')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
                
                showAboutDialog(
                  context: context,
                  applicationName: 'Mesures Electroniques',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.account_balance_sharp),
                  children: [
                    const Text(
                        "Application d'historique de mesures électroniques."),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: BlocProvider(
        create: (context) =>
            MeasurementBloc(context.read<MeasurementRepository>())
              ..add(LoadMeasurements()),
        child: Builder(
          builder: (context) {
            return BlocBuilder<MeasurementBloc, MeasurementState>(
              builder: (context, state) {
                if (state is MeasurementLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MeasurementLoaded) {
                  final history = state.measurements;

                  if (history.isEmpty) {
                    return const Center(
                        child: Text("Aucune mesure disponible."));
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final measurement = history[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _buildHistoryCard(measurement),
                        );
                      },
                    ),
                  );
                } else if (state is MeasurementError) {
                  return Center(child: Text("Erreur: ${state.message}"));
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(dynamic measurement) {
    final bool smokeDetected = measurement.smokeDetection;
    final Color smokeColor = smokeDetected ? Colors.red : Colors.green;

    final DateTime dateTime = measurement.dateTime;
    final String dayName = DateFormat.EEEE('fr_FR').format(dateTime);
    final String dateFormatted = DateFormat('d MMMM yyyy', 'fr_FR').format(dateTime);
    final String timeFormatted = DateFormat.Hm('fr_FR').format(dateTime);


   // final timeFormatted =
       // "${measurement.dateTime.hour.toString().padLeft(2, '0')}:${measurement.dateTime.minute.toString().padLeft(2, '0')}";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date : $dayName |$dateFormatted  |$timeFormatted",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.thermostat, color: Colors.orange),
                const SizedBox(width: 10),
                Text(
                  "Température : ${measurement.temperature.toStringAsFixed(1)} °C",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  "Hudimité d'eau : ${measurement.humidity.toStringAsFixed(1)} %",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.scale, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  "Poids mesuré : ${measurement.weight.toStringAsFixed(1)} kg",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.smoke_free, color: smokeColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    smokeDetected
                        ? "Fumée détectée"
                        : "Aucune fumée détectée",
                    style: TextStyle(fontSize: 14, color: smokeColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
