// Replace WeatherDashboard with this:
class CropCareGuide extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Care Guide')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildQuickTips(),
            _buildFarmingCalendar(),
            _buildDiseaseLibrary(),
            _buildPersonalizedRecommendations(),
          ],
        ),
      ),
    );
  }
}
